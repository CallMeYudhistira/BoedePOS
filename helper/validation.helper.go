package helper

import (
	"fmt"
	"unicode"

	"github.com/go-playground/validator/v10"
)

func lowerFirst(s string) string {
	if s == "" {
		return s
	}
	runes := []rune(s)
	runes[0] = unicode.ToLower(runes[0])
	return string(runes)
}

func FormatValidationError(err error) map[string]string {
	errors := make(map[string]string)

	for _, e := range err.(validator.ValidationErrors) {
		field := lowerFirst(e.Field())

		switch e.Tag() {
		case "required":
			errors[field] = fmt.Sprintf("%s wajib diisi.", field)

		case "min":
			errors[field] = fmt.Sprintf(
				"%s setidaknya harus bernilai %s atau lebih.",
				field,
				e.Param(),
			)

		case "max":
			errors[field] = fmt.Sprintf(
				"%s tidak boleh bernilai lebih dari %s.",
				field,
				e.Param(),
			)

		case "number":
			errors[field] = fmt.Sprintf(
				"%s harus bernilai angka.",
				field,
			)

		default:
			errors[field] = fmt.Sprintf("%s is invalid", field)
		}
	}

	return errors
}
