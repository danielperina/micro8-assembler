ldr r0 =81 // srqt(81)
jsr =sqrt
hlt

sqrt:
    ldr r1 =1 // r 
    ldr r2 =2 // d 
    ldr r3 =4 // s
    
    str r0 $fe
    
sqrtLoop:
    ldr r0 $fe
    
    add r1 =1 // r++
    add r2 =2 // d+=2
    
    str r2 $ff
    
    add r3 =1 // s++
    add r3 $ff // s+=d
    
    str r3 $ff
    str r0 $fe
    
    sub r0 $ff
    bc =sqrtLoop
    
    str r1 $ff
    ldr r0 $ff
ret