package router

import (
	"github.com/CallMeYudhistira/BoedePOS/handler"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AddProductRouter(db *gorm.DB, rg *gin.RouterGroup) {
	product := rg.Group("/products")

	product.GET("", handler.GetAllProduct(db))
	product.POST("", handler.StoreProduct(db))
	product.GET("/:id", handler.FindProduct(db))
	product.PUT("/:id", handler.UpdateProduct(db))
	product.DELETE("/:id", handler.DestroyProduct(db))
}
