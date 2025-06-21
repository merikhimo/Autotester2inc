package main

import (
	"Autotester/configs"
	"Autotester/internal/middleware"
	"Autotester/internal/routes"
	"fmt"
	"net/http"
)

func main() {
	config := configs.LoadConfig()

	router := http.NewServeMux()

	routes.RegisterRoutes(router, config)
	wrapped := middleware.Recovery(middleware.Logger(middleware.CORS(router)))

	server := http.Server{
		Addr:    ":8081",
		Handler: wrapped,
	}
	fmt.Println("The server is listening on 8081")
	err := server.ListenAndServe()
	if err != nil {
		return
	}
}
