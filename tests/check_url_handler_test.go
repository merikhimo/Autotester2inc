package tests

import (
	"Autotester/configs"
	"Autotester/internal/handlers"
	"Autotester/internal/util"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

type mockSiteChecker struct {
	result bool
}

func (m *mockSiteChecker) CheckSite(_ string) bool {
	return m.result
}

func setupHandler(siteAvailable bool) *handlers.CheckUrlHandler {
	cfg := &configs.Config{Timeout: 1}
	h := handlers.NewCheckUrlHandler(cfg)
	h.SiteChecker = &mockSiteChecker{result: siteAvailable}
	return h
}

func TestCheck_InvalidJSON(t *testing.T) {
	handler := setupHandler(true)
	req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString("not-json"))
	w := httptest.NewRecorder()
	handler.Check(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

func TestCheck_InvalidURL(t *testing.T) {
	handler := setupHandler(true)
	payload := `{"url": "ftp://invalid"}`
	req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(payload))
	w := httptest.NewRecorder()
	handler.Check(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

func TestCheck_SiteUnavailable(t *testing.T) {
	handler := setupHandler(false)
	payload := `{"url": "https://example.com"}`
	req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(payload))
	w := httptest.NewRecorder()
	handler.Check(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}

func TestCheck_Success(t *testing.T) {
	handler := setupHandler(true)
	payload := `{"url": "https://example.com"}`
	req := httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(payload))
	w := httptest.NewRecorder()
	handler.Check(w, req)
	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}
	
	found := false
	for _, c := range w.Result().Cookies() {
		if c.Name == "instructions_shown" && c.Value == "true" {
			found = true
		}
	}
	if !found {
		t.Error("expected cookie 'instructions_shown=true' to be set")
	}
	
	var resp map[string]interface{}
	if err := json.NewDecoder(w.Body).Decode(&resp); err != nil {
		t.Error("invalid json in response")
	}
}
func TestAvailabilityClient_CheckSite_InvalidURL(t *testing.T) {
	client := util.NewAvailabilityClient(1 * time.Second)
	ok := client.CheckSite("http://invalid.invalid")
	if ok {
		t.Error("expected false for invalid site")
	}
}
