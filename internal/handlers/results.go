package handlers

import (
	"Autotester/configs"
	"Autotester/internal/domain"
	"Autotester/pkg/res"
	"encoding/json"
	"io"
	"net/http"
)

// ResultHandler handles /api/results requests.
type ResultHandler struct {
	*configs.Config
}

// NewResultHandler returns a new ResultHandler.
func NewResultHandler(config *configs.Config) *ResultHandler {
	return &ResultHandler{Config: config}
}

// Results handles the /api/results endpoint.
func (h *ResultHandler) Results(w http.ResponseWriter, req *http.Request) {
	body, err := io.ReadAll(req.Body)
	if err != nil {
		res.ErrorResponce(w, "Failed to read request body: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer req.Body.Close()

	var results []domain.Result
	if err := json.Unmarshal(body, &results); err != nil {
		res.ErrorResponce(w, "Failed to parse results: "+err.Error(), http.StatusBadRequest)
		return
	}

	resp := domain.APIResponse{
		Status: "success",
		Data:   results,
	}

	res.JSONResponce(w, resp, http.StatusOK)
}
