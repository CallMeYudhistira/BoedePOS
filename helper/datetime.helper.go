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

func GetPeriodRange(period string) (time.Time, time.Time) {
	now := NowLocale()
	var start, end time.Time

	switch period {
	case "daily":
		start = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, Locale)
		end = start.AddDate(0, 0, 1).Add(-time.Nanosecond)
	case "weekly":
		// Start of week (Monday)
		daysSinceMonday := int(now.Weekday()) - 1
		if daysSinceMonday < 0 {
			daysSinceMonday = 6 // Sunday
		}
		start = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, Locale).AddDate(0, 0, -daysSinceMonday)
		end = start.AddDate(0, 0, 7).Add(-time.Nanosecond)
	case "monthly":
		start = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, Locale)
		end = start.AddDate(0, 1, 0).Add(-time.Nanosecond)
	case "yearly":
		start = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, Locale)
		end = start.AddDate(1, 0, 0).Add(-time.Nanosecond)
	default:
		return time.Time{}, time.Time{}
	}

	return start, end
}
