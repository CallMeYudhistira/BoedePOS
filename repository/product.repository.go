package repository

import (
	"database/sql"

	"github.com/CallMeYudhistira/BoedePOS/model"
)

func CreateProduct(db *sql.DB, product model.Product) (error, *int) {
	var lastId int

	sqlStatement := `
		INSERT INTO products (name, price)
		VALUES ($1, $2) RETURNING id
	`
	err := db.QueryRow(sqlStatement, product.Name, product.Price).Scan(&lastId)
	if err != nil {
		return err, nil
	}

	return nil, &lastId
}

func GetProduct(db *sql.DB, productId int) (model.Product, error) {
	var product model.Product

	sqlStatement := `
		SELECT * FROM products
		WHERE id = $1 LIMIT 1
	`

	err := db.QueryRow(sqlStatement, productId).Scan(&product.ID, &product.Name, &product.Price, &product.Created_at)
	if err != nil {
		return product, err
	}

	return product, nil
}

func GetAllProduct(db *sql.DB) ([]model.Product, error) {
	result := []model.Product{}
	sqlStatement := `SELECT * FROM products`

	rows, err := db.Query(sqlStatement)
	if err != nil {
		return nil, err
	}

	for rows.Next() {
		var product model.Product

		err = rows.Scan(&product.ID, &product.Name, &product.Price, &product.Created_at)
		if err != nil {
			return nil, err
		}

		result = append(result, product)
	}

	return result, nil
}

func Updateproduct(db *sql.DB, product model.Product) error {
	sqlStatement := `
		UPDATE products SET name = $1, price = $2
		WHERE id = $3
	`

	_, err := db.Exec(sqlStatement, product.Name, product.Price, product.ID)

	return err
}

func Deleteproduct(db *sql.DB, productId int) error {
	sqlStatement := `
		DELETE FROM products
		WHERE id = $1
	`

	_, err := db.Exec(sqlStatement, productId)

	return err
}
