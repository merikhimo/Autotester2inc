package handlers

import (
	"Autotester/configs"
	"Autotester/internal/domain"
	"Autotester/internal/util"
	"Autotester/pkg/res"
	"encoding/json"
	"io"
	"net/http"
)

type CheckUrlHandler struct {
	*configs.Config
}

func NewCheckUrlHandler(config *configs.Config) *CheckUrlHandler {
	return &CheckUrlHandler{Config: config}
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
	if _, err := util.NewAvailabilityClient(h.Config.Timeout).CheckSite(payload.Url); err != nil {
		res.ErrorResponce(w, "Site is not available or returned an invalid status code: "+err.Error(), http.StatusBadRequest)
		return
	}
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
