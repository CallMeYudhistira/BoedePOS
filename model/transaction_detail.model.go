package model

type TransactionDetail struct {
	ID            uint        `json:"id" gorm:"primaryKey"`
	TransactionID uint        `json:"transaction_id"`
	ProductID     *uint       `json:"product_id"` // pointer karena ON DELETE SET NULL

	ProductName   string      `json:"product_name"`
	Qty           int         `json:"qty"`
	Price         int64       `json:"price"`
	Subtotal      int64       `json:"subtotal"`

	Transaction   Transaction `json:"transaction,omitempty" gorm:"foreignKey:TransactionID"`
	Product       Product     `json:"product,omitempty" gorm:"foreignKey:ProductID"`
}