package util

import (
	"log"
	"net/http"
	"time"
)

type AvailabilityClient struct {
	client *http.Client
}

func NewAvailabilityClient(timeout time.Duration) *AvailabilityClient {
	return &AvailabilityClient{
		client: &http.Client{
			Timeout: timeout},
	}
}

func (ac *AvailabilityClient) CheckSite(url string) bool {
	req, err := http.NewRequest("GET", url, nil)
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
	if resp.StatusCode >= 200 && resp.StatusCode < 400 {
		log.Printf("Site %s is available", url)
		return true
	} else {
		log.Printf("Site %s returned status code %d", url, resp.StatusCode)
		return false
	}
}
