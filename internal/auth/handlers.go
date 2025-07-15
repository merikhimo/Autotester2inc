package auth

import (
	"encoding/json"
	"net/http"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"time"
)

type AuthHandler struct {
	db        *gorm.DB
	jwtSecret string
}

func (h *AuthHandler) Migrate() error {
	return h.db.AutoMigrate(&User{})
}

func NewAuthHandler(db *gorm.DB, jwtSecret string) *AuthHandler {
	return &AuthHandler{db: db, jwtSecret: jwtSecret}
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	// 1. Decode JSON body
	var req RegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error": "Invalid request body"}`, http.StatusBadRequest)
		return
	}

	// 2. Validate input
	if req.Email == "" || len(req.Password) < 8 {
		http.Error(w, `{"error": "Email and password (min 8 chars) required"}`, http.StatusBadRequest)
		return
	}

	// 3. Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, `{"error": "Failed to hash password"}`, http.StatusInternalServerError)
		return
	}

	// 4. Create user
	user := User{
		Email:        req.Email,
		PasswordHash: string(hashedPassword),
	}

	if err := h.db.Create(&user).Error; err != nil {
		http.Error(w, `{"error": "Email already exists"}`, http.StatusConflict)
		return
	}

	// 5. Generate token
	token, err := h.generateJWT(user.ID)
	if err != nil {
		http.Error(w, `{"error": "Failed to generate token"}`, http.StatusInternalServerError)
		return
	}

	// 6. Return response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(TokenResponse{Token: token})
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	// 1. Decode JSON body
	var req LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, `{"error": "Invalid request body"}`, http.StatusBadRequest)
		return
	}

	// 2. Find user
	var user User
	if err := h.db.Where("email = ?", req.Email).First(&user).Error; err != nil {
		http.Error(w, `{"error": "Invalid credentials"}`, http.StatusUnauthorized)
		return
	}

	// 3. Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		http.Error(w, `{"error": "Invalid credentials"}`, http.StatusUnauthorized)
		return
	}

	// 4. Generate token
	token, err := h.generateJWT(user.ID)
	if err != nil {
		http.Error(w, `{"error": "Failed to generate token"}`, http.StatusInternalServerError)
		return
	}

	// 5. Return response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(TokenResponse{Token: token})
}
// Added JWT generation method
func (h *AuthHandler) generateJWT(userID uint) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": userID,
		"exp": time.Now().Add(time.Hour * 24).Unix(),
	})
	return token.SignedString([]byte(h.jwtSecret))
}