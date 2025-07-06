package tests

import (
	"Autotester/configs"
	"Autotester/internal/handlers"
	"bytes"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

type alwaysAvailableChecker struct{}

func (a *alwaysAvailableChecker) CheckSite(_ string) bool { return true }

func setupRouterWithMockChecker() *http.ServeMux {
	cfg := &configs.Config{
		Timeout:    2,
		PythonPath: "http://localhost:8000",
	}
	router := http.NewServeMux()

	// /api/checkurl
	checkHandler := handlers.NewCheckUrlHandler(cfg)
	checkHandler.SiteChecker = &alwaysAvailableChecker{}
	router.HandleFunc("/api/checkurl", checkHandler.Check)

	// /api/tests
	testsHandler := handlers.NewTestsHandler(cfg)
	testsHandler.PostFunc = func(url, contentType string, body io.Reader) (*http.Response, error) {
		
		return &http.Response{
			StatusCode: 200,
			Body:       io.NopCloser(bytes.NewBufferString(`{"status":"ok"}`)),
		}, nil
	}
	router.HandleFunc("/api/tests", testsHandler.Tests)

	// /api/results
	resultsHandler := handlers.NewResultHandler(cfg)
	router.HandleFunc("/api/results", resultsHandler.Results)

	return router
}

func TestIntegration_CheckUrl_Success(t *testing.T) {
	router := setupRouterWithMockChecker()
	payload := `{"url": "https://example.com"}`
	req := httptest.NewRequest(http.MethodPost, "/api/checkurl", bytes.NewBufferString(payload))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

func TestIntegration_CheckUrl_InvalidJSON(t *testing.T) {
	router := setupRouterWithMockChecker()
	req := httptest.NewRequest(http.MethodPost, "/api/checkurl", bytes.NewBufferString("not-json"))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

func TestIntegration_TestsEndpoint(t *testing.T) {
	router := setupRouterWithMockChecker()
	payload := `{"url": "https://example.com", "tests": ["test1", "test2"]}`
	req := httptest.NewRequest(http.MethodPost, "/api/tests", bytes.NewBufferString(payload))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
}

func TestIntegration_ResultsEndpoint_BadJSON(t *testing.T) {
	router := setupRouterWithMockChecker()
	req := httptest.NewRequest(http.MethodPost, "/api/results", bytes.NewBufferString("not-json"))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

func TestIntegration_CheckUrl_SetsCookie(t *testing.T) {
	router := setupRouterWithMockChecker()
	payload := `{"url": "https://example.com"}`
	req := httptest.NewRequest(http.MethodPost, "/api/checkurl", bytes.NewBufferString(payload))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	found := false
	for _, c := range w.Result().Cookies() {
		if c.Name == "instructions_shown" && c.Value == "true" {
			found = true
		}
	}
	if !found {
		t.Error("expected cookie 'instructions_shown=true' to be set")
	}
}
