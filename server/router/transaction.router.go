package router

import (
	"github.com/CallMeYudhistira/BoedePOS/handler"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AddTransactionRouter(db *gorm.DB, rg *gin.RouterGroup) {
	transaction := rg.Group("/transactions")

	transaction.GET("", handler.GetAllTransaction(db))
	transaction.POST("", handler.StoreTransaction(db))
	transaction.GET("/reports", handler.GetSalesReport(db))
	transaction.GET("/:id", handler.FindTransaction(db))
	transaction.DELETE("/:id", handler.DestroyTransaction(db))
}
