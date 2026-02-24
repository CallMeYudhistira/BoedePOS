package repository

import (
	"errors"

	"github.com/CallMeYudhistira/BoedePOS/helper"
	"github.com/CallMeYudhistira/BoedePOS/model"
	"gorm.io/gorm"
)

func GetAllTransaction(db *gorm.DB) ([]model.Transaction, error) {
	var transactions []model.Transaction
	err := db.Preload("TransactionDetails").Order("created_at desc").Find(&transactions).Error
	return transactions, err
}

func CreateTransaction(db *gorm.DB, req *model.TransactionRequest) (model.Transaction, error) {

	var transaction model.Transaction

	err := db.Transaction(func(tx *gorm.DB) error {

		var total int64 = 0

		transaction = model.Transaction{
			Total:     req.Total,
			Pay:       req.Pay,
			Change:    req.Pay - req.Total,
			CreatedAt: helper.NowLocale(),
		}

		if err := tx.Create(&transaction).Error; err != nil {
			return err
		}

		for _, item := range req.Items {

			var product model.Product
			if err := tx.First(&product, item.ProductID).Error; err != nil {
				return err
			}

			var finalPrice int64

			if product.IsFraction {
				finalPrice = item.Price // Harga Eceran
			} else {
				finalPrice = product.Price // Harga Fix
			}

			subtotal := int64(item.Qty) * finalPrice
			total += subtotal

			detail := model.TransactionDetail{
				TransactionID: transaction.ID,
				ProductID:     &product.ID,
				ProductName:   product.Name,
				Qty:           item.Qty,
				Price:         finalPrice,
				Subtotal:      subtotal,
			}

			if err := tx.Create(&detail).Error; err != nil {
				return err
			}
		}

		if req.Pay < total {
			return errors.New("Insufficient payment")
		}

		transaction.Total = total
		transaction.Change = req.Pay - total

		if err := tx.Save(&transaction).Error; err != nil {
			return err
		}

		return nil
	})

	return transaction, err
}

func FindTransaction(db *gorm.DB, id uint) (model.Transaction, error) {
	var transaction model.Transaction
	err := db.Preload("TransactionDetails").First(&transaction, id).Error
	return transaction, err
}

func DeleteTransaction(db *gorm.DB, id uint) error {
	return db.Delete(&model.Transaction{}, id).Error
}
