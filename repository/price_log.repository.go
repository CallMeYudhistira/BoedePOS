package repository

import (
	"time"

	"github.com/CallMeYudhistira/BoedePOS/model"
	"gorm.io/gorm"
)

func GetPriceLogs(db *gorm.DB, productID uint) ([]model.PriceLog, error) {
	var priceLogs []model.PriceLog
	err := db.Preload("Product").Where("product_id = ?", productID).Order("created_at desc").Find(&priceLogs).Error
	return priceLogs, err
}

func StorePriceLog(db *gorm.DB, priceLog *model.PriceLog) error {
	err := db.Table("products").Where("id = ?", priceLog.ProductID).Update("price", priceLog.NewPrice).Error
	if err != nil {
		return err
	}

	err = db.Create(priceLog).Error
	return err
}

func CheckPriceLogToday(db *gorm.DB, productID uint) error {
	var existing model.PriceLog
	todayStart := time.Now().Truncate(24 * time.Hour)
	tomorrow := todayStart.Add(24 * time.Hour)

	return db.Where(
		"product_id = ? AND created_at >= ? AND created_at < ?",
		productID,
		todayStart,
		tomorrow,
	).First(&existing).Error
}

func FindPriceLog(db *gorm.DB, priceLog *model.PriceLog) error {
	return db.Preload("Product").First(&priceLog, priceLog.ID).Error
}