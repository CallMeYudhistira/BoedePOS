package model

import "time"

type Product struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Name      string    `json:"name" binding:"required"`
	Price     int       `json:"price" binding:"required,min=1"`
	CreatedAt time.Time `json:"created_at"`
}
