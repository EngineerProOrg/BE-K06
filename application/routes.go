package application

import (
	"assignment/handler"
	"assignment/repository"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"net/http"
)

func (a *App) loadRoutes() {
	router := chi.NewRouter()
	router.Use(middleware.Logger)

	router.Get("/", func(w http.ResponseWriter, request *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	router.Route("/users", a.loadUserRoutes)
	router.Route("/pings", a.loadPingRoutes)
	a.router = router
}

func (a *App) loadPingRoutes(route chi.Router) {
	pingHandler := &handler.Ping{
		Repo: repository.RedisRepo{
			Client: a.rbd,
		}}
	route.Post("/", pingHandler.PingEndPoint)
	route.Get("/top_ten", pingHandler.GetTopTenCount)
	route.Get("/{username}", pingHandler.GetPingCount)
}

func (a *App) loadUserRoutes(route chi.Router) {
	userHandler := &handler.User{
		Repo: repository.RedisRepo{
			Client: a.rbd,
		}}

	route.Post("/", userHandler.SignIn)
	route.Get("/", userHandler.List)
	route.Get("/user/{username}", userHandler.GetUserById)
	route.Get("/session/{session}", userHandler.LoginBySession)
}
