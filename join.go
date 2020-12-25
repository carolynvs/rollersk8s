package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
	"strings"

	"github.com/pkg/errors"
)

func main() {
	r, err := http.Get("http://rainbowdash:8081/join")
	if err != nil {
		log.Fatal(err)
	}
	defer r.Body.Close()

	b, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Fatal("could not read join response")
	}

	var result struct {
		Token string
		Hash  string
	}
	err = json.Unmarshal(b, &result)
	if err != nil {
		log.Fatal(errors.Wrapf(err, "could not parse join response %q", string(b)))
	}

	join := exec.Command("kubeadm", "join", "--token", result.Token, "--discovery-token-ca-cert-hash", result.Hash, "rainbowdash:6443")
	fmt.Println(strings.Join(join.Args, " "))
	err = join.Run()
	if err != nil {
		log.Fatal(errors.Wrap(err, "cluster join failed"))
	}
}
