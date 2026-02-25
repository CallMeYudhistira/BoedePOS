package model

import "time"

type PriceLog struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	ProductID uint      `json:"product_id"`
	OldPrice  int       `json:"old_price" binding:"required,min=1"`
	NewPrice  int       `json:"new_price" binding:"required,min=1"`
	CreatedAt time.Time `json:"created_at"`

	Product   *Product  `json:"product,omitempty" gorm:"foreignKey:ProductID;references:ID"`
}