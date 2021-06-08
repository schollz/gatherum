package main

import (
	"bufio"
	"net/url"
	"os"
	"time"

	"github.com/gorilla/websocket"
)

func main() {
	u := url.URL{Scheme: "ws", Host: "localhost:5555", Path: "/"}
	var cstDialer = websocket.Dialer{
		Subprotocols:     []string{"bus.sp.nanomsg.org"},
		ReadBufferSize:   1024,
		WriteBufferSize:  1024,
		HandshakeTimeout: 3 * time.Second,
	}

	norns, _, err := cstDialer.Dial(u.String(), nil)
	if err != nil {
		os.Exit(1)
	}
	defer norns.Close()
	stdin := bufio.NewScanner(os.Stdin)
	for stdin.Scan() {
		norns.WriteMessage(websocket.TextMessage, []byte("last_command=[["+stdin.Text()+"]];"+stdin.Text()+"\n"))
	}
}
