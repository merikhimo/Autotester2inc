package routes

import (
	"Autotester/configs"
	"Autotester/internal/handlers"
	"net/http"
)

type RoutesHandlerDeps struct {
	Config *configs.Config
}

func RegisterRoutes(router *http.ServeMux, config *configs.Config) {
	scanHandler := handlers.NewCheckUrlHandler(config)
	testsHandler := handlers.NewTestsHandler(config)
	resultsHandler := handlers.NewResultHandler(config)

	router.HandleFunc("POST /api/checkurl", scanHandler.Check)
	router.HandleFunc("POST /api/tests", testsHandler.Tests)
	router.HandleFunc("POST /api/results", resultsHandler.Results)
	router.HandleFunc("GET /api/ping", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("pong"))
	})
}
