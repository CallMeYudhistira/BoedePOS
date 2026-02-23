package model

type Product struct {
	ID         uint       `json:"id" gorm:"primaryKey"`
	Name       string     `json:"name" binding:"required"`
	Price      int        `json:"price" binding:"required,min=1"`
	IsFraction bool       `json:"is_fraction"`

	PriceLogs  []PriceLog `json:"price_logs,omitempty" gorm:"foreignKey:ProductID"` // hasMany
}