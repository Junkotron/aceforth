#!/bin/bash

# Användning: ./remote_compile.sh user@machine /path/to/remote/dir local_file.asm [forth_file.fs]

REMOTE=$1
REMOTE_DIR=$2
LOCAL_FILE=$3
LOCAL_DIR=$(dirname "$LOCAL_FILE")
FORTH_FILE=${4:-"$LOCAL_DIR/program.fs"}

FILENAME=$(basename "$LOCAL_FILE")
BASENAME="${FILENAME%.*}"

echo "BASENAME=$BASENAME"

# 1. Skapa mappen på fjärrmaskinen
ssh "$REMOTE" mkdir -p "$REMOTE_DIR"

# 2. Skicka asm-filen och program.fs (om den existerar) i ett svep
if [ -f "$FORTH_FILE" ]; then
    echo "Skickar med $(basename "$FORTH_FILE")..."
    scp "$LOCAL_FILE" "$FORTH_FILE" "$REMOTE:$REMOTE_DIR/"
else
    echo "Varning: Hittade ingen $FORTH_FILE, skickar bara $FILENAME..."
    scp "$LOCAL_FILE" "$REMOTE:$REMOTE_DIR/"
fi

# 3. Gå till mappen och kör z80asm i samma session (använd enbart filnamnet)
ssh "$REMOTE" "cd '$REMOTE_DIR' && z80asm -o '$BASENAME.bin' '$FILENAME'"

# 4. Hämta hem den genererade binärfilen
scp "$REMOTE:$REMOTE_DIR/$BASENAME.bin" .

