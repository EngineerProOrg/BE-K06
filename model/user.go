package model

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

var Users = []User{
	{Username: "user", Password: "123456"},
	{Username: "admin", Password: "admin"},
}
