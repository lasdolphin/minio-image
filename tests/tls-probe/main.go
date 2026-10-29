package main

import (
	"crypto/x509"
	"errors"
	"fmt"
	"net/http"
	"time"
)

var advisoryHosts = []string{
	"dv-g3b",
	"dv-g3b-aaa",
	"dv-g3b-noct",
	"dv-g3b-aaa-noct",
}

func certificateRejected(err error) bool {
	var unknown x509.UnknownAuthorityError
	var invalid x509.CertificateInvalidError
	var hostname x509.HostnameError
	return errors.As(err, &unknown) || errors.As(err, &invalid) || errors.As(err, &hostname)
}

func main() {
	client := &http.Client{Timeout: 15 * time.Second}
	failed := false
	for _, host := range advisoryHosts {
		response, err := client.Get("https://" + host + "-emudhra.we-have-a-problem.com/")
		if err == nil {
			response.Body.Close()
			fmt.Printf("%s=ACCEPTED status=%d\n", host, response.StatusCode)
			failed = true
			continue
		}
		if certificateRejected(err) {
			fmt.Printf("%s=REJECTED certificate-validation\n", host)
			continue
		}
		fmt.Printf("%s=FAILED %v\n", host, err)
		failed = true
	}
	if failed {
		panic("eMudhra runtime trust verification failed")
	}
}
