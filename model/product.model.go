package model

type Product struct {
	ID         uint                `json:"id" gorm:"primaryKey"`
	Name       string              `json:"name"`
	Price      int64               `json:"price"`
	IsFraction bool                `json:"is_fraction"`

	PriceLogs  []PriceLog          `json:"price_logs,omitempty" gorm:"foreignKey:ProductID"`
	Details    []TransactionDetail `json:"transaction_details,omitempty" gorm:"foreignKey:ProductID"`
}