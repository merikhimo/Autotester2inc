package util

import (
	"context"
	"errors"
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

func (Client *AvailabilityClient) CheckSite(url string) (int, error) {
	ctx, cancel := context.WithTimeout(context.Background(), Client.client.Timeout)
	defer cancel()
	// Используем HEAD запрос для проверки доступности
	req, err := http.NewRequestWithContext(ctx, "HEAD", url, nil)
	if err != nil {
		return 0, err
	}
	resp, err := Client.client.Do(req)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 400 {
		return 0, errors.New("invalid status code")
	}
	return resp.StatusCode, nil
}
