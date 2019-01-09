#!/bin/bash

# Specifying a unique listening port, unique RPC port, and unique data directories to sandbox each daemon instance, simulating multiple nodes on the same local machine

bitcoind -server -listen -port=17590 -rpcuser=USER -rpcpassword=PASS -rpcport=16590 -datadir=$HOME/.bitcoin/regtest/A/ -addnode=localhost:17591 -regtest -pid=$HOME/.bitcoin/regtest/A/ -daemon -debug -deprecatedrpc=generate -deprecatedrpc=signrawtransaction

bitcoind -server -listen -port=17591 -rpcuser=USER -rpcpassword=PASS -rpcport=16591 -datadir=$HOME/.bitcoin/regtest/B/ -addnode=localhost:17592 -regtest -pid=$HOME/.bitcoin/regtest/B/ -daemon -debug -deprecatedrpc=generate -deprecatedrpc=signrawtransaction

bitcoind -server -listen -port=17592 -rpcuser=USER -rpcpassword=PASS -rpcport=16592 -datadir=$HOME/.bitcoin/regtest/C/ -addnode=localhost:17590 -regtest -pid=$HOME/.bitcoin/regtest/C/ -daemon -debug -deprecatedrpc=generate -deprecatedrpc=signrawtransaction