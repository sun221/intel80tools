asm4D$OV1:
do;
/* to force the code generation this needs a non-standard definition
   of put2Hex
*/
put2Hex: procedure(arg1w, arg2w) external; declare arg1w address, arg2w address; end;

$IF OVL4
$include(asm4d.ipx)
$ELSE
$include(asmov1.ipx)
$ENDIF

declare aAssemblyComple(*) byte initial(CR, LF, 'ASSEMBLY COMPLETE,'),
	aNoErrors(*) byte initial('   NO ERRORS'),
	asc$751E(*) byte initial(' ('),
	asc$7520(*) byte initial('     )'),
	aPublicSymbols(*) byte initial(CR, LF, 'PUBLIC SYMBOLS', CR, LF, 0),
	aExternalSymbol(*) byte initial(CR, LF, 'EXTERNAL SYMBOLS', CR, LF, 0),
	pad754E address,

	aUserSymbols(*) byte data(CR, LF, 'USER SYMBOLS', CR, LF, 0),
	lstHeader(*) byte data('  LOC  OBJ         LINE        SOURCE STATEMENT', CR, LF, LF, 0),
	wa6DB2(*) address data(.aPublicSymbols, .aExternalSymbol, .aUserSymbols),
	asc$6DB8(*) byte data(CR, LF, LF, 0),
	asc$6DBC(*) byte data(CR),
	topLFs(*) byte data(LF, LF, LF, 0),
	b6DC1(2) byte data(20h, 40h),
	ascLParen(*) byte data(' (', 0),
	ascRParen(*) byte data(')', 0),
	a1234(*) byte data('  1234');


out2Hex: procedure(arg1b);
    declare arg1b byte;
    call put2Hex(.outch, arg1b);
end;


print2Hex: procedure(arg1b);
    declare arg1b byte;
    call put2Hex(.printChar, arg1b);
end;



printStr: procedure(arg1w) reentrant;
    declare arg1w address;
    declare ch based arg1w byte;

    do while ch <> 0;
        call printChar(ch);
        arg1w = arg1w + 1;
    end;
end;

printNStr: procedure(arg1b, arg2w) reentrant;
    declare arg1b byte, arg2w address;
    declare ch based arg2w byte;

    do while arg1b > 0;
        call printChar(ch);
        arg2w = arg2w + 1;
        arg1b = arg1b - 1;
    end;
end;


printCRLF: procedure reentrant;
    call printChar(0Dh);
    call printChar(0Ah);
end;

declare asc$7752 byte initial(' '),
    asc$7553(*) byte initial('    ', 0);


itoa: procedure(arg1w, arg2w);
    declare (arg1w, arg2w) address;
    declare ch based arg2w byte;

    call move(5, .spaces5, arg2w);
    arg2w = arg2w + 4;

    do while 1;
        ch = arg1w mod 10 + '0';
        arg2w = arg2w - 1;
        if (arg1w := arg1w /10) = 0 then
            return;
    end;
end;


printDecimal: procedure(arg1w) reentrant public;
    declare arg1w address;
    call itoa(arg1w, .asc$7752);
    call printStr(.asc$7553);
end;

skipToEOP: procedure public;
    do while lineCnt <= ctlPAGELENGTH;
        call outch(LF);
        lineCnt = lineCnt + 1;
    end;
end;


newPageHeader: procedure public;
    call printStr(.topLFs);
    call printStr(.asmHeader);
    call printDecimal(pageCnt);
    call printCRLF;
    if ctlTITLE then
        call printNStr(titleLen, .ctlTITLESTR);

    call printCRLF;
    call printCRLF;
    if not b68AE then
        call printStr(.lstHeader);
    pageCnt = pageCnt + 1;
end;


newPage: procedure public;
    if ctlTTY then
        call skipToEOP;
    else
        call outch(FF);

    lineCnt = 1;
    if not scanCmdLine then
        call newPageHeader;
end;


sub$6F4D: procedure public;
    if sub$465B then
    do while ctlEJECT > 0;
        call newPage;
        ctlEJECT = ctlEJECT - 1;
    end;
end;




