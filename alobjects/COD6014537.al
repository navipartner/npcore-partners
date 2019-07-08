codeunit 6014537 "RP Epson Label Device Library"
{
    // Epson Label Command Library.
    //  Work started by Mikkel Vilhelmsen.
    //  Contributions providing function interfaces for valid
    //  Epson TM-L90 escape sequences are welcome. Functionality
    //  for other printers should be put in a library on its own.
    // 
    //  All functions write ESC code to a string buffer which can
    //  be sent to a printer or stored to a file.
    // 
    //  Functionality of this library is build
    //  with reference to
    //      https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=76
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    // 
    // ShortHandFunctions
    //  "PrintText(Text : Text[100];FontType : Text[10];Bold : Boolean;UnderLine : Boolean;DoubleStrike : Boolean;Align : Integer)"
    //   Adds the text variable to the buffer, applying the font style given as arguments.
    // 
    //  "PrintBarcode(BarcodeType : Text[30];Text : Text[30];Width : Integer;Height : Integer)"
    //   Prints a barcode corresponding to the Text argument.
    //   BarcodeType in ['UPC-A','UPC-1','EAN13','JAN8','CODE39','ITF','CODABAR']
    //   Width in [2-7], Height in [1-255].
    // 
    //  "PrintBold(Text : Text[250])"
    //   Adds the Text to buffer formatting it as bold.
    // 
    //  "PrintUnderLine(Text : Text[250])"
    //   Adds the Text to buffer formatting it as underlined.
    // 
    //  "PrintDefaultLogo()"
    //   Prints the logo stored in the printer at index 0.
    // 
    //  "PrintControlChar(Char : Text[1])"
    //   Performs an action equavalent as when writing the Char using the
    //   control font of the Epson V driver.
    // 
    //  "PrintJob("Printer Name" : Text[250])"
    //   Sends the buffer data to the printer of the specified name.
    // 
    //  "SetFontStretch(Height : Integer;Width : Integer)"
    //   Mulplies the font stretch equal to the arguments. Both arguments
    //   is in the range of [1-8].
    // 
    //  "SetFontFace(FontFace : Text[30])"
    //   Writes an ESC seqence to the buffer, telling the printer to change
    //   the font used for printing. Valid font face pattern are [A|B][1..8][1..8]
    // 
    // NPR5.32/MMV /20170410 CASE 241995 Retail Print 2.0

    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        Itt: Integer;
        J: Integer;
        cNUL: Char;
        ff: File;
        kc1: Char;
        kc2: Char;
    begin
    end;

    var
        TempPattern: Text[50];
        ESC: Codeunit "RP Escape Code Library";
        PrintBuffer: Text;
        iTemp: Integer;
        iTemp2: Integer;
        PrinterInitialized: Boolean;
        LabelHeight: Integer;

    local procedure "// Interface implementation"()
    begin
    end;

    local procedure DeviceCode(): Text
    begin
        exit('EPSON');
    end;

    procedure IsThisDevice(Text: Text): Boolean
    begin
        exit(StrPos(UpperCase(Text), DeviceCode) > 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "RP Device Settings")
    begin
        InitJob;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnEndJob', '', false, false)]
    local procedure OnEndJob()
    begin
        EndJob();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnPrintData', '', false, false)]
    local procedure OnPrintData(var POSPrintBuffer: Record "RP Print Buffer" temporary)
    begin
        with POSPrintBuffer do
          PrintData(Text, Font, Align, Rotation, Height, Width, X, Y);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnLookupFont', '', false, false)]
    local procedure OnLookupFont(var LookupOK: Boolean;var Value: Text)
    begin
        LookupOK := SelectFont(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnLookupCommand', '', false, false)]
    local procedure OnLookupCommand(var LookupOK: Boolean;var Value: Text)
    begin
        //LookupOK := SelectCommand(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnGetPageWidth', '', false, false)]
    local procedure OnGetPageWidth(FontFace: Text[30];var Width: Integer)
    begin
        Width := GetPageWidth(FontFace);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnGetPrintBytes', '', false, false)]
    local procedure OnGetPrintBytes(var PrintBytes: Text)
    begin
        PrintBytes := PrintBuffer;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnSetPrintBytes', '', false, false)]
    local procedure OnSetPrintBytes(var PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnBuildDeviceList', '', false, false)]
    local procedure OnBuildDeviceList(var tmpRetailList: Record "Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Value := DeviceCode();
        tmpRetailList.Choice := DeviceCode();
        tmpRetailList.Insert;
    end;

    local procedure "// Shorthand function"()
    begin
    end;

    procedure InitJob()
    begin
        PrintBuffer := '';
        PrinterInitialized := false;
    end;

    procedure EndJob()
    begin
        PrintDataInPageMode();
        FeedLabelToPosition(2,0,65,49); //Feed to label peeling position - This command also makes the next print backfeed to begin with.
        //FeedLabelToPosition(2,0,67,49); //Feed to print start on next label
        //FeedLabelToPosition(2,0,67,50); //Feed to print start on current label
        //FeedLabelToPosition(2,0,66,49); //Feed to cutting position
        //SelectCutModeAndCutPaper(1,0); //Cut at current position
    end;

    procedure PrintData(TextIn: Text[100];FontType: Text[100];Align: Integer;Rotation: Integer;Height: Integer;Width: Integer;X: Integer;Y: Integer)
    var
        BarcodeNo: Integer;
        Err00001: Label 'Font ''%1'' is not supported';
        FontParam: Text;
        StringLib: Codeunit "String Library";
    begin
        if not PrinterInitialized then
          InitializePrinter(FontType);

        if UpperCase(CopyStr(FontType,1,6)) = 'CODE39' then
          PrintBarcode(FontType,Width,Height,Align,Rotation,X,Y,TextIn)
        else if CopyStr(FontType,1,5) = 'EAN13' then
          PrintBarcode(FontType,Width,Height,Align,Rotation,X,Y,TextIn)
        else if CopyStr(FontType,1,4) = 'UPC-A' then
          PrintBarcode(FontType,Width,Height,Align,Rotation,X,Y,TextIn)
        else if UpperCase(CopyStr(FontType,1,7)) = 'BARCODE' then begin
          case true of
            StrLen(TextIn) = 13       : PrintBarcode('EAN13',Width,Height,Align,Rotation,X,Y,TextIn);
            StrLen(TextIn) = 12       : PrintBarcode('UPC-A',Width,Height,Align,Rotation,X,Y,TextIn);
            StrLen(TextIn) < 12       : PrintBarcode('CODE39',Width,Height,Align,Rotation,X,Y,TextIn);
          end;
        end else if CopyStr(FontType,1,4) = 'Font' then begin
          StringLib.Construct(FontType);
          FontParam := StringLib.SelectStringSep(2,' ');
          Text(FontParam,Align,Rotation,X,Y,Height,false,TextIn);
        end else if CopyStr(FontType,1,9) = 'Bold Font' then begin
          StringLib.Construct(FontType);
          FontParam := StringLib.SelectStringSep(3,' ');
          Text(FontParam,Align,Rotation,X,Y,Height,true,TextIn);
        end else if CopyStr(FontType,1,5) = 'SETUP' then
          exit
        else
          Error(Err00001,FontType);
    end;

    procedure PrintBarcode(BarcodeType: Text[30];Width: Integer;Height: Integer;Align: Integer;Rotation: Integer;X: Integer;Y: Integer;Text: Text[30])
    var
        BarcodeId: Char;
        highY: Integer;
        lowY: Integer;
        highX: Integer;
        lowX: Integer;
        highH: Integer;
        lowH: Integer;
        AreaHeight: Integer;
        highP: Integer;
        lowP: Integer;
        BitConverter: DotNet npNetBitConverter;
        ByteArray: DotNet npNetArray;
    begin
        case UpperCase(BarcodeType) of
          'UPC-A'   : BarcodeId := 0;
          'UPC-1'   : BarcodeId := 1;
          'EAN13'   : BarcodeId := 2;
          'JAN8'    : BarcodeId := 3;
          'CODE39'  : BarcodeId := 4;
          'ITF'     : BarcodeId := 5;
          'CODABAR' : BarcodeId := 6;
        end;

        SelectPrintDirectInPageMode(Rotation);

        if (LabelHeight-Y) > 0 then
          AreaHeight := LabelHeight-Y
        else
          AreaHeight := LabelHeight-1;

        ByteArray := BitConverter.GetBytes(X);
        lowX  := ByteArray.GetValue(0);
        highX := ByteArray.GetValue(1);

        ByteArray := BitConverter.GetBytes(Y);
        lowY  := ByteArray.GetValue(0);
        highY := ByteArray.GetValue(1);

        ByteArray := BitConverter.GetBytes(AreaHeight);
        lowH  := ByteArray.GetValue(0);
        highH := ByteArray.GetValue(1);

        //width is maxed (255 in each) since horizontal limit doesn't affect print
        SetPrintAreaInPageMode(lowX,highX,lowY,highY,255,255,lowH,highH);

        SetBarCodeWidth(Width);
        SetBarCodeHeight(Height);

        //Calc low & high byte for print pos
        if Height > 0 then begin
          ByteArray := BitConverter.GetBytes(Height);
          lowP  := ByteArray.GetValue(0);
          highP := ByteArray.GetValue(1);
          SetRelativeVerticalPrintPos(lowP,highP);
        end;

        PrintBarCodeA(BarcodeId,Text);
        LineFeed;

        if Rotation > 0 then
          SelectPrintDirectInPageMode(0);
    end;

    procedure PrintBold(Text: Text[250])
    begin
        TurnExphasizedModeOnOff(1);
        AddTextToBuffer(Text);
        TurnExphasizedModeOnOff(0);
    end;

    procedure PrintUnderLine(Text: Text[250])
    begin
        TurnUnderlineModeOnOff(1);
        AddTextToBuffer(Text);
        TurnUnderlineModeOnOff(0);
    end;

    procedure PrintDefaultLogo()
    begin
        PrintNVGraphicsData(1,0);
    end;

    procedure PrintAltDefaultLogo()
    begin
        // if placed on "h"
        //PrintNVGraphicsDataNew(6,0,48,69,48,48,1,1);

        // default value.
        PrintNVGraphicsDataNew(6,0,48,69,48,48,1,1);
    end;

    local procedure PrintControlChar(Char: Text[1])
    begin
        case Char of
          'G' : PrintDefaultLogo;
          'P' : SelectCutModeAndCutPaper(66,3);//papercut
          'A' : GeneratePulse(0,25,25);
          'B' : GeneratePulse(0,50,50);
          'C' : GeneratePulse(0,75,75);
          'D' : GeneratePulse(0,100,100);
          'E' : GeneratePulse(0,125,125);
          'a' : GeneratePulse(1,25,25);
          'b' : GeneratePulse(1,50,50);
          'c' : GeneratePulse(1,75,75);
          'd' : GeneratePulse(1,100,100);
          'e' : GeneratePulse(1,125,125);
          'h' : PrintAltDefaultLogo;
        end;
    end;

    procedure SetFontStretch(Height: Integer;Width: Integer)
    var
        Int: Integer;
        n: Char;
    begin
        TempPattern := '0' + ESC.GetBitPatternAndPad(Width,3) + '0' + ESC.GetBitPatternAndPad(Height,3);
        n           := ESC.TranslateBitPattern(TempPattern);
        SelectCharacterSize(n);
    end;

    procedure SetFontFace(FontFace: Text[30])
    var
        FontType: Char;
        FontWidth: Integer;
        FontHeight: Integer;
    begin
        case FontFace[1] of
          'A' : FontType := 48;
          'B' : FontType := 49;
        end;

        Evaluate(FontWidth,Format(FontFace[2]));
        Evaluate(FontHeight,Format(FontFace[3]));

        SetFontStretch(FontHeight-1,FontWidth-1);
        SelectCharacterFont(FontType);
    end;

    procedure GetPrintBytes(): Text
    begin
        exit(PrintBuffer);
    end;

    procedure SetPrintBytes(PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    procedure "// Base Functions"()
    begin
    end;

    procedure HorizontalTab()
    begin
        // Ref sheet 103, Horizontal Tab
        AddToBuffer('HT');
    end;

    procedure LineFeed()
    begin
        // Ref sheet 103, Print And Line Feed
        AddToBuffer('LF');
    end;

    procedure FormFeed()
    begin
        // Ref sheet 103, Print and return to standard mode (in page mode)
        AddToBuffer('FF');
    end;

    procedure CarriageReturn()
    begin
        // Ref sheet 103, Print and carriage return
        AddToBuffer('CR');
    end;

    procedure Cancel()
    begin
        // Ref sheet 104, Cancel print in data in page mode
        AddToBuffer('CAN');
    end;

    local procedure "// Advanced Functions"()
    begin
    end;

    local procedure Barcode()
    begin
    end;

    local procedure CancelUserDefinedCharacters(n: Char)
    begin
        // Ref sheet 116
        TempPattern := 'ESC ? %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure DefineUserDefindCharacters(y: Char;c1: Char;c2: Char)
    begin
        // Ref sheet 112
        TempPattern := 'ESC & %1 %2 %3';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(y),ESC.C2ESC(c1),ESC.C2ESC(c2)));
    end;

    local procedure ExecuteTestPrint(pL: Char;pH: Char;n: Integer;m: Integer)
    begin
        // Ref sheet 135
        TempPattern := 'GS ( A %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(pL),ESC.C2ESC(pH),n,m));
    end;

    local procedure FeedLabelToPosition(pL: Char;pH: Char;fn: Char;m: Char)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=48
        TempPattern := 'FS ( L %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(pL),ESC.C2ESC(pH),ESC.C2ESC(fn),ESC.C2ESC(m)));
    end;

    local procedure InitializePrinter(FontType: Text)
    var
        StringLib: Codeunit "String Library";
    begin
        TempPattern := 'ESC @';
        AddToBuffer(TempPattern);

        StringLib.Construct(FontType);
        if (CopyStr(FontType,1,12) = 'SETUP HEIGHT') then //Syntax: SETUP HEIGHT y
          Evaluate(LabelHeight,StringLib.SelectStringSep(3,' '))
        else
          LabelHeight := 330;

        SelectPageMode();
        SelectCharacterCodeTable(16);
        SetHorzAndVertMotionUnits(0,0);
        SelectDefaultLineSpacing();
        //SetLineSpacing(150);

        PrinterInitialized := true;
    end;

    procedure GeneratePulse(m: Integer;t1: Char;t2: Char)
    begin
        // Ref sheet 124
        TempPattern := 'ESC p %1 %2 %3';
        AddToBuffer(StrSubstNo(TempPattern,m,ESC.C2ESC(t1),ESC.C2ESC(t2)));
    end;

    local procedure PrintAndFeedPaper(n: Char)
    begin
        // Ref sheet 118
        TempPattern := 'ESC J %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure PrintAndFeedNLines(n: Char)
    begin
        // Ref sheet 123
        TempPattern := 'ESC t %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure PrintBarCodeA(m: Char;"d1..dk": Text[30])
    begin
        // Ref sheet 190 m in [0-6]
        // 0; UPC-A, 1: UPC-1, 2; EAN13, 3; JAN8, 4; CODE39
        // 5; ITF, 6; CODABAR(NW-7)
        TempPattern := 'GS k %1 %2 NUL';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(m),"d1..dk"));
    end;

    local procedure PrintBarCodeB(m: Char;"d1..dk": Text[30])
    begin
        // Ref sheet 191 m in [A-N]
        //
        TempPattern := 'GS k %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(m),"d1..dk"));
    end;

    local procedure PrintDataInPageMode()
    begin
        // Ref sheet 110
        AddToBuffer('ESC FF');
    end;

    procedure PrintNVGraphicsData(n: Char;m: Char)
    begin
        // Ref sheet 198 n in [1-255], m in [0-3]
        //
        TempPattern := 'FS p %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n),ESC.C2ESC(m)));
    end;

    procedure PrintNVGraphicsDataNew(pL: Char;pH: Char;m: Char;fn: Char;kc1: Char;kc2: Char;x: Char;y: Char)
    begin
        // Ref sheet 191 m in [A-N]
        //
        TempPattern := 'GS ( L %1 %2 %3 %4 %5 %6 %7 %8';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(pL),ESC.C2ESC(pH),ESC.C2ESC(m),ESC.C2ESC(fn),ESC.C2ESC(kc1),ESC.C2ESC(kc2),ESC.C2ESC(x),ESC.C2ESC(y)));
    end;

    local procedure SelectBitImageMode(m: Char;nL: Char;nH: Char;"d1..dk": Text[50])
    begin
        // Ref sheet 115
        TempPattern := 'ESC * %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(m),ESC.C2ESC(nL),ESC.C2ESC(nH),"d1..dk"));
    end;

    local procedure SelectCancelUserDefinedCharSet(n: Char)
    begin
        // Ref sheet 110
        TempPattern := 'ESC % ' + ESC.C2ESC(n);
        AddToBuffer(TempPattern);
    end;

    local procedure SelectCharacterCodeTable(n: Char)
    begin
        // Ref sheet 125, 16 = Windows-1252, NAV danish superset.
        TempPattern := 'ESC t %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)))
    end;

    local procedure SelectCharacterFont(n: Char)
    begin
        // Ref sheet 118 (n in [0,1])
        TempPattern := 'ESC M %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure SelectHRICharacterFont(n: Integer)
    begin
        // Ref sheet 118 (n in [0,1])
        TempPattern := 'GS f %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure SelectCharacterSize(n: Char)
    begin
        // Ref sheet 134
        // Bit 0-2 Height Magnification
        // Bit 3 Reserved
        // Bit 4-6 Width Magnification
        // Bit 7 reserved
        TempPattern := 'GS ! %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure SelectCutModeAndCutPaper(m: Char;n: Char)
    begin
        // Ref sheet 184
        TempPattern := 'GS V %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(m),ESC.C2ESC(n)));
    end;

    local procedure SelectDefaultLineSpacing()
    begin
        // Ref sheet 115
        TempPattern := 'ESC 2';
        AddToBuffer(TempPattern);
    end;

    local procedure SelectInternationalCharSet(n: Char)
    begin
        // Ref sheet 119 (n in [0,17])
        TempPattern := 'ESC R %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure SelectJustification(n: Integer)
    begin
        TempPattern := 'ESC a %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure SelectPeripheralDevice(n: Char)
    begin
        // Ref sheet 111
        TempPattern := 'ESC = %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure SelectPageMode()
    begin
        // Ref sheet 111
        TempPattern := 'ESC L';
        AddToBuffer(TempPattern);
    end;

    local procedure SelectPrintMode(n: Char)
    begin
        // Ref sheet 111
        TempPattern := 'ESC ! %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure SelectPrintSpeed(K: Char;pL: Char;pH: Char;fn: Char;m: Char)
    begin
        // Ref sheet 149, pL + pH x 256 = 2
        TempPattern := 'GS ( %1 %2 %3 %4 %5';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(K),ESC.C2ESC(pL),ESC.C2ESC(pH),ESC.C2ESC(fn),ESC.C2ESC(m)));
    end;

    local procedure SelectStandardMode()
    begin
        // Ref sheet 119
        TempPattern := 'ESC S';
        AddToBuffer(TempPattern);
    end;

    local procedure SelectPrintDirectInPageMode(n: Integer)
    begin
        // Ref sheet 120  (n in[0,1,2,3])
        TempPattern := 'ESC T %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure SetAbsolutePrintPosition(nL: Char;nH: Char)
    begin
        // Ref sheet 111
        TempPattern := 'ESC $ %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
    end;

    local procedure SetAbsVerticalPrintPos(nL: Char;nH: Char)
    begin
        // Ref sheet 134 LSB of   0 <= nL, nH <= 255
        TempPattern := 'GS $ %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
    end;

    local procedure SetBarCodeHeight(n: Char)
    begin
        // Ref sheet 189
        TempPattern := 'GS h %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure SetBarCodeWidth(n: Char)
    begin
        // Ref sheet 193
        TempPattern := 'GS w %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure SetHorzAndVertMotionUnits(x: Char;y: Char)
    begin
        // Ref sheet 183
        TempPattern := 'GS P %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(x),ESC.C2ESC(y)));
    end;

    local procedure SetHorizontalTabPositions("n1..nk": Text[50])
    begin
        // Ref sheet 117
        TempPattern := 'ESC D %1 NUL';
        AddToBuffer(StrSubstNo(TempPattern,"n1..nk"));
    end;

    local procedure SetLeftMargin(nL: Char;nH: Char)
    begin
        // Ref sheet 183
        TempPattern := 'GS L %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
    end;

    local procedure SetLineSpacing(n: Char)
    begin
        // Ref sheet 116
        TempPattern := 'ESC 3 %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure SetPrintAreaInPageMode(xL: Char;xH: Char;yL: Char;yH: Char;dxL: Char;dxH: Char;dyL: Char;dyH: Char)
    begin
        // Ref sheet 121
        AddToBuffer('ESC W');
        AddTextToBuffer(Format(xL) + Format(xH) + Format(yL) + Format(yH) + Format(dxL) + Format(dxH) + Format(dyL) + Format(dyH));
    end;

    local procedure SetPrintAreaWidth(nL: Char;nH: Char)
    begin
        // Ref sheet 184
        TempPattern := 'GS W %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
    end;

    local procedure SetPrintPosToLineBeginning(n: Char)
    begin
        //https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=61
        TempPattern := 'GS T %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure SetRelativePrintPosition(nL: Char;nH: Char)
    begin
        // Ref sheet 121
        TempPattern := 'ESC \ %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
    end;

    local procedure SetRelativeVerticalPrintPos(nL: Char;nH: Char)
    begin
        // Ref sheet 184
        TempPattern := 'GS \ %1 %2';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
    end;

    local procedure SetRightSideCharacterSpacing(n: Char)
    begin
        // Ref sheet 110
        TempPattern := 'ESC SP %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)))
    end;

    local procedure Text(Type: Text;Align: Integer;Rotation: Integer;X: Integer;Y: Integer;Height: Integer;Bold: Boolean;TextIn: Text)
    var
        tmpY: Integer;
        highY: Integer;
        lowY: Integer;
        tmpX: Integer;
        highX: Integer;
        lowX: Integer;
        tmpH: Integer;
        highH: Integer;
        lowH: Integer;
        AreaHeight: Integer;
        highP: Integer;
        lowP: Integer;
        BitConverter: DotNet npNetBitConverter;
        ByteArray: DotNet npNetArray;
    begin
        // Align     :   Alignment of text
        // Rotate    :   Orientation,                [0,1,2,3] -> [0�,90�,180�,270�]
        // Type      :   Font Type
        // Height    :   Character height
        // Width     :   Character width
        // X         :
        // Y         :
        // TextIn    :   String content

        if Bold then
          TurnExphasizedModeOnOff(1);

        if (LabelHeight-Y) > 0 then
          AreaHeight := LabelHeight-Y
        else
          AreaHeight := LabelHeight-1;

        ByteArray := BitConverter.GetBytes(X);
        lowX  := ByteArray.GetValue(0);
        highX := ByteArray.GetValue(1);

        ByteArray := BitConverter.GetBytes(Y);
        lowY  := ByteArray.GetValue(0);
        highY := ByteArray.GetValue(1);

        ByteArray := BitConverter.GetBytes(AreaHeight);
        lowH  := ByteArray.GetValue(0);
        highH := ByteArray.GetValue(1);

        //width is maxed (255 in each) since horizontal limit doesn't affect print
        SetPrintAreaInPageMode(lowX,highX,lowY,highY,255,255,lowH,highH);

        SelectPrintDirectInPageMode(Rotation);

        SetFontFace(Type);

        if Height > 0 then begin
          ByteArray := BitConverter.GetBytes(Height);
          lowP  := ByteArray.GetValue(0);
          highP := ByteArray.GetValue(1);
          SetRelativeVerticalPrintPos(lowP,highP);
        end;

        AddTextToBuffer(TextIn);
        LineFeed();

        if Bold then
          TurnExphasizedModeOnOff(0);

        if Rotation > 0 then
          SelectPrintDirectInPageMode(0);
    end;

    local procedure TurnDoubleStrikeModeOnOff(n: Integer)
    begin
        // Ref sheet 118 (n in [0,1])
        TempPattern := 'ESC G %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure TurnExphasizedModeOnOff(n: Integer)
    begin
        // Ref sheet 117 (n in [0,1])
        TempPattern := 'ESC E %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure TurnUnderlineModeOnOff(n: Integer)
    begin
        // Ref sheet 117
        TempPattern := 'ESC - %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    local procedure TurnUpsideDownPrintOnOff(n: Char)
    begin
        // Ref sheet 126 LSB of n is 1 = turn on
        TempPattern := 'ESC { %1';
        AddToBuffer(StrSubstNo(TempPattern,ESC.C2ESC(n)));
    end;

    local procedure Turn90ClockWiserRotModeOnOff(n: Integer)
    begin
        // Ref sheet 120 (n in [0,1]
        TempPattern := 'ESC V %1';
        AddToBuffer(StrSubstNo(TempPattern,n));
    end;

    procedure "// Info Functions"()
    begin
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        case FontFace[1] of
          'A' :
            case FontFace[2] of
              '1' : exit(42);
              '2' : exit(21);
              '3' : exit(14);
              '4' : exit(10);
              '5' : exit(8);
              '6' : exit(7);
              '7' : exit(6);
              '8' : exit(5);
            end;
          'B' :
            case FontFace[2] of
              '1' : exit(56);
              '2' : exit(28);
              '3' : exit(18);
              '4' : exit(14);
              '5' : exit(11);
              '6' : exit(9);
              '7' : exit(8);
              '8' : exit(7);
            end;
        end;
    end;

    procedure SelectFont(var Value: Text): Boolean
    var
        RetailList: Record "Retail List" temporary;
    begin
        ConstructFontSelectionList(RetailList);
        if PAGE.RunModal(PAGE ::"Retail List",RetailList) = ACTION::LookupOK then begin
          Value := RetailList.Choice;
          exit(true);
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "Retail List" temporary)
    begin
        AddOption(RetailList, 'Font A11');
        AddOption(RetailList, 'Font A12');
        AddOption(RetailList, 'Font A13');
        AddOption(RetailList, 'Font A14');
        AddOption(RetailList, 'Font A15');
        AddOption(RetailList, 'Font A16');
        AddOption(RetailList, 'Font A17');
        AddOption(RetailList, 'Font A18');
        AddOption(RetailList, 'Font A19');
        AddOption(RetailList, 'Font A20');
        AddOption(RetailList, 'Font A21');
        AddOption(RetailList, 'Font A22');
        AddOption(RetailList, 'Font A40');
        AddOption(RetailList, 'Font A50');

        AddOption(RetailList, 'Font B11');
        AddOption(RetailList, 'Font B12');
        AddOption(RetailList, 'Font B13');
        AddOption(RetailList, 'Font B14');
        AddOption(RetailList, 'Font B15');
        AddOption(RetailList, 'Font B16');
        AddOption(RetailList, 'Font B17');
        AddOption(RetailList, 'Font B18');
        AddOption(RetailList, 'Font B19');
        AddOption(RetailList, 'Font B20');
        AddOption(RetailList, 'Font B21');
        AddOption(RetailList, 'Font B22');
        AddOption(RetailList, 'Font B40');
        AddOption(RetailList, 'Font B50');

        AddOption(RetailList, 'Bold Font A11');
        AddOption(RetailList, 'Bold Font A12');
        AddOption(RetailList, 'Bold Font A13');
        AddOption(RetailList, 'Bold Font A14');
        AddOption(RetailList, 'Bold Font A15');
        AddOption(RetailList, 'Bold Font A16');
        AddOption(RetailList, 'Bold Font A17');
        AddOption(RetailList, 'Bold Font A18');
        AddOption(RetailList, 'Bold Font A19');
        AddOption(RetailList, 'Bold Font A20');
        AddOption(RetailList, 'Bold Font A21');
        AddOption(RetailList, 'Bold Font A22');
        AddOption(RetailList, 'Bold Font A40');
        AddOption(RetailList, 'Bold Font A50');

        AddOption(RetailList, 'Bold Font B11');
        AddOption(RetailList, 'Bold Font B12');
        AddOption(RetailList, 'Bold Font B13');
        AddOption(RetailList, 'Bold Font B14');
        AddOption(RetailList, 'Bold Font B15');
        AddOption(RetailList, 'Bold Font B16');
        AddOption(RetailList, 'Bold Font B17');
        AddOption(RetailList, 'Bold Font B18');
        AddOption(RetailList, 'Bold Font B19');
        AddOption(RetailList, 'Bold Font B20');
        AddOption(RetailList, 'Bold Font B21');
        AddOption(RetailList, 'Bold Font B22');
        AddOption(RetailList, 'Bold Font B40');
        AddOption(RetailList, 'Bold Font B50');

        AddOption(RetailList,'BARCODE EAN13');
        AddOption(RetailList,'BACRODE CODE39');
    end;

    procedure AddOption(var RetailList: Record "Retail List" temporary;Value: Text[50])
    begin
        RetailList.Number += 1;
        RetailList.Choice := Value;
        RetailList.Insert;
    end;

    local procedure "// Aux Functions"()
    begin
    end;

    local procedure AddToBuffer(Text: Text[1024])
    begin
        ESC.WriteSequenceToBuffer(Text, PrintBuffer);
    end;

    local procedure AddCharToBuffer(CharCode: Integer)
    begin
        PrintBuffer += Format(CharCode);
    end;

    local procedure AddTextToBuffer(Text: Text[1024])
    begin
        PrintBuffer += Text;
    end;
}

