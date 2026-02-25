package model

import "time"

type Transaction struct {
	ID                 uint                `json:"id" gorm:"primaryKey"`
	Pay                int64               `json:"pay" gorm:"not null"`
	CreatedAt          time.Time           `json:"created_at"`
	TransactionDetails []TransactionDetail `json:"transaction_details" gorm:"foreignKey:TransactionID;constraint:OnDelete:CASCADE"`
	
	// Virtual fields for JSON response
	Total  int64 `json:"total" gorm:"-"`
	Change int64 `json:"change" gorm:"-"`
}

type TransactionRequest struct {
	Pay   int64                      `json:"pay" binding:"required,min=1"`
	Items []TransactionDetailRequest `json:"items" binding:"required,min=1,dive"`
}
