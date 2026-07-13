-- ============================================================
-- Seed: Update courses with new fields + insert sections & lessons
-- Run after 20260712130000_add_course_fields_sections_lessons.sql
-- ============================================================

-- 1. Update existing courses with new field values
UPDATE public.courses SET
    is_bestseller = TRUE,
    average_rating = 4.8,
    reviews_count = 12600,
    total_lessons = 48,
    learning_outcomes = '[
        "Identify and test mobile ICs",
        "Advanced soldering techniques",
        "Fault finding and troubleshooting",
        "IC replacement and reballing",
        "Read mobile phone schematics",
        "Use oscilloscope for signal tracing"
    ]'::jsonb,
    requirements = '[
        "Basic knowledge of mobile phone hardware",
        "Soldering iron and basic tools",
        "Multimeter for testing",
        "Willingness to learn"
    ]'::jsonb
WHERE slug = 'mobile-ic-repair-complete-course';

UPDATE public.courses SET
    is_bestseller = FALSE,
    average_rating = 4.7,
    reviews_count = 8900,
    total_lessons = 36,
    learning_outcomes = '[
        "Master hot air soldering techniques",
        "Perform micro-soldering on PCBs",
        "BGA rework and alignment",
        "Jumper wire techniques",
        "PCB trace repair and restoration",
        "Work with real damaged boards"
    ]'::jsonb,
    requirements = '[
        "Completed basic mobile repair course",
        "Hot air rework station",
        "Microscope recommended",
        "Practice PCBs"
    ]'::jsonb
WHERE slug = 'advanced-soldering-techniques';

UPDATE public.courses SET
    is_bestseller = TRUE,
    average_rating = 4.9,
    reviews_count = 15300,
    total_lessons = 32,
    learning_outcomes = '[
        "Understand power management ICs",
        "Diagnose charging circuit faults",
        "Repair battery connector issues",
        "Voltage regulation troubleshooting",
        "Fix power-related failures in iPhones",
        "Fix power-related failures in Android devices"
    ]'::jsonb,
    requirements = '[
        "Intermediate mobile repair knowledge",
        "Multimeter with voltage measurement",
        "Schematic reading basics"
    ]'::jsonb
WHERE slug = 'power-ic-deep-dive';

UPDATE public.courses SET
    is_bestseller = FALSE,
    average_rating = 4.8,
    reviews_count = 7200,
    total_lessons = 28,
    learning_outcomes = '[
        "Stencil alignment techniques",
        "Solder ball placement and reflow",
        "Reflow profiling for different boards",
        "CPU underfill removal",
        "Successful reballing for iPhones",
        "Reballing for Samsung and Huawei"
    ]'::jsonb,
    requirements = '[
        "Advanced soldering experience",
        "BGA rework station",
        "Stencil set for various CPUs",
        "Soldering microscope"
    ]'::jsonb
WHERE slug = 'cpu-reballing-bga-repair';

UPDATE public.courses SET
    is_bestseller = FALSE,
    average_rating = 4.6,
    reviews_count = 5400,
    total_lessons = 20,
    learning_outcomes = '[
        "Select proper micro-soldering tools",
        "Use microscope effectively",
        "Wire soldering techniques",
        "Component removal and replacement",
        "Practice on donor boards",
        "Build confidence in micro-soldering"
    ]'::jsonb,
    requirements = '[
        "No prior soldering experience needed",
        "Basic soldering iron",
        "Magnification tool recommended"
    ]'::jsonb
WHERE slug = 'micro-soldering-beginners';

UPDATE public.courses SET
    is_bestseller = FALSE,
    average_rating = 4.7,
    reviews_count = 6300,
    total_lessons = 24,
    learning_outcomes = '[
        "Read circuit diagrams confidently",
        "Identify component symbols",
        "Signal tracing on schematics",
        "Understand power rails",
        "Use schematics to diagnose faults",
        "Work with iPhone and Android schematics"
    ]'::jsonb,
    requirements = '[
        "Basic electronics knowledge",
        "Multimeter familiarity",
        "PDF reader for schematics"
    ]'::jsonb
WHERE slug = 'schematic-reading-mobile-repair';

UPDATE public.courses SET
    is_bestseller = TRUE,
    average_rating = 4.5,
    reviews_count = 9800,
    total_lessons = 22,
    learning_outcomes = '[
        "Fix boot loop issues",
        "Repair hang on logo problems",
        "Restore no IMEI devices",
        "Firmware flashing techniques",
        "EDL mode repair",
        "iTunes recovery methods"
    ]'::jsonb,
    requirements = '[
        "Basic mobile repair knowledge",
        "USB cable and PC",
        "Firmware files for common brands"
    ]'::jsonb
