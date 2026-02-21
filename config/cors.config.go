package config

import (
	"time"

	"github.com/gin-contrib/cors"
)

func CorsConfig() cors.Config {
	return cors.Config{
		AllowOrigins: []string{
			"http://localhost:1001",
			"http://127.0.0.1:1001",
		},
		AllowMethods: []string{
			"GET", "POST", "PUT", "DELETE", "OPTIONS",
		},
		AllowHeaders: []string{
			"Authorization",
			"Content-Type",
		},
		AllowCredentials: true,
		MaxAge:           24 * time.Hour,
	}
}
