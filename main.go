package main

import (
	"log"
	"os"

	"github.com/CallMeYudhistira/BoedePOS/config"
	"github.com/CallMeYudhistira/BoedePOS/database"
	"github.com/CallMeYudhistira/BoedePOS/router"
)

func main() {

	// 1️⃣ Load env
	if err := config.LoadEnvironment(); err != nil {
		log.Fatal(err)
	}

	// 2️⃣ Connect SQL (for migration)
	sqlDB, err := config.ConnectSQL()
	if err != nil {
		log.Fatal("SQL connection failed:", err)
	}
	defer sqlDB.Close()

	// 3️⃣ Run migration
	migrator := database.NewMigrator(sqlDB)
	if err := migrator.Down(); err != nil {
		log.Fatal("Migration failed:", err)
	}
	log.Println("Migration complete ✅")

	// 4️⃣ Connect GORM
	gormDB, err := config.ConnectGorm(sqlDB)
	if err != nil {
		log.Fatal("GORM connection failed:", err)
	}

	// 5️⃣ Start server
	PORT := os.Getenv("APP_PORT")
	log.Println("Running at", PORT)

	router.StartServer(gormDB).Run(PORT)
}