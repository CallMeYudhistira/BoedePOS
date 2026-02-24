package repository

import (
	"gorm.io/gorm"
	"github.com/CallMeYudhistira/BoedePOS/model"
)

func CreateProduct(db *gorm.DB, product *model.Product) error {
	return db.Create(product).Error
}

func GetProduct(db *gorm.DB, id uint) (model.Product, error) {
	var product model.Product
	err := db.Preload("PriceLogs").First(&product, id).Error
	return product, err
}

func GetAllProduct(db *gorm.DB) ([]model.Product, error) {
	var products []model.Product
	err := db.Preload("PriceLogs").Find(&products).Error
	return products, err
}

func UpdateProduct(db *gorm.DB, product *model.Product) error {
	return db.Updates(product).Error
}

func DeleteProduct(db *gorm.DB, id uint) error {
	return db.Delete(&model.Product{}, id).Error
}