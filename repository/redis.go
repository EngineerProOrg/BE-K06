package repository

import (
	"assignment/model"
	"context"
	"errors"
	"fmt"
	"github.com/bsm/redislock"
	"github.com/go-redis/redis_rate/v10"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"slices"
	"time"
)

type RedisRepo struct {
	Client *redis.Client
}

var UserIsNotExist = errors.New("user is not exist")

func (r *RedisRepo) SignIn(ctx context.Context, user *model.User) (string, error) {
	index := slices.IndexFunc(model.Users, func(u model.User) bool {
		return user.Password == u.Password && user.Username == u.Username
	})
	if index == -1 {
		return "", UserIsNotExist
	}
	session := uuid.NewString()
	_, err := r.Client.SetNX(ctx, session, model.Users[index].Username, 600*time.Second).Result()

	if err != nil {
		return "", fmt.Errorf("failed to set: %w", err)
	}
	return session, nil
}

var CannotPingMultiply = errors.New("cannot ping multiply times")

func (r *RedisRepo) PingEntryPoint(ctx context.Context) error {
	redisLocker := redislock.New(r.Client)
	lock, err := redisLocker.Obtain(ctx, "ping-api", 10*time.Second, nil)
	if errors.Is(err, redislock.ErrNotObtained) {
		return CannotPingMultiply
	}
	//r.Client.PFAdd(ctx)
	defer lock.Release(ctx)

	time.Sleep(5 * time.Second)
	return nil
}

var RedisError = errors.New("Redis server is wrong")
var TooManyRequest = errors.New("Two many request")

func (r *RedisRepo) RateLimit(ctx context.Context, username string) error {
	limiter := redis_rate.NewLimiter(r.Client)
	res, err := limiter.Allow(ctx, username, redis_rate.PerMinute(2))
	if err != nil {
		return RedisError
	}

	if res.Allowed == 0 {
		return TooManyRequest
	}
	return nil
}

func (r *RedisRepo) CountPing(ctx context.Context, username string) error {
	err := r.Client.ZIncrBy(ctx, "ping_counter", 1, username).Err()
	return err
}

func (r *RedisRepo) GetPingCount(ctx context.Context, username string) ([]float64, error) {
	count, err := r.Client.ZMScore(ctx, "ping_counter", username).Result()
	return count, err
}

func (r *RedisRepo) GetTopCount(ctx context.Context) ([]redis.Z, error) {
	usernames, err := r.Client.ZRevRangeWithScores(ctx, "ping_counter", 0, 10).Result()
	return usernames, err
}

func (r *RedisRepo) GetUserBySession(ctx context.Context, session string) (model.User, error) {
	value, err := r.Client.Get(ctx, session).Result()
	if errors.Is(err, redis.Nil) {
		return model.User{}, UserIsNotExist
	} else if err != nil {
		return model.User{}, fmt.Errorf("get user: %w", err)
	}

	index := slices.IndexFunc(model.Users, func(u model.User) bool {
		return value == u.Username
	})
	user := model.Users[index]
	return user, nil
}

type FindAllPages struct {
	Size   uint
	Offset uint
}

func (r *RedisRepo) List(ctx context.Context) ([]model.User, error) {
	return model.Users, nil
}
