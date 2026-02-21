package router

import (
	"github.com/CallMeYudhistira/BoedePOS/config"
	"database/sql"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func StartServer(db *sql.DB) *gin.Engine {
	r := gin.Default()

	// =====================
	// CORS CONFIG
	// =====================
	r.Use(cors.New(config.CorsConfig()))

	// =====================
	// ROUTER
	// =====================
	api := r.Group("/api")

	api.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "BoedePOS running 🚀"})
	})

	return r
}
