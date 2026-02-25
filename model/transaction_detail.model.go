package model

type TransactionDetail struct {
	ID            uint    `json:"id" gorm:"primaryKey"`
	TransactionID uint    `json:"transaction_id"`
	ProductID     *uint   `json:"product_id"`
	ProductName   string  `json:"product_name"`
	Qty           int     `json:"qty"`
	Price         int64   `json:"price"`
	Subtotal      int64   `json:"subtotal"`
	Product       *Product `json:"product,omitempty" gorm:"foreignKey:ProductID"`
}

type TransactionDetailRequest struct {
	ProductID   uint   `json:"product_id" binding:"required"`
	ProductName string `json:"product_name" binding:"required"`
	Qty         int    `json:"qty" binding:"required,min=1"`
	Price       int64  `json:"price" binding:"required,min=1"`
}
