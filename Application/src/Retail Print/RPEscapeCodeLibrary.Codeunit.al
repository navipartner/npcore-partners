codeunit 6014540 "NPR RP Escape Code Library"
{
    Access = Internal;
    // Escape Code Library.
    //  Work started by Nicolai Esbensen.
    //  This Library is complete. Please do not extend,
    //  but feel free to implement libraries using the functionality
    //  of this library.
    // 
    //  Functionality of this library is build
    //  with reference to
    //    - TM-T88V
    //      Specification
    //      (STANDARD)
    //      Rev. B
    // 
    //  Manual is located at
    //  "N:\UDV\POS Devices\Tutorials\epson_tmt_88v-specification.pdf"
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    //  "Get(Sequence : Text[1024]) Result : Text[30]"
    //   Translates the input sequence from text reprecentation to escape code.
    //   The valid keywords for the ESC chars at listed in the section ESC
    //   shorthands. Example of a valid ESC string is; 'GS ! ESC 1 0'.
    //   Note, blank spaces will be removed.
    // 
    //  "WriteSequenceToBuffer(VAR Sequence : Text[1024];VAR NaviString : Automation "'NaviString'.NaviString")"
    //   Translates the sequence and appends it to the NaviString variable.
    // 
    //  "C2ESC(VAR Char : Char) ReturnESCCode : Text[30]"
    //   Translates a Char variable to it's textual reprensentation. Should be done
    //   for all chararguments in order to bypass the NAV char reprensentation.
    // 
    //  "TranslateBitPattern(Pattern : Text[8]) ReturnPattern : Char"
    //   Translates the input bitpattern to its char reprensentation. A valid
    //   pattern is '00001111', with the Char reprentation ESC.
    // 
    //  "GetBitPattern(Integer : Integer) ReturnPattern : Text[30]"
    //   Returns a bitpattern in string format with a value representing
    //   the integer given as an argument.
    // 
    // ------------------------------------------------------------------------
    //  ESC Shorthands
    //    Shorthands for all individual ESC which can not be represented by
    //    a visual input sign.
    // 
    // NPR5.32/MMV /20170425  CASE 241995 Retail Print 2.0
    // NPR5.38/MHA /20180105  CASE 301053 Corrected CASE for c23 in C2ESC


    trigger OnRun()
    begin
    end;

    var
        Initialized: Boolean;
        cNUL: Char;
        c01: Char;
        c02: Char;
        c03: Char;
        cEOT: Char;
        cENQ: Char;
        cACK: Char;
        c07: Char;
        c08: Char;
        cHT: Char;
        cLF: Char;
        c11: Char;
        cFF: Char;
        cCR: Char;
        c14: Char;
        c15: Char;
        c16: Char;
        cDLE: Char;
        cXON: Char;
        cXOFF: Char;
        cDC4: Char;
        cNAK: Char;
        c22: Char;
        c23: Char;
        cCAN: Char;
        c25: Char;
        c26: Char;
        cESC: Char;
        cFS: Char;
        cGS: Char;
        cRS: Char;
        c31: Char;
        cSP: Char;
        tNUL: Text[5];

    procedure Get(Sequence: Text[1024]) Result: Text[30]
    begin
        Result := TranslateEscapeSequence(Sequence);
    end;

    procedure WriteSequenceToBuffer(Sequence: Text[1024]; var Text: Text)
    var
        String: Codeunit "NPR String Library";
        Token: Text[30];
        Itt: Integer;
    begin
        TestInitialize();
        String.Construct(Sequence);
        for Itt := 1 to String.CountOccurences(' ') + 1 do begin
            Token := String.SelectStringSep(Itt, ' ');
            case Token of
                'NUL':
                    Text += Format(cNUL);
                '01':
                    Text += Format(c01);
                '02':
                    Text += Format(c02);
                '03':
                    Text += Format(c03);
                'EOT':
                    Text += Format(cEOT);
                'ENQ':
                    Text += Format(cENQ);
                'ACK':
                    Text += Format(cACK);
                '07':
                    Text += Format(c07);
                '08':
                    Text += Format(c08);
                'HT':
                    Text += Format(cHT);
                'LF':
                    Text += Format(cLF);
                '11':
                    Text += Format(c11);
                'FF':
                    Text += Format(cFF);
                'CR':
                    Text += Format(cCR);
                '14':
                    Text += Format(c14);
                '15':
                    Text += Format(c15);
                '16':
                    Text += Format(c16);
                'DLE':
                    Text += Format(cDLE);
                'XON':
                    Text += Format(cXON);
                'XOFF':
                    Text += Format(cXOFF);
                'DC4':
                    Text += Format(cDC4);
                'NAK':
                    Text += Format(cNAK);
                '22':
                    Text += Format(c22);
                '23':
                    Text += Format(c23);
                'CAN':
                    Text += Format(cCAN);
                '25':
                    Text += Format(c25);
                '26':
                    Text += Format(c26);
                'ESC':
                    Text += Format(cESC);
                'FS':
                    Text += Format(cFS);
                'GS':
                    Text += Format(cGS);
                'RS':
                    Text += Format(cRS);
                '31':
                    Text += Format(c31);
                'SP':
                    Text += Format(cSP);
                else
                    Text += Format(Token);
            end;
        end;
    end;

    local procedure TranslateEscapeSequence(Sequence: Text[1024]) ReturnSequence: Text[1024]
    var
        String: Codeunit "NPR String Library";
        Token: Text[100];
        Itt: Integer;
    begin
        String.Construct(Sequence);
        for Itt := 1 to String.CountOccurences(' ') + 1 do begin
            Token := String.SelectStringSep(Itt, ' ');
            case Token of
                'NUL':
                    ReturnSequence += NUL();
                '01':
                    ReturnSequence += "01"();
                '02':
                    ReturnSequence += "02"();
                '03':
                    ReturnSequence += "03"();
                'EOT':
                    ReturnSequence += EOT();
                'ENQ':
                    ReturnSequence += ENQ();
                'ACK':
                    ReturnSequence += ACK();
                '07':
                    ReturnSequence += "07"();
                '08':
                    ReturnSequence += "08"();
                'HT':
                    ReturnSequence += HT();
                'LF':
                    ReturnSequence += LF();
                '11':
                    ReturnSequence += "11"();
                'FF':
                    ReturnSequence += FF();
                'CR':
                    ReturnSequence += CR();
                '14':
                    ReturnSequence += "14"();
                '15':
                    ReturnSequence += "15"();
                '16':
                    ReturnSequence += "16"();
                'DLE':
                    ReturnSequence += DLE();
                'XON':
                    ReturnSequence += XON();
                'XOFF':
                    ReturnSequence += XOFF();
                'DC4':
                    ReturnSequence += DC4();
                'NAK':
                    ReturnSequence += NAK();
                '22':
                    ReturnSequence += "22"();
                '23':
                    ReturnSequence += "23"();
                'CAN':
                    ReturnSequence += CAN();
                '25':
                    ReturnSequence += "25"();
                '26':
                    ReturnSequence += "26"();
                'ESC':
                    ReturnSequence += ESC();
                'FS':
                    ReturnSequence += FS();
                'GS':
                    ReturnSequence += GS();
                'RS':
                    ReturnSequence += RS();
                '31':
                    ReturnSequence += "31"();
                'SP':
                    ReturnSequence += SP();
                else
                    ReturnSequence += Token;
            end;
        end;
    end;

    procedure C2ESC(Char: Char) ReturnESCCode: Text[30]
    begin
        case Char of
            cNUL:
                exit('NUL');
            c01:
                exit('01');
            c02:
                exit('02');
            c03:
                exit('03');
            cEOT:
                exit('EOT');
            cENQ:
                exit('ENQ');
            cACK:
                exit('ACK');
            c07:
                exit('07');
            c08:
                exit('08');
            cHT:
                exit('HT');
            cLF:
                exit('LF');
            c11:
                exit('11');
            cFF:
                exit('FF');
            cCR:
                exit('CR');
            c14:
                exit('14');
            c15:
                exit('15');
            c16:
                exit('16');
            cDLE:
                exit('DLE');
            cXON:
                exit('XON');
            cXOFF:
                exit('XOFF');
            cDC4:
                exit('DC4');
            cNAK:
                exit('NAK');
            c22:
                exit('22');
            //-NPR5.38 [301053]
            //c22   :  EXIT('23');
            c23:
                exit('23');
            //+NPR5.38 [301053]
            cCAN:
                exit('CAN');
            c25:
                exit('25');
            c26:
                exit('26');
            cESC:
                exit('ESC');
            cFS:
                exit('FS');
            cGS:
                exit('GS');
            cRS:
                exit('RS');
            c31:
                exit('31');
            cSP:
                exit('SP');
            else
                exit(Format(Char))
        end;
    end;

    procedure TranslateBitPattern(Pattern: Text[8]) ReturnPattern: Char
    var
        Itt: Integer;
        TempInt: Integer;
    begin
        for Itt := 8 downto 1 do begin
            if Format(Pattern[Itt]) = '1' then
                TempInt += Power(2, 8 - Itt);
        end;
        ReturnPattern := TempInt;
    end;

    procedure GetBitPattern("Integer": Integer) ReturnPattern: Text[30]
    var
        Itt: Integer;
        BitLength: Integer;
    begin
        for Itt := 30 downto 0 do begin
            if (Integer div Power(2, Itt)) > 0 then begin
                BitLength := Itt;
                Itt := 0;
            end;
        end;

        for Itt := BitLength downto 0 do begin
            if (Integer div Power(2, Itt)) > 0 then begin
                ReturnPattern := ReturnPattern + '1';
                Integer -= Power(2, Itt);
            end else
                ReturnPattern := ReturnPattern + '0'
        end;
    end;

    procedure GetBitPatternAndPad("Integer": Integer; PatternLength: Integer) ReturnPattern: Text[30]
    var
        String: Codeunit "NPR String Library";
    begin
        ReturnPattern := String.PadStrLeft(GetBitPattern(Integer), PatternLength, '0', false);
    end;

    local procedure Initialize()
    begin
        cNUL := 0;
        tNUL := Format(cNUL);
        c01 := 1;
        c02 := 2;
        c03 := 3;
        cEOT := 4;
        cENQ := 5;
        cACK := 6;
        c07 := 7;
        c08 := 8;
        cHT := 9;
        cLF := 10;
        c11 := 11;
        cFF := 12;
        cCR := 13;
        c14 := 14;
        c15 := 15;
        c16 := 16;
        cDLE := 17;
        cXON := 18;
        cXOFF := 19;
        cDC4 := 20;
        cNAK := 21;
        c22 := 22;
        c23 := 23;
        cCAN := 24;
        c25 := 25;
        c26 := 26;
        cESC := 27;
        cFS := 28;
        cGS := 29;
        cRS := 30;
        c31 := 31;
        cSP := 32;
        Initialized := true;
    end;

    local procedure TestInitialize()
    begin
        if not Initialized then
            Initialize();
    end;

    procedure "-- ESC Shorthands"()
    begin
    end;

    procedure NUL(): Text[1]
    begin
        TestInitialize();
        exit(Format(cNUL));
    end;

    procedure "01"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c01));
    end;

    procedure "02"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c02));
    end;

    procedure "03"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c03));
    end;

    procedure EOT(): Text[1]
    begin
        TestInitialize();
        exit(Format(cEOT));
    end;

    procedure ENQ(): Text[1]
    begin
        TestInitialize();
        exit(Format(cEOT));
    end;

    procedure ACK(): Text[1]
    begin
        TestInitialize();
        exit(Format(cACK));
    end;

    procedure "07"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c07));
    end;

    procedure "08"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c08));
    end;

    procedure HT(): Text[1]
    begin
        TestInitialize();
        exit(Format(cHT));
    end;

    procedure LF(): Text[1]
    begin
        TestInitialize();
        exit(Format(cLF));
    end;

    procedure "11"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c11));
    end;

    procedure FF(): Text[1]
    begin
        TestInitialize();
        exit(Format(cFF));
    end;

    procedure CR(): Text[1]
    begin
        TestInitialize();
        exit(Format(cCR));
    end;

    procedure "14"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c14));
    end;

    procedure "15"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c15));
    end;

    procedure "16"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c16));
    end;

    procedure DLE(): Text[1]
    begin
        TestInitialize();
        exit(Format(cDLE));
    end;

    procedure XON(): Text[1]
    begin
        TestInitialize();
        exit(Format(cXON));
    end;

    procedure XOFF(): Text[1]
    begin
        TestInitialize();
        exit(Format(cXOFF));
    end;

    procedure DC4(): Text[1]
    begin
        TestInitialize();
        exit(Format(cDC4));
    end;

    procedure NAK(): Text[1]
    begin
        TestInitialize();
        exit(Format(cNAK));
    end;

    procedure "22"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c22));
    end;

    procedure "23"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c23));
    end;

    procedure CAN(): Text[1]
    begin
        TestInitialize();
        exit(Format(cCAN));
    end;

    procedure "25"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c25));
    end;

    procedure "26"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c26));
    end;

    procedure ESC(): Text[1]
    begin
        TestInitialize();
        exit(Format(cESC));
    end;

    procedure FS(): Text[1]
    begin
        TestInitialize();
        exit(Format(cFS));
    end;

    procedure GS(): Text[1]
    begin
        TestInitialize();
        exit(Format(cGS));
    end;

    procedure RS(): Text[1]
    begin
        TestInitialize();
        exit(Format(cRS));
    end;

    procedure "31"(): Text[1]
    begin
        TestInitialize();
        exit(Format(c31));
    end;

    procedure SP(): Text[1]
    begin
        TestInitialize();
        exit(Format(cSP));
    end;

    procedure GetCharNo(CharNo: Integer) Char: Char
    begin
        Char := CharNo;
    end;
}

