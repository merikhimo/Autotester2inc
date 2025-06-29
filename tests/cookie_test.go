package tests

import (
	"Autotester/internal/cookies"
	"net/http/httptest"
	"testing"
)

func TestSetCookieHandler(t *testing.T) {
	w := httptest.NewRecorder()
	cookies.SetCookieHandler(w, "test", "val", 60)
	result := w.Result()
	c := result.Cookies()
	if len(c) == 0 || c[0].Name != "test" || c[0].Value != "val" {
		t.Error("cookie not set correctly")
	}
}

func TestGetCookie_NotFound(t *testing.T) {
	r := httptest.NewRequest("GET", "/", nil)
	_, err := cookies.GetCookie(r, "notfound")
	if err == nil {
		t.Error("expected error for missing cookie")
	}
}
