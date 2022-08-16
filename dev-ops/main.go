package main

import (
	"fmt"
	"net/http"
)

func HandlerFunc(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World")
}

func main() {
	http.HandleFunc("/", HandlerFunc)
	http.ListenAndServe(":8080", nil)
}
