package handlers

import (
	"Autotester/configs"
	"Autotester/pkg/res"
	"bytes"
	"io"
	"net/http"
)

type TestsHandler struct {
	*configs.Config
}

func NewTestsHandler(config *configs.Config) *TestsHandler {
	return &TestsHandler{Config: config}
}

func (h *TestsHandler) Tests(w http.ResponseWriter, req *http.Request) {
	// Читаем тело входящего запроса
	body, err := io.ReadAll(req.Body)
	if err != nil {
		res.ErrorResponce(w, "Failed to read request body: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer req.Body.Close()

	// Отправляем тот же JSON на другой API
	resp, err := http.Post(
		h.Config.PythonPath,
		"application/json",
		bytes.NewBuffer(body),
	)
	if err != nil {
		res.ErrorResponce(w, "Failed to forward request: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
}
