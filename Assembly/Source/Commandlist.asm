
;Spur
;.386
;.model small,c
;.stack 4096
extern strcmp:proc
.data
;Calling certain variables from C

  fmtlist   db     "%s, %d, %lu", 0Ah,0
  string_1  db     "signed byte and unsigned double word", 0
  data_1    db     -2
  data_2    dd     0FFFFFFFFh

 ;Functions

BRAYMESSAGE	DB 'Brayconn moment https://media.discordapp.net/avatars/145351267256893440/e834a22a03021ef131522ffa84ae7d26.png?size=4096', 0
HOWMESSAGE	DB 'https://imgur.com/gallery/8cfRt', 0
HIMESSAGE	DB 'how are you?', 0
MUFFINMESSAGE DB "No muffins for you :3...", 10
			  DB "Unless you ask nicely :)", 0
FORMATMESSAGE	DB '~~crossed out~~ *italics* ***bold italics*** __underlined__ ||spoiler|| `code box` ```big code box```', 0
HELPMESSAGE		DB "```css", 10
	DB "{All commands will start with and '=' symbol!}", 10
	DB "[=how] -- Sends in an inside joke gif of a cat.", 10
	DB "[=bray] -- Replys to the one and only, Brayconn.", 10
	DB "[=hi] -- Replies to you :)", 10
	DB "[=muffin] -- NO MUFFINS FOR YOU!!!.", 10
	DB "[=format] -- A temporary test command trying out the different formats.", 10
	DB "[=smudge] -- Replys to the one and only, Smudge.", 10
	DB "[=txin] -- Replys to the one and only, Txin.", 10
	DB "[=help] -- A command that you just used and displays all of the commands that this bot has.```", 0
SMUDGEMESSAGE	DB 'h mmm m mm m <:aaaa:797489022111842314>', 0
TXINMESSAGE		DB 'This is Txin message', 0
  ;Commands
HOW			DB '=how', 0
BRAY		DB '=bray', 0
HI			DB '=hi', 0
MUFFIN		DB '=muffin', 0
FORMAT		DB '=format', 0
HELP		DB '=help', 0
SMUDGE		DB '=smudge', 0
TXIN		DB '=txin', 0

.code
public OnMessageASM
OnMessageASM PROC
	;pop rcx
	;mov rcx, [
	mov rdi, rcx
	mov rdx, offset HOW
	call strcmp
	cmp rax, 0
	jz howresponse
	mov rcx, rdi
	mov rdx, offset BRAY
	call strcmp
	cmp rax, 0
	jz brayresponse
	mov rcx, rdi
	mov rdx, offset HI
	call strcmp
	cmp rax, 0
	jz hiresponse
	mov rcx, rdi
	mov rdx, offset MUFFIN
	call strcmp
	cmp rax, 0
	jz muffinresponse
	mov rcx, rdi
	mov rdx, offset FORMAT
	call strcmp
	cmp rax, 0
	jz formatresponse
	mov rcx, rdi
	mov rdx, offset HELP
	call strcmp
	cmp rax, 0
	jz helpresponse
	mov rcx, rdi
	mov rdx, offset SMUDGE
	call strcmp
	cmp rax, 0
	jz smudgeresponse
	mov rcx, rdi
	mov rdx, offset TXIN
	call strcmp
	cmp rax, 0
	jz txinresponse
	mov rax, 0


	ret

howresponse:
	mov RAX, offset HOWMESSAGE
	ret
brayresponse:
	mov RAX, offset BRAYMESSAGE
	ret
hiresponse:
	mov RAX, offset HIMESSAGE
	ret
muffinresponse:
	mov rax, offset MUFFINMESSAGE
	ret
formatresponse:
	mov rax, offset FORMATMESSAGE
	ret
helpresponse:
	mov rax, offset HELPMESSAGE
	ret
smudgeresponse:
	mov rax, offset SMUDGEMESSAGE
	ret
txinresponse:
	mov rax, offset TXINMESSAGE
	ret
OnMessageASM endp

end
;public StringTrue
;StringTrue proc
	;cmp rax, 