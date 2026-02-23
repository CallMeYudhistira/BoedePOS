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

func GetPriceLogs(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, err := strconv.Atoi(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid product ID", "error": err.Error()})
			return
		}

		priceLogs, err := repository.GetPriceLogs(db, uint(id))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to get price logs", "error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{"success": true, "message": nil, "data": priceLogs})
	}
}

func StorePriceLog(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var priceLog model.PriceLog
		productID, err := strconv.Atoi(c.Param("id"))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid product ID", "error": err.Error()})
			return
		}

		if err := c.ShouldBindJSON(&priceLog); err != nil {
			if ve, ok := err.(validator.ValidationErrors); ok {
				c.JSON(http.StatusUnprocessableEntity, gin.H{
					"success": false,
					"message": "Validation error",
					"error":   helper.FormatValidationError(ve),
				})
				return
			}

			c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request body", "error": err.Error()})
			return
		}

		priceLog.ProductID = uint(productID)

		if err := repository.StorePriceLog(db, &priceLog); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to store price log", "error": err.Error()})
			return
		}

		db.Preload("Product").First(&priceLog, priceLog.ID)

		c.JSON(http.StatusCreated, gin.H{
			"success": true,
			"message": "Price log created successfully",
			"data":    priceLog,
		})
	}
}