printChar: procedure(c) reentrant;
    declare c byte;
    declare cnt byte;

    if c = FF then
    do;
        call newPage;
        return;
    end;

    if c = LF then
        if ctlPAGING then
        do;
            if (lineCnt := lineCnt + 1) >= ctlPAGELENGTH - 2 then
            do;
                if ctlTTY then
                    call outch(LF);
                if ctlEJECT > 0 then
                    ctlEJECT = ctlEJECT - 1;
                call newPage;
                return;
            end;
        end;

    if c = CR then
        curCol = 0;

    cnt = 1;
    if c = TAB then
    do;
        cnt = 8 - (curCol and 7);
        c = ' ';
    end;

    do while cnt <> 0;
        if curCol < 132 then
        do;
            if c >= ' ' then
                curCol = curCol + 1;
            if curCol > ctlPAGEWIDTH then
            do;
                call printCRLF;
                call printStr(.spaces24);
                curCol = curCol + 1;
            end;
            call outch(c);
        end;
        cnt = cnt - 1;
    end;
end;

declare b755C(*) byte initial(' CDSME');

sub7041$8447: procedure public;
    declare b7562 byte,
        w7563 address,
        (b7563, b7564) byte at(.w7563),
        b7565 byte;

    sub$718C: procedure(arg1w);
        declare arg1w address;
        declare ch based curTokenSym$p byte;

        curTokenSym$p = curTokenSym$p - 1;
        call arg1w(ch and not b7565);
    end;


    b68AE = TRUE;
    if not ctlSYMBOLS then
        return;

    b755C(0) = 'A';
    do b7562 = 0 to 2;
        jj = isPhase2Print and ctlSYMBOLS;
$IF OVL4
        ctlDEBUG = ctlDEBUG or ctlMACRODEBUG;
$ENDIF
        curTokenSym$p = symTab(1) - 2;
        call printCRLF;
        call printStr(wa6DB2(b7562));

        do while (curTokenSym$p := curTokenSym$p + 8) < endSymTab(1);
            w7563 = curTokenSym.tok(0);
            if b7563 <> 9 then
                if b7563 <> 6 then
$IF OVL4
                    if sub$3FA9 then
$ENDIF
                        if b7562 <> 0 or b7563 <> 3 then
                            if b7562 = 2 or (b7564 and b6DC1(b7562)) <> 0 then
                            do;
                                call unpackToken(curTokenSym$p - 6, .tokStr);
                                if jj then
                                do;
                                    if (ctlPAGEWIDTH - curCol) < 11h then
                                        call printCRLF;

                                    call printStr(.tokStr);
                                    call printChar(' ');
$IF OVL4
                                    if b7563 = 3Ah then
                                        call printChar('+');
                                    else
$ENDIF
				    if (b7565 := (b7564 and 40h) <> 0) then
                                        call printChar('E');
                                    else
                                        call printChar(b755C(b7564 and 7));

                                    call printChar(' ');
                                    call sub$718C(.print2Hex);
                                    call sub$718C(.print2Hex);
                                    curTokenSym$p = curTokenSym$p + 2;
                                    call printStr(.spaces4);
                                end;
                            end;
        end;
    end;

    if ctlDEBUG then
        b68AE = FALSE;

    if jj then
        call printCRLF;
end;

printCmdLine: procedure public;
    declare ch based actRead byte;

    call outch(FF);
    call sub$6F4D;
    ch = 0;
    call printStr(.cmdLineBuf);
    call newPageHeader;
end;


outStr: procedure(s) reentrant public;
    declare s address;
    declare ch based s byte;

    do while ch <> 0;
        call outch(ch);
        s = s + 1;
    end;
end;

outNStr: procedure(cnt, s) reentrant;
    declare cnt byte, s address,
        ch based s byte;

    do while cnt > 0;
        call outch(ch);
        s = s + 1;
        cnt = cnt - 1;
    end;
end;


sub$721E: procedure byte public;
    return w68A2 < w68A0;
end;



