package model

type Product struct {
	ID         int    `json:"id"`
	Name       string `json:"name" binding:"required"`
	Price      int    `json:"price" binding:"required,min=1,number"`
	Created_at string `json:"created_at"`
}
