-- +migrate Up

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    total BIGINT NOT NULL,
    pay BIGINT NOT NULL,
    change BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- +migrate Down

DROP TABLE IF EXISTS transactions;