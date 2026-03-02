package router

import (
	"github.com/CallMeYudhistira/BoedePOS/handler"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AddPriceLogRouter(db *gorm.DB, rg *gin.RouterGroup) {
	price_log := rg.Group("/price_logs")

	price_log.GET("", handler.GetPriceLogs(db))
	price_log.GET("/:id", handler.GetPriceLogs(db))
	price_log.POST("/:id", handler.StorePriceLog(db))
}
