package handlers

import (
	"Autotester/configs"
	"Autotester/internal/domain"
	"Autotester/pkg/res"
	"encoding/json"
	"io"
	"net/http"
)

type ResultHandler struct {
	*configs.Config
}

func NewResultHandler(config *configs.Config) *ResultHandler {
	return &ResultHandler{Config: config}
}

func (h *ResultHandler) Results(w http.ResponseWriter, req *http.Request) {
	// Читаем результаты тестов из тела запроса
	body, err := io.ReadAll(req.Body)
	if err != nil {
		res.ErrorResponce(w, "Failed to read request body: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer req.Body.Close()

	// Парсим результаты в нашу структуру
	var results []domain.Result
	if err := json.Unmarshal(body, &results); err != nil {
		res.ErrorResponce(w, "Failed to parse results: "+err.Error(), http.StatusBadRequest)
		return
	}

	// Формируем ответ в стандартном формате
	resp := domain.APIResponse{
		Status: "success",
		Data:   results,
	}

	// Отправляем ответ
	res.JSONResponce(w, resp, http.StatusOK)
}
