# achtungdiebash  🐍
Multiplayer actung die curve written in bash!

# how to play
Grab your best friend/s and make sure you are on the same wifi

Run `server.sh` on your laptop

Then run the client on both you and your friends laptop. This bash one liner is the client 😎
```
/bin/bash -c 'while :; do printf "\033c"; read -n1 input && printf "$(whoami) $input" | nc -N <server_ip>^C337; done'
```
> replace <server_ip> with your local ip address

After running the client, press any `wasd` key to join the lobby, and press `r` to ready up

The game only supports up to 6 players, if you play more than 6 anything could happen


# If you can't join the lobby

Try these steps to debug
* Make sure you can reach eachother; Try to ping yourself from your friend laptop
* Try to run `nc -l 1337` on your laptop, and then run `echo "test!" | nc <your_ip> 1337` from your frined laptop
* Some netcat's dont support the -N option. If this is the case, try without -N or sometimes with -c in the client bash oneliner.
