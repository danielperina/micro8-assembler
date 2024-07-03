
ldr r0 =8
ldr r1 =10
jsr =MUL
str r0 result
hlt

result: db 0

MUL:
    ldr r2 =0
    add r1 =0
    bz =END_MUL
    add r0 =0
    bz =END_MUL
    str r0 $ff
MUL_LOOP:
    add r2 $ff
    sub r1 =1
    bz =END_MUL
    b =MUL_LOOP    
END_MUL:
    str r2 $ff
    ldr r0 $ff
ret