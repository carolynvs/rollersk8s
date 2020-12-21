package main

import (
	"fmt"
	"os"
	"os/user"
	"path/filepath"
	"strconv"

	"github.com/pkg/errors"
	"github.com/spf13/cobra"
)

type Node struct {
	MACAddress string
	Leader     bool
}

func (n Node) Role() string {
	if n.Leader {
		return "leader"
	}
	return "follower"
}

var nodes = map[string]Node{
	"rainbowdash":     {MACAddress: "01-f4-4d-30-6d-56-0c", Leader: true},
	"twilightsparkle": {MACAddress: "01-f4-4d-30-6d-48-f6"},
	"applejack":       {MACAddress: "01-f4-4d-30-6d-48-08"},
	"fluttershy":      {MACAddress: "01-f4-4d-30-6d-5e-6c"},
	"pinkiepie":       {MACAddress: "01-f4-4d-30-6d-61-51"},
}

func main() {
	var node string
	var complete bool
	cmd := cobra.Command{
		Use: "reimage",
		RunE: func(cmd *cobra.Command, args []string) error {
			return reimage(node, complete)
		},
	}
	cmd.Flags().StringVarP(&node, "node", "n", "", "Node hostname")
	cmd.Flags().BoolVarP(&complete, "complete", "c", false, "Indicates if the restore is complete")

	cmd.Execute()
}

func reimage(name string, complete bool) error {
	node, ok := nodes[name]
	if !ok {
		return errors.Errorf("Invalid node: %s", name)
	}

	pxeDir := "/var/ftpd/pxelinux.cfg"
	pxeFile := filepath.Join(pxeDir, node.MACAddress)

	err := os.Remove(pxeFile)
	if !os.IsNotExist(err) {
		return errors.Wrapf(err, "could not remove %q", pxeFile)
	}

	if complete {
		fmt.Println("removed pxe config for", name)
		return nil
	}

	role := node.Role()
	err = os.Symlink(role, pxeFile)
	if err != nil {
		return errors.Wrapf(err, "could not create pxe config file %s pointing to %s", pxeFile, role)
	}

	u, err := user.Lookup("dnsmasq")
	if err != nil {
		return errors.Wrapf(err, "could not get uid for dnsmasq")
	}
	uid, err := strconv.Atoi(u.Uid)
	if err != nil {
		return errors.Wrapf(err, "could not get uid for dnsmasq")
	}
	fmt.Println("chown", uid, pxeFile)
	err = os.Chown(pxeFile, uid, -1)
	if err != nil {
		return errors.Wrap(err, "could not make dnsmasq own the pxe config file")
	}

	fmt.Println("created pxe config for", name)
	return nil
}
