package router

import (
	"github.com/CallMeYudhistira/BoedePOS/handler"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AddTransactionRouter(db *gorm.DB, rg *gin.RouterGroup) {
	product := rg.Group("/transactions")

	product.GET("/", handler.GetAllTransaction(db))
	product.POST("/", handler.StoreTransaction(db))
	product.GET("/:id", handler.FindTransaction(db))
	product.DELETE("/:id", handler.DestroyTransaction(db))
}
