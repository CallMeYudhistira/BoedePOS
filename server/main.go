package main

import (
	"log"
	"os"

	"github.com/CallMeYudhistira/BoedePOS/config"
	"github.com/CallMeYudhistira/BoedePOS/database"
	"github.com/CallMeYudhistira/BoedePOS/helper"
	"github.com/CallMeYudhistira/BoedePOS/router"
)

func main() {

	// Load env
	if err := config.LoadEnvironment(); err != nil {
		log.Fatal(err)
	}

	// Set Locale Time
	if err := helper.LoadLocale(); err != nil {
		log.Fatal(err)
	}

	// Connect SQL (for migration)
	sqlDB, err := config.ConnectSQL()
	if err != nil {
		log.Fatal("SQL connection failed:", err)
	}
	defer sqlDB.Close()

	// Run migration
	migrator := database.NewMigrator(sqlDB)
	if err := migrator.Up(); err != nil {
		log.Fatal("Migration failed:", err)
	}
	log.Println("Migration complete ✅")

	// Connect GORM
	gormDB, err := config.ConnectGorm(sqlDB)
	if err != nil {
		log.Fatal("GORM connection failed:", err)
	}

	// Start server
	PORT := os.Getenv("APP_PORT")
	log.Println("Running at", PORT)

	router.StartServer(gormDB).Run(PORT)
}
