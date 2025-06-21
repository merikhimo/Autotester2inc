package domain

// UrlRequest represents the payload for URL scanning requests.
type UrlRequest struct {
	Url   string   `json:"url"`
	Tests []string `json:"tests,omitempty"` // Array of test names to be performed
}

// APIResponse represents a standard response structure for API endpoints.
type APIResponse struct {
	Status string      `json:"status"`
	Data   interface{} `json:"data,omitempty"`
	Error  string      `json:"error,omitempty"`
}

type Result struct {
	Test   string `json:"test"`   // Name of the test performed
	Result bool   `json:"result"` // Result of the test (true/false)
}
