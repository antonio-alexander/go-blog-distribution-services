package internal

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"sync"
)

func Main(pwd string, args []string, envs map[string]string, osSignal chan os.Signal) error {
	var httpAddress, httpPort string
	var wg sync.WaitGroup
	var err error

	//get address/port from args
	cli := flag.NewFlagSet("", flag.ContinueOnError)
	cli.StringVar(&httpAddress, "address", "", "http address")
	cli.StringVar(&httpPort, "port", "8080", "http port")
	if err := cli.Parse(args); err != nil {
		return err
	}

	//get address/port from env (overrides args)
	if _, ok := envs["HTTP_PORT"]; ok {
		httpPort = envs["HTTP_PORT"]
	}
	if _, ok := envs["HTTP_ADDRESS"]; ok {
		httpAddress = envs["HTTP_ADDRESS"]
	}

	//generate and create handle func, when connecting, it will use this port
	// indicate via console that the webserver is starting
	http.HandleFunc("/", func(writer http.ResponseWriter, request *http.Request) {
		fmt.Fprintf(writer, "Hello, World!\nVersion: \"%s\"\nGit Commit: \"%s\"\nGit Branch: \"%s\"\n", Version, GitCommit, GitBranch)
	})
	server := &http.Server{
		Addr:    httpAddress + ":" + httpPort,
		Handler: nil,
	}
	fmt.Printf("starting web server on %s:%s\n", httpAddress, httpPort)
	stopped := make(chan struct{})
	wg.Add(1)
	go func() {
		defer wg.Done()
		defer close(stopped)

		if err = server.ListenAndServe(); err != nil {
			return
		}
	}()
	select {
	case <-stopped:
	case <-osSignal:
		err = server.Close()
	}
	wg.Wait()
	return err
}
