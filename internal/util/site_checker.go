package util

import (
	"log"
	"net/http"
	"time"
)

// AvailabilityClient checks site availability.
type AvailabilityClient struct {
	client *http.Client
}

// NewAvailabilityClient returns a new AvailabilityClient with timeout.
func NewAvailabilityClient(timeout time.Duration) *AvailabilityClient {
	return &AvailabilityClient{
		client: &http.Client{
			Timeout: timeout,
		},
	}
}

// CheckSite checks if the site is available.
func (ac *AvailabilityClient) CheckSite(url string) bool {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		log.Printf("Error creating request for %s: %v", url, err)
		return false
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
	resp, err := ac.client.Do(req)
	if err != nil {
		log.Printf("Error checking site %s: %v", url, err)
		return false
	}
	defer resp.Body.Close()
	if resp.StatusCode >= http.StatusOK && resp.StatusCode < http.StatusBadRequest {
		log.Printf("Site %s is available", url)
		return true
	}
	log.Printf("Site %s returned status code %d", url, resp.StatusCode)
	return false
}
