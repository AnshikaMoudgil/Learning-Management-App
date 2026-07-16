-- ============================================================
-- Migration: Live Sessions — sessions, live_session_meetings,
--            session_attendance, session_recordings
-- ============================================================

-- ============================================================
-- 1. sessions table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.sessions (
    id            UUID         DEFAULT gen_random_uuid() PRIMARY KEY,
    course_id     UUID         NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    instructor_id UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title         TEXT         NOT NULL,
    description   TEXT,
    start_time    TIMESTAMPTZ  NOT NULL,
    duration      INTEGER      NOT NULL CHECK (duration > 0),
    status        TEXT         NOT NULL DEFAULT 'scheduled'
                               CHECK (status IN (
                                   'draft', 'scheduled', 'live', 'finished',
                                   'recording_processing', 'recording_ready', 'cancelled'
                               )),
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sessions_course_id     ON public.sessions(course_id);
CREATE INDEX IF NOT EXISTS idx_sessions_instructor_id ON public.sessions(instructor_id);
CREATE INDEX IF NOT EXISTS idx_sessions_status        ON public.sessions(status);
CREATE INDEX IF NOT EXISTS idx_sessions_start_time    ON public.sessions(start_time);

-- ============================================================
-- 2. live_session_meetings table
-- Stores provider-specific meeting data returned by Zoom API
-- ============================================================
CREATE TABLE IF NOT EXISTS public.live_session_meetings (
    id                 UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id         UUID        NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
    provider           TEXT        NOT NULL DEFAULT 'zoom'
                                   CHECK (provider IN ('zoom', 'google_meet', 'livekit')),
    meeting_id         TEXT,
    meeting_uuid       TEXT,
    password           TEXT,
    join_url           TEXT,
    start_url          TEXT,
    host_user_id       TEXT,
    waiting_room       BOOLEAN     NOT NULL DEFAULT TRUE,
    auto_recording     BOOLEAN     NOT NULL DEFAULT TRUE,
    recording_status   TEXT        NOT NULL DEFAULT 'none'
                                   CHECK (recording_status IN ('none', 'processing', 'ready', 'failed')),
    recording_url      TEXT,
    provider_metadata  JSONB,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_live_session_meetings_session_id
    ON public.live_session_meetings(session_id);
CREATE INDEX IF NOT EXISTS idx_live_session_meetings_meeting_id
    ON public.live_session_meetings(meeting_id);

-- ============================================================
-- 3. session_attendance table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.session_attendance (
    id                  UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id          UUID        NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
    user_id             UUID        REFERENCES public.profiles(id) ON DELETE SET NULL,
    zoom_participant_id TEXT,
    display_name        TEXT,
    join_time           TIMESTAMPTZ,
    leave_time          TIMESTAMPTZ,
    duration            INTEGER,
    attendance_status   TEXT        NOT NULL DEFAULT 'absent'
                                    CHECK (attendance_status IN ('attended', 'partial', 'absent')),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_session_attendance_session_id ON public.session_attendance(session_id);
CREATE INDEX IF NOT EXISTS idx_session_attendance_user_id    ON public.session_attendance(user_id);

-- ============================================================
-- 4. session_recordings table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.session_recordings (
    id                     UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id             UUID        NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
    provider_recording_id  TEXT,
    download_url           TEXT,
    r2_url                 TEXT,
    duration               INTEGER,
    size                   BIGINT,
    processing_status      TEXT        NOT NULL DEFAULT 'none'
                                       CHECK (processing_status IN ('none', 'processing', 'ready', 'failed')),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_session_recordings_session_id ON public.session_recordings(session_id);

-- ============================================================
-- 5. updated_at triggers (reuse existing set_updated_at function)
-- ============================================================
DROP TRIGGER IF EXISTS set_sessions_updated_at ON public.sessions;
CREATE TRIGGER set_sessions_updated_at
    BEFORE UPDATE ON public.sessions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_live_session_meetings_updated_at ON public.live_session_meetings;
CREATE TRIGGER set_live_session_meetings_updated_at
    BEFORE UPDATE ON public.live_session_meetings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_session_attendance_updated_at ON public.session_attendance;
CREATE TRIGGER set_session_attendance_updated_at
    BEFORE UPDATE ON public.session_attendance
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_session_recordings_updated_at ON public.session_recordings;
CREATE TRIGGER set_session_recordings_updated_at
    BEFORE UPDATE ON public.session_recordings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 6. Enable RLS
-- ============================================================
ALTER TABLE public.sessions               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_session_meetings  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_attendance     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_recordings     ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 7. RLS Policies — sessions
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'sessions' AND policyname = 'Authenticated users can read sessions') THEN
        CREATE POLICY "Authenticated users can read sessions"
            ON public.sessions FOR SELECT
            USING (
                auth.uid() IS NOT NULL
                AND status <> 'draft'
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'sessions' AND policyname = 'Admins and instructors can create sessions') THEN
        CREATE POLICY "Admins and instructors can create sessions"
            ON public.sessions FOR INSERT
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin', 'instructor')
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'sessions' AND policyname = 'Admins and owning instructor can update sessions') THEN
        CREATE POLICY "Admins and owning instructor can update sessions"
            ON public.sessions FOR UPDATE
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
                OR instructor_id = auth.uid()
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'sessions' AND policyname = 'Admins and owning instructor can delete sessions') THEN
        CREATE POLICY "Admins and owning instructor can delete sessions"
            ON public.sessions FOR DELETE
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
                OR instructor_id = auth.uid()
            );
    END IF;
