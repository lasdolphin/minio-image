package main

import (
	"crypto/x509"
	"errors"
	"testing"
)

func TestCertificateRejected(t *testing.T) {
	if !certificateRejected(x509.UnknownAuthorityError{}) {
		t.Fatal("unknown authority must be accepted as certificate rejection")
	}
	if certificateRejected(errors.New("network unavailable")) {
		t.Fatal("non-certificate error must fail verification")
	}
}
