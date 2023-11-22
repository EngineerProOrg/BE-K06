package handler

import (
	"assignment/model"
	"assignment/repository"
	"encoding/json"
	"fmt"
	"github.com/go-chi/chi/v5"
	"net/http"
)

type User struct {
	Repo repository.RedisRepo
}

func (u *User) List(
	w http.ResponseWriter,
	r *http.Request,
) {
	data, err := json.Marshal(model.Users)
	if err != nil {
		fmt.Errorf("error while encode users: %w", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Write(data)
}

func (u *User) SignIn(
	w http.ResponseWriter,
	r *http.Request) {
	var user *model.User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	session, err := u.Repo.SignIn(r.Context(), user)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	data, err := json.Marshal(session)
	if err != nil {
		fmt.Println("failed to marshal:", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Write(data)
}

func (u *User) LoginBySession(w http.ResponseWriter, r *http.Request) {
	session := chi.URLParam(r, "session")
	user, err := u.Repo.GetUserBySession(r.Context(), session)
	if err != nil {
		fmt.Println("Authenticated failed: ", err)
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	data, err := json.Marshal(user)
	if err != nil {
		fmt.Println("Failed to marshal: ", err)
		w.WriteHeader(http.StatusInternalServerError)
	}
	w.Write(data)
}

func (u *User) GetUserById(
	w http.ResponseWriter,
	r *http.Request) {
}