sub$7229: procedure public;
    declare ch based w68A2 byte;
    declare b7568 byte;

    if (b68AB := sub$721E or b68AB) then
    do;
        call out2Hex(high(w68A6));
        call out2Hex(low(w68A6));
    end;
    else
        call outStr(.spaces4);

    call outch(' ');
    do  b7568 = 1 to 4;
        if sub$721E and b6B34 then
        do;
            w68A6 = w68A6 + 1;
            call out2Hex(ch);
        end;
        else
            call outStr(.spaces2);

        w68A2 = w68A2 + 1;
    end;

    call outch(' ');
    if shr(jj := tokenAttr(b6A56), 6) then
        call outch('E');
    else if not b68AB then
        call outch(' ');
    else
        call outch(b755C(jj and 7));
end;


sub$72D8: procedure public;
    if not b689B then
        return;

    call printStr(.ascLParen);    /* " (" */
    call printNStr(4, .b6A57);
    call printStr(.ascRParen);    /* ")" */
    call printCRLF;
    call move(4, .asciiLineNo, .b6A57);
end;



ovl3: procedure public;
    declare ch based off6C2C byte;
$IF OVL4
    declare ch1 based off9056 byte;
$ENDIF
loop:
    w68A0 = (w68A2 := tokStart(b6A56)) + tokenSize(b6A56);
    if isSkipping then
        w68A0 = w68A2;

    call outch(asmErrCode);
$IF OVL4
    if b$905E = 0FFh then
        call outch('-');
    else
$ENDIF
        call outch(' ');

    if not blankAsmErrCode then
    do;
        asmErrCode = ' ';
        b689B = 0FFh;
    end;
    if b6B20$9A77 then
        call outStr(.spaces15);
    else
        call sub$7229;

    if fileIdx > 0 then
    do;
        call outch(a1234(ii := b6C21 + fileIdx));
        if ii > 0 then    
            call outch('=');
        else
            call outch(' ');
    end;
    else
        call outStr(.spaces2);

    if b68AD then
    do;
        call outStr(.spaces4);
        call printCRLF;
    end;
    else
    do;
        b68AD = 0FFh;
        call outNStr(4, .asciiLineNo);
$IF OVL4
        if b$905B > 1 then
            call outch('+');
        else
$ENDIF
            call outch(' ');
$IF OVL4
        if b$905B > 1 then
        do;
            curCol = 18h;
            ch1 = 0;
            call printStr(.b$8FD5);
            call printChar(LF);
        end;
        else
        do;
$ENDIF
            curCol = 18h;
            call printNStr(b6C30, off6C2E);
	    if ch <> LF then
                 call printChar(LF);
$IF OVL4
        end;
$ENDIF
    end;

    if b6B20$9A77 then
    do;
        if ctlPAGING then
            call sub$6F4D;
    end;
    else
    do;
        do while sub$721E;
            call outStr(.spaces2);
            call sub$7229;
            call printCRLF;
        end;

        if b6A56 > 0 and (b6B23 or b6B24) then
        do;
            call sub$546F;
            goto loop;
        end;
    end;

    call sub$72D8;
end;

asmComplete: procedure public;
    if errCnt > 0 then
        call itoa(errCnt, .aNoErrors);
    call printNStr((errCnt = 1) + 32, .aAssemblyComple);
    if errCnt > 0 then
    do;
        call move(4, .b6A57, .asc$7520);
        call printNStr(8, .asc$751E);
    end;
    call outch(CR);
    call outch(LF);
end;

ovl9: procedure public;
    if ctlPRINT then
        call closeF(outfd);
    outfd = 0;
    lineCnt = 1;
    call asmComplete;
    call flushout;
end;

ovl10: procedure public;
    declare ch based w68A6 byte;

    call closeF(infd);
$IF OVL4
    call closeF(macrofd);
    call delete(.asmax$ref, .statusIO);
    if ctlOBJECT then
        call closeF(objfd);
$ENDIF
    if ctlXREF then
    do;
        w68A6 = physmem - 1;
        ch = '0';
        if asxref$tmp(0) = ':' then
            ch = asxref$tmp(2);
    
        call load(.asxref, 0, 1, 0, .statusIO);
        call ioErrChk;
    end;

    call exit;
end;
end;
