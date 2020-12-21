package main

import (
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
		return nil
	}

	role := "follower"
	if node.Leader {
		role = "leader"
	}
	err = os.Symlink(role, pxeFile)
	if err != nil {
		return errors.Wrapf(err, "could not create pxe config file %s pointing to %s", pxeFile, role)
	}

	u, err := user.Lookup("dnsmasq")
	if err != nil {
		return errors.Wrapf(err, "could not get uid for dnsmasq")
	}
	uid, _ := strconv.Atoi(u.Uid)
	g, err := user.LookupGroup("root")
	if err != nil {
		return errors.Wrapf(err, "could not get gid for root")
	}
	gid, _ := strconv.Atoi(g.Gid)
	err = os.Chown(pxeFile, uid, gid)
	return errors.Wrap(err, "could not make dnsmasq own the pxe config file")
}
