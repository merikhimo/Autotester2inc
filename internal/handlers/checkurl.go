package handlers

import (
	"Autotester/configs"
	"Autotester/internal/cookies"
	"Autotester/internal/domain"
	"Autotester/internal/util"
	"Autotester/pkg/res"
	"encoding/json"
	"io"
	"net/http"
)

type SiteChecker interface {
	CheckSite(url string) bool
}

type CheckUrlHandler struct {
	*configs.Config
	SiteChecker SiteChecker
}

func NewCheckUrlHandler(config *configs.Config) *CheckUrlHandler {
	return &CheckUrlHandler{
		Config:      config,
		SiteChecker: util.NewAvailabilityClient(config.Timeout),
	}
}

func (h *CheckUrlHandler) Check(w http.ResponseWriter, req *http.Request) {
	var payload domain.UrlRequest
	body, err := io.ReadAll(req.Body)
	if err != nil {
		res.ErrorResponce(w, "Failed to read request body: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer req.Body.Close()

	if err := json.Unmarshal(body, &payload); err != nil {
		res.ErrorResponce(w, "Failed to parse JSON: "+err.Error(), http.StatusBadRequest)
		return
	}
	if err := util.ValidateUrl(&payload.Url); err != nil {
		res.ErrorResponce(w, err.Error(), http.StatusBadRequest)
		return
	}
	if !h.SiteChecker.CheckSite(payload.Url) {
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
	res.JSONResponce(w, resp, http.StatusOK)
	return
}
