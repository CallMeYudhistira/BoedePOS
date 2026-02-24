-- +migrate Up

CREATE TABLE transaction_detail (
    id SERIAL PRIMARY KEY,
    transaction_id INT REFERENCES transactions(id) ON DELETE CASCADE,
    product_id INT REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(255) NOT NULL,
    qty INT NOT NULL,
    price BIGINT NOT NULL,
    subtotal BIGINT NOT NULL
);

-- +migrate Down

DROP TABLE IF EXISTS transaction_detail;