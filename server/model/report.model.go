package model

type MostSoldProduct struct {
	Name     string `json:"name"`
	Qty      int    `json:"qty"`
	Turnover int64  `json:"turnover"`
}

type SalesReport struct {
	TotalTurnover     int64            `json:"total_turnover"`
	TotalTransactions int              `json:"total_transactions"`
	TotalItemsSold    int              `json:"total_items_sold"`
	MostSoldProduct   *MostSoldProduct `json:"most_sold_product"`
}
