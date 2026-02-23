-- +migrate Up

CREATE TABLE price_logs (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    old_price BIGINT NOT NULL,
    new_price BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- +migrate Down

DROP TABLE IF EXISTS price_logs;