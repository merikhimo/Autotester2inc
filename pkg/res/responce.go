package res

import (
	"Autotester/internal/domain"
	"encoding/json"
	"net/http"
)

func JSONResponce(w http.ResponseWriter, resp domain.APIResponse, statusCode int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(resp)
}

func ErrorResponce(w http.ResponseWriter, errMsg string, statusCode int) {
	resp := domain.APIResponse{
		Status: "error",
		Error:  errMsg,
	}
	JSONResponce(w, resp, statusCode)
}
