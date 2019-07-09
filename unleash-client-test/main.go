package main

import (
	"io"
	"log"
	"net/http"

	"github.com/Unleash/unleash-client-go"
)

type metricsInterface struct {
}

func init() {
	unleash.Initialize(
		unleash.WithAppName("my-application"),
		unleash.WithUrl("http://localhost:3000/api/v4/projects/1/unleash/"),
		// This is due to bug with Unleash and sync call and broken
		unleash.WithListener(&metricsInterface{}),
	)
}

func helloServer(w http.ResponseWriter, req *http.Request) {
	if unleash.IsEnabled("#8") {
		io.WriteString(w, "Feature enabled\n")
	} else {
		io.WriteString(w, "hello, world!\n")
	}
}

func main() {
	http.HandleFunc("/", helloServer)
	log.Fatal(http.ListenAndServe(":12345", nil))
}
