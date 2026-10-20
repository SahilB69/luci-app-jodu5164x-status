#!/usr/bin/env python3
"""Tiny mock telnet ODU for testing prompt-driven authentication."""
import argparse
import socketserver

class Handler(socketserver.StreamRequestHandler):
    def handle(self):
        mode = self.server.mode
        if mode in ("userpass", "wrongpass"):
            self.wfile.write(b"QTI Linux reference banner\r\njioodu login: ")
            user = self.rfile.readline().strip()
            if user != b"root":
                self.wfile.write(b"Login incorrect\r\njioodu login: ")
                return
            self.wfile.write(b"Password: ")
            password = self.rfile.readline().strip()
            if password != b"secret" or mode == "wrongpass":
                self.wfile.write(b"Login incorrect\r\njioodu login: ")
                return
        elif mode == "passonly":
            self.wfile.write(b"Password: ")
            if self.rfile.readline().strip() != b"secret":
                self.wfile.write(b"Login incorrect\r\njioodu login: ")
                return
        else:
            self.wfile.write(b"~ # ")
        while True:
            line = self.rfile.readline()
            if not line:
                return
            cmd = line.decode("utf-8", "replace").strip()
            if cmd == "exit":
                return
            if cmd.endswith("; echo"):
                pass
            # Echo a predictable shell prompt; helper marker is emitted by shell.
            if "; echo ODU_DONE_" in cmd:
                marker = cmd.split("; echo ", 1)[1]
                self.wfile.write((marker + "\r\n~ # ").encode())
            else:
                self.wfile.write(("ok\r\n~ # ").encode())

class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--port", type=int, default=2323)
    p.add_argument("--mode", choices=("nologin", "passonly", "userpass", "wrongpass"), default="userpass")
    args = p.parse_args()
    with Server((args.host, args.port), Handler) as server:
        server.mode = args.mode
        server.serve_forever()

if __name__ == "__main__":
    main()