WHERE slug = 'mobile-software-troubleshooting';

UPDATE public.courses SET
    is_bestseller = FALSE,
    average_rating = 4.6,
    reviews_count = 8100,
    total_lessons = 26,
    learning_outcomes = '[
        "Bypass FRP for Samsung devices",
        "Bypass FRP for Xiaomi devices",
        "Bypass FRP for Oppo and Vivo",
        "Bypass FRP for Huawei devices",
        "Use Octopus and UMT tools",
        "Use Miracle Box and Sigma tools"
    ]'::jsonb,
    requirements = '[
        "Basic software repair knowledge",
        "Windows PC with admin access",
        "USB data cable"
    ]'::jsonb
WHERE slug = 'frp-bypass-unlock-tools';

UPDATE public.courses SET
    is_bestseller = FALSE,
    average_rating = 4.8,
    reviews_count = 4600,
    total_lessons = 30,
    learning_outcomes = '[
        "Recover data from water-damaged phones",
        "Extract data from broken screens",
        "Data recovery from dead motherboards",
        "Bypass locked devices for data",
        "Logical recovery techniques",
        "Chip-off data recovery methods"
    ]'::jsonb,
    requirements = '[
        "Advanced hardware repair skills",
        "Data recovery software",
        "Chip-off equipment for advanced module"
    ]'::jsonb
WHERE slug = 'mobile-data-recovery-guide';

UPDATE public.courses SET
    is_bestseller = FALSE,
    average_rating = 4.5,
    reviews_count = 5200,
    total_lessons = 16,
    learning_outcomes = '[
        "Use Odin for Samsung flashing",
        "Use SP Flash Tool for MediaTek",
        "Use iBox for advanced repair",
        "Use 3uTools for iOS devices",
        "Fix dead devices with firmware",
        "Upgrade and downgrade firmware safely"
    ]'::jsonb,
    requirements = '[
        "Basic mobile repair knowledge",
        "Windows PC",
        "Firmware files"
    ]'::jsonb
WHERE slug = 'flashing-firmware-repair';

-- 2. Seed course_sections and course_lessons

-- For "Mobile IC Repair Complete Course"
DO $$
DECLARE
    v_course_id UUID;
    v_section_id UUID;
BEGIN
    SELECT id INTO v_course_id FROM public.courses WHERE slug = 'mobile-ic-repair-complete-course' LIMIT 1;

    IF v_course_id IS NOT NULL THEN
        -- Section 1
        INSERT INTO public.course_sections (course_id, title, description, sort_order)
        VALUES (v_course_id, 'Introduction to Mobile IC Repair', 'Get started with the fundamentals of IC repair, tools, and safety.', 1)
        RETURNING id INTO v_section_id;

        INSERT INTO public.course_lessons (section_id, course_id, title, description, video_duration, is_free_preview, sort_order) VALUES
        (v_section_id, v_course_id, 'What are ICs and Why They Fail', 'Understand the role of ICs in mobile devices and common failure modes.', '14:30', TRUE, 1),
        (v_section_id, v_course_id, 'Essential Tools for IC Repair', 'Overview of tools: soldering station, microscope, multimeter, hot air gun.', '18:45', TRUE, 2),
        (v_section_id, v_course_id, 'Safety Precautions and Best Practices', 'Learn safety measures to protect yourself and the devices.', '12:15', FALSE, 3),
        (v_section_id, v_course_id, 'Understanding Mobile Phone Architecture', 'Overview of PCB layers, components placement, and signal flow.', '22:00', FALSE, 4);

        -- Section 2
        INSERT INTO public.course_sections (course_id, title, description, sort_order)
        VALUES (v_course_id, 'Component Identification & Testing', 'Learn to identify and test various ICs and components on the motherboard.', 2)
        RETURNING id INTO v_section_id;

        INSERT INTO public.course_lessons (section_id, course_id, title, description, video_duration, is_free_preview, sort_order) VALUES
        (v_section_id, v_course_id, 'Identifying Common ICs on Motherboard', 'Visual identification of power ICs, audio ICs, charging ICs, and more.', '20:30', FALSE, 1),
        (v_section_id, v_course_id, 'Understanding IC Labels and Markings', 'Decode part numbers, date codes, and manufacturer markings.', '15:00', FALSE, 2),
        (v_section_id, v_course_id, 'Using Multimeter for IC Testing', 'Measure continuity, resistance, and voltage on IC pins.', '25:10', FALSE, 3),
        (v_section_id, v_course_id, 'Oscilloscope Basics for Signal Tracing', 'Introduction to oscilloscope usage for troubleshooting IC signals.', '28:30', FALSE, 4);

        -- Section 3
        INSERT INTO public.course_sections (course_id, title, description, sort_order)
        VALUES (v_course_id, 'Soldering Techniques', 'Master the essential soldering skills required for IC repair work.', 3)
        RETURNING id INTO v_section_id;

        INSERT INTO public.course_lessons (section_id, course_id, title, description, video_duration, is_free_preview, sort_order) VALUES
        (v_section_id, v_course_id, 'Hot Air Soldering Basics', 'Proper technique for using hot air station to remove and place ICs.', '32:00', FALSE, 1),
        (v_section_id, v_course_id, 'Micro-soldering Fundamentals', 'Fine-pitch soldering techniques for small components.', '26:15', FALSE, 2),
        (v_section_id, v_course_id, 'BGA Rework Station Setup', 'Configure and use BGA rework station for chip-level repair.', '35:20', FALSE, 3),
        (v_section_id, v_course_id, 'Jumper Wire Techniques', 'How to run jumper wires for broken traces and damaged pads.', '18:40', FALSE, 4);

        -- Section 4
        INSERT INTO public.course_sections (course_id, title, description, sort_order)
        VALUES (v_course_id, 'Advanced Fault Finding & Repair', 'Real-world troubleshooting scenarios and advanced repair techniques.', 4)
        RETURNING id INTO v_section_id;

        INSERT INTO public.course_lessons (section_id, course_id, title, description, video_duration, is_free_preview, sort_order) VALUES
        (v_section_id, v_course_id, 'Power IC Failure Diagnosis', 'Step-by-step diagnosis and replacement of faulty power ICs.', '38:00', FALSE, 1),
        (v_section_id, v_course_id, 'Audio IC and Charging IC Repair', 'Common failures and repair methods for audio and charging circuits.', '30:15', FALSE, 2),
        (v_section_id, v_course_id, 'CPU and NAND Reballing', 'Advanced reballing techniques for CPUs and NAND flash chips.', '42:30', FALSE, 3),
        (v_section_id, v_course_id, 'Final Project: Full Motherboard Repair', 'Apply all skills to repair a real damaged motherboard from start to finish.', '55:00', FALSE, 4);

        -- Sync total_lessons
        UPDATE public.courses SET total_lessons = (
            SELECT COUNT(*) FROM public.course_lessons WHERE course_id = v_course_id
        ) WHERE id = v_course_id;
    END IF;
