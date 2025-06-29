package res

import (
	"Autotester/internal/domain"
	"encoding/json"
	"net/http"
)

// JSONResponce writes a JSON response with the given status code.
func JSONResponce(w http.ResponseWriter, resp domain.APIResponse, statusCode int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, "failed to encode response", http.StatusInternalServerError)
	}
}

// ErrorResponce writes an error response with the given message and status code.
func ErrorResponce(w http.ResponseWriter, errMsg string, statusCode int) {
	resp := domain.APIResponse{
		Status: "error",
		Error:  errMsg,
	}
	JSONResponce(w, resp, statusCode)
}
