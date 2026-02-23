package main

import (
	"log"
	"os"

	"github.com/CallMeYudhistira/BoedePOS/config"
	"github.com/CallMeYudhistira/BoedePOS/database"
	"github.com/CallMeYudhistira/BoedePOS/router"
)

func main() {
	// 1️⃣ Load environment
	if err := config.LoadEnvironment(); err != nil {
		log.Fatal(err)
	}

	// 2️⃣ Connect DB
	db, err := config.Connect()
	if err != nil {
		log.Fatal("DB connection failed:", err)
	}
	defer db.Close()

	log.Println("Database connected ✅")

	// 3️⃣ Run Migration
	migrator := database.NewMigrator(db)

	if err := migrator.Up(); err != nil {
		log.Fatal("Migration failed:", err)
	}

	log.Println("Migration complete ✅")

	// 4️⃣ Start Server
	PORT := os.Getenv("APP_PORT")

	log.Println("Running at", PORT)
	router.StartServer(db).Run(PORT)
}
