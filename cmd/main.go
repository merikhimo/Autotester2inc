package main

import (
	"Autotester/configs"
	"Autotester/internal/auth"
	"Autotester/internal/database"
	"Autotester/internal/routes"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	config := configs.LoadConfig()
	
	// Initialize database
	db, err := database.NewDB(
		config.DBHost,
		config.DBPort,
		config.DBUser,
		config.DBPassword,
		config.DBName,
	)
	if err != nil {
		log.Fatal("Database connection failed: ", err)
	}

	// Auto-migrate models
	db.AutoMigrate(&auth.User{})

	// Create router
	router := mux.NewRouter()

	// Setup routes
	deps := &routes.RoutesHandlerDeps{
		Config: config,
		DB:     db,
	}
	routes.SetupAuthRoutes(router, deps)

	// Start server
	log.Println("Server starting on :8081")
	log.Fatal(http.ListenAndServe(":8081", router))
}