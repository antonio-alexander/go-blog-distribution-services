package main

import (
	"os"
	"os/signal"
	"strings"
	"syscall"

	internal "github.com/antonio-alexander/go-blog-distribution-services/cmd/internal"
)

func main() {
	pwd, _ := os.Getwd()
	args := os.Args[1:]
	envs := make(map[string]string)
	for _, env := range os.Environ() {
		if s := strings.Split(env, "="); len(s) > 1 {
			switch {
			case len(s) == 2:
				envs[s[0]] = s[1]
			case len(s) > 2:
				envs[s[0]] = strings.Join(s[1:], "=")
			}
		}
	}
	osSignal := make(chan os.Signal, 1)
	signal.Notify(osSignal, syscall.SIGINT, syscall.SIGTERM)
	if err := internal.Main(pwd, args, envs, osSignal); err != nil {
		os.Stderr.WriteString(err.Error())
		os.Exit(1)
	}
}
