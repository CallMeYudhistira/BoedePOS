package handler

import (
	"net/http"
	"strconv"

	"github.com/CallMeYudhistira/BoedePOS/helper"
	"github.com/CallMeYudhistira/BoedePOS/model"
	"github.com/CallMeYudhistira/BoedePOS/repository"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"gorm.io/gorm"
)

func GetAll(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		products, err := repository.GetAllProduct(db)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": nil,
			"error":   nil,
			"data":    products,
		})
	}
}

func Store(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var product model.Product

		if err := c.ShouldBindJSON(&product); err != nil {

			if ve, ok := err.(validator.ValidationErrors); ok {
				c.AbortWithStatusJSON(http.StatusUnprocessableEntity, gin.H{
					"success": false,
					"message": "Validation error.",
					"error":   helper.FormatValidationError(ve),
					"data":    nil,
				})
				return
			}

			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid request body.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		err := repository.CreateProduct(db, &product)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		response, err := repository.GetProduct(db, product.ID)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		c.JSON(http.StatusCreated, gin.H{
			"success": true,
			"message": "Product successfully created.",
			"error":   nil,
			"data":    response,
		})
	}
}

func Find(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		product, err := repository.GetProduct(db, uint(id))
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": nil,
			"error":   nil,
			"data":    product,
		})
	}
}

func Update(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var product model.Product
		id, err := strconv.Atoi(c.Param("id"))

		if err := c.ShouldBindJSON(&product); err != nil {

			if ve, ok := err.(validator.ValidationErrors); ok {
				c.AbortWithStatusJSON(http.StatusUnprocessableEntity, gin.H{
					"success": false,
					"message": "Validation error.",
					"error":   helper.FormatValidationError(ve),
					"data":    nil,
				})
				return
			}

			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid request body.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		product.ID = uint(id)
		if err := repository.UpdateProduct(db, &product); err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		response, err := repository.GetProduct(db, product.ID)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "Product successfully updated.",
			"error":   nil,
			"data":    response,
		})
	}
}

func Destroy(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		err = repository.DeleteProduct(db, uint(id))
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "Product successfully deleted.",
			"error":   nil,
			"data":    nil,
		})
	}
}
