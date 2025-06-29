package handlers

import (
	"Autotester/configs"
	"Autotester/pkg/res"
	"bytes"
	"io"
	"net/http"
)

// TestsHandler handles /api/tests requests.
type TestsHandler struct {
	*configs.Config
	PostFunc func(url, contentType string, body io.Reader) (*http.Response, error)
}

// NewTestsHandler returns a new TestsHandler.
func NewTestsHandler(config *configs.Config) *TestsHandler {
	return &TestsHandler{
		Config:   config,
		PostFunc: http.Post, // default function
	}
}

// Tests handles the /api/tests endpoint.
func (h *TestsHandler) Tests(w http.ResponseWriter, req *http.Request) {
	body, err := io.ReadAll(req.Body)
	if err != nil {
		res.ErrorResponce(w, "Failed to read request body: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer req.Body.Close()

	resp, err := h.PostFunc(
		h.Config.PythonPath+"/run",
		"application/json",
		bytes.NewBuffer(body),
	)
	if err != nil {
		res.ErrorResponce(w, "Failed to forward request: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
}