END;
$$;

-- ============================================================
-- 8. RLS Policies — live_session_meetings
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'live_session_meetings' AND policyname = 'Enrolled users can read session meetings') THEN
        CREATE POLICY "Enrolled users can read session meetings"
            ON public.live_session_meetings FOR SELECT
            USING (
                auth.uid() IS NOT NULL
                AND EXISTS (
                    SELECT 1 FROM public.sessions s
                    WHERE s.id = live_session_meetings.session_id
                    AND (
                        s.instructor_id = auth.uid()
                        OR EXISTS (
                            SELECT 1 FROM public.enrollments e
                            WHERE e.course_id = s.course_id
                            AND e.user_id = auth.uid()
                            AND e.status = 'active'
                            AND (e.validity_end_at IS NULL OR e.validity_end_at > NOW())
                        )
                    )
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'live_session_meetings' AND policyname = 'Admins can manage session meetings') THEN
        CREATE POLICY "Admins can manage session meetings"
            ON public.live_session_meetings FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            );
    END IF;
END;
$$;

-- ============================================================
-- 9. RLS Policies — session_attendance
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'session_attendance' AND policyname = 'Users can read own attendance') THEN
        CREATE POLICY "Users can read own attendance"
            ON public.session_attendance FOR SELECT
            USING (user_id = auth.uid());
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'session_attendance' AND policyname = 'Instructors can read attendance for their sessions') THEN
        CREATE POLICY "Instructors can read attendance for their sessions"
            ON public.session_attendance FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.sessions s
                    WHERE s.id = session_attendance.session_id
                    AND s.instructor_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'session_attendance' AND policyname = 'Admins can manage attendance') THEN
        CREATE POLICY "Admins can manage attendance"
            ON public.session_attendance FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            );
    END IF;
END;
$$;

-- ============================================================
-- 10. RLS Policies — session_recordings
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'session_recordings' AND policyname = 'Enrolled users can read session recordings') THEN
        CREATE POLICY "Enrolled users can read session recordings"
            ON public.session_recordings FOR SELECT
            USING (
                auth.uid() IS NOT NULL
                AND EXISTS (
                    SELECT 1 FROM public.sessions s
                    JOIN public.enrollments e ON e.course_id = s.course_id
                    WHERE s.id = session_recordings.session_id
                    AND e.user_id = auth.uid()
                    AND e.status = 'active'
                    AND (e.validity_end_at IS NULL OR e.validity_end_at > NOW())
                    AND s.status = 'recording_ready'
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'session_recordings' AND policyname = 'Instructors can read recordings for their sessions') THEN
        CREATE POLICY "Instructors can read recordings for their sessions"
            ON public.session_recordings FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.sessions s
                    WHERE s.id = session_recordings.session_id
                    AND s.instructor_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'session_recordings' AND policyname = 'Admins can manage session recordings') THEN
        CREATE POLICY "Admins can manage session recordings"
            ON public.session_recordings FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE id = auth.uid()
                    AND role IN ('admin', 'superadmin')
                )
            );
    END IF;
END;
$$;
