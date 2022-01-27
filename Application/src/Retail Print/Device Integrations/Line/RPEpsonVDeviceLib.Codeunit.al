codeunit 6014543 "NPR RP Epson V Device Lib."
{
    Access = Internal;
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

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        ESC: Codeunit "NPR RP Escape Code Library";
        SETTING_MEDIAWIDTH: Label 'Width of media.';
        MediaWidth: Option "80mm","58mm";
        SETTING_ENCODING: Label 'Text encoding.';
        Error_InvalidDeviceSetting: Label 'Invalid device setting: %1';
        Encoding: Option "Windows-1252","Windows-1256";
        PrintBuffer: Codeunit "Temp Blob";
        PrintBufferOutStream: OutStream;
        DPI: Option "200","300";
        SETTING_DPI: Label 'DPI of device.';

    local procedure DeviceCode(): Text
    begin
        exit('EPSON');
    end;

    procedure IsThisDevice(Text: Text): Boolean
    begin
        exit(StrPos(UpperCase(Text), DeviceCode()) > 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        Init(DeviceSettings);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnLineFeed', '', false, false)]
    local procedure OnLineFeed()
    begin
        LineFeed();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnPrintData', '', false, false)]
    local procedure OnPrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    begin
        PrintData(POSPrintBuffer.Text, POSPrintBuffer.Font, POSPrintBuffer.Bold, POSPrintBuffer.Underline, POSPrintBuffer.DoubleStrike, POSPrintBuffer.Align, POSPrintBuffer.Width);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnLookupFont', '', false, false)]
    local procedure OnLookupFont(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectFont(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnLookupCommand', '', false, false)]
    local procedure OnLookupCommand(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectCommand(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnLookupDeviceSetting', '', false, false)]
    local procedure OnLookupDeviceSetting(var LookupOK: Boolean; var tmpDeviceSetting: Record "NPR RP Device Settings" temporary)
    begin
        LookupOK := SelectDeviceSetting(tmpDeviceSetting);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnGetPageWidth', '', false, false)]
    local procedure OnGetPageWidth(FontFace: Text[30]; var Width: Integer)
    begin
        Width := GetPageWidth(FontFace);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnGetTargetEncoding', '', false, false)]
    local procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
        case Encoding of
            Encoding::"Windows-1252":
                //Hack: iso-8859-1 implements everything between 0-255 without any gaps, which we need for printing logos since all possible byte values need to be represented in the printjob.
                //Correct solution would be to build a bytearray instead of string in variable PrintBuffer. Biggest consequence at this moment is the lack of euro sign in iso-8859-1.
                TargetEncoding := 'iso-8859-1';
            Encoding::"Windows-1256":
                TargetEncoding := 'Windows-1256';
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnPrepareJobForHTTP', '', false, false)]
    local procedure OnPrepareJobForHTTP(var FormattedTargetEncoding: Text; var HTTPEndpoint: Text; var Supported: Boolean)
    begin
        FormattedTargetEncoding := 'utf-8';
        HTTPEndpoint := '/cgi-bin/epos/service.cgi?devid=local_printer&timeout=15000';
        FormatJobForHTTP();
        Supported := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnPrepareJobForBluetooth', '', false, false)]
    local procedure OnPrepareJobForBluetooth(var FormattedTargetEncoding: Text; var Supported: Boolean)
    begin
        case Encoding of
            Encoding::"Windows-1252":
                //Hack: iso-8859-1 implements everything between 0-255 without any gaps, which we need for printing logos since all possible byte values need to be represented in the printjob.
                //Correct solution would be to build a bytearray instead of string in variable PrintBuffer. Biggest consequence at this moment is the lack of euro sign in iso-8859-1.
                FormattedTargetEncoding := 'iso-8859-1';
            Encoding::"Windows-1256":
                FormattedTargetEncoding := 'Windows-1256';
        end;
        Supported := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnGetPrintBytes', '', false, false)]
    local procedure OnGetPrintBytes(var PrintBytes: Text)
    begin
        PrintBytes := GetPrintBytes();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnSetPrintBytes', '', false, false)]
    local procedure OnSetPrintBytes(var PrintBytes: Text)
    begin
        SetPrintBytes(PrintBytes);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnBuildDeviceList', '', false, false)]
    local procedure OnBuildDeviceList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Value := DeviceCode();
        tmpRetailList.Choice := DeviceCode();
        tmpRetailList.Insert();
    end;

    procedure Init(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        InitBuffer();
        Clear(MediaWidth);

        if DeviceSettings.FindSet() then
            repeat
                case DeviceSettings.Name of
                    'MEDIA_WIDTH':
                        if DeviceSettings.Value = '58mm' then
                            MediaWidth := MediaWidth::"58mm";
                    'ENCODING':
                        if DeviceSettings.Value = 'Windows-1256' then
                            Encoding := Encoding::"Windows-1256";
                    'DPI':
                        if DeviceSettings.Value = '300' then
                            DPI := DPI::"300";
                    else
                        Error(Error_InvalidDeviceSetting, DeviceSettings.Value);
                end;
            until DeviceSettings.Next() = 0;

        InitializePrinter();
        case Encoding of
            Encoding::"Windows-1252":
                SelectCharacterCodeTable(16);
            Encoding::"Windows-1256":
                SelectCharacterCodeTable(50);
        end;
    end;

    procedure PrintData(Data: Text[100]; FontType: Text[10]; Bold: Boolean; UnderLine: Boolean; DoubleStrike: Boolean; Align: Integer; Width: Integer)
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
        TypeHelper: Codeunit "Type Helper";
        PLow: Integer;
        PHigh: Integer;
        TextLength: Integer;
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
            'QR',
            'QR1L',
            'QR1M',
            'QR1Q',
            'QR1H',
            'QR2L',
            'QR2M',
            'QR2Q',
            'QR2H',
            'QRML',
            'QRMM',
            'QRMQ',
            'QRMH':
                begin
                    // Select QR Model; 1 (Old), 2 (New), M (Micro)
                    case CopyStr(BarcodeType, 3, 1) of
                        '1':
                            QRSelectModel(4, 0, 49, 65, 49, 0);
                        'M':
                            QRSelectModel(4, 0, 49, 65, 51, 0);
                        else // '2'
                            QRSelectModel(4, 0, 49, 65, 50, 0); // default
                    end;

                    // Set Size
                    if Width > 0 then
                        QRSelectSize(3, 0, 49, 67, Width)
                    else
                        QRSelectSize(3, 0, 49, 67, 3); // default

                    // Set Error Correction Level
                    case CopyStr(BarcodeType, 4, 1) of
                        'M':
                            QRSelectErrorLevel(3, 0, 49, 69, 49);
                        'Q':
                            QRSelectErrorLevel(3, 0, 49, 69, 50);
                        'H':
                            QRSelectErrorLevel(3, 0, 49, 69, 51);
                        else // 'L'
                            QRSelectErrorLevel(3, 0, 49, 69, 48); // default
                    end;

                    // Store QR
                    TextLength := StrLen(Text) + 3;
                    PLow := TypeHelper.BitwiseAnd(TextLength, 255);
                    PHigh := (TextLength - PLow) / 256;
                    QRStoreData(PLow, PHigh, 49, 80, 48, Text);

                    // Print QR
                    QRPrintData(3, 0, 49, 81, 48);
                end;
        end;

        AddTextToBuffer(Text);
        LineFeed();
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
    begin
        PrintNVGraphicsDataNew(6, 0, 48, 69, 48, 48, 1, 1);
    end;

    local procedure PrintControlChar(Char: Text[1])
    begin
        case Char of
            'G':
                PrintDefaultLogo();
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
                PrintAltDefaultLogo();
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
        if (Height > 7) or (Height < 0) then
            Height := 0;
        if (Width > 7) or (Width < 0) then
            Width := 0;

        SelectCharacterSize(Power(2, 4) * Width + Height); //Width is packed into upper half of 8-bit byte.
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
        InitBuffer();
        PrintBufferOutStream.Write(PrintBytes);
    end;

    procedure GetPrintBytes(): Text
    var
        PrintBufferInStream: InStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        StreamReader: DotNet NPRNetStreamReader;
        NetEncoding: DotNet NPRNetEncoding;
    begin
        PrintBuffer.CreateInStream(PrintBufferInStream, TEXTENCODING::UTF8);
        MemoryStream := PrintBufferInStream;
        MemoryStream.Position := 0;
        StreamReader := StreamReader.StreamReader(MemoryStream, NetEncoding.UTF8);
        exit(StreamReader.ReadToEnd());
    end;

    procedure HorizontalTab()
    begin
        // Ref sheet 103, Horizontal Tab
        AddTextToBuffer(ESC.HT());
    end;

    procedure LineFeed()
    begin
        // Ref sheet 103, Print And Line Feed
        AddTextToBuffer(ESC.LF());
    end;

    procedure FormFeed()
    begin
        // Ref sheet 103, Print and return to standard mode (in page mode)
        AddTextToBuffer(ESC.FF());
    end;

    procedure CarriageReturn()
    begin
        // Ref sheet 103, Print and carriage return
        AddTextToBuffer(ESC.CR());
    end;

    procedure Cancel()
    begin
        // Ref sheet 104, Cancel print in data in page mode
        AddTextToBuffer(ESC.CAN());
    end;

    local procedure InitializePrinter()
    begin
        // Ref sheet 116
        // TempPattern := 'ESC @';
        AddTextToBuffer(ESC.ESC() + '@');
    end;

    procedure GeneratePulse(m: Integer; t1: Char; t2: Char)
    begin
        // Ref sheet 124
        // TempPattern := 'ESC p %1 %2 %3';
        AddTextToBuffer(ESC.ESC() + 'p' + Format(m) + Format(t1) + Format(t2));
    end;

    local procedure PrintBarCodeA(m: Char; "d1..dk": Text[30])
    begin
        // Ref sheet 190 m in [0-6]
        // 0; UPC-A, 1: UPC-1, 2; EAN13, 3; JAN8, 4; CODE39
        // 5; ITF, 6; CODABAR(NW-7)
        // TempPattern := 'GS k %1 %2 NUL';
        AddTextToBuffer(ESC.GS() + 'k' + Format(m) + "d1..dk" + ESC.NUL());
    end;

    local procedure PrintBarCodeB(m: Char; n: Char; "d1..dn": Text)
    begin
        // Ref sheet 191 m in [A-N]
        // Command:
        // GS k m n d1..dn
        AddTextToBuffer(ESC.GS() + 'k' + Format(m) + Format(n) + "d1..dn");
    end;

    local procedure QRSelectModel(pL: Char; pH: Char; cn: Char; fn: Char; n1: Char; n2: Char)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=140
        AddTextToBuffer(ESC.GS() + '(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(n1) + Format(n2));
    end;

    local procedure QRSelectSize(pL: Char; pH: Char; cn: Char; fn: Char; n: Char)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=141
        AddTextToBuffer(ESC.GS() + '(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(n));
    end;

    local procedure QRSelectErrorLevel(pL: Char; pH: Char; cn: Char; fn: Char; n: Char)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=142
        AddTextToBuffer(ESC.GS() + '(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(n));
    end;

    local procedure QRStoreData(pL: Char; pH: Char; cn: Char; fn: Char; m: Char; "d1..dk": Text)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=143
        AddTextToBuffer(ESC.GS() + '(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(m) + "d1..dk");
    end;

    local procedure QRPrintData(pL: Char; pH: Char; cn: Char; fn: Char; m: Char)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=144
        AddTextToBuffer(ESC.GS() + '(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(m));
    end;

    local procedure PrintBitmapFromKeyword(Keyword: Code[20]; RegisterNo: Code[10])
    var
        RetailLogoMgt: Codeunit "NPR Retail Logo Mgt.";
        ESCPOS: Text;
        InStream: InStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        NetEncoding: DotNet NPRNetEncoding;
        RetailLogo: Record "NPR Retail Logo";
        StreamReader: DotNet NPRNetStreamReader;
    begin
        RetailLogo.SetAutoCalcFields(ESCPOSLogo);

        if RetailLogoMgt.GetRetailLogo(Keyword, RegisterNo, RetailLogo) then
            repeat
                if RetailLogo.ESCPOSLogo.HasValue() then begin
                    RetailLogo.ESCPOSLogo.CreateInStream(InStream);
                    MemoryStream := InStream;
                    MemoryStream.Position := 0;
                    StreamReader := StreamReader.StreamReader(MemoryStream, NetEncoding.UTF8);
                    ESCPOS := StreamReader.ReadToEnd();
                    PrintBitmapFromESCPOS(ESCPOS, RetailLogo."ESCPOS Height Low Byte", RetailLogo."ESCPOS Height High Byte", RetailLogo."ESCPOS Cmd Low Byte", RetailLogo."ESCPOS Cmd High Byte");
                end;
            until RetailLogo.Next() = 0;
    end;

    procedure PrintBitmapFromESCPOS(ESCPOS: Text; hL: Integer; hH: Integer; cmdL: Integer; cmdH: Integer)
    begin
        if ESCPOS = '' then
            exit;

        StoreGraphicsInBuffer(cmdL, cmdH, 48, 112, 48, 1, 1, 49, 0, 2, hL, hH, ESCPOS); // 0/2 is always the low/high width bytes since 512px is assumed constant.

        LineFeed();
        PrintGraphicsInBuffer();
        LineFeed();
    end;

    local procedure PrintGraphicsInBuffer()
    var
        m: Char;
        fn: Char;
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=98
        // pL := 2;
        // pH := 0;
        // m  := 48;
        // fn := 50;
        //
        // TempPattern := 'GS ( L %1 %2 %3 %4';
        m := 48;
        fn := 50;
        AddTextToBuffer(ESC.GS() + '(' + 'L' + ESC."02"() + ESC.NUL() + Format(m) + Format(fn));
    end;

    procedure PrintNVGraphicsData(n: Char; m: Char)
    begin
        // Ref sheet 198 n in [1-255], m in [0-3]
        // TempPattern := 'FS p %1 %2';
        AddTextToBuffer(ESC.FS() + 'p' + Format(n) + Format(m));
    end;

    procedure PrintNVGraphicsDataNew(pL: Char; pH: Char; m: Char; fn: Char; kc1: Char; kc2: Char; x: Char; y: Char)
    begin
        // Ref sheet 191 m in [A-N]
        // TempPattern := 'GS ( L %1 %2 %3 %4 %5 %6 %7 %8';
        AddTextToBuffer(ESC.GS() + '(' + 'L' + Format(pL) + Format(pH) + Format(m) + Format(fn) + Format(kc1) + Format(kc2) + Format(x) + Format(y));
    end;

    local procedure SelectCharacterCodeTable(n: Char)
    begin
        // Ref sheet 125, 16 = Windows-1252, NAV danish superset.
        // TempPattern := 'ESC t %1';
        AddTextToBuffer(ESC.ESC() + 't' + Format(n));
    end;

    local procedure SelectCharacterFont(n: Char)
    begin
        // Ref sheet 118 (n in [0,1])
        // TempPattern := 'ESC M %1';
        AddTextToBuffer(ESC.ESC() + 'M' + Format(n));
    end;

    local procedure SelectCharacterSize(n: Char)
    begin
        // Ref sheet 134
        // Bit 0-2 Height Magnification
        // Bit 3 Reserved
        // Bit 4-6 Width Magnification
        // Bit 7 reserved
        // TempPattern := 'GS ! %1';
        AddTextToBuffer(ESC.GS() + '!' + Format(n));
    end;

    local procedure SelectCutModeAndCutPaper(m: Char; n: Char)
    begin
        // Ref sheet 184
        // TempPattern := 'GS V %1 %2';
        AddTextToBuffer(ESC.GS() + 'V' + Format(m) + Format(n));
    end;

    local procedure SelectJustification(n: Integer)
    begin
        // TempPattern := 'ESC a %1';
        AddTextToBuffer(ESC.ESC() + 'a' + Format(n));
    end;

    local procedure SetBarCodeHeight(n: Char)
    begin
        // Ref sheet 189
        // TempPattern := 'GS h %1';
        AddTextToBuffer(ESC.GS() + 'h' + Format(n));
    end;

    local procedure SetBarCodeWidth(n: Char)
    begin
        // Ref sheet 193
        // TempPattern := 'GS w %1';
        AddTextToBuffer(ESC.GS() + 'w' + Format(n));
    end;

    local procedure StoreGraphicsInBuffer(pL: Char; pH: Char; m: Char; fn: Char; a: Char; bx: Char; by: Char; c: Char; xL: Char; xH: Char; yL: Char; yH: Char; Image: Text)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=99
        AddTextToBuffer(ESC.GS() + '(' + 'L' + Format(pL) + Format(pH) + Format(m) + Format(fn) + Format(a) + Format(bx) + Format(by) + Format(c) + Format(xL) + Format(xH) + Format(yL) + Format(yH) + Image);
    end;

    local procedure TurnDoubleStrikeModeOnOff(n: Integer)
    begin
        // Ref sheet 118 (n in [0,1])
        // TempPattern := 'ESC G %1';
        AddTextToBuffer(ESC.ESC() + 'G' + Format(n));
    end;

    local procedure TurnExphasizedModeOnOff(n: Integer)
    begin
        // Ref sheet 117 (n in [0,1])
        // TempPattern := 'ESC E %1';
        AddTextToBuffer(ESC.ESC() + 'E' + Format(n));
    end;

    local procedure TurnUnderlineModeOnOff(n: Integer)
    begin
        // Ref sheet 117
        // TempPattern := 'ESC - %1';
        AddTextToBuffer(ESC.ESC() + '-' + Format(n));
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        case MediaWidth of
            MediaWidth::"80mm":
                case DPI of
                    DPI::"200":
                        case FontFace[1] of
                            'A':
                                case FontFace[2] of
                                    '1':
                                        exit(42);
                                    '2':
                                        exit(21);
                                    '3':
                                        exit(14);
                                    '4':
                                        exit(10);
                                    '5':
                                        exit(8);
                                    '6':
                                        exit(7);
                                    '7':
                                        exit(6);
                                    '8':
                                        exit(5);
                                end;
                            'B':
                                case FontFace[2] of
                                    '1':
                                        exit(56);
                                    '2':
                                        exit(28);
                                    '3':
                                        exit(18);
                                    '4':
                                        exit(14);
                                    '5':
                                        exit(11);
                                    '6':
                                        exit(9);
                                    '7':
                                        exit(8);
                                    '8':
                                        exit(7);
                                end;
                        end;
                    DPI::"300":
                        case FontFace[1] of
                            'A':
                                case FontFace[2] of
                                    '1':
                                        exit(47);
                                    '2':
                                        exit(23);
                                    '3':
                                        exit(16);
                                    '4':
                                        exit(12);
                                    '5':
                                        exit(9);
                                    '6':
                                        exit(7);
                                    '7':
                                        exit(6);
                                    '8':
                                        exit(6);
                                end;
                            'B':
                                case FontFace[2] of
                                    '1':
                                        exit(56);
                                    '2':
                                        exit(28);
                                    '3':
                                        exit(19);
                                    '4':
                                        exit(14);
                                    '5':
                                        exit(11);
                                    '6':
                                        exit(9);
                                    '7':
                                        exit(8);
                                    '8':
                                        exit(7);
                                end;
                        end;
                end;
            MediaWidth::"58mm":
                case FontFace[1] of
                    'A':
                        case FontFace[2] of
                            '1':
                                exit(32);
                            '2':
                                exit(16);
                            '3':
                                exit(10);
                            '4':
                                exit(8);
                            '5':
                                exit(6);
                            '6':
                                exit(5);
                            '7':
                                exit(4);
                            '8':
                                exit(4);
                        end;
                    'B':
                        case FontFace[2] of
                            '1':
                                exit(42);
                            '2':
                                exit(21);
                            '3':
                                exit(14);
                            '4':
                                exit(10);
                            '5':
                                exit(8);
                            '6':
                                exit(7);
                            '7':
                                exit(6);
                            '8':
                                exit(5);
                        end;
                end;
        end;
    end;

    local procedure IsBarcodeFont(Font: Text): Boolean
    begin
        Font := UpperCase(Font);

        if CopyStr(Font, 1, 7) = 'BARCODE' then //Legacy syntax support - Remove this when the hardcoded receipts are deprecated.
            exit(true);

        if Font in ['UPC-A', 'UPC-E', 'EAN13', 'EAN8', 'CODE39', 'ITF', 'CODABAR', 'CODE128',
                    'QR', 'QR1L', 'QR1M', 'QR1Q', 'QR1H', 'QR2L', 'QR2M', 'QR2Q', 'QR2H', 'QRML', 'QRMM', 'QRMQ', 'QRMH'] then
            exit(true);
    end;

    local procedure InitBuffer()
    begin
        Clear(PrintBufferOutStream);
        Clear(PrintBuffer);
        PrintBuffer.CreateOutStream(PrintBufferOutStream, TEXTENCODING::UTF8);
    end;

    local procedure AddTextToBuffer(Text: Text)
    begin
        PrintBufferOutStream.WriteText(Text);
    end;

    local procedure FormatJobForHTTP()
    var
        DotNetEncoding: DotNet NPRNetEncoding;
        ByteArray: DotNet NPRNetArray;
        BitConverter: DotNet NPRNetBitConverter;
        Regex: DotNet NPRNetRegex;
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

        ByteArray := DotNetEncoding.GetBytes(GetPrintBytes());
        HexBuffer := BitConverter.ToString(ByteArray);
        HexBuffer := Regex.Replace(HexBuffer, '-', '');

        SetPrintBytes('<?xml version="1.0" encoding="utf-8"?>' +
                      '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
                        '<s:Body>' +
                          '<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">' +
                            '<command>' + HexBuffer + '</command>' +
                          '</epos-print>' +
                        '</s:Body>' +
                      '</s:Envelope>');
    end;

    procedure SelectFont(var Value: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        ConstructFontSelectionList(TempRetailList);
        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then begin
            Value := TempRetailList.Choice;
            exit(true);
        end;
    end;

    procedure SelectCommand(var Value: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        ConstructCommandSelectionList(TempRetailList);
        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then begin
            Value := TempRetailList.Choice;
            exit(true);
        end;
    end;

    local procedure SelectDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        RetailList: Page "NPR Retail List";
    begin
        ConstructDeviceSettingList(TempRetailList);
        RetailList.SetShowValue(true);
        RetailList.SetRec(TempRetailList);
        RetailList.LookupMode(true);
        if RetailList.RunModal() = ACTION::LookupOK then begin
            RetailList.GetRec(TempRetailList);
            tmpDeviceSetting.Name := TempRetailList.Value;
            case tmpDeviceSetting.Name of
                'MEDIA_WIDTH':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := '80mm,58mm';
                    end;
                'ENCODING':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'Windows-1252,Windows-1256';
                    end;
                'DPI':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := '200,300';
                    end;
            end;
            exit(tmpDeviceSetting.Insert());
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(RetailList, 'A11', '');
        AddOption(RetailList, 'A21', '');
        AddOption(RetailList, 'B11', '');
        AddOption(RetailList, 'B21', '');
        AddOption(RetailList, 'EAN13', '');
        AddOption(RetailList, 'CODE39', '');
        AddOption(RetailList, 'CODE128', '');
        AddOption(RetailList, 'QR', '');
        AddOption(RetailList, 'QR1L', '');
        AddOption(RetailList, 'QR1M', '');
        AddOption(RetailList, 'QR1Q', '');
        AddOption(RetailList, 'QR1H', '');
        AddOption(RetailList, 'QR2L', '');
        AddOption(RetailList, 'QR2M', '');
        AddOption(RetailList, 'QR2Q', '');
        AddOption(RetailList, 'QR2H', '');
        AddOption(RetailList, 'QRML', '');
        AddOption(RetailList, 'QRMM', '');
        AddOption(RetailList, 'QRMQ', '');
        AddOption(RetailList, 'QRMH', '');
    end;

    procedure ConstructCommandSelectionList(var RetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(RetailList, 'OPENDRAWER', '');
        AddOption(RetailList, 'PAPERCUT', '');
        AddOption(RetailList, 'STOREDLOGO_1', '');
        AddOption(RetailList, 'STOREDLOGO_2', '');
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(tmpRetailList, SETTING_MEDIAWIDTH, 'MEDIA_WIDTH');
        AddOption(tmpRetailList, SETTING_ENCODING, 'ENCODING');
        AddOption(tmpRetailList, SETTING_DPI, 'DPI');
    end;

    procedure AddOption(var RetailList: Record "NPR Retail List" temporary; Choice: Text; Value: Text)
    begin
        RetailList.Number += 1;
        RetailList.Choice := Choice;
        RetailList.Value := Value;
        RetailList.Insert();
    end;

    local procedure BuildCommandC128(Value: Text): Text
    var
        Length: Integer;
        i: Integer;
        Numeric: Boolean;
        Code128: Text;
        Char: DotNet NPRNetChar;
        ConsecutiveNumbers: Integer;
        CurrentMode: Option " ",CodeA,CodeB,CodeC;
        Buffer: Text;
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

