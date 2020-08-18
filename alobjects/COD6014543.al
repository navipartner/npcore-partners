codeunit 6014543 "RP Epson V Device Library"
{
    // Epson V Command Library.
    //  Work started by Nicolai Esbensen.
    //  Contributions providing function interfaces for valid
    //  Epson TM-T88V escape sequences are welcome. Functionality
    //  for other printers should be put in a library on its own.
    // 
    //  All functions write ESC code to a string buffer which can
    //  be sent to a printer or stored to a file.
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
    // ---------------------------------------------------------------------------------
    // Base Functions
    //  Writes standard functional sequences to the buffer. All with reference to the
    //  manual.
    // 
    // ---------------------------------------------------------------------------------
    // Advanced Functions
    //  Implementations of ESC function calls. All functions have references to the
    //  documentation sheet in the printer documentation.
    // 
    // ---------------------------------------------------------------------------------
    // Info Functions
    //  List of functions implementing printer information.
    // 
    // ---------------------------------------------------------------------------------
    // Test Functions
    //  Functions for testing the functionality implemented in this library.
    // 
    // NPR4.02/MMV/20150416 CASE 211669 Decreased barcode width from 4 to 2 when FontType is Code39 to fit integers with more than 6 numbers.
    //                                  Also added small comment in PrintBarcode to make it clear that only uppercase CODE39 barcode fonts have hardcoded widths.
    // 
    // NPR4.15/MMV/20151002 CASE 223893 Added methods for printing with Epson webservice:
    //                                  PrintWeb()
    //                                  IntToHex()
    //                                  SetPrintBuffer()
    //                                  GetPrintBuffer()
    // 
    // NPR4.15/TSA/20151015 CASE 220508 Changed the printjob function to handle proxy print
    // 
    // NPR4.16/MMV/20151104 CASE 226339 Only run StringBufferDotNet when printing to a local printer (meaning not through Epson webservice or proxy) since it is client-side .NET
    // NPR4.16/TSA/20151109 CASE 220508 Refactored proxy printing, separating formating formating and print method. PrintJob() restored
    // NPR4.18/MMV/20160128 CASE 224257 Allow custom width for barcodes
    // NPR4.21/MMV/20160205 CASE 223223 Added support for sending logo bitmaps from NAV
    // NPR5.20/MMV/20160225 CASE 233229 Moved print method logic away from device codeunits.
    //                                  Also removed old case comments, along with small cleanup/renaming.
    // NPR5.25/MMV /20160622 CASE 245048 Moved graphic buffer command away from Escape Library CU since it cannot handle char 32 (space).
    // NPR5.29/MMV /20170117 CASE 245881 Added support for code128.
    //                                   Refactored barcode code.
    // NPR5.29.01/MMV /20170202 CASE 265076 Added AUTOCALCFIELD when retrieving retail logo.
    // NPR5.29.01/MMV /20170203 CASE 265474 Added temporary code for barcode size that hardcoded print objects might depend on for now.
    // NPR5.32/MMV /20170324 CASE 241995 Retail Print 2.0
    // NPR5.35/MMV /20170817 CASE 287357 Updated HTTP payload.
    // NPR5.37/MMV /20170929 CASE 291769 Added font widths for 58mm.
    // NPR5.37/MMV /20171002 CASE 269767 Added proper command support.
    // NPR5.37/MMV /20171012 CASE 290904 Added encoding command.
    // NPR5.40/MMV /20180305 CASE 284505 Moved from global string buffer to global blob buffer for performance.
    //                                   Removed excessive usage of escape command library for performance.
    // NPR5.54/MMV /20200207 CASE 389961 Removed .NET interop in SetFontStretch
    // NPR5.55/MITH/20200210 CASE 387982 Added "DPI" to device settings to handle different DPIs (m30 uses 300 dpi)

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
        SETTING_MEDIAWIDTH: Label 'Width of media.';
        MediaWidth: Option "80mm","58mm";
        SETTING_ENCODING: Label 'Text encoding.';
        Error_InvalidDeviceSetting: Label 'Invalid device setting: %1';
        Encoding: Option "Windows-1252","Windows-1256";
        PrintBuffer: Codeunit "Temp Blob";
        PrintBufferOutStream: OutStream;
        DPI: Option "200","300";
        SETTING_DPI: Label 'DPI of device.';

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

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "RP Device Settings")
    begin
        Init(DeviceSettings);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnLineFeed', '', false, false)]
    local procedure OnLineFeed()
    begin
        LineFeed;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnPrintData', '', false, false)]
    local procedure OnPrintData(var POSPrintBuffer: Record "RP Print Buffer" temporary)
    begin
        with POSPrintBuffer do
            PrintData(Text, Font, Bold, Underline, DoubleStrike, Align, Width);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnLookupFont', '', false, false)]
    local procedure OnLookupFont(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectFont(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnLookupCommand', '', false, false)]
    local procedure OnLookupCommand(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectCommand(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnLookupDeviceSetting', '', false, false)]
    local procedure OnLookupDeviceSetting(var LookupOK: Boolean; var tmpDeviceSetting: Record "RP Device Settings" temporary)
    begin
        LookupOK := SelectDeviceSetting(tmpDeviceSetting);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetPageWidth', '', false, false)]
    local procedure OnGetPageWidth(FontFace: Text[30]; var Width: Integer)
    begin
        Width := GetPageWidth(FontFace);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetTargetEncoding', '', false, false)]
    local procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
        //-NPR5.37 [290904]
        //TargetEncoding := 'iso-8859-1';
        case Encoding of
            Encoding::"Windows-1252":
                //Hack: iso-8859-1 implements everything between 0-255 without any gaps, which we need for printing logos since all possible byte values need to be represented in the printjob.
                //Correct solution would be to build a bytearray instead of string in variable PrintBuffer. Biggest consequence at this moment is the lack of euro sign in iso-8859-1.
                TargetEncoding := 'iso-8859-1';
            Encoding::"Windows-1256":
                TargetEncoding := 'Windows-1256';
        end;
        //+NPR5.37 [290904]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnPrepareJobForHTTP', '', false, false)]
    local procedure OnPrepareJobForHTTP(var FormattedTargetEncoding: Text; var HTTPEndpoint: Text; var Supported: Boolean)
    begin
        FormattedTargetEncoding := 'utf-8';
        HTTPEndpoint := '/cgi-bin/epos/service.cgi?devid=local_printer&timeout=15000';
        //-NPR5.40 [284505]
        //PrintBuffer := FormatJobForHTTP(PrintBuffer);
        FormatJobForHTTP();
        //+NPR5.40 [284505]
        Supported := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnPrepareJobForBluetooth', '', false, false)]
    local procedure OnPrepareJobForBluetooth(var FormattedTargetEncoding: Text; var Supported: Boolean)
    begin
        //-NPR5.37 [290904]
        //FormattedTargetEncoding := 'iso-8859-1';
        case Encoding of
            Encoding::"Windows-1252":
                //Hack: iso-8859-1 implements everything between 0-255 without any gaps, which we need for printing logos since all possible byte values need to be represented in the printjob.
                //Correct solution would be to build a bytearray instead of string in variable PrintBuffer. Biggest consequence at this moment is the lack of euro sign in iso-8859-1.
                FormattedTargetEncoding := 'iso-8859-1';
            Encoding::"Windows-1256":
                FormattedTargetEncoding := 'Windows-1256';
        end;
        //+NPR5.37 [290904]
        Supported := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetPrintBytes', '', false, false)]
    local procedure OnGetPrintBytes(var PrintBytes: Text)
    begin
        //-NPR5.40 [284505]
        //PrintBytes := PrintBuffer;
        PrintBytes := GetPrintBytes();
        //+NPR5.40 [284505]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnSetPrintBytes', '', false, false)]
    local procedure OnSetPrintBytes(var PrintBytes: Text)
    begin
        //-NPR5.40 [284505]
        //PrintBuffer := PrintBytes;
        SetPrintBytes(PrintBytes);
        //+NPR5.40 [284505]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnBuildDeviceList', '', false, false)]
    local procedure OnBuildDeviceList(var tmpRetailList: Record "Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Value := DeviceCode();
        tmpRetailList.Choice := DeviceCode();
        tmpRetailList.Insert;
    end;

    procedure "// ShortHandFunctions"()
    begin
    end;

    procedure Init(var DeviceSettings: Record "RP Device Settings")
    begin
        //-NPR5.40 [284505]
        //CLEAR(PrintBuffer);
        InitBuffer();
        //+NPR5.40 [284505]
        Clear(MediaWidth);

        if DeviceSettings.FindSet then
            repeat
                case DeviceSettings.Name of
                    'MEDIA_WIDTH':
                        if DeviceSettings.Value = '58mm' then
                            MediaWidth := MediaWidth::"58mm";
                    'ENCODING':
                        if DeviceSettings.Value = 'Windows-1256' then
                            Encoding := Encoding::"Windows-1256";
            //-NPR5.55 [387982]
            'DPI' :
              if DeviceSettings.Value = '300' then
                DPI := DPI::"300";
            //+NPR5.55 [387982]
                    else
                        Error(Error_InvalidDeviceSetting, DeviceSettings.Value);
                end;
            until DeviceSettings.Next = 0;

        InitializePrinter;
        case Encoding of
            Encoding::"Windows-1252":
                SelectCharacterCodeTable(16);
            Encoding::"Windows-1256":
                SelectCharacterCodeTable(50);
        end;
    end;

    procedure PrintData(Data: Text[100]; FontType: Text[10]; Bold: Boolean; UnderLine: Boolean; DoubleStrike: Boolean; Align: Integer; Width: Integer)
    var
        BarcodeNo: Integer;
    begin
        if UpperCase(FontType) = 'CONTROL' then
            PrintControlChar(CopyStr(Data, 1, 1))
        else
            if UpperCase(FontType) = 'COMMAND' then
                SendCommand(Data)
            else
                if IsBarcodeFont(FontType) then
                    PrintBarcode(FontType, Data, Width, 40)
                else
                    if FontType = 'Logo' then
                        PrintBitmapFromKeyword(Data, '')
                    else begin
                        SelectJustification(Align);
                        if Bold then TurnExphasizedModeOnOff(1);
                        if UnderLine then TurnUnderlineModeOnOff(1);
                        if DoubleStrike then TurnDoubleStrikeModeOnOff(1);

                        SetFontFace(FontType);
                        AddTextToBuffer(Data);

                        if Bold then TurnExphasizedModeOnOff(0);
                        if UnderLine then TurnUnderlineModeOnOff(0);
                        if DoubleStrike then TurnDoubleStrikeModeOnOff(0);
                    end;
    end;

    procedure PrintBarcode(BarcodeType: Text[30]; Text: Text; Width: Integer; Height: Integer)
    var
        Int: Integer;
        Code128: Text;
    begin
        if BarcodeType in ['CODE39', 'Barcode4'] then
            Width := 1;

        if BarcodeType = 'Code39' then
            Width := 2;

        if BarcodeType = 'EAN13' then
            Width := 3;

        BarcodeType := UpperCase(BarcodeType);

        if CopyStr(BarcodeType, 1, 7) = 'BARCODE' then begin
            Evaluate(Int, Format(BarcodeType[8]));
            case Int of
                1:
                    BarcodeType := 'UPC-A';
                2:
                    BarcodeType := 'UPC-E';
                3:
                    BarcodeType := 'EAN13';
                4:
                    BarcodeType := 'CODE39';
                5:
                    BarcodeType := 'EAN8';
                6:
                    BarcodeType := 'ITF';
                7:
                    BarcodeType := 'CODABAR';
            end;

            if Int = 4 then
                Height := 60
            else
                Height := 40;
        end;
        //REMOVE EVERYTHING ABOVE THIS LINE WHEN HARDCODED PRINTS ARE DEPRECATED

        SelectJustification(1);
        SetBarCodeWidth(Width);
        SetBarCodeHeight(Height);

        case BarcodeType of
            'UPC-A':
                PrintBarCodeA(0, Text);
            'UPC-E':
                PrintBarCodeA(1, Text);
            'EAN13':
                PrintBarCodeA(2, Text);
            'EAN8':
                PrintBarCodeA(3, Text);
            'CODE39':
                PrintBarCodeA(4, Text);
            'ITF':
                PrintBarCodeA(5, Text);
            'CODABAR':
                PrintBarCodeA(6, Text);
            'CODE128':
                begin
                    Code128 := BuildCommandC128(Text);
                    if StrLen(Code128) > 0 then
                        PrintBarCodeB(73, StrLen(Code128), Code128);
                end;
            'QR':
                begin
                    Error('Not implemented');
                end;
        end;

        AddTextToBuffer(Text);
        LineFeed;
        SelectJustification(0);
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
        PrintNVGraphicsData(1, 0);
    end;

    procedure PrintAltDefaultLogo()
    var
        Register: Record Register;
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        Register.Get(RetailFormCode.FetchRegisterNumber);
        if Register."Send Receipt Logo from NAV" then
            PrintBitmapFromKeyword('RECEIPT', Register."Register No.")
        else
            PrintNVGraphicsDataNew(6, 0, 48, 69, 48, 48, 1, 1);
    end;

    local procedure PrintControlChar(Char: Text[1])
    begin
        case Char of
            'G':
                PrintDefaultLogo;
            'P':
                SelectCutModeAndCutPaper(66, 3);//papercut
            'A':
                GeneratePulse(0, 25, 25);
            'B':
                GeneratePulse(0, 50, 50);
            'C':
                GeneratePulse(0, 75, 75);
            'D':
                GeneratePulse(0, 100, 100);
            'E':
                GeneratePulse(0, 125, 125);
            'a':
                GeneratePulse(1, 25, 25);
            'b':
                GeneratePulse(1, 50, 50);
            'c':
                GeneratePulse(1, 75, 75);
            'd':
                GeneratePulse(1, 100, 100);
            'e':
                GeneratePulse(1, 125, 125);
            'h':
                PrintAltDefaultLogo;
            'm':
                PrintBitmapFromKeyword('TAXFREE', '');
        end;
    end;

    local procedure SendCommand(Command: Text)
    begin
        case UpperCase(Command) of
            'OPENDRAWER':
                GeneratePulse(0, 25, 25);
            'PAPERCUT':
                SelectCutModeAndCutPaper(66, 3);
            'STOREDLOGO_1':
                PrintNVGraphicsDataNew(6, 0, 48, 69, 48, 48, 1, 1);
            'STOREDLOGO_2':
                PrintNVGraphicsData(1, 0);
        end;
    end;

    procedure SetFontStretch(Height: Integer; Width: Integer)
    begin
        //-NPR5.54 [389961]
        if (Height > 7) or (Height < 0) then
            Height := 0;
        if (Width > 7) or (Width < 0) then
            Width := 0;

        SelectCharacterSize(Power(2, 4) * Width + Height); //Width is packed into upper half of 8-bit byte.
        //+NPR5.54 [389961]
    end;

    procedure SetFontFace(FontFace: Text[30])
    var
        FontType: Char;
        FontWidth: Integer;
        FontHeight: Integer;
    begin
        case FontFace[1] of
            'A':
                FontType := 48;
            'B':
                FontType := 49;
        end;

        Evaluate(FontWidth, Format(FontFace[2]));
        Evaluate(FontHeight, Format(FontFace[3]));

        SetFontStretch(FontHeight - 1, FontWidth - 1);
        SelectCharacterFont(FontType);
    end;

    procedure SetPrintBytes(PrintBytes: Text)
    begin
        //-NPR5.40 [284505]
        //PrintBuffer := PrintBytes;
        InitBuffer();
        PrintBufferOutStream.Write(PrintBytes);
        //+NPR5.40 [284505]
    end;

    procedure GetPrintBytes(): Text
    var
        PrintBufferInStream: InStream;
        BufferText: Text;
        Result: Text;
        MemoryStream: DotNet npNetMemoryStream;
        StreamReader: DotNet npNetStreamReader;
        Encoding: DotNet npNetEncoding;
    begin
        //-NPR5.40 [284505]
        //EXIT(PrintBuffer);
        PrintBuffer.CreateInStream(PrintBufferInStream, TEXTENCODING::UTF8);
        MemoryStream := PrintBufferInStream;
        MemoryStream.Position := 0;
        StreamReader := StreamReader.StreamReader(MemoryStream, Encoding.UTF8);
        exit(StreamReader.ReadToEnd());
        //+NPR5.40 [284505]
    end;

    procedure "// Base Functions"()
    begin
    end;

    procedure HorizontalTab()
    begin
        // Ref sheet 103, Horizontal Tab
        //-NPR5.40 [284505]
        //AddToBuffer('HT');
        AddTextToBuffer(ESC.HT);
        //+NPR5.40 [284505]
    end;

    procedure LineFeed()
    begin
        // Ref sheet 103, Print And Line Feed
        //-NPR5.40 [284505]
        //AddToBuffer('LF');
        AddTextToBuffer(ESC.LF);
        //+NPR5.40 [284505]
    end;

    procedure FormFeed()
    begin
        // Ref sheet 103, Print and return to standard mode (in page mode)
        //-NPR5.40 [284505]
        //AddToBuffer('FF');
        AddTextToBuffer(ESC.FF);
        //+NPR5.40 [284505]
    end;

    procedure CarriageReturn()
    begin
        // Ref sheet 103, Print and carriage return
        //-NPR5.40 [284505]
        //AddToBuffer('CR');
        AddTextToBuffer(ESC.CR);
        //+NPR5.40 [284505]
    end;

    procedure Cancel()
    begin
        // Ref sheet 104, Cancel print in data in page mode
        //-NPR5.40 [284505]
        //AddToBuffer('CAN');
        AddTextToBuffer(ESC.CAN);
        //+NPR5.40 [284505]
    end;

    local procedure "// Advanced Functions"()
    begin
    end;

    local procedure CancelUserDefinedCharacters(n: Char)
    begin
        // Ref sheet 116
        //-NPR5.40 [284505]
        // TempPattern := 'ESC ? %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + '?' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure DefineUserDefindCharacters(y: Char; c1: Char; c2: Char)
    begin
        // Ref sheet 112
        //-NPR5.40 [284505]
        // TempPattern := 'ESC & %1 %2 %3';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(y),ESC.C2ESC(c1),ESC.C2ESC(c2)));
        AddTextToBuffer(ESC.ESC + '&' + Format(y) + Format(c1) + Format(c2));
        //+NPR5.40 [284505]
    end;

    local procedure ExecuteTestPrint(pL: Char; pH: Char; n: Integer; m: Integer)
    begin
        // Ref sheet 135
        //-NPR5.40 [284505]
        // TempPattern := 'GS ( A %1 %2 %3 %4';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(pL),ESC.C2ESC(pH),n,m));
        AddTextToBuffer(ESC.GS + '(' + 'A' + Format(pL) + Format(pH) + Format(n) + Format(m));
        //+NPR5.40 [284505]
    end;

    local procedure InitializePrinter()
    begin
        // Ref sheet 116
        //-NPR5.40 [284505]
        // TempPattern := 'ESC @';
        // AddToBuffer(TempPattern);
        AddTextToBuffer(ESC.ESC + '@');
        //+NPR5.40 [284505]
    end;

    procedure GeneratePulse(m: Integer; t1: Char; t2: Char)
    begin
        // Ref sheet 124
        //-NPR5.40 [284505]
        // TempPattern := 'ESC p %1 %2 %3';
        // AddToBuffer(STRSUBSTNO(TempPattern,m,ESC.C2ESC(t1),ESC.C2ESC(t2)));
        AddTextToBuffer(ESC.ESC + 'p' + Format(m) + Format(t1) + Format(t2));
        //+NPR5.40 [284505]
    end;

    local procedure PrintAndFeedPaper(n: Char)
    begin
        // Ref sheet 118
        //-NPR5.40 [284505]
        // TempPattern := 'ESC J %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + 'J' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure PrintAndFeedNLines(n: Char)
    begin
        // Ref sheet 123
        //-NPR5.40 [284505]
        // TempPattern := 'ESC t %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + 't' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure PrintBarCodeA(m: Char; "d1..dk": Text[30])
    begin
        // Ref sheet 190 m in [0-6]
        // 0; UPC-A, 1: UPC-1, 2; EAN13, 3; JAN8, 4; CODE39
        // 5; ITF, 6; CODABAR(NW-7)
        //-NPR5.40 [284505]
        // TempPattern := 'GS k %1 %2 NUL';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(m),"d1..dk"));
        AddTextToBuffer(ESC.GS + 'k' + Format(m) + "d1..dk" + ESC.NUL);
        //+NPR5.40 [284505]
    end;

    local procedure PrintBarCodeB(m: Char; n: Char; "d1..dn": Text)
    begin
        // Ref sheet 191 m in [A-N]
        //
        // Command:
        // GS k m n d1..dn
        //-NPR5.40 [284505]
        // AddToBuffer('GS k');
        // AddTextToBuffer(FORMAT(m) + FORMAT(n) + "d1..dn");
        AddTextToBuffer(ESC.GS + 'k' + Format(m) + Format(n) + "d1..dn");
        //+NPR5.40 [284505]
    end;

    local procedure PrintBitmapFromKeyword(Keyword: Code[20]; RegisterNo: Code[10])
    var
        RetailLogoMgt: Codeunit "Retail Logo Mgt.";
        ESCPOS: Text;
        InStream: InStream;
        MemoryStream: DotNet npNetMemoryStream;
        Encoding: DotNet npNetEncoding;
        RetailLogo: Record "Retail Logo";
        StreamReader: DotNet npNetStreamReader;
    begin
        RetailLogo.SetAutoCalcFields(ESCPOSLogo);

        if RetailLogoMgt.GetRetailLogo(Keyword, RegisterNo, RetailLogo) then
            repeat
                if RetailLogo.ESCPOSLogo.HasValue then begin
                    RetailLogo.ESCPOSLogo.CreateInStream(InStream);
                    //-NPR5.40 [248505]
                    //      MemoryStream := MemoryStream.MemoryStream;
                    //      COPYSTREAM(MemoryStream, InStream);
                    //      ByteArray := MemoryStream.ToArray;
                    //      Encoding := Encoding.GetEncoding('utf-8');
                    //      ESCPOS := Encoding.GetString(ByteArray);
                    //
                    //      PrintBitmapFromESCPOS(ESCPOS, RetailLogo.Height);
                    MemoryStream := InStream;
                    MemoryStream.Position := 0;
                    StreamReader := StreamReader.StreamReader(MemoryStream, Encoding.UTF8);
                    ESCPOS := StreamReader.ReadToEnd();
                    PrintBitmapFromESCPOS(ESCPOS, RetailLogo."ESCPOS Height Low Byte", RetailLogo."ESCPOS Height High Byte", RetailLogo."ESCPOS Cmd Low Byte", RetailLogo."ESCPOS Cmd High Byte");
                    //+NPR5.40 [284505]
                end;
            until RetailLogo.Next = 0;
    end;

    procedure PrintBitmapFromESCPOS(ESCPOS: Text; hL: Integer; hH: Integer; cmdL: Integer; cmdH: Integer)
    var
        HeightLowByte: Integer;
        HeightHighByte: Integer;
        CommandLowByte: Integer;
        CommandHighByte: Integer;
        RetailLogo: Record "Retail Logo";
    begin
        if ESCPOS = '' then
            exit;

        //-NPR5.40 [284505]
        // ByteArray      := BitConverter.GetBytes(Height);
        // HeightLowByte  := ByteArray.GetValue(0);
        // HeightHighByte := ByteArray.GetValue(1);
        //
        // ByteArray       := BitConverter.GetBytes(STRLEN(ESCPOS) + 10); //10 is the constant number of bytes before the variable length image data in this command.
        // CommandLowByte  := ByteArray.GetValue(0);
        // CommandHighByte := ByteArray.GetValue(1);
        //
        // StoreGraphicsInBuffer(CommandLowByte, CommandHighByte, 48, 112, 48, 1, 1, 49, 0, 2, HeightLowByte, HeightHighByte, ESCPOS); // 0/2 is always the low/high width bytes since 512px is assumed constant.
        StoreGraphicsInBuffer(cmdL, cmdH, 48, 112, 48, 1, 1, 49, 0, 2, hL, hH, ESCPOS); // 0/2 is always the low/high width bytes since 512px is assumed constant.
        //+NPR5.40 [284505]
        LineFeed;
        PrintGraphicsInBuffer();
        LineFeed;
    end;

    local procedure PrintGraphicsInBuffer()
    var
        m: Char;
        fn: Char;
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=98
        //-NPR5.40 [284505]
        // pL := 2;
        // pH := 0;
        // m  := 48;
        // fn := 50;
        //
        // TempPattern := 'GS ( L %1 %2 %3 %4';
        // AddToBuffer(STRSUBSTNO(TempPattern,FORMAT(pL),FORMAT(pH),FORMAT(m),FORMAT(fn)));
        m := 48;
        fn := 50;
        AddTextToBuffer(ESC.GS + '(' + 'L' + ESC."02" + ESC.NUL + Format(m) + Format(fn));
        //+NPR5.40 [284505]
    end;

    local procedure PrintDataInPageMode()
    begin
        // Ref sheet 110
        //-NPR5.40 [284505]
        //AddToBuffer('ESC FF');
        AddTextToBuffer(ESC.ESC + ESC.FF);
        //+NPR5.40 [284505]
    end;

    procedure PrintNVGraphicsData(n: Char; m: Char)
    begin
        // Ref sheet 198 n in [1-255], m in [0-3]
        //-NPR5.40 [284505]
        // TempPattern := 'FS p %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n),ESC.C2ESC(m)));
        AddTextToBuffer(ESC.FS + 'p' + Format(n) + Format(m));
        //+NPR5.40 [284505]
    end;

    procedure PrintNVGraphicsDataNew(pL: Char; pH: Char; m: Char; fn: Char; kc1: Char; kc2: Char; x: Char; y: Char)
    begin
        // Ref sheet 191 m in [A-N]
        //-NPR5.40 [284505]
        // TempPattern := 'GS ( L %1 %2 %3 %4 %5 %6 %7 %8';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(pL),ESC.C2ESC(pH),ESC.C2ESC(m),ESC.C2ESC(fn),ESC.C2ESC(kc1),ESC.C2ESC(kc2),ESC.C2ESC(x),ESC.C2ESC(y)));
        AddTextToBuffer(ESC.GS + '(' + 'L' + Format(pL) + Format(pH) + Format(m) + Format(fn) + Format(kc1) + Format(kc2) + Format(x) + Format(y));
        //+NPR5.40 [284505]
    end;

    local procedure SelectBitImageMode(m: Char; nL: Char; nH: Char; "d1..dk": Text)
    begin
        // Ref sheet 115
        //-NPR5.40 [284505]
        // TempPattern := 'ESC * %1 %2 %3';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(m),ESC.C2ESC(nL),ESC.C2ESC(nH)));
        // AddTextToBuffer("d1..dk");
        AddTextToBuffer(ESC.ESC + '*' + Format(m) + Format(nL) + Format(nH) + Format("d1..dk"));
        //+NPR5.40 [284505]
    end;

    local procedure SelectCancelUserDefinedCharSet(n: Char)
    begin
        // Ref sheet 110
        //-NPR5.40 [284505]
        // TempPattern := 'ESC % ' + ESC.C2ESC(n);
        // AddToBuffer(TempPattern);
        AddTextToBuffer(ESC.ESC + '%' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectCharacterCodeTable(n: Char)
    begin
        // Ref sheet 125, 16 = Windows-1252, NAV danish superset.
        //-NPR5.40 [284505]
        // TempPattern := 'ESC t %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)))
        AddTextToBuffer(ESC.ESC + 't' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectCharacterFont(n: Char)
    begin
        // Ref sheet 118 (n in [0,1])
        //-NPR5.40 [284505]
        // TempPattern := 'ESC M %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + 'M' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectHRICharacterFont(n: Integer)
    begin
        // Ref sheet 118 (n in [0,1])
        //-NPR5.40 [284505]
        // TempPattern := 'GS f %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.GS + 'f' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectCharacterSize(n: Char)
    begin
        // Ref sheet 134
        // Bit 0-2 Height Magnification
        // Bit 3 Reserved
        // Bit 4-6 Width Magnification
        // Bit 7 reserved
        //-NPR5.40 [284505]
        // TempPattern := 'GS ! %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.GS + '!' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectCutModeAndCutPaper(m: Char; n: Char)
    begin
        // Ref sheet 184
        //-NPR5.40 [284505]
        // TempPattern := 'GS V %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(m),ESC.C2ESC(n)));
        AddTextToBuffer(ESC.GS + 'V' + Format(m) + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectDefaultLineSpacing()
    begin
        // Ref sheet 115
        //-NPR5.40 [284505]
        // TempPattern := 'ESC 2';
        // AddToBuffer(TempPattern);
        AddTextToBuffer(ESC.ESC + '2');
        //+NPR5.40 [284505]
    end;

    local procedure SelectInternationalCharSet(n: Char)
    begin
        // Ref sheet 119 (n in [0,17])
        //-NPR5.40 [284505]
        // TempPattern := 'ESC R %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + 'R' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectJustification(n: Integer)
    begin
        //-NPR5.40 [284505]
        // TempPattern := 'ESC a %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.ESC + 'a' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectPeripheralDevice(n: Char)
    begin
        // Ref sheet 111
        //-NPR5.40 [284505]
        // TempPattern := 'ESC = %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + '=' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectPageMode()
    begin
        // Ref sheet 111
        //-NPR5.40 [284505]
        // TempPattern := 'ESC L';
        // AddToBuffer(TempPattern);
        AddTextToBuffer(ESC.ESC + 'L');
        //+NPR5.40 [284505]
    end;

    local procedure SelectPrintMode(n: Char)
    begin
        // Ref sheet 111
        //-NPR5.40 [284505]
        // TempPattern := 'ESC ! %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + '!' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SelectPrintSpeed(K: Char; pL: Char; pH: Char; fn: Char; m: Char)
    begin
        // Ref sheet 149, pL + pH x 256 = 2
        //-NPR5.40 [284505]
        // TempPattern := 'GS ( %1 %2 %3 %4 %5';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(K),ESC.C2ESC(pL),ESC.C2ESC(pH),ESC.C2ESC(fn),ESC.C2ESC(m)));
        AddTextToBuffer(ESC.GS + '(' + Format(K) + Format(pL) + Format(pH) + Format(fn) + Format(m));
        //+NPR5.40 [284505]
    end;

    local procedure SelectStandardMode()
    begin
        // Ref sheet 119
        //-NPR5.40 [284505]
        // TempPattern := 'ESC S';
        // AddToBuffer(TempPattern);
        AddTextToBuffer(ESC.ESC + 'S');
        //+NPR5.40 [284505]
    end;

    local procedure SelectPrintDirectInPageMode(n: Integer)
    begin
        // Ref sheet 120  (n in[0,1,2,3])
        //-NPR5.40 [284505]
        // TempPattern := 'ESC T %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.ESC + 'T' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SetAbsolutePrintPosition(nL: Char; nH: Char)
    begin
        // Ref sheet 111
        //-NPR5.40 [284505]
        // TempPattern := 'ESC $ %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
        AddTextToBuffer(ESC.ESC + '$' + Format(nL) + Format(nH));
        //+NPR5.40 [284505]
    end;

    local procedure SetAbsVerticalPrintPos(nL: Char; nH: Char)
    begin
        // Ref sheet 134 LSB of   0 <= nL, nH <= 255
        //-NPR5.40 [284505]
        // TempPattern := 'GS $ %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
        AddTextToBuffer(ESC.GS + '$' + Format(nL) + Format(nH));
        //+NPR5.40 [284505]
    end;

    local procedure SetBarCodeHeight(n: Char)
    begin
        // Ref sheet 189
        //-NPR5.40 [284505]
        // TempPattern := 'GS h %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.GS + 'h' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SetBarCodeWidth(n: Char)
    begin
        // Ref sheet 193
        //-NPR5.40 [284505]
        // TempPattern := 'GS w %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.GS + 'w' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SetHorzAndVertMotionUnits(x: Char; y: Char)
    begin
        // Ref sheet 183
        //-NPR5.40 [284505]
        // TempPattern := 'GS P %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(x),ESC.C2ESC(y)));
        AddTextToBuffer(ESC.GS + 'P' + Format(x) + Format(y));
        //+NPR5.40 [284505]
    end;

    local procedure SetHorizontalTabPositions("n1..nk": Text[50])
    begin
        // Ref sheet 117
        //-NPR5.40 [284505]
        // TempPattern := 'ESC D %1 NUL';
        // AddToBuffer(STRSUBSTNO(TempPattern,"n1..nk"));
        AddTextToBuffer(ESC.ESC + 'D' + "n1..nk" + ESC.NUL);
        //+NPR5.40 [284505]
    end;

    local procedure SetLeftMargin(nL: Char; nH: Char)
    begin
        // Ref sheet 183
        //-NPR5.40 [284505]
        // TempPattern := 'GS L %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
        AddTextToBuffer(ESC.GS + 'L' + Format(nL) + Format(nH));
        //+NPR5.40 [284505]
    end;

    local procedure SetLineSpacing(n: Char)
    begin
        // Ref sheet 116
        //-NPR5.40 [284505]
        // TempPattern := 'ESC 3 %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + '3' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure SetPrintAreaInPageMode(W: Char; xl: Char; xH: Char; yL: Char; yH: Char; dxL: Char; dxH: Char; dyL: Char; dyH: Char)
    begin
        // Ref sheet 121
        //-NPR5.40 [284505]
        // TempPattern := 'ESC %1 %2 %3 %4 %5 %6 %7 %8 %9';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(W),ESC.C2ESC(xl),ESC.C2ESC(xH),
        //                                                ESC.C2ESC(yL),ESC.C2ESC(yH),
        //                                                ESC.C2ESC(dxL),ESC.C2ESC(dxH),
        //                                                ESC.C2ESC(dyL),ESC.C2ESC(dyH)));
        AddTextToBuffer(ESC.ESC + Format(W) + Format(xl) + Format(xH) + Format(yL) + Format(yH) + Format(dxL) + Format(dxH) + Format(dyL) + Format(dyH));
        //+NPR5.40 [284505]
    end;

    local procedure SetPrintAreaWidth(nL: Char; nH: Char)
    begin
        // Ref sheet 184
        //-NPR5.40 [284505]
        // TempPattern := 'GS W %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
        AddTextToBuffer(ESC.GS + 'W' + Format(nL) + Format(nH));
        //+NPR5.40 [284505]
    end;

    local procedure SetRelativePrintPosition(nL: Char; nH: Char)
    begin
        // Ref sheet 121
        //-NPR5.40 [284505]
        // TempPattern := 'ESC \ %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
        AddTextToBuffer(ESC.ESC + '\' + Format(nL) + Format(nH));
        //+NPR5.40 [284505]
    end;

    local procedure SetRelativeVerticalPrintPos(nL: Char; nH: Char)
    begin
        // Ref sheet 184
        //-NPR5.40 [284505]
        // TempPattern := 'GS \ %1 %2';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(nL),ESC.C2ESC(nH)));
        AddTextToBuffer(ESC.GS + '\' + Format(nL) + Format(nH));
        //+NPR5.40 [284505]
    end;

    local procedure SetRightSideCharacterSpacing(n: Char)
    begin
        // Ref sheet 110
        //-NPR5.40 [284505]
        // TempPattern := 'ESC SP %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)))
        AddTextToBuffer(ESC.ESC + ESC.SP + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure StoreGraphicsInBuffer(pL: Char; pH: Char; m: Char; fn: Char; a: Char; bx: Char; by: Char; c: Char; xL: Char; xH: Char; yL: Char; yH: Char; Image: Text)
    var
        TempPattern: Text;
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=99
        //-NPR5.40 [284505]
        // AddToBuffer('GS ( L');
        // AddTextToBuffer(FORMAT(pL) + FORMAT(pH) + FORMAT(m) + FORMAT(fn) + FORMAT(a) + FORMAT(bx) + FORMAT(by) + FORMAT(c) + FORMAT(xL) + FORMAT(xH) + FORMAT(yL) + FORMAT(yH) + Image);
        AddTextToBuffer(ESC.GS + '(' + 'L' + Format(pL) + Format(pH) + Format(m) + Format(fn) + Format(a) + Format(bx) + Format(by) + Format(c) + Format(xL) + Format(xH) + Format(yL) + Format(yH) + Image);
        //+NPR5.40 [284505]
    end;

    local procedure TurnDoubleStrikeModeOnOff(n: Integer)
    begin
        // Ref sheet 118 (n in [0,1])
        //-NPR5.40 [284505]
        // TempPattern := 'ESC G %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.ESC + 'G' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure TurnExphasizedModeOnOff(n: Integer)
    begin
        // Ref sheet 117 (n in [0,1])
        //-NPR5.40 [284505]
        // TempPattern := 'ESC E %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.ESC + 'E' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure TurnUnderlineModeOnOff(n: Integer)
    begin
        // Ref sheet 117
        //-NPR5.40 [284505]
        // TempPattern := 'ESC - %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.ESC + '-' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure TurnUpsideDownPrintOnOff(n: Char)
    begin
        // Ref sheet 126 LSB of n is 1 = turn on
        //-NPR5.40 [284505]
        // TempPattern := 'ESC { %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,ESC.C2ESC(n)));
        AddTextToBuffer(ESC.ESC + '{' + Format(n));
        //+NPR5.40 [284505]
    end;

    local procedure Turn90ClockWiserRotModeOnOff(n: Integer)
    begin
        // Ref sheet 120 (n in [0,1]
        //-NPR5.40 [284505]
        // TempPattern := 'ESC V %1';
        // AddToBuffer(STRSUBSTNO(TempPattern,n));
        AddTextToBuffer(ESC.ESC + 'V' + Format(n));
        //+NPR5.40 [284505]
    end;

    procedure "// Info Functions"()
    begin
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        case MediaWidth of
            MediaWidth::"80mm":
            //-NPR5.55 [387982]
            case DPI of
              DPI::"200":
            //+NPR5.55 [387982]
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
            //-NPR5.55 [387982]
              DPI::"300":
                case FontFace[1] of
                  'A' :
                    case FontFace[2] of
                      '1' : exit(47);
                      '2' : exit(23);
                      '3' : exit(16);
                      '4' : exit(12);
                      '5' : exit(9);
                      '6' : exit(7);
                      '7' : exit(6);
                      '8' : exit(6);
                    end;
                  'B' :
                    case FontFace[2] of
                      '1' : exit(56);
                      '2' : exit(28);
                      '3' : exit(19);
                      '4' : exit(14);
                      '5' : exit(11);
                      '6' : exit(9);
                      '7' : exit(8);
                      '8' : exit(7);
                    end;
                end;
            end;
            //+NPR5.55 [387982]
          //-NPR5.37 [291769]
          MediaWidth::"58mm" :
            case FontFace[1] of
              'A' :
                case FontFace[2] of
                  '1' : exit(32);
                  '2' : exit(16);
                  '3' : exit(10);
                  '4' : exit(8);
                  '5' : exit(6);
                  '6' : exit(5);
                  '7' : exit(4);
                  '8' : exit(4);
                end;
              'B' :
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
            end;
          //MediaWidth::"58mm" : ERROR('Not implemented');
          //+NPR5.37 [291769]
        end;
    end;

    local procedure IsBarcodeFont(Font: Text): Boolean
    begin
        Font := UpperCase(Font);

        if CopyStr(Font, 1, 7) = 'BARCODE' then //Legacy syntax support - Remove this when the hardcoded receipts are deprecated.
            exit(true);

        if Font in ['UPC-A', 'UPC-E', 'EAN13', 'EAN8', 'CODE39', 'ITF', 'CODABAR', 'CODE128', 'QR'] then
            exit(true);
    end;

    local procedure "// Aux Functions"()
    begin
    end;

    local procedure InitBuffer()
    begin
        //-NPR5.40 [284505]
        Clear(PrintBufferOutStream);
        Clear(PrintBuffer);
        PrintBuffer.CreateOutStream(PrintBufferOutStream, TEXTENCODING::UTF8);
        //+NPR5.40 [284505]
    end;

    local procedure AddTextToBuffer(Text: Text)
    begin
        //-NPR5.40 [284505]
        //PrintBuffer += Text;
        PrintBufferOutStream.WriteText(Text);
        //+NPR5.40 [284505]
    end;

    local procedure FormatJobForHTTP()
    var
        DotNetEncoding: DotNet npNetEncoding;
        ByteArray: DotNet npNetArray;
        BitConverter: DotNet npNetBitConverter;
        Regex: DotNet npNetRegex;
        HexBuffer: Text;
    begin
        //formats job as per epson ePOS-Print XML specification:
        //https://reference.epson-biz.com/modules/ref_epos_print_xml_en/index.php?content_id=1

        case Encoding of
            Encoding::"Windows-1252":
                //Hack: iso-8859-1 implements everything between 0-255 without any gaps, which we need for printing logos since all possible byte values need to be represented in the printjob.
                //Correct solution would be to build a bytearray instead of string in variable PrintBuffer. Biggest consequence at this moment is the lack of euro sign in iso-8859-1.
                DotNetEncoding := DotNetEncoding.GetEncoding('iso-8859-1');
            Encoding::"Windows-1256":
                DotNetEncoding := DotNetEncoding.GetEncoding('Windows-1256');
        end;

        //-NPR5.40 [284505]
        //ByteArray := DotNetEncoding.GetBytes(PrintJob);
        ByteArray := DotNetEncoding.GetBytes(GetPrintBytes());
        //+NPR5.40 [284505]
        HexBuffer := BitConverter.ToString(ByteArray);
        HexBuffer := Regex.Replace(HexBuffer, '-', '');

        //-NPR5.40 [284505]
        //EXIT('<?xml version="1.0" encoding="utf-8"?>' +
        SetPrintBytes('<?xml version="1.0" encoding="utf-8"?>' +
        //+NPR5.40 [284505]
                      '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
                        '<s:Body>' +
                          '<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">' +
                            '<command>' + HexBuffer + '</command>' +
                          '</epos-print>' +
                        '</s:Body>' +
                      '</s:Envelope>');
    end;

    local procedure GetThreeBitFontPattern(Int: Integer): Text
    begin
        //-NPR5.40 [284505]
        case Int of
            0:
                exit('000');
            1:
                exit('001');
            2:
                exit('010');
            3:
                exit('011');
            4:
                exit('100');
            5:
                exit('101');
            6:
                exit('110');
            7:
                exit('111');
        end;
        exit('000');
        //+NPR5.40 [284505]
    end;

    procedure "// Lookup Functions"()
    begin
    end;

    procedure SelectFont(var Value: Text): Boolean
    var
        RetailList: Record "Retail List" temporary;
    begin
        ConstructFontSelectionList(RetailList);
        if PAGE.RunModal(PAGE::"Retail List", RetailList) = ACTION::LookupOK then begin
            Value := RetailList.Choice;
            exit(true);
        end;
    end;

    procedure SelectCommand(var Value: Text): Boolean
    var
        RetailList: Record "Retail List" temporary;
    begin
        ConstructCommandSelectionList(RetailList);
        if PAGE.RunModal(PAGE::"Retail List", RetailList) = ACTION::LookupOK then begin
            Value := RetailList.Choice;
            exit(true);
        end;
    end;

    local procedure SelectDeviceSetting(var tmpDeviceSetting: Record "RP Device Settings" temporary): Boolean
    var
        tmpRetailList: Record "Retail List" temporary;
        RetailList: Page "Retail List";
    begin
        ConstructDeviceSettingList(tmpRetailList);
        RetailList.SetShowValue(true);
        RetailList.SetRec(tmpRetailList);
        RetailList.LookupMode(true);
        if RetailList.RunModal = ACTION::LookupOK then begin
            RetailList.GetRec(tmpRetailList);
            tmpDeviceSetting.Name := tmpRetailList.Value;
            case tmpDeviceSetting.Name of
                'MEDIA_WIDTH':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := '80mm,58mm';
                    end;
                //-NPR5.37 [290904]
                'ENCODING':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'Windows-1252,Windows-1256';
                    end;
            //+NPR5.37 [290904]
            //-NPR5.55 [387982]
            'DPI' :
              begin
                tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                tmpDeviceSetting.Options := '200,300';
              end;
            //+NPR5.55 [387982]
            end;
            exit(tmpDeviceSetting.Insert);
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "Retail List" temporary)
    begin
        AddOption(RetailList, 'A11', '');
        AddOption(RetailList, 'A21', '');
        AddOption(RetailList, 'B11', '');
        AddOption(RetailList, 'B21', '');
        AddOption(RetailList, 'EAN13', '');
        AddOption(RetailList, 'CODE39', '');
        AddOption(RetailList, 'CODE128', '');
    end;

    procedure ConstructCommandSelectionList(var RetailList: Record "Retail List" temporary)
    begin
        AddOption(RetailList, 'OPENDRAWER', '');
        AddOption(RetailList, 'PAPERCUT', '');
        //-NPR5.37 [290904]
        AddOption(RetailList, 'STOREDLOGO_1', '');
        AddOption(RetailList, 'STOREDLOGO_2', '');
        //+NPR5.37 [290904]
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "Retail List" temporary)
    begin
        AddOption(tmpRetailList, SETTING_MEDIAWIDTH, 'MEDIA_WIDTH');
        //-NPR5.37 [290904]
        AddOption(tmpRetailList, SETTING_ENCODING, 'ENCODING');
        //+NPR5.37 [290904]
        //-NPR5.55 [387982]
        AddOption(tmpRetailList, SETTING_DPI, 'DPI');
        //+NPR5.55 [387982]
    end;

    procedure AddOption(var RetailList: Record "Retail List" temporary; Choice: Text; Value: Text)
    begin
        RetailList.Number += 1;
        RetailList.Choice := Choice;
        RetailList.Value := Value;
        RetailList.Insert;
    end;

    local procedure "// Code 128 Functions"()
    begin
    end;

    local procedure BuildCommandC128(Value: Text): Text
    var
        Length: Integer;
        i: Integer;
        Numeric: Boolean;
        Code128: Text;
        Char: DotNet npNetChar;
        ConsecutiveNumbers: Integer;
        j: Integer;
        String: DotNet npNetString;
        CurrentMode: Option " ",CodeA,CodeB,CodeC;
        Buffer: Text;
        Beginning: Boolean;
    begin
        // This function builds a value using the following code128 code set logic:
        // Switch to Code C when: More than 4 digits at the start/end or 6 in the middle. Otherwise stay with last used code set if possible.
        // This is done to minimize the width of the final barcode and it's quite messy - the printer itself should do this work instead of us but it can't....

        Length := StrLen(Value);

        if Length = 0 then
            exit('');

        for i := 1 to Length do begin
            Numeric := Char.IsNumber(Value[i]);

            if (not Numeric) and (ConsecutiveNumbers > 4) then
                if (StrLen(Code128) = 0) or (ConsecutiveNumbers > 6) then
                    Code128 += PrepareNumericDataC128(Buffer, CurrentMode, (StrLen(Code128) = 0));

            Buffer += Format(Value[i]);

            if Numeric then begin
                ConsecutiveNumbers += 1;
                if i = Length then
                    if ConsecutiveNumbers > 4 then
                        Code128 += PrepareNumericDataC128(Buffer, CurrentMode, (StrLen(Code128) = 0))
                    else
                        Code128 += PrepareDataC128(Buffer, CurrentMode);
            end else begin
                ConsecutiveNumbers := 0;
                Code128 += PrepareDataC128(Buffer, CurrentMode);
            end;
        end;

        exit(Code128);
    end;

    local procedure PrepareNumericDataC128(var Data: Text; var CurrentMode: Option " ",CodeA,CodeB,CodeC; First: Boolean) ReturnValue: Text
    var
        i: Integer;
        Char: Char;
        Length: Integer;
        Int: Integer;
        OddChar: Text;
    begin
        Length := StrLen(Data);

        if (Length mod 2 <> 0) then begin
            //If start of total C128 command then we handle last digit as non-numeric. Otherwise we handle first digit this way.
            if First then begin
                OddChar := Format(Data[Length]);
                Data := CopyStr(Data, 1, Length - 1);
            end else begin
                OddChar := Format(Data[1]);
                ReturnValue += PrepareDataC128(OddChar, CurrentMode);
                Data := CopyStr(Data, 2);
            end;

            Length -= 1;
        end;

        ReturnValue += SwitchModeC128(CurrentMode::CodeC, CurrentMode);

        i := 1;
        while (i < Length) do begin
            Evaluate(Int, Format(Data[i]) + Format(Data[i + 1]));
            Char := Int;
            ReturnValue += Format(Char);
            i += 2;
        end;

        if First and (OddChar <> '') then
            ReturnValue += PrepareDataC128(OddChar, CurrentMode);

        Clear(Data);
    end;

    local procedure PrepareDataC128(var Data: Text; var CurrentMode: Option " ",CodeA,CodeB,CodeC) ReturnValue: Text
    var
        i: Integer;
        Char: Char;
    begin
        for i := 1 to StrLen(Data) do begin
            Char := Data[i];

            if Char < 32 then
                ReturnValue += SwitchModeC128(CurrentMode::CodeA, CurrentMode)
            else
                if (Char > 95) or (CurrentMode in [CurrentMode::CodeC, CurrentMode::" "]) then
                    ReturnValue += SwitchModeC128(CurrentMode::CodeB, CurrentMode);

            ReturnValue += Format(Char);
        end;

        Clear(Data);
    end;

    local procedure SwitchModeC128(SwitchTo: Option " ",CodeA,CodeB,CodeC; var CurrentMode: Option " ",CodeA,CodeB,CodeC) Command: Text
    var
        Char: Char;
    begin
        if CurrentMode = SwitchTo then
            exit('');

        Char := 123;
        Command := Format(Char);

        case SwitchTo of
            SwitchTo::CodeA:
                Char := 65;
            SwitchTo::CodeB:
                Char := 66;
            SwitchTo::CodeC:
                Char := 67;
        end;

        Command += Format(Char);
        CurrentMode := SwitchTo;
        exit(Command);
    end;
}

