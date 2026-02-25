package config

import (
	"github.com/gin-contrib/cors"
)

func CorsConfig() cors.Config {
	return cors.Config{
		AllowAllOrigins: true,
		AllowMethods: []string{
			"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS",
		},
		AllowHeaders: []string{
			"Content-Type",
		},
		ExposeHeaders: []string{
			"Content-Length",
		},
	}
}
