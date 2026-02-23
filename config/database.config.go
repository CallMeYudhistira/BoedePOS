package config

import (
	"database/sql"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	_ "github.com/lib/pq"
)

func ConnectSQL() (*sql.DB, error) {
	dsn := os.Getenv("DATABASE_DSN")
	return sql.Open("postgres", dsn)
}

func ConnectGorm(sqlDB *sql.DB) (*gorm.DB, error) {
	return gorm.Open(postgres.New(postgres.Config{
		Conn: sqlDB,
	}), &gorm.Config{})
}