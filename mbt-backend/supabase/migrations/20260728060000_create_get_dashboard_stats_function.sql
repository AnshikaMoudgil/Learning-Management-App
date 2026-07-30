-- ============================================================
-- Migration: Create get_dashboard_stats() RPC function
-- ============================================================
-- Consolidates 22+ individual count queries into a single
-- database function, eliminating N+1 round-trips and

create or replace function public.get_dashboard_stats()
returns json
language plpgsql
security definer
as $$
declare
  result json;
  v_month_start     timestamptz := date_trunc('month', now());
  v_thirty_days_ago timestamptz := now() - interval '30 days';
  v_seven_days_ago  timestamptz := now() - interval '7 days';
  v_three_days_fwd  timestamptz := now() + interval '3 days';
begin
  with
  counts as (
    select
      (select count(*) from public.courses)                                              as total_courses,
      (select count(*) from public.courses where is_published = true)                    as published_courses,
      (select count(*) from public.profiles where role = 'learner')                      as total_learners,
      (select count(*) from public.profiles where role in ('admin','superadmin','instructor')) as total_staff,
      (select count(*) from public.sessions)                                             as total_sessions,
      (select count(*) from public.coupons)                                              as total_coupons,
      (select count(*) from public.coupons where is_active = true)                       as active_coupons,
      (select count(*) from public.payments)                                             as total_payments,
      (select count(*) from public.device_change_requests)                                as total_device_requests,
      (select count(*) from public.courses          where created_at >= v_month_start)    as new_courses,
      (select count(*) from public.profiles         where role = 'learner'
                                                       and created_at >= v_month_start)   as new_learners,
      (select count(*) from public.sessions         where created_at >= v_month_start)    as new_sessions,
      (select count(*) from public.payments         where created_at >= v_month_start)    as new_payments,
      (select count(*) from public.device_change_requests where status = 'pending')       as pending_device_requests,
      (select count(*) from public.payments         where status = 'failed')             as failed_payments,
      (select count(*) from public.payments         where status = 'failed'
                                                       and created_at >= v_seven_days_ago) as failed_payments_this_week,
      (select count(*) from public.coupons          where expires_at >= now()
                                                       and expires_at <= v_three_days_fwd) as expiring_coupons
  ),
  top_courses as (
    select
      c.id,
      c.title,
      c.slug,
      c.price,
      c.average_rating,
      c.reviews_count,
      count(e.id) as enrollment_count
    from public.courses c
    left join public.enrollments e on e.course_id = c.id and e.status = 'active'
    group by c.id
    order by count(e.id) desc
    limit 8
  ),
  daily_payments as (
    select
      d::date as date,
      coalesce(p.cnt, 0)  as count,
      coalesce(p.amt, 0)  as amount
    from generate_series(v_thirty_days_ago::date, current_date, '1 day'::interval) d
    left join (
      select
        created_at::date as day,
        count(*)         as cnt,
        sum(amount_paid) as amt
      from public.payments
      where created_at >= v_thirty_days_ago
      group by created_at::date
    ) p on p.day = d::date
    order by d
  ),
  recent_payments as (
    select id, amount_paid, status, created_at, user_id
    from public.payments
    order by created_at desc
    limit 5
  ),
  recent_learners as (
    select id, full_name, email, created_at
    from public.profiles
    where role = 'learner'
    order by created_at desc
    limit 5
  ),
  recent_courses as (
    select id, title, slug, created_at, is_published
    from public.courses
    where is_published = true
    order by created_at desc
    limit 5
  ),
  expired_coupons as (
    select id, code, expires_at
    from public.coupons
    where expires_at is not null and expires_at < now()
  ),
  combined_activity as (
    select 'signup' as atype,
           (full_name || ' joined') as adesc,
           created_at as atime,
           id
    from recent_learners
    union all
    select 'payment' as atype,
           'Payment of ₹' || (amount_paid::numeric(10,2))::text as adesc,
           created_at as atime,
           id
    from recent_payments
    union all
    select 'course' as atype,
           '"' || title || '" published' as adesc,
           created_at as atime,
           id
    from recent_courses
  ),
  recent_activity as (
    select json_agg(
      json_build_object('type', atype, 'desc', adesc, 'time', atime, 'id', id)
      order by atime desc
    ) as items
    from combined_activity
    limit 7
  )
  select json_build_object(
    'totalCourses',          (select total_courses           from counts),
    'publishedCourses',      (select published_courses       from counts),
    'totalLearners',         (select total_learners          from counts),
    'totalStaff',            (select total_staff             from counts),
    'totalSessions',         (select total_sessions          from counts),
    'totalCoupons',          (select total_coupons           from counts),
    'activeCoupons',         (select active_coupons          from counts),
    'totalPayments',         (select total_payments          from counts),
    'totalDeviceRequests',   (select total_device_requests   from counts),
    'monthlyDeltas', json_build_object(
      'newCourses',          (select new_courses             from counts),
      'newLearners',         (select new_learners            from counts),
      'newSessions',         (select new_sessions            from counts),
      'newPayments',         (select new_payments            from counts)
    ),
    'dailyPayments', (select coalesce(json_agg(
      json_build_object('date', date::text, 'count', count, 'amount', amount)
      order by date
    ), '[]'::json) from daily_payments),
    'recentActivity', coalesce((select items from recent_activity), '[]'::json),
    'alerts', json_build_object(
      'pendingDeviceRequests', (select pending_device_requests from counts),
      'failedPayments',        (select failed_payments         from counts),
      'expiredCoupons',        (select count(*)                from expired_coupons)
    ),
    'needsAttention', json_build_object(
      'failedPaymentsThisWeek', (select failed_payments_this_week  from counts),
      'expiringCoupons',        (select expiring_coupons            from counts),
      'pendingDeviceRequests',  (select pending_device_requests    from counts)
    ),
    'topCourses', (select coalesce(json_agg(
      json_build_object(
        'id', t.id,
        'title', t.title,
        'slug', t.slug,
        'price', t.price,
        'rating', t.average_rating,
        'reviews', t.reviews_count,
        'enrollments', t.enrollment_count
      ) order by t.enrollment_count desc
    ), '[]'::json) from top_courses t)
  ) into result;

  return result;
end;
$$;
