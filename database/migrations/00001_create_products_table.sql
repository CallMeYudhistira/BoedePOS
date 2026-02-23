-- +migrate Up

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price INT NOT NULL,
    is_fraction BOOLEAN DEFAULT FALSE
);

-- +migrate Down

DROP TABLE IF EXISTS products;