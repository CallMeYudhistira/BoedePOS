package repository

import (
	"gorm.io/gorm"
	"github.com/CallMeYudhistira/BoedePOS/model"
)

func CreateProduct(db *gorm.DB, product *model.Product) error {
	return db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(product).Error; err != nil {
			return err
		}

		if err := CreateInitialPriceLog(tx, product.ID, int(product.Price)); err != nil {
			return err
		}

		return nil
	})
}

func GetProduct(db *gorm.DB, id uint) (model.Product, error) {
	var product model.Product
	err := db.Preload("PriceLogs").First(&product, id).Error
	return product, err
}

func GetAllProduct(db *gorm.DB, filter model.ProductFilter) ([]model.Product, error) {
	var products []model.Product
	
	query := db.Preload("PriceLogs")
	
	if filter.Name != "" {
		query = query.Where("name ILIKE ?", "%"+filter.Name+"%")
	}
	
	err := query.Find(&products).Error
	return products, err
}

func UpdateProduct(db *gorm.DB, product *model.Product) error {
	return db.Model(&model.Product{}).
		Where("id = ?", product.ID).
		Omit("price").
		Select("name", "is_fraction").
		Updates(product).Error
}

func DeleteProduct(db *gorm.DB, id uint) error {
	return db.Delete(&model.Product{}, id).Error
}
