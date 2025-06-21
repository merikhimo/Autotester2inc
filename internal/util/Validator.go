package util

import (
	"errors"
	"net/url"
	"strings"
)

func ValidateUrl(link *string) error {
	if link == nil || *link == "" {
		return errors.New("url cannot be empty")
	}
	if !strings.HasPrefix(*link, "http://") && !strings.HasPrefix(*link, "https://") {
		return errors.New("url does not start with http:// or https://")
	}
	parsed, err := url.ParseRequestURI(*link)
	if err != nil {
		return errors.New("wrong url format")
	}
	if parsed.Host == "" || !strings.Contains(parsed.Host, ".") {
		return errors.New("url must have a hostname")
	}
	return nil
}

//Написать проверку, существует ли сайт
