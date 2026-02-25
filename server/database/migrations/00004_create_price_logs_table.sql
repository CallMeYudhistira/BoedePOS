-- +migrate Up

CREATE TABLE price_logs (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    old_price BIGINT NOT NULL,
    new_price BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX unique_price_update_per_day
ON price_logs (product_id, DATE(created_at));

-- +migrate Down

DROP INDEX IF EXISTS unique_price_update_per_day;

DROP TABLE IF EXISTS price_logs;