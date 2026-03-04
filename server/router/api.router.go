package router

import (
	"github.com/CallMeYudhistira/BoedePOS/config"
	"github.com/CallMeYudhistira/BoedePOS/middleware"
	"gorm.io/gorm"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func StartServer(db *gorm.DB) *gin.Engine {
	r := gin.Default()

	// =====================
	// CORS CONFIG
	// =====================
	r.Use(cors.New(config.CorsConfig()))

	// =====================
	// ROUTER
	// =====================
	api := r.Group("/api")

	// Apply API Key Middleware
	api.Use(middleware.APIKeyMiddleware())

	api.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "BoedePOS running 🚀"})
	})

	AddProductRouter(db, api)
	AddPriceLogRouter(db, api)
	AddTransactionRouter(db, api)

	return r
}