END;
$$;

-- For "Power IC Section - Deep Dive"
DO $$
DECLARE
    v_course_id UUID;
    v_section_id UUID;
BEGIN
    SELECT id INTO v_course_id FROM public.courses WHERE slug = 'power-ic-deep-dive' LIMIT 1;

    IF v_course_id IS NOT NULL THEN
        INSERT INTO public.course_sections (course_id, title, description, sort_order)
        VALUES (v_course_id, 'Power IC Fundamentals', 'Understand power management ICs and their role in mobile devices.', 1)
        RETURNING id INTO v_section_id;

        INSERT INTO public.course_lessons (section_id, course_id, title, description, video_duration, is_free_preview, sort_order) VALUES
        (v_section_id, v_course_id, 'What is a Power IC?', 'Introduction to power management ICs and their functions.', '16:00', TRUE, 1),
        (v_section_id, v_course_id, 'Types of Power ICs in Mobile Phones', 'Buck converters, boost converters, LDOs, and PMICs.', '22:30', FALSE, 2),
        (v_section_id, v_course_id, 'Power Rail Mapping', 'Mapping power rails on iPhone and Android motherboards.', '28:00', FALSE, 3),
        (v_section_id, v_course_id, 'Common Power IC Failure Symptoms', 'No power, short circuit, overheating, and battery drain issues.', '19:45', FALSE, 4);

        INSERT INTO public.course_sections (course_id, title, description, sort_order)
        VALUES (v_course_id, 'Charging Circuit Repair', 'Diagnose and repair charging-related faults.', 2)
        RETURNING id INTO v_section_id;

        INSERT INTO public.course_lessons (section_id, course_id, title, description, video_duration, is_free_preview, sort_order) VALUES
        (v_section_id, v_course_id, 'Charging Circuit Architecture', 'Understanding the charging path from port to battery.', '20:00', FALSE, 1),
        (v_section_id, v_course_id, 'Tristar and Tigris IC Repair', 'Common Apple charging IC failures and replacement.', '34:15', FALSE, 2),
        (v_section_id, v_course_id, 'Android Charging IC Repair', 'Repair charging ICs on Samsung, Xiaomi, and other Android devices.', '30:00', FALSE, 3);

        UPDATE public.courses SET total_lessons = (
            SELECT COUNT(*) FROM public.course_lessons WHERE course_id = v_course_id
        ) WHERE id = v_course_id;
    END IF;
END;
$$;
