-- +migrate Up

ALTER TABLE transactions DROP COLUMN total;
ALTER TABLE transactions DROP COLUMN change;

-- +migrate Down

ALTER TABLE transactions ADD COLUMN total BIGINT NOT NULL DEFAULT 0;
ALTER TABLE transactions ADD COLUMN change BIGINT NOT NULL DEFAULT 0;
