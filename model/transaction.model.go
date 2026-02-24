package model

import "time"

type Transaction struct {
	ID        uint                 `json:"id" gorm:"primaryKey"`
	Total     int64                `json:"total" binding:"required"`
	Pay       int64                `json:"pay" binding:"required"`
	Change    int64                `json:"change" binding:"required"`
	CreatedAt time.Time            `json:"created_at"`

	Details   []TransactionDetail  `json:"details,omitempty" gorm:"foreignKey:TransactionID"`
}