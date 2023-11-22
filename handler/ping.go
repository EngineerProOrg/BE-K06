package handler

import (
	"assignment/model"
	"assignment/repository"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/go-chi/chi/v5"
	"net/http"
)

type Ping struct {
	Repo repository.RedisRepo
}

func (p *Ping) PingEndPoint(
	w http.ResponseWriter,
	r *http.Request,
) {
	err := p.Repo.PingEntryPoint(r.Context())
	if errors.Is(err, repository.CannotPingMultiply) {
		fmt.Errorf("Cannot ping mutiply times: %w", err)
		w.WriteHeader(http.StatusAlreadyReported)
		return
	}

	var username model.User
	if err := json.NewDecoder(r.Body).Decode(&username); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	err = p.Repo.RateLimit(r.Context(), username.Username)
	if errors.Is(err, repository.RedisError) {
		fmt.Println("redis error:", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	if errors.Is(err, repository.TooManyRequest) {
		fmt.Println("Too many request:", err)
		w.WriteHeader(http.StatusTooManyRequests)
		return
	}

	err = p.Repo.CountPing(r.Context(), username.Username)
	if err != nil {
		fmt.Println("failed to count:", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	data, err := json.Marshal("Ping successfully!")
	if err != nil {
		fmt.Println("failed to marshal:", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Write(data)
}

func (p *Ping) GetTopTenCount(
	w http.ResponseWriter,
	r *http.Request,
) {
	topTen, err := p.Repo.GetTopCount(r.Context())
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	data, err := json.Marshal(topTen)
	if err != nil {
		fmt.Println("failed to marshal:", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Write(data)
}

func (p *Ping) GetPingCount(
	w http.ResponseWriter,
	r *http.Request,
) {
	username := chi.URLParam(r, "username")
	count, err := p.Repo.GetPingCount(r.Context(), username)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	if len(count) != 1 {
		w.WriteHeader(http.StatusNotFound)
		return
	}

	data, err := json.Marshal(count)
	if err != nil {
		fmt.Println("failed to marshal:", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Write(data)
}
