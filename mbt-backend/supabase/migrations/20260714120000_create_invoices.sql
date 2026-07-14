-- ============================================================
-- Migration: Create Invoices and Invoice Items tables
-- ============================================================

CREATE TYPE public.invoice_status AS ENUM ('paid', 'refunded', 'void');
CREATE TYPE public.invoice_item_type AS ENUM ('course', 'bundle', 'subscription', 'service');

CREATE TABLE IF NOT EXISTS public.invoices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    invoice_number TEXT UNIQUE NOT NULL,
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE RESTRICT,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    status public.invoice_status DEFAULT 'paid' NOT NULL,
    currency TEXT NOT NULL,
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    discount NUMERIC(10,2) DEFAULT 0.00 NOT NULL CHECK (discount >= 0),
    tax NUMERIC(10,2) DEFAULT 0.00 NOT NULL CHECK (tax >= 0),
    total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    issued_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    paid_at TIMESTAMPTZ NOT NULL,
    pdf_url TEXT,
    company_snapshot JSONB NOT NULL,
    customer_snapshot JSONB NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON public.invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_payment_id ON public.invoices(payment_id);
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_number ON public.invoices(invoice_number);

CREATE TABLE IF NOT EXISTS public.invoice_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    invoice_id UUID NOT NULL REFERENCES public.invoices(id) ON DELETE CASCADE,
    item_type public.invoice_item_type NOT NULL,
    item_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    discount NUMERIC(10,2) DEFAULT 0.00 NOT NULL CHECK (discount >= 0),
    tax NUMERIC(10,2) DEFAULT 0.00 NOT NULL CHECK (tax >= 0),
    total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON public.invoice_items(invoice_id);

-- Set updated_at trigger for invoices
DROP TRIGGER IF EXISTS set_invoices_updated_at ON public.invoices;
CREATE TRIGGER set_invoices_updated_at
    BEFORE UPDATE ON public.invoices
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Invoices
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'invoices' AND policyname = 'Users can read own invoices') THEN
        CREATE POLICY "Users can read own invoices"
            ON public.invoices FOR SELECT
            USING (user_id = auth.uid());
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'invoices' AND policyname = 'Admins can manage invoices') THEN
        CREATE POLICY "Admins can manage invoices"
            ON public.invoices FOR ALL
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

-- RLS Policies for Invoice Items
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'invoice_items' AND policyname = 'Users can read own invoice items') THEN
        CREATE POLICY "Users can read own invoice items"
            ON public.invoice_items FOR SELECT
            USING (
                EXISTS (
                    SELECT 1 FROM public.invoices i
                    WHERE i.id = invoice_items.invoice_id
                    AND i.user_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'invoice_items' AND policyname = 'Admins can manage invoice items') THEN
        CREATE POLICY "Admins can manage invoice items"
            ON public.invoice_items FOR ALL
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
