package main

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/exec"
	"regexp"

	"github.com/pkg/errors"
)

func main() {
	http.HandleFunc("/join", handle)
	log.Fatal(http.ListenAndServe("0.0.0.0:8081", nil))
}

func handle(w http.ResponseWriter, r *http.Request) {
	var buf bytes.Buffer
	cmd := exec.Command("kubeadm", "token", "create", "--print-join-command")
	cmd.Stdout = &buf
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		log.Println(errors.Wrapf(err, "could not get join command for %s", r.RemoteAddr))
		w.WriteHeader(500)
		return
	}

	// format: kubeadm join 192.168.0.116:6443 --token TOKEN --discovery-token-ca-cert-hash HASH
	regex := regexp.MustCompile(`kubeadm join .+ --token ([^\s]+)\s+--discovery-token-ca-cert-hash ([^\s]+)`)
	matches := regex.FindStringSubmatch(buf.String())
	if len(matches) != 3 {
		log.Println(errors.Errorf("could not parse join command %q", buf))
		w.WriteHeader(500)
		return
	}

	result := struct {
		Token string
		Hash  string
	}{matches[1], matches[2]}

	b, err := json.Marshal(result)
	if err != nil {
		log.Println(errors.Wrapf(err, "could not marshal join response %v", result))
		w.WriteHeader(500)
		return
	}

	w.WriteHeader(200)
	w.Write(b)
}
