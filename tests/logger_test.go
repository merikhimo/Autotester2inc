package tests

import (
	"Autotester/internal/middleware"
	"bytes"
	"log"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestLoggerMiddleware(t *testing.T) {
	var buf bytes.Buffer
	log.SetOutput(&buf)
	defer log.SetOutput(nil)

	called := false
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
	})

	req := httptest.NewRequest("GET", "/test", nil)
	w := httptest.NewRecorder()

	mw := middleware.Logger(handler)
	mw.ServeHTTP(w, req)

	if !called {
		t.Error("next handler was not called")
	}
	logged := buf.String()
	if !strings.Contains(logged, "Started GET /test") || !strings.Contains(logged, "Completed in") {
		t.Error("logger did not log expected output")
	}
}
