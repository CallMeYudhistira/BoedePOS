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

func GetAllTransaction(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var filter model.DateFilter
		if err := c.ShouldBindQuery(&filter); err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid query parameters.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		transactions, err := repository.GetAllTransaction(db, filter)
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
			"data":    transactions,
		})
	}
}

func StoreTransaction(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {

		var req model.TransactionRequest

		if err := c.ShouldBindJSON(&req); err != nil {
			if ve, ok := err.(validator.ValidationErrors); ok {
				c.JSON(http.StatusUnprocessableEntity, gin.H{
					"success": false,
					"message": "Validation error",
					"error":   helper.FormatValidationError(ve),
					"data":    nil,
				})
				return
			}

			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid request body.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		transaction, err := repository.CreateTransaction(db, &req)
		if err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{
					"success": false,
					"message": "Product not found.",
					"error":   err.Error(),
					"data":    nil,
				})
				return
			}

			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		result, _ := repository.FindTransaction(db, transaction.ID)

		c.JSON(http.StatusCreated, gin.H{
			"success": true,
			"message": "Transaction successfully created.",
			"error":   nil,
			"data":    result,
		})
	}
}

func FindTransaction(db *gorm.DB) gin.HandlerFunc {
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

		transaction, err := repository.FindTransaction(db, uint(id))
		if err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{
					"success": false,
					"message": "Transaction not found.",
					"error":   err.Error(),
					"data":    nil,
				})
				return
			}

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
			"data":    transaction,
		})
	}
}

func DestroyTransaction(db *gorm.DB) gin.HandlerFunc {
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

		_, err = repository.FindTransaction(db, uint(id))
		if err != nil {
			if err == gorm.ErrRecordNotFound {
				c.JSON(http.StatusNotFound, gin.H{
					"success": false,
					"message": "Transaction not found.",
					"error":   err.Error(),
					"data":    nil,
				})
				return
			}

			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Internal server error.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		err = repository.DeleteTransaction(db, uint(id))
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
			"message": "Transaction successfully deleted.",
			"error":   nil,
			"data":    nil,
		})
	}
}

func GetSalesReport(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var filter model.DateFilter
		if err := c.ShouldBindQuery(&filter); err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid query parameters.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		report, err := repository.GetSalesReport(db, filter)
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
			"data":    report,
		})
	}
}
