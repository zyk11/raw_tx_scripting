#!/bin/bash

# Automating the creation of a normal Null Data transaction

create_raw_tx() {
	DATA="$1"
	#get new wallet address to send bitcoins to
	CHANGE_ADDRESS=$(curl -s --user USER:PASS --data-binary \
	'{"jsonrpc": "1.0", "id":"curltest", "method": "getnewaddress", "params": ["''", "'legacy'"] }' \
	-H 'content-type: text/plain;' http://localhost:16590 | jq -r '.result')

	#get TXID for first spendable UTXO from wallet, minimum 1 bitcoin
	UTXO_TXID=$(curl -s --user USER:PASS --data-binary \
	'{"jsonrpc":"1.0", "id":"curltest", "method":"listunspent","params":[6, 9999999, [] , true, { "minimumAmount": 1 } ]}' \
	-H 'content-type:text/plain;' http://localhost:16590 | jq -r '.result | .[0] | .txid')
	echo "`date '+%Y-%m-%d %H:%M:%S'` [*] UTXO_TXID: " $UTXO_TXID

	#get amount for first spendable UTXO, minimum 1 bitcoin
	UTXO_AMOUNT=$(curl -s --user USER:PASS --data-binary \
	'{"jsonrpc":"1.0", "id":"curltest", "method":"listunspent","params":[6, 9999999, [] , true, { "minimumAmount": 1 } ]}' \
	-H 'content-type:text/plain;' http://localhost:16590 | jq -r '.result | .[0] | .amount')
	echo "`date '+%Y-%m-%d %H:%M:%S'` [*] UTXO_AMOUNT: " $UTXO_AMOUNT

	#get VOUT ID for first spendable UTXO, minimum 1 bitcoin 
	UTXO_VOUT=$(curl -s --user USER:PASS --data-binary \
	'{"jsonrpc":"1.0", "id":"curltest", "method":"listunspent","params":[]}' \
	-H 'content-type:text/plain;' http://localhost:16590 | jq -r '.result | .[0] | .vout')
	echo "`date '+%Y-%m-%d %H:%M:%S'` [*] UTXO_VOUT: " $UTXO_VOUT

	#Subtract fee from UTXO_AMOUNT
	AMOUNT=$(echo $UTXO_AMOUNT - 0.0001 | bc)

	#create raw transaction
	RAW_TX=$(curl -s --user USER:PASS --data-binary \
	'{"jsonrpc": "1.0", "id":"curltest", "method":"createrawtransaction", "params": [''[ { "txid": "'$UTXO_TXID'", "vout": '$UTXO_VOUT' } ]'',''{ "data": "'$DATA'", "'$CHANGE_ADDRESS'": '$AMOUNT'}'']}' \
	-H 'content-type: text/plain;' http://localhost:16590  | jq -r '.result')
	echo "`date '+%Y-%m-%d %H:%M:%S'` [*] RAW_TX: " $RAW_TX

	#sign raw transaction
	SIGNED_RAW_TX=$(curl -s --user USER:PASS --data-binary \
	'{"jsonrpc": "1.0", "id":"curltest", "method": "signrawtransactionwithwallet", "params": ["'$RAW_TX'"] }' \
	-H 'content-type: text/plain;' http://localhost:16590 | jq -r '.result | .hex')
	echo "`date '+%Y-%m-%d %H:%M:%S'` [*] SIGNED_RAW_TX: " $SIGNED_RAW_TX

	#send transaction to network peers
	echo "`date '+%Y-%m-%d %H:%M:%S'` [*] Sending raw transaction to peers"
	RESULT=$(curl -s --user USER:PASS --data-binary \
	'{"jsonrpc": "1.0", "id":"curltest", "method": "sendrawtransaction", "params": ["'$SIGNED_RAW_TX'"] }' \
	-H 'content-type: text/plain;' http://localhost:16590)

	if [ "$(echo $RESULT | jq -r '.error')" == "null" ]
	then
		NEW_TXID=$(echo $RESULT | jq -r '.result')
		echo "`date '+%Y-%m-%d %H:%M:%S'` [+] Transaction sent successfully with TXID: " $NEW_TXID 
	else
		echo "`date '+%Y-%m-%d %H:%M:%S'` [-] Error: " $RESULT
	fi
}

main(){
	if [ "$1" ]
	then
		echo "`date '+%Y-%m-%d %H:%M:%S'` [*] Creating raw transaction"
		create_raw_tx $1
	else
		echo "`date '+%Y-%m-%d %H:%M:%S'` [-] OP_RETURN data required"
	fi
}

main $1

