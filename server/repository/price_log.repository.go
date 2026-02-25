package repository

import (
	"github.com/CallMeYudhistira/BoedePOS/helper"
	"github.com/CallMeYudhistira/BoedePOS/model"
	"gorm.io/gorm"
)

func GetPriceLogs(db *gorm.DB, filter model.PriceLogFilter) ([]model.PriceLog, error) {
	var priceLogs []model.PriceLog
	query := db.Preload("Product").Order("created_at desc")

	if filter.ProductID != 0 {
		query = query.Where("product_id = ?", filter.ProductID)
	}

	if filter.Period != "" {
		start, end := helper.GetPeriodRange(filter.Period)
		if !start.IsZero() {
			query = query.Where("created_at BETWEEN ? AND ?", start, end)
		}
	} else if filter.Date != "" {
		query = query.Where("DATE(created_at) = ?", filter.Date)
	} else if filter.StartDate != "" && filter.EndDate != "" {
		query = query.Where("DATE(created_at) BETWEEN ? AND ?", filter.StartDate, filter.EndDate)
	}

	err := query.Find(&priceLogs).Error
	return priceLogs, err
}

func StorePriceLog(db *gorm.DB, priceLog *model.PriceLog) error {
	return db.Transaction(func(tx *gorm.DB) error {
		priceLog.CreatedAt = helper.NowLocale()

		if err := tx.Model(&model.Product{}).
			Where("id = ?", priceLog.ProductID).
			Update("price", priceLog.NewPrice).Error; err != nil {
			return err
		}

		if err := tx.Create(priceLog).Error; err != nil {
			return err
		}

		return nil
	})
}

func CreateInitialPriceLog(tx *gorm.DB, productID uint, price int) error {
	priceLog := model.PriceLog{
		ProductID: productID,
		OldPrice:  0,
		NewPrice:  price,
		CreatedAt: helper.NowLocale(),
	}
	return tx.Create(&priceLog).Error
}

func CheckPriceLogToday(db *gorm.DB, productID uint) error {
	var existing model.PriceLog

	now := helper.NowLocale()
	today := now.Format("2006-01-02") // format YYYY-MM-DD

	return db.Where(
		"product_id = ? AND DATE(created_at) = ?",
		productID,
		today,
	).First(&existing).Error
}

func FindPriceLog(db *gorm.DB, priceLog *model.PriceLog) error {
	return db.Preload("Product").First(&priceLog, priceLog.ID).Error
}
