package domain

// UrlRequest represents the payload for URL scanning requests.
type UrlRequest struct {
	Url   string   `json:"url"`
	Tests []string `json:"tests,omitempty"`
}

// APIResponse represents a standard response structure for API endpoints.
type APIResponse struct {
	Status string      `json:"status"`
	Data   interface{} `json:"data,omitempty"`
	Error  string      `json:"error,omitempty"`
}

// Result represents a test result.
type Result struct {
	Test   string `json:"test"`
	Result bool   `json:"result"`
}
