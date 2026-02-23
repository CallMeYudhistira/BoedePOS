package router

import (
	"github.com/CallMeYudhistira/BoedePOS/handler"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AddProductRouter(db *gorm.DB, rg *gin.RouterGroup) {
	product := rg.Group("/products")

	product.GET("/", handler.GetAll(db))
	product.POST("/", handler.Store(db))
	product.GET("/:id", handler.Find(db))
	product.PUT("/:id", handler.Update(db))
	product.DELETE("/:id", handler.Destroy(db))
}
