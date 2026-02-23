package repository

import (
	"github.com/CallMeYudhistira/BoedePOS/model"
	"gorm.io/gorm"
)

func GetPriceLogs(db *gorm.DB, productID uint) ([]model.PriceLog, error) {
	var priceLogs []model.PriceLog
	err := db.Preload("Product").Where("product_id = ?", productID).Order("created_at desc").Find(&priceLogs).Error
	return priceLogs, err
}

func StorePriceLog(db *gorm.DB, priceLog *model.PriceLog) error {
	return db.Create(priceLog).Error
}