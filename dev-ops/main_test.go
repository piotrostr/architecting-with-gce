package main

import (
	"net/http/httptest"
	"testing"
)

func TestHandlerFunc(t *testing.T) {
	req := httptest.NewRequest("GET", "http://google.com", nil)
	w := httptest.NewRecorder()
	HandlerFunc(w, req)
	if w.Body.String() != "Hello World" {
		tpl := "handlerFunc unexpected body: %v want %v"
		t.Errorf(tpl, w.Body.String(), "Hello World")
	}
}
