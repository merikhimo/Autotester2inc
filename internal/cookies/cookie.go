package cookies

import (
	"errors"
	"log"
	"net/http"
)

func SetCookieHandler(w http.ResponseWriter, name, value string, maxAge int) {
	cookie := &http.Cookie{
		Name:     name,
		Value:    value,
		MaxAge:   maxAge,
		HttpOnly: false,
		SameSite: http.SameSiteLaxMode,
	}
	http.SetCookie(w, cookie)
}
func GetCookie(r *http.Request, name string) (*http.Cookie, error) {
	cookie, err := r.Cookie(name)
	if err != nil {
		switch {
		case errors.Is(err, http.ErrNoCookie):
			log.Println("cookie not found")
		default:
			log.Println("server error:", err)
		}
		return nil, err
	}
	return cookie, nil
}
