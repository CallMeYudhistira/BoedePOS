package database

import (
	"database/sql"
	"embed"
	"fmt"
	"os"

	migrate "github.com/rubenv/sql-migrate"
)

type Migrator interface {
	Up() error
	Down() error
}

type SQLMigrator struct {
	db       *sql.DB
	source   migrate.MigrationSource
	provider string
}

//go:embed migrations/*.sql
var migrationFs embed.FS

const (
	databaseProviderKey = "DB_PROVIDER"
	sourceRoot          = "migrations"
)

func NewMigrator(db *sql.DB) Migrator {
	source := &migrate.EmbedFileSystemMigrationSource{
		FileSystem: migrationFs,
		Root:       sourceRoot,
	}

	provider := os.Getenv(databaseProviderKey)

	return &SQLMigrator{
		db:       db,
		source:   source,
		provider: provider,
	}
}

func (sqlm *SQLMigrator) Up() error {
	n, err := migrate.Exec(sqlm.db, sqlm.provider, sqlm.source, migrate.Up)
	if err != nil {
		return err
	}

	fmt.Println("migration success, applied", n, "migrations!")
	return nil
}

func (sqlm *SQLMigrator) Down() error {
	n, err := migrate.Exec(sqlm.db, sqlm.provider, sqlm.source, migrate.Down)
	if err != nil {
		return err
	}

	fmt.Println("rollback success, reverted", n, "migrations!")
	return nil
}
