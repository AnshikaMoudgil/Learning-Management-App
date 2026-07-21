import { NextResponse } from 'next/server';
import { getSupabaseAdmin } from '@/app/lib/supabaseClient';

const startOfMonth = () => {
  const d = new Date();
  return new Date(d.getFullYear(), d.getMonth(), 1).toISOString();
};

const startOfDay = (daysAgo: number) => {
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  d.setHours(0, 0, 0, 0);
  return d.toISOString();
};

const endOfDay = (daysAgo: number) => {
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  d.setHours(23, 59, 59, 999);
  return d.toISOString();
};

const daysFromNow = (days: number) => {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString();
};

export async function GET(request: Request) {
  try {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
    if (!serviceRoleKey || serviceRoleKey === 'placeholder-service-key') {
      return NextResponse.json({ error: 'Service role key not configured.' }, { status: 500 });
    }

    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'No authorization token.' }, { status: 401 });
    }

    const token = authHeader.replace('Bearer ', '');
    const adminClient = getSupabaseAdmin();

    const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid session.' }, { status: 401 });
    }

    const monthStart = startOfMonth();
    const thirtyDaysAgo = startOfDay(30);

    const [
      { count: totalCourses },
      { count: publishedCourses },
      { count: totalLearners },
      { count: totalStaff },
      { count: totalSessions },
      { count: totalCoupons },
      { count: activeCoupons },
      { count: totalPayments },
      { count: totalDeviceRequests },
      { count: newCoursesThisMonth },
      { count: newLearnersThisMonth },
      { count: newSessionsThisMonth },
      { count: newPaymentsThisMonth },
      { count: pendingDeviceRequests },
      { count: failedPayments },
      { data: recentPayments },
      { data: recentLearners },
      { data: recentCourses },
      { data: expiredCouponsData },
      { data: paymentsChartData },
      { count: failedPaymentsThisWeek },
      { count: expiringCoupons },
    ] = await Promise.all([
      adminClient.from('courses').select('*', { count: 'exact', head: true }),
      adminClient.from('courses').select('*', { count: 'exact', head: true }).eq('is_published', true),
      adminClient.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'learner'),
      adminClient.from('profiles').select('*', { count: 'exact', head: true }).in('role', ['admin', 'superadmin', 'instructor']),
      adminClient.from('sessions').select('*', { count: 'exact', head: true }),
      adminClient.from('coupons').select('*', { count: 'exact', head: true }),
      adminClient.from('coupons').select('*', { count: 'exact', head: true }).eq('is_active', true),
      adminClient.from('payments').select('*', { count: 'exact', head: true }),
      adminClient.from('device_change_requests').select('*', { count: 'exact', head: true }),
      adminClient.from('courses').select('*', { count: 'exact', head: true }).gte('created_at', monthStart),
      adminClient.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'learner').gte('created_at', monthStart),
      adminClient.from('sessions').select('*', { count: 'exact', head: true }).gte('created_at', monthStart),
      adminClient.from('payments').select('*', { count: 'exact', head: true }).gte('created_at', monthStart),
      adminClient.from('device_change_requests').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
      adminClient.from('payments').select('*', { count: 'exact', head: true }).eq('status', 'failed'),
      adminClient.from('payments').select('id, amount_paid, status, created_at, user_id').order('created_at', { ascending: false }).limit(5),
      adminClient.from('profiles').select('id, full_name, email, created_at').eq('role', 'learner').order('created_at', { ascending: false }).limit(5),
      adminClient.from('courses').select('id, title, slug, created_at, is_published').eq('is_published', true).order('created_at', { ascending: false }).limit(5),
      adminClient.from('coupons').select('id, code, expires_at').not('expires_at', 'is', null).lt('expires_at', new Date().toISOString()),
      adminClient.from('payments').select('created_at, amount_paid').gte('created_at', thirtyDaysAgo).order('created_at', { ascending: true }),
      adminClient.from('payments').select('*', { count: 'exact', head: true }).eq('status', 'failed').gte('created_at', startOfDay(7)),
      adminClient.from('coupons').select('*', { count: 'exact', head: true }).gte('expires_at', new Date().toISOString()).lte('expires_at', daysFromNow(3)),
    ]);

    const { data: allEnrollments } = await adminClient
      .from('enrollments')
      .select('course_id')
      .eq('status', 'active');
    const enrollmentCounts: Record<string, number> = {};
    for (const e of (allEnrollments || [])) {
      enrollmentCounts[e.course_id] = (enrollmentCounts[e.course_id] || 0) + 1;
    }
    const topCourseIds = Object.entries(enrollmentCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 8)
      .map(([id]) => id);
    const { data: topCourseRows } = topCourseIds.length > 0
      ? await adminClient.from('courses')
          .select('id, title, slug, price, average_rating, reviews_count')
          .in('id', topCourseIds)
      : { data: [] };
    const courseMap = new Map((topCourseRows || []).map((c: any) => [c.id, c]));
    const topCoursesData = topCourseIds
      .map(id => courseMap.get(id))
      .filter(Boolean);

    const dailyPayments: Record<string, { date: string; count: number; amount: number }> = {};
    for (let i = 30; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const key = d.toISOString().slice(0, 10);
      dailyPayments[key] = { date: key, count: 0, amount: 0 };
    }
    for (const p of (paymentsChartData || [])) {
      const key = new Date(p.created_at).toISOString().slice(0, 10);
      if (dailyPayments[key]) {
        dailyPayments[key].count += 1;
        dailyPayments[key].amount += (p.amount_paid || 0);
      }
    }

    const recentActivity = [
      ...(recentLearners || []).map((l: any) => ({ type: 'signup', desc: `${l.full_name || 'Someone'} joined`, time: l.created_at, id: l.id })),
      ...(recentPayments || []).map((p: any) => ({ type: 'payment', desc: `Payment of ₹${(p.amount_paid || 0).toFixed(2)}`, time: p.created_at, id: p.id })),
      ...(recentCourses || []).map((c: any) => ({ type: 'course', desc: `"${c.title}" published`, time: c.created_at, id: c.id })),
    ].sort((a: any, b: any) => new Date(b.time).getTime() - new Date(a.time).getTime()).slice(0, 7);

    const response = NextResponse.json({
      totalCourses: totalCourses || 0,
      publishedCourses: publishedCourses || 0,
      totalLearners: totalLearners || 0,
      totalStaff: totalStaff || 0,
      totalSessions: totalSessions || 0,
      totalCoupons: totalCoupons || 0,
      activeCoupons: activeCoupons || 0,
      totalPayments: totalPayments || 0,
      totalDeviceRequests: totalDeviceRequests || 0,
      monthlyDeltas: {
        newCourses: newCoursesThisMonth || 0,
        newLearners: newLearnersThisMonth || 0,
        newSessions: newSessionsThisMonth || 0,
        newPayments: newPaymentsThisMonth || 0,
      },
      dailyPayments: Object.values(dailyPayments),
      recentActivity,
      alerts: {
        pendingDeviceRequests: pendingDeviceRequests || 0,
        failedPayments: failedPayments || 0,
        expiredCoupons: (expiredCouponsData || []).length,
      },
      needsAttention: {
        failedPaymentsThisWeek: failedPaymentsThisWeek || 0,
        expiringCoupons: expiringCoupons || 0,
        pendingDeviceRequests: pendingDeviceRequests || 0,
      },
      topCourses: (topCoursesData || []).map((c: any) => ({
        id: c.id,
        title: c.title,
        slug: c.slug,
        price: c.price,
        rating: c.average_rating,
        reviews: c.reviews_count,
        enrollments: enrollmentCounts[c.id] || 0,
      })),
    });
    response.headers.set('Cache-Control', 's-maxage=60, stale-while-revalidate=300');
    return response;
  } catch (err: unknown) {
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Server error' }, { status: 500 });
  }
}
