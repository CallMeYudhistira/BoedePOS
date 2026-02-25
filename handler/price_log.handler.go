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
		var filter model.PriceLogFilter
		if err := c.ShouldBindQuery(&filter); err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid query parameters.",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		// Backward compatibility: check if ID is passed in URL
		if c.Param("id") != "" {
			productID, err := strconv.Atoi(c.Param("id"))
			if err == nil {
				filter.ProductID = uint(productID)
			}
		}

		priceLogs, err := repository.GetPriceLogs(db, filter)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false, 
				"message": "Failed to get price logs", 
				"error": err.Error(), 
				"data": nil,
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{"success": true, "message": nil, "error": nil, "data": priceLogs})
	}
}

func StorePriceLog(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {

		var priceLog model.PriceLog

		productID, err := strconv.Atoi(c.Param("id"))
		if err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid product ID",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		if err := c.ShouldBindJSON(&priceLog); err != nil {
			if ve, ok := err.(validator.ValidationErrors); ok {
				c.AbortWithStatusJSON(http.StatusUnprocessableEntity, gin.H{
					"success": false,
					"message": "Validation error",
					"error":   helper.FormatValidationError(ve),
					"data":    nil,
				})
				return
			}

			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid request body",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		priceLog.ProductID = uint(productID)

		err = repository.CheckPriceLogToday(db, priceLog.ProductID)
		if err == nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Product already has price update today",
				"error":   nil,
				"data":    nil,
			})
			return
		}
		if err != gorm.ErrRecordNotFound {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Database error",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		_, err = repository.GetProduct(db, priceLog.ProductID)
		if err != nil {
			if err == gorm.ErrRecordNotFound {
				c.AbortWithStatusJSON(http.StatusNotFound, gin.H{
					"success": false,
					"message": "Product not found.",
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

		if err := repository.StorePriceLog(db, &priceLog); err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Failed to store price log",
				"error":   err.Error(),
				"data":    nil,
			})
			return
		}

		_ = repository.FindPriceLog(db, &priceLog)
		c.JSON(http.StatusCreated, gin.H{
			"success": true,
			"message": "Price log created successfully",
			"data":    priceLog,
			"error":   nil,
		})
	}
}
