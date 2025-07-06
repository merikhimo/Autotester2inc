package handlers

import (
	"Autotester/configs"
	"Autotester/internal/cookies"
	"Autotester/internal/domain"
	"Autotester/internal/util"
	"Autotester/pkg/res"
	"encoding/json"
	"io"
	"log"
	"net/http"
)

// SiteChecker defines the interface for checking site availability.
type SiteChecker interface {
	CheckSite(url string) bool
}

// CheckUrlHandler handles /api/checkurl requests.
type CheckUrlHandler struct {
	*configs.Config
	SiteChecker SiteChecker
}

// NewCheckUrlHandler returns a new CheckUrlHandler.
func NewCheckUrlHandler(config *configs.Config) *CheckUrlHandler {
	return &CheckUrlHandler{
		Config:      config,
		SiteChecker: util.NewAvailabilityClient(config.Timeout),
	}
}

// Check handles the /api/checkurl endpoint.
func (h *CheckUrlHandler) Check(w http.ResponseWriter, req *http.Request) {
	log.Println("Received /api/checkurl request")
	var payload domain.UrlRequest
	body, err := io.ReadAll(req.Body)
	if err != nil {
		log.Println("Failed to read request body:", err)
		res.ErrorResponce(w, "Failed to read request body: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer req.Body.Close()

	if err := json.Unmarshal(body, &payload); err != nil {
		log.Println("Failed to parse JSON:", err)
		res.ErrorResponce(w, "Failed to parse JSON: "+err.Error(), http.StatusBadRequest)
		return
	}
	if err := util.ValidateUrl(&payload.Url); err != nil {
		log.Println("URL validation failed:", err)
		res.ErrorResponce(w, err.Error(), http.StatusBadRequest)
		return
	}
	if !h.SiteChecker.CheckSite(payload.Url) {
		log.Println("Site is not available:", payload.Url)
		res.ErrorResponce(w, "Site is not available", http.StatusBadRequest)
		return
	}
	cookies.SetCookieHandler(w, "instructions_shown", "true", 60*60*24*7)
	resp := domain.APIResponse{
		Status: "success",
		Data: map[string]interface{}{
			"url":             payload.Url,
			"ready_for_tests": true,
		},
	}
	log.Println("Successfully processed /api/checkurl request")
	res.JSONResponce(w, resp, http.StatusOK)
}
