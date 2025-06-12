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

; identifier for IX with A, B, C, D, E, high or low
#subruledef z80_ix {
    ixa => 7`3
    ixb => 0`3
    ixc => 1`3
    ixd => 2`3
    ixe => 3`3
    ixh => 4`3
    ixl => 5`3
}

; identifier for IY with A, B, C, D, E, high or low
#subruledef z80_iy {
    iya => 7`3
    iyb => 0`3
    iyc => 1`3
    iyd => 2`3
    iye => 3`3
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


#ruledef z80
{
    adc  a , ( hl )                         =>        0x8E
    adc  a , ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0x8E    @ off
    adc  a ,  {imm: i8       }              =>        0xCE    @ imm
    adc  a ,  {reg: z80_r8   }              =>        0b10001 @ reg
    adc  a ,  {reg: z80_ix   }              => 0xDD @ 0b10001 @ reg
    adc  a ,  {reg: z80_iy   }              => 0xFD @ 0b10001 @ reg
    adc  hl,  {reg: z80_r16  }              => 0xED @ 0b01    @ reg @ 0xA`4

    adc  a , ( hl )                         =>        0x86
    adc  a , ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0x86    @ off
    adc  a ,  {imm: i8       }              =>        0xC6    @ imm
    adc  a ,  {reg: z80_r8   }              =>        0b10000 @ reg
    adc  a ,  {reg: z80_ix   }              => 0xDD @ 0b10000 @ reg
    adc  a ,  {reg: z80_iy   }              => 0xFD @ 0b10000 @ reg
    adc  hl,  {reg: z80_r16  }              =>        0b00    @ reg @ 0x9`4
    adc  {ixy: z80_ix_iy}, {reg: z80_r16}   => ixy  @ 0b00    @ reg @ 0x9`4

    and  ( hl )                             =>        0xA6
    and  ({ixy: z80_ix_iy} + {off: u8})     => ixy  @ 0xA6    @ off
    and   {imm: i8       }                  =>        0xE6    @ imm
    and   {reg: z80_r8   }                  =>        0b10100 @ reg
    and   {reg: z80_ix   }                  => 0xDD @ 0b10100 @ reg
    and   {reg: z80_iy   }                  => 0xFD @ 0b10100 @ reg

    bit  {bit: u3}, ( hl )                         =>       0xCB @ off @ 0b01 @ bit @ 6`3
    bit  {bit: u3}, ({ixy: z80_ix_iy} + {off: u8}) => ixy @ 0xCB @ off @ 0b01 @ bit @ 6`3
    bit  {bit: u3},  {reg: z80_r8   }              =>       0xCB @ off @ 0b01 @ bit @ reg

    call                   {imm: u16} => 0xCD @ le(imm)
    call {cond: z80_cond}, {imm: u16} => 0b11 @ cond @ 0b100 @ le(imm)

    ccf  => 0x3F

    cp   ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0xBE    @ off
    cp    {imm: i8       }              =>        0xFE    @ imm
    cp    {reg: z80_r8   }              =>        0b10111 @ reg
    cp    {reg: z80_ix   }              => 0xDD @ 0b10111 @ reg
    cp    {reg: z80_iy   }              => 0xFD @ 0b10111 @ reg

    cpd  => 0xED @ 0xA9
    cpdr => 0xED @ 0xB9
    cpi  => 0xED @ 0xA1
    cpir => 0xED @ 0xB1
    cpl  => 0x2F
    daa  => 0x27

    dec ( hl )                         =>        0x35
    dec ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0x35 @ off
    dec  {reg: z80_r8   }              =>        0b00 @ reg @ 5`3
    dec  {reg: z80_r16  }              =>        0b00 @ reg @ 0xB`4
    dec  {ixy: z80_ix_iy}              => ixy  @ 0x2B
    dec  {reg: z80_ix   }              => 0xDD @ 0b00 @ reg @ 5`3
    dec  {reg: z80_iy   }              => 0xFD @ 0b00 @ reg @ 5`3

    di             => 0xF3
    djnz {off: u8} => 0x10 @ off
    ei             => 0xFB

    ex (sp), hl               =>        0xE3
    ex (sp), {ixy: z80_ix_iy} => ixy  @ 0xE3
    ex  af , af               => 0x08        ; is it " ex af, af' " ?
    ex  de , hl               => 0xEB

    exx  => 0xD9
    halt => 0x76

    im 0 => 0xED @ 0x46
    im 1 => 0xED @ 0x56
    im 2 => 0xED @ 0x5E

    in a, ({imm: i8    }) => 0xDB @ imm
    in a, ({reg: z80_r8}) => 0xED @ 0b01 @ reg @ 0b000

    inc ( hl )                         =>        0x34   
    inc ({ixy: z80_ix_iy} + {off: u8}) => ixy  @ 0x34 @ off
    inc  {reg: z80_r8   }              =>        0b00 @ reg @ 4`3
    inc  {reg: z80_r16  }              =>        0b00 @ reg @ 3`4
    inc  {ixy: z80_ix_iy}              => ixy  @ 0x23
    inc  {reg: z80_ix   }              => 0xDD @ 0b00 @ reg @ 4`3
    inc  {reg: z80_iy   }              => 0xFD @ 0b00 @ reg @ 4`3

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
    
    ld  ( bc ), a                                     => 0x02
    ld  ( de ), a                                     => 0x12
    ld  ( hl ), {imm: i8}                             =>        0x36              @ imm
    ld  ({ixy: z80_ix_iy} + {off: u8}), {imm: i8}     => ixy  @ 0x36    @ off     @ imm
    ld  ( hl ), {reg: z80_r8}                         =>        0b01110 @ reg
    ld  ({ixy: z80_ix_iy} + {off: u8}), {reg: z80_r8} => ixy  @ 0b01110 @ reg     @ off
    ld  ({imm: i16     }), a                          =>        0x32    @ le(imm)
    ld  ({imm: i16     }), bc                         => 0xED @ 0x43    @ le(imm)
    ld  ({imm: i16     }), de                         => 0xED @ 0x53    @ le(imm)
    ld  ({imm: i16     }), hl                         =>        0x22    @ le(imm)
    ld  ({imm: i16     }), ix                         => 0xDD @ 0x22    @ le(imm)
    ld  ({imm: i16     }), iy                         => 0xFD @ 0x22    @ le(imm)
    ld  ({imm: i16     }), sp                         => 0xED @ 0x73    @ le(imm)
    ld   a, ( bc )                                    => 0x0A
    ld   a, ( de )                                    => 0x1A
    ld   a, ( hl )                                    => 0x7E
    ld   a, ({ixy: z80_ix_iy} + {off: u8})            => ixy  @ 0x7E    @ off
    ld   a, ({imm: i16      })                        => 0x3A @ le(imm)
    ld   a,  {imm: i8       }                         => 0x3E @ imm
    ld   a,  {reg: z80_r8   }                         =>        0b01111 @ reg
    ld   a,  {reg: z80_ix   }                         => 0xDD @ 0b01111 @ reg
    ld   a,  {reg: z80_iy   }                         => 0xFD @ 0b01111 @ reg
    ld   a,  i                                        => 0xED @ 0x57
    ld   a,  r                                        => 0xED @ 0x5F

; ref:
; https://map.grauw.nl/resources/z80instr.php#instructionset

}
