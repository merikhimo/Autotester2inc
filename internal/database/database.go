package database

import (
	"fmt"
	"log"
	"time"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func NewDB(host, port, user, password, dbname string) (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=UTC",
		host, user, password, dbname, port)

	var db *gorm.DB
	var err error

	for i := 0; i < 5; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
		if err == nil {
			break
		}
		log.Printf("Retrying DB connection... (Attempt %d)", i+1)
		time.Sleep(2 * time.Second)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %v", err)
	}

	sqlDB, _ := db.DB()
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)

	log.Println("Database connection established")
	return db, nil
}