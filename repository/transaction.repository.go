package repository

import (
	"errors"

	"github.com/CallMeYudhistira/BoedePOS/helper"
	"github.com/CallMeYudhistira/BoedePOS/model"
	"gorm.io/gorm"
)

func calculateTransactionTotals(t *model.Transaction) {
	var total int64 = 0
	for _, detail := range t.TransactionDetails {
		total += detail.Subtotal
	}
	t.Total = total
	t.Change = t.Pay - total
}

func GetAllTransaction(db *gorm.DB, filter model.DateFilter) ([]model.Transaction, error) {
	var transactions []model.Transaction
	query := db.Preload("TransactionDetails.Product").Order("created_at desc")

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

	err := query.Find(&transactions).Error
	if err == nil {
		for i := range transactions {
			calculateTransactionTotals(&transactions[i])
		}
	}
	return transactions, err
}

func CreateTransaction(db *gorm.DB, req *model.TransactionRequest) (model.Transaction, error) {
	var transaction model.Transaction

	err := db.Transaction(func(tx *gorm.DB) error {
		// 1. Get unique product IDs from request
		productIDMap := make(map[uint]bool)
		for _, item := range req.Items {
			productIDMap[item.ProductID] = true
		}

		uniqueProductIDs := make([]uint, 0, len(productIDMap))
		for id := range productIDMap {
			uniqueProductIDs = append(uniqueProductIDs, id)
		}

		// 2. Fetch all unique products
		var products []model.Product
		if err := tx.Where("id IN ?", uniqueProductIDs).Find(&products).Error; err != nil {
			return err
		}

		if len(products) != len(uniqueProductIDs) {
			return gorm.ErrRecordNotFound
		}

		productMap := make(map[uint]model.Product)
		for _, p := range products {
			productMap[p.ID] = p
		}

		// 3. Initialize Transaction (Total and Change are not stored anymore)
		transaction = model.Transaction{
			Pay:       req.Pay,
			CreatedAt: helper.NowLocale(),
		}

		if err := tx.Create(&transaction).Error; err != nil {
			return err
		}

		var total int64 = 0
		details := make([]model.TransactionDetail, len(req.Items))

		// 4. Calculate totals and prepare details
		for i, item := range req.Items {
			product, ok := productMap[item.ProductID]
			if !ok {
				return gorm.ErrRecordNotFound
			}

			var finalPrice int64
			if product.IsFraction {
				finalPrice = item.Price 
			} else {
				finalPrice = product.Price
			}

			subtotal := int64(item.Qty) * finalPrice
			total += subtotal

			details[i] = model.TransactionDetail{
				TransactionID: transaction.ID,
				ProductID:     &product.ID,
				ProductName:   product.Name,
				Qty:           item.Qty,
				Price:         finalPrice,
				Subtotal:      subtotal,
			}
		}

		if req.Pay < total {
			return errors.New("insufficient payment")
		}

		// 5. Batch create details
		if err := tx.Create(&details).Error; err != nil {
			return err
		}

		// Set virtual fields for the response
		transaction.TransactionDetails = details
		transaction.Total = total
		transaction.Change = req.Pay - total

		return nil
	})

	return transaction, err
}

func FindTransaction(db *gorm.DB, id uint) (model.Transaction, error) {
	var transaction model.Transaction
	err := db.Preload("TransactionDetails.Product").First(&transaction, id).Error
	if err == nil {
		calculateTransactionTotals(&transaction)
	}
	return transaction, err
}

func DeleteTransaction(db *gorm.DB, id uint) error {
	return db.Delete(&model.Transaction{}, id).Error
}
