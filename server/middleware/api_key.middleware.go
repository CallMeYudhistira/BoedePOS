package middleware

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func APIKeyMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		apiKey := c.GetHeader("X-API-KEY")
		expectedKey := os.Getenv("API_KEY")

		if expectedKey == "" {
			// If API_KEY is not set in env, allow access but log a warning (or you might want to block it)
			c.Next()
			return
		}

		if apiKey != expectedKey {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Invalid API Key",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}
