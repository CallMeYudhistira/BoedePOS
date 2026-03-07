package model

type PaginationFilter struct {
	Page  int `form:"page"`
	Limit int `form:"limit"`
}

type ProductFilter struct {
	Name string `form:"name"`
	PaginationFilter
}

type DateFilter struct {
	Date      string `form:"date"`       // format YYYY-MM-DD
	StartDate string `form:"start_date"` // format YYYY-MM-DD
	EndDate   string `form:"end_date"`   // format YYYY-MM-DD
	Period    string `form:"period"`     // daily, weekly, monthly, yearly
	PaginationFilter
}

type PriceLogFilter struct {
	ProductID uint `form:"product_id"`
	DateFilter
}
