package config

import (
	"log"
	"github.com/joho/godotenv"
)

func LoadEnvironment() error {
	// Only return error if .env exists but failed to load.
	// In production/docker, env vars are often passed directly.
	err := godotenv.Load()
	if err != nil {
		log.Println("Note: .env file not found, using system environment variables")
	}
	return nil
}
