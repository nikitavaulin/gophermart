BEGIN;

CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL
);

CREATE TABLE orders (
    number TEXT PRIMARY KEY CHECK (number ~ '^[0-9]+$'),
    user_id BIGINT NOT NULL REFERENCES users(id),
    status TEXT NOT NULL DEFAULT 'NEW'
        CHECK (status IN ('NEW', 'PROCESSING', 'INVALID', 'PROCESSED')),
    accrual NUMERIC CHECK (
        accrual IS NULL OR
        (status = 'PROCESSED' AND accrual >= 0 AND accrual < 'Infinity'::NUMERIC)
    ),
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE balances (
    user_id BIGINT PRIMARY KEY REFERENCES users(id),
    current NUMERIC NOT NULL DEFAULT 0 CHECK (current >= 0 AND current < 'Infinity'::NUMERIC),
    withdrawn NUMERIC NOT NULL DEFAULT 0 CHECK (withdrawn >= 0 AND withdrawn < 'Infinity'::NUMERIC)
);

CREATE TABLE withdrawals (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    order_number TEXT NOT NULL UNIQUE CHECK (order_number ~ '^[0-9]+$'),
    sum NUMERIC NOT NULL CHECK (sum > 0 AND sum < 'Infinity'::NUMERIC),
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX orders_user_uploaded_idx ON orders (user_id, uploaded_at DESC, number);
CREATE INDEX withdrawals_user_processed_idx ON withdrawals (user_id, processed_at DESC, id DESC);
CREATE INDEX orders_pending_idx ON orders (uploaded_at, number)
    WHERE status IN ('NEW', 'PROCESSING');

COMMIT;
