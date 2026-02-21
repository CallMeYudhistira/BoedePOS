package config

import (
	"fmt"
	"github.com/joho/godotenv"
)

func LoadEnvironment() error {
	if err := godotenv.Load(); err != nil {
		err := fmt.Errorf("Failed to load .env file: %w", err)
		return err
	}
	return nil
}
