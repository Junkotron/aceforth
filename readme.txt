
Ace demo of parsing text into Forth.

This demo will make you load an assembler piece into memory then you
can set the pointer (at b0 2+) to any text area ending with a 0 "eof"

calling "b" will make the ace parse through the text as if you had
typed it in yourself

Either just load a pre-made "b0.TZX" and type "b" and watch the letters
fly by and load two new words that are runnable.


Prepering from source code

1) assemble the "b0.asm" into a b0.bin file with z80asm or similar check its size
2) create b0 <size> allot
3) somehow bload the binary from the adress of b0 i.e. "b0 0 bload b0bin"
4) ": b b0 call ; immediate
5) It is a bit tricky to reset the pointer so do a "save b0"
6) type: "b" and watch the text fly

The trick that makes this work is the fact that after you have called any
word that word can manipulate the input buffer and the ace will just happily
parse on with whats in there upon return.
In order to continue after each line a simple "b" is appended to each
source line, triggering the parsing yet once again.


Testing the simple screen-like editor
--

Again the simple thing is just to load the "tine.TZX"

Although to my memory the screen like forth editor was deemed obsolete by some
people actively developing their own forth dialect as early as back in 84-85.
I wrote this as a quick way to get something going and a simple screen editor
has the advantage that it is - well simple.

you need another area to temporarily store the editor src
i.e. "create edsrc <size> allot 0 c," ( We add the "eof" character here to be sure
the ace dont parse its way into infinity)
Then load the source code into edsrc, i.e. "edsrc 0 bload edsrc"

One also needs a word for the non-stored \ "backslash" comments used in editor.fs
( since we dont care much about editing this file on-site we dont
  want the comments stored as is standard for ace)
i.e. ": \ 13 word drop ascii b 9953 c! ; immediate"
(again we need to "fool" the ace into continuing with the parsing by putting a
"b" back on the buffer)

Then lets compile the editor.fs into a runnable, but first we define a convenience
word, "parse" that takes a number pointer to a buffer assumes naively its gonna be
terminated with a zero and parses it like the ace would normally the stuff you
typed into it.

: parse
  find dup 0= if drop exit then
  execute
  b0 2+ !
  b0 call
;

Now to get the editor going you can type "parse edsrc"

...
...

The small "tine" editor is also extremely primitive and most likely have bugs

Try to create an editor buffer i.e. "cretine myex"

and then "tine myex" walk around and write some code i.e

---

\ a comment

: silly 11 0 do i . loop ;

\ another comment

---

( The horizontal bars on the right are line break chars keep them on for now! )

Then exit with shift-1 and try

"parse myex"

...

vlist
...

You should now be able to run the "silly" word

silly
0 1 2 3 ....

If you are happy with the editor as is (who wouldn't?) you can do a
"create edsrc redefine edsrc" to save about 2k

