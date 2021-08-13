section .text
	global _start

_start:

read:
	mov edx, 16
	mov ecx, inputBuffer
	mov ebx, 0
	mov eax, 3
	int 0x80              ; read input 16 bytes at a time

	mov [count], eax      ; store number of bytes read in

	cmp eax, 0
	je exit               ; exit when reach end of file/input

	mov esi, inputBuffer  ; address of input into ESI
	mov edi, hexstr       ; address of hex string into EDI
	mov ecx, 0            ; set ECX to 0 to use as index pointer through input

convert:

	mov eax, 0
	mov edx, ecx          ; copy ECX index to EDX
	shl edx, 1            ; multiply pointer by 2 w/ left shift
	add edx, ecx          ; add to multiply pointer location by 3

	mov al, byte [esi + ecx] 
	mov ebx, eax          ; put byte from input into al and duplicate
			      ; for second nibble
	and al, 0Fh
	mov al, byte [digits + eax]
	mov byte [hexstr + edx + 1], al
			      ; mask all but low nibble, get char equivalent
			      ; and write char equivalent to hex string
	shr bl, 4
	mov bl, byte [digits + ebx]
	mov byte [hexstr + edx], bl
			      ; shift high 4 bits into low 4 bits
			      ; look up char equivalent and write
	inc ecx
	cmp ecx, [count]      ; if ecx, our indexer for user input, equals count
	jl convert            ; which is how many bytes were read, loop again

	mov edx, hexlen
	mov ecx, hexstr
	mov ebx, 1
	mov eax, 4
	int 0x80              ; print overwritten hex string
	
	mov [tmp], edx
	mov edx, 0            ; save edx, our indexer for hexstr, in tmp
			      ; and set to 0 to clear hexstr with 0s
			      ; before rewiritng with new input

	resetloop:
		mov BYTE [hexstr + edx], '0'
		inc edx
		mov BYTE [hexstr + edx], '0'
		inc edx
		mov BYTE [hexstr + edx], ' '
		inc edx

	cmp edx, 48           ; increment 48x to save 0s in hexstr
	jl resetloop

	mov edx, DWORD [tmp]  ; bring the old edx indexer back to read new input
	jmp read

exit:
	mov ebx, 0
	mov eax, 1	
	int 0x80              ; exit once end of file is reached
	

section .data

	hexstr db "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ", 10
	hexlen equ $-hexstr
	digits db "0123456789ABCDEF"

section .bss

	inputBuffer resb 16   ; read 16 bytes at a time
	count resd 1	
	tmp resd 1	

