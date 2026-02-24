package model

import "time"

type Transaction struct {
	ID                 uint                `json:"id" gorm:"primaryKey"`
	Total              int64               `json:"total"`
	Pay                int64               `json:"pay"`
	Change             int64               `json:"change"`
	CreatedAt          time.Time           `json:"created_at"`
	TransactionDetails []TransactionDetail `json:"transaction_details" gorm:"foreignKey:TransactionID;constraint:OnDelete:CASCADE"`
}

type TransactionRequest struct {
	Total int64                      `json:"total" binding:"required"`
	Pay   int64                      `json:"pay" binding:"required"`
	Items []TransactionDetailRequest `json:"items" binding:"required,dive"`
}
