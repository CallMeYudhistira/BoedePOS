package helper

import (
	"os"
	"time"
)

var Locale *time.Location

func LoadLocale() error {
	loc, err := time.LoadLocation(os.Getenv("LOCALE"))
	if err != nil {
		return err
	}
	Locale = loc
	return nil
}

func NowLocale() time.Time {
	return time.Now().In(Locale)
}