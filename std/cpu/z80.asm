#subruledef z80_reladdr
{
	{addr: u16} =>
	{
		reladdr = addr - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		reladdr`8
	}
}


; 3-bits identifier for the 8-bits registers
#subruledef z80_r8 {
    a    => 7`3
    b    => 0`3
    c    => 1`3
    d    => 2`3
    e    => 3`3
    h    => 4`3
    l    => 5`3
}

; 2-bits identifier for the 16-bits registers
#subruledef z80_r16 {
    bc => 0`2
    de => 1`2
    hl => 2`2
    sp => 3`2
    af => assert(0 != 0, "invalid operand AF for this instruction")
}

; 2-bits identifier for the 16-bits registers for push and pop
#subruledef z80_r16_push_pop {
    bc => 0`2
    de => 1`2
    hl => 2`2
    af => 3`2
    sp => assert(0 != 0, "invalid operand SP for this instruction")
}

; identifier for IX and IY registers
#subruledef z80_ix_iy {
    ix => 0xDD
    iy => 0xFD
}

; IX high or IX low
#subruledef z80_ixp{
    ixh => 4`3
    ixl => 5`3
}

; IY high or IY low
#subruledef z80_iyq{
    iyh => 4`3
    iyl => 5`3
}

; 3-bits identifier for condition type
#subruledef z80_cond {
    nz => 0`3
    z  => 1`3
    nc => 2`3
    c  => 3`3
    po => 4`3
    pe => 5`3
    p  => 6`3
    m  => 7`3
}


; The following ruleset was defined using this reference:
; https://map.grauw.nl/resources/z80instr.php#instructionset

#ruledef z80
{
    adc  a , ( hl )                         =>         0x8E
    adc  a , ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0x8E @ off
    adc  a ,  {imm: i8       }              =>         0xCE @ imm
    adc  a ,  {reg: z80_r8   }              =>        (0x88 + reg)`8
    adc  a ,  {reg: z80_ixp  }              => 0xDD @ (0x88 + reg)`8
    adc  a ,  {reg: z80_iyq  }              => 0xFD @ (0x88 + reg)`8
    adc  hl,  {reg: z80_r16  }              => 0xED @ (4 + reg)`4 @ 0xA`4

    adc  a , ( hl )                         =>         0x86
    adc  a , ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0x86 @ off
    adc  a ,  {imm: i8       }              =>         0xC6 @ imm
    adc  a ,  {reg: z80_r8   }              =>        (0x80 + reg)`8
    adc  a ,  {reg: z80_ixp  }              => 0xDD @ (0x80 + reg)`8
    adc  a ,  {reg: z80_iyq  }              => 0xFD @ (0x80 + reg)`8
    adc  hl,  {reg: z80_r16  }              =>         reg`4 @ 0x9`4
    adc  {ixy: z80_ix_iy}, {reg: z80_r16}   => ixy  @  reg`4 @ 0x9`4

    and ( hl )                         =>         0xA6
    and ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0xA6 @ off
    and  {imm: i8       }              =>         0xE6 @ imm
    and  {reg: z80_r8   }              =>        (0xA0 + reg)`8
    and  {reg: z80_ixp  }              => 0xDD @ (0xA0 + reg)`8
    and  {reg: z80_iyq  }              => 0xFD @ (0xA0 + reg)`8

    bit  {bit: u3}, ( hl )                         =>       0xCB       @ (0x46 + bit * 8      )`8
    bit  {bit: u3}, ({ixy: z80_ix_iy} + {off: u8}) => ixy @ 0xCB @ off @ (0x46 + bit * 8      )`8
    bit  {bit: u3},  {reg: z80_r8   }              =>       0xCB       @ (0x40 + bit * 8 + reg)`8

    call                   {imm: u16} =>  0xCD               @ le(imm)
    call {cond: z80_cond}, {imm: u16} => (0xC4 + cond * 8)`8 @ le(imm)

    ccf  => 0x3F

    cp ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0xBE @ off
    cp  {imm: i8       }              =>         0xFE @ imm
    cp  {reg: z80_r8   }              =>        (0xB8 + reg)`8
    cp  {reg: z80_ixp  }              => 0xDD @ (0xB8 + reg)`8
    cp  {reg: z80_iyq  }              => 0xFD @ (0xB8 + reg)`8

    cpd  => 0xED @ 0xA9
    cpdr => 0xED @ 0xB9
    cpi  => 0xED @ 0xA1
    cpir => 0xED @ 0xB1
    cpl  => 0x2F
    daa  => 0x27

    dec ( hl )                         =>         0x35
    dec ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0x35 @ off
    dec  {ixy: z80_ix_iy}              => ixy  @  0x2B
    dec  {reg: z80_r16  }              =>         reg`4 @ 0xB`4
    dec  {reg: z80_r8   }              =>        (5 + reg * 8)`8
    dec  {reg: z80_ixp  }              => 0xDD @ (5 + reg * 8)`8
    dec  {reg: z80_iyq  }              => 0xFD @ (5 + reg * 8)`8

    di             => 0xF3
    djnz {off: u8} => 0x10 @ off
    ei             => 0xFB

    ex ( sp ), hl               =>        0xE3
    ex ( sp ), {ixy: z80_ix_iy} => ixy  @ 0xE3
    ex   af  , af               => 0x08        ; is it " ex af, af' " ?
    ex   de  , hl               => 0xEB

    exx  => 0xD9
    halt => 0x76

    im 0 => 0xED @ 0x46
    im 1 => 0xED @ 0x56
    im 2 => 0xED @ 0x5E

    in a, ({imm: i8})     => 0xDB @ imm
    in {reg: z80_r8}, (C) => 0xED @ (0x40 + reg * 8)`8

    inc ( hl )                         =>         0x34   
    inc ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0x34 @ off
    inc  {ixy: z80_ix_iy}              => ixy  @  0x23
    inc  {reg: z80_r16  }              =>         reg`4 @ 3`4
    inc  {reg: z80_r8   }              =>        (4 + reg * 8)`8
    inc  {reg: z80_ixp  }              => 0xDD @ (4 + reg * 8)`8
    inc  {reg: z80_iyq  }              => 0xFD @ (4 + reg * 8)`8

    ind  => 0xED @ 0xAA
    indr => 0xED @ 0xBA
    ini  => 0xED @ 0xA2
    inir => 0xED @ 0xB2

    jp  {imm: i16}                     => 0xC3 @ le(imm)
    jp ( hl )                          => 0xE9
    jp ({ixy:  z80_ix_iy})             => ixy  @ 0xE9
    jp  {cond: z80_cond } , {imm: i16} => 0b11 @ cond @ 0b010 @ le(imm)

    jr     {off: u8} => 0x18 @ off
    jr nz, {off: u8} => 0x20 @ off
    jr z , {off: u8} => 0x28 @ off
    jr nc, {off: u8} => 0x30 @ off
    jr c , {off: u8} => 0x38 @ off

    ; <LOAD>

    ld ( bc ), a                                     => 0x02
    ld ( de ), a                                     => 0x12
    ld ( hl ), {imm: i8}                             =>         0x36          @ imm
    ld ({ixy: z80_ix_iy} + {off: u8}), {imm: i8}     => ixy  @  0x36 @ off    @ imm
    ld ({ixy: z80_ix_iy} + {off: u8}), {reg: z80_r8} => ixy  @ (0x70 + reg)`8 @ off
    ld ( hl ), {reg: z80_r8}                         =>        (0x70 + reg)`8

    ld ({imm: i16}), a                =>        0x32 @ le(imm)
    ld ({imm: i16}), bc               => 0xED @ 0x43 @ le(imm)
    ld ({imm: i16}), de               => 0xED @ 0x53 @ le(imm)
    ld ({imm: i16}), hl               =>        0x22 @ le(imm)
    ld ({imm: i16}), {ixy: z80_ix_iy} => ixy  @ 0x22 @ le(imm)
    ld ({imm: i16}), sp               => 0xED @ 0x73 @ le(imm)

    ld  a, ( bc )       => 0x0A
    ld  a, ( de )       => 0x1A
    ld  a, ({imm: i16}) => 0x3A @ le(imm)
    ld  a,  i           => 0xED @ 0x57
    ld  a,  r           => 0xED @ 0x5F

    ld  {reg:  z80_r8 }, ( hl )                          =>        (0x46 + reg)`8
    ld  {reg:  z80_r8 }, ({ixy:  z80_ix_iy} + {off: u8}) => ixy  @ (0x46 + reg)`8 @ off
    ld  {reg:  z80_r8 },  {imm:  i8       }              =>        (   6 + reg)`8 @ imm
    ld  {reg1: z80_r8 },  {reg2: z80_r8   }              =>        (0x40 + reg1 * 8 + reg2)`8
    ld  {reg1: z80_r8 },  {reg2: z80_ixp  }              => 0xDD @ (0x40 + reg1 * 8 + reg2)`8
    ld  {reg1: z80_r8 },  {reg2: z80_iyq  }              => 0xFD @ (0x40 + reg1 * 8 + reg2)`8

    ld  bc, ({imm: i16}) => 0xED @ 0x4B @ le(imm)
    ld  de, ({imm: i16}) => 0xED @ 0x5B @ le(imm)
    ld  hl, ({imm: i16}) => 0x2A        @ le(imm)
    ld  sp, ({imm: i16}) => 0xED @ 0x7B @ le(imm)

    ld  bc,  {imm: i16}  => 0x01 @ le(imm)
    ld  de,  {imm: i16}  => 0x11 @ le(imm)
    ld  hl,  {imm: i16}  => 0x21 @ le(imm)
    ld  sp,  {imm: i16}  => 0x31 @ le(imm)

    ld  {ixy: z80_ix_iy}, ({imm: i16}) => ixy @ 0x2A @ le(imm)
    ld  {ixy: z80_ix_iy},  {imm: i16}  => ixy @ 0x21 @ le(imm)

    ld  {reg: z80_ixp}, {imm: i8} => 0xDD @ (0x26 + (reg - 4) * 8)`8 @ imm
    ld  {reg: z80_iyq}, {imm: i8} => 0xFD @ (0x26 + (reg - 4) * 8)`8 @ imm

    ld  {reg: z80_ixp}, a   => 0xDD @ (0x60 + (reg - 4) * 8 + 7)`8
    ld  {reg: z80_ixp}, b   => 0xDD @ (0x60 + (reg - 4) * 8 + 0)`8
    ld  {reg: z80_ixp}, c   => 0xDD @ (0x60 + (reg - 4) * 8 + 1)`8
    ld  {reg: z80_ixp}, d   => 0xDD @ (0x60 + (reg - 4) * 8 + 2)`8
    ld  {reg: z80_ixp}, e   => 0xDD @ (0x60 + (reg - 4) * 8 + 3)`8
    ld  {reg: z80_ixp}, ixh => 0xDD @ (0x60 + (reg - 4) * 8 + 4)`8
    ld  {reg: z80_ixp}, ixl => 0xDD @ (0x60 + (reg - 4) * 8 + 5)`8

    ld  {reg: z80_iyq}, a   => 0xFD @ (0x60 + (reg - 4) * 8 + 7)`8
    ld  {reg: z80_iyq}, b   => 0xFD @ (0x60 + (reg - 4) * 8 + 0)`8
    ld  {reg: z80_iyq}, c   => 0xFD @ (0x60 + (reg - 4) * 8 + 1)`8
    ld  {reg: z80_iyq}, d   => 0xFD @ (0x60 + (reg - 4) * 8 + 2)`8
    ld  {reg: z80_iyq}, e   => 0xFD @ (0x60 + (reg - 4) * 8 + 3)`8
    ld  {reg: z80_iyq}, iyh => 0xFD @ (0x60 + (reg - 4) * 8 + 4)`8
    ld  {reg: z80_iyq}, iyl => 0xFD @ (0x60 + (reg - 4) * 8 + 5)`8

    ld  r , a                => 0xED @ 0x4F
    ld  sp, hl               =>        0xF9
    ld  sp, {ixy: z80_ix_iy} => ixy  @ 0xF9

    ldd  => 0xED @ 0xA8
    lddr => 0xED @ 0xB8
    ldi  => 0xED @ 0xA0
    ldir => 0xED @ 0xB0

    ; </LOAD>

    mulub a , {reg: z80_r8} => 0xED @ (0xC1 + reg * 8)`8
    muluw hl, bc            => 0xED @  0xC3
    muluw hl, sp            => 0xED @  0xF3

    neg => 0xED @ 0x44
    nop => 0x00

    or ( hl )                         =>         0xB6
    or ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0xB6 @ off
    or  {imm: i8       }              => 0xF6 @  imm
    or  {reg: z80_r8   }              =>        (0xB0 + reg)`8
    or  {reg: z80_ixp  }              => 0xDD @ (0xB0 + reg)`8
    or  {reg: z80_iyq  }              => 0xFD @ (0xB0 + reg)`8

    otdr => 0xED @ 0xBB
    otir => 0xED @ 0xB3

    out ( c ), {reg: z80_r8} => 0xED @ (0x41 + reg * 8)`8
    out ({imm: i8}), a       => 0xD3 @ imm
    outd                     => 0xED @ 0xAB
    outi                     => 0xED @ 0xA3

    pop  {reg: z80_r16_push_pop} => (0xC1 + reg * 0x10)`8
    pop  {ixy: z80_ix_iy       } => ixy @ 0xE1

    push {reg: z80_r16_push_pop} => (0xC5 + reg * 0x10)`8
    push {ixy: z80_ix_iy       } => ixy @ 0xE5

    res {bit: u3}, ( hl )                         =>       0xCB       @ (0x86 + bit * 8      )`8
    res {bit: u3}, ({ixy: z80_ix_iy} + {off: u8}) => ixy @ 0xCB @ off @ (0x86 + bit * 8      )`8
    res {bit: u3},  {reg: z80_r8   }              =>       0xCB       @ (0x80 + bit * 8 + reg)`8

    ret                  =>  0xC9
    ret {cond: z80_cond} => (0xC0 + cond * 8)`8
    reti                 => 0xED @ 0x4D
    retn                 => 0xED @ 0x45

    rl   ( hl )                         =>        0xCB       @  0x16
    rl   ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0xCB @ off @  0x16
    rl    {reg: z80_r8}                 =>        0xCB       @ (0x10 + reg)`8
    rla                                 => 0x17
    rlc  ( hl )                         =>        0xCB       @  0x06
    rlc  ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0xCB @ off @  0x06
    rlc   {reg: z80_r8}                 =>        0xCB       @  reg`8
    rlca                                => 0x07
    rld                                 => 0xED @ 0x6F

    rr   ( hl )                         =>        0xCB       @  0x1E
    rr   ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0xCB @ off @  0x1E
    rr    {reg: z80_r8}                 =>        0xCB       @ (0x18 + reg)`8
    rra                                 => 0x1F
    rrc  ( hl )                         =>        0xCB       @  0x0E
    rrc  ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0xCB @ off @  0x0E
    rrc   {reg: z80_r8}                 =>        0xCB       @ (8 + reg)`8
    rrca                                => 0x0F
    rrd                                 => 0xED @ 0x67

    rst  0  => 0xC7
    rst  0h => 0xC7
    rst 00h => 0xC7
    rst  8h => 0xCF
    rst 08h => 0xCF
    rst 10h => 0xD7
    rst 18h => 0xDF
    rst 20h => 0xE7
    rst 28h => 0xEF
    rst 30h => 0xF7
    rst 38h => 0xFF

    sbc  a , ( hl )                         =>         0x9E
    sbc  a , ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0x9E @ off
    sbc  a ,  {imm: i8       }              =>         0xDE @ imm
    sbc  a ,  {reg: z80_r8   }              =>        (0x98 + reg)`8
    sbc  a ,  {reg: z80_ixp  }              => 0xDD @ (0x98 + reg)`8
    sbc  a ,  {reg: z80_iyq  }              => 0xFD @ (0x98 + reg)`8
    sbc  hl,  {reg: z80_r16  }              => 0xED @ (4 + reg)`4 @ 2`4

    scf => 0x37

    set {bit: u3}, ( hl )                         =>       0xCB       @ (0xC6 + bit * 8      )`8
    set {bit: u3}, ({ixy: z80_ix_iy} + {off: u8}) => ixy @ 0xCB @ off @ (0xC6 + bit * 8      )`8
    set {bit: u3},  {reg: z80_r8   }              =>       0xCB       @ (0xC0 + bit * 8 + reg)`8

    sla  ( hl )                         =>       0xCB       @  0x26
    sla  ({ixy: z80_ix_iy} + {off: u8}) => ixy @ 0xCB @ off @  0x26
    sla   {reg: z80_r8}                 =>       0xCB       @ (0x20 + reg)`8
    sra  ( hl )                         =>       0xCB       @  0x2E
    sra  ({ixy: z80_ix_iy} + {off: u8}) => ixy @ 0xCB @ off @  0x2E
    sra   {reg: z80_r8}                 =>       0xCB       @ (0x28 + reg)`8
    srl  ( hl )                         =>       0xCB       @  0x3E
    srl  ({ixy: z80_ix_iy} + {off: u8}) => ixy @ 0xCB @ off @  0x3E
    srl   {reg: z80_r8}                 =>       0xCB       @ (0x38 + reg)`8

    sub ( hl )                         =>         0x96
    sub ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0x96 @ off
    sub  {imm: i8       }              =>         0xD6 @ imm
    sub  {reg: z80_r8   }              =>        (0x90 + reg)`8
    sub  {reg: z80_ixp  }              => 0xDD @ (0x90 + reg)`8
    sub  {reg: z80_iyq  }              => 0xFD @ (0x90 + reg)`8

    xor ( hl )                         =>         0xAE
    xor ({ixy: z80_ix_iy} + {off: u8}) => ixy  @  0xAE @ off
    xor  {imm: i8       }              =>         0xEE @ imm
    xor  {reg: z80_r8   }              =>        (0xA8 + reg)`8
    xor  {reg: z80_ixp  }              => 0xDD @ (0xA8 + reg)`8
    xor  {reg: z80_iyq  }              => 0xFD @ (0xA8 + reg)`8
}
