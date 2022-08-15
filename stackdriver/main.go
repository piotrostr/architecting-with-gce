package main

import (
	"fmt"
	"net/http"
)

func main() {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "hello world\n")
		panic("this error is to see logs")
	})
	http.ListenAndServe(":8080", handler)
}
