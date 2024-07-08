codeunit 6014543 "NPR RP Epson TM Device Lib." implements "NPR ILine Printer"
{
#pragma warning disable AA0139
    Access = Internal;

    var

        _MediaWidth: Option "80mm","58mm";
        _EncodingCodepage: Integer;
        _PrintBuffer: Codeunit "Temp Blob";
        _dpi: Option "200","300";
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;
        SettingDpiLbl: Label 'DPI of device.';
        SettingMediawidthLbl: Label 'Width of media.';
        SettingEncodingLbl: Label 'Text encoding.';
        InvalidDeviceSettingErr: Label 'Invalid device setting: %1';

    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        Clear(_MediaWidth);
        Clear(_dpi);
        Clear(_EncodingCodepage);

        ParseDeviceSettings(DeviceSettings);
        InitBuffer();
        InitializePrinter();
        SetCharacterCodeForCodepage(_EncodingCodepage);
        SelectJustification(0); //In case printer remembers a justification from the tail of a past print
    end;

    procedure LineFeed()
    begin
        _DotNetStream.WriteByte(10);
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    begin
        case UpperCase(POSPrintBuffer.Font) of
            'COMMAND':
                PrintCommand(POSPrintBuffer);
            'UPC-A',
            'UPC-E',
            'EAN13',
            'EAN8',
            'CODE39',
            'ITF',
            'CODABAR',
            'CODE128',
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
                PrintBarcode(POSPrintBuffer);
            'LOGO':
                PrintBitmapFromKeyword(POSPrintBuffer.Text, POSPrintBuffer.Align);
            else
                PrintText(POSPrintBuffer);
        end;
    end;

    procedure EndJob()
    begin
    end;

    procedure LookupFont(var Value: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        ConstructFontSelectionList(TempRetailList);
        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then begin
            Value := TempRetailList.Choice;
            exit(true);
        end;
    end;

    procedure LookupCommand(var Value: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        ConstructCommandSelectionList(TempRetailList);
        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then begin
            Value := TempRetailList.Choice;
            exit(true);
        end;
    end;

    procedure LookupDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean
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
                        tmpDeviceSetting.Options := 'Windows-1252,Windows-1256,Windows-1251';
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

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        case _MediaWidth of
            _MediaWidth::"80mm":
                case _dpi of
                    _dpi::"200":
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
                    _dpi::"300":
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
            _MediaWidth::"58mm":
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

    procedure PrepareJobForHTTP(var HTTPEndpoint: Text): Boolean
    begin
        HTTPEndpoint := '/cgi-bin/epos/service.cgi?devid=local_printer&timeout=15000';
        FormatJobForHTTP();
        exit(true);
    end;

    procedure PrepareJobForBluetooth(): Boolean
    begin
        exit(true);
    end;

    procedure GetPrintBufferAsBase64(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
    begin
        _PrintBuffer.CreateInStream(IStream);
        exit(Base64Convert.ToBase64(IStream));
    end;

    local procedure PrintCommand(PrintBuffer: Record "NPR RP Print Buffer")
    begin
        case UpperCase(PrintBuffer.Text) of
            'OPENDRAWER':
                GeneratePulse(0, 25, 25);
            'PAPERCUT':
                SelectCutModeAndCutPaper(66, 3);
            'STOREDLOGO_1':
                PrintNVGraphicsDataNew(6, 0, 48, 69, 48, 48, 1, 1);
            'STOREDLOGO_2':
                PrintNVGraphicsData(1, 0);
            'CLEARFORMAT':
                InitializePrinter();
        end;
    end;

    procedure PrintBarcode(POSPrintBuffer: Record "NPR RP Print Buffer")
    var
        Code128: Text;
        TypeHelper: Codeunit "Type Helper";
        PLow: Integer;
        PHigh: Integer;
        TextLength: Integer;
    begin
        SelectJustification(1);
        SetBarCodeWidth(POSPrintBuffer.Width);
        if (POSPrintBuffer.Height > 0) and (POSPrintBuffer.Height < 256) then
            SetBarCodeHeight(POSPrintBuffer.Height)
        else
            SetBarCodeHeight(40);

        case POSPrintBuffer.Font of
            'UPC-A':
                PrintBarCodeA(0, POSPrintBuffer.Text);
            'UPC-E':
                PrintBarCodeA(1, POSPrintBuffer.Text);
            'EAN13':
                PrintBarCodeA(2, POSPrintBuffer.Text);
            'EAN8':
                PrintBarCodeA(3, POSPrintBuffer.Text);
            'CODE39':
                PrintBarCodeA(4, POSPrintBuffer.Text);
            'ITF':
                PrintBarCodeA(5, POSPrintBuffer.Text);
            'CODABAR':
                PrintBarCodeA(6, POSPrintBuffer.Text);
            'CODE128':
                begin
                    Code128 := BuildCommandC128(POSPrintBuffer.Text);
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
                    case CopyStr(POSPrintBuffer.Font, 3, 1) of
                        '1':
                            QRSelectModel(4, 0, 49, 65, 49, 0);
                        'M':
                            QRSelectModel(4, 0, 49, 65, 51, 0);
                        else // '2'
                            QRSelectModel(4, 0, 49, 65, 50, 0); // default
                    end;

                    // Set Size
                    if POSPrintBuffer.Width > 0 then
                        QRSelectSize(3, 0, 49, 67, POSPrintBuffer.Width)
                    else
                        QRSelectSize(3, 0, 49, 67, 3); // default

                    // Set Error Correction Level
                    case CopyStr(POSPrintBuffer.Font, 4, 1) of
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
                    TextLength := StrLen(POSPrintBuffer.Text) + 3;
                    PLow := TypeHelper.BitwiseAnd(TextLength, 255);
                    PHigh := (TextLength - PLow) / 256;
                    QRStoreData(PLow, PHigh, 49, 80, 48, POSPrintBuffer.Text);

                    // Print QR
                    QRPrintData(3, 0, 49, 81, 48);
                end;
        end;

        if not POSPrintBuffer."Hide HRI" then
            AddStringToBuffer(POSPrintBuffer.Text);
        LineFeed();
    end;

    local procedure PrintBitmapFromKeyword(Keyword: Text; Alignment: Integer)
    var
        InStream: InStream;
        RetailLogo: Record "NPR Retail Logo";
        POSUnit: Record "NPR POS Unit";
        RegisterNo: Code[10];
    begin
        RetailLogo.SetAutoCalcFields(ESCPOSLogo);
        RetailLogo.SetRange(Keyword, Keyword);

        RegisterNo := POSUnit.GetCurrentPOSUnit();
        RetailLogo.SetRange("Register No.", RegisterNo);
        if RetailLogo.IsEmpty then
            RetailLogo.SetRange("Register No.", '');

        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        if RetailLogo.FindSet() then
            repeat
                if RetailLogo.ESCPOSLogo.HasValue() then begin
                    SelectJustification(Alignment);
                    StoreGraphicsInBuffer(RetailLogo."ESCPOS Cmd Low Byte", RetailLogo."ESCPOS Cmd High Byte", 48, 112, 48, 1, 1, 49, 0, 2, RetailLogo."ESCPOS Height Low Byte", RetailLogo."ESCPOS Height High Byte");

                    RetailLogo.ESCPOSLogo.CreateInStream(InStream);
                    AddStreamToBuffer(InStream);

                    LineFeed();
                    PrintGraphicsInBuffer();
                end;
            until RetailLogo.Next() = 0;
    end;

    procedure PrintText(var POSPrintBuffer: Record "NPR RP Print Buffer")
    var
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
    begin
        if POSPrintBuffer.Bold then TurnExphasizedModeOnOff(1);
        if POSPrintBuffer.UnderLine then TurnUnderlineModeOnOff(1);
        if POSPrintBuffer.DoubleStrike then TurnDoubleStrikeModeOnOff(1);
        if POSPrintBuffer.Align = POSPrintBuffer.Align::Center then begin
            if LinePrintMgt.GetColumnCount(POSPrintBuffer) = 1 then
                //Allow centering single lines via printer logic, but anything else, i.e. two, three, four columns is handled via space padding as printer alignment is for the entire line.
                SelectJustification(1)
            else
                // Notes in documentation: https://www.epson-biz.com/modules/ref_escpos/index.php?content_id=58 states that we must have this in the beginning of the line when in Standard mode.
                SelectJustification(0);
        end else
            // Notes in documentation: https://www.epson-biz.com/modules/ref_escpos/index.php?content_id=58 states that we must have this in the beginning of the line when in Standard mode.
            SelectJustification(0);

        SetFontFace(POSPrintBuffer.Font);
        AddStringToBuffer(POSPrintBuffer.Text);

        if POSPrintBuffer.Bold then TurnExphasizedModeOnOff(0);
        if POSPrintBuffer.UnderLine then TurnUnderlineModeOnOff(0);
        if POSPrintBuffer.DoubleStrike then TurnDoubleStrikeModeOnOff(0);
    end;

    procedure SetCharacterCodeForCodepage(Codepage: Integer)
    begin
        case Codepage of
            437:
                SelectCharacterCodeTable(0);
            720:
                SelectCharacterCodeTable(32);
            737:
                SelectCharacterCodeTable(14);
            775:
                SelectCharacterCodeTable(33);
            850:
                SelectCharacterCodeTable(2);
            852:
                SelectCharacterCodeTable(18);
            855:
                SelectCharacterCodeTable(34);
            857:
                SelectCharacterCodeTable(13);
            858:
                SelectCharacterCodeTable(19);
            860:
                SelectCharacterCodeTable(3);
            861:
                SelectCharacterCodeTable(35);
            862:
                SelectCharacterCodeTable(36);
            863:
                SelectCharacterCodeTable(4);
            864:
                SelectCharacterCodeTable(37);
            865:
                SelectCharacterCodeTable(5);
            866:
                SelectCharacterCodeTable(17);
            869:
                SelectCharacterCodeTable(38);
            874:
                SelectCharacterCodeTable(20);
            1250:
                SelectCharacterCodeTable(45);
            1251:
                SelectCharacterCodeTable(46);
            1252:
                SelectCharacterCodeTable(16);
            1253:
                SelectCharacterCodeTable(47);
            1254:
                SelectCharacterCodeTable(48);
            1255:
                SelectCharacterCodeTable(49);
            1256:
                SelectCharacterCodeTable(50);
            1257:
                SelectCharacterCodeTable(51);
            1258:
                SelectCharacterCodeTable(52);
            20290:
                SelectCharacterCodeTable(1);
            28591:
                SelectCharacterCodeTable(39);
            28597:
                SelectCharacterCodeTable(15);
            28605:
                SelectCharacterCodeTable(40);
            else
                SelectCharacterCodeTable(16);
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

    procedure ParseDeviceSettings(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        _EncodingCodepage := 1252; //default if not overwritten

        if not DeviceSettings.FindSet() then
            exit;

        repeat
            case DeviceSettings.Name of
                'MEDIA_WIDTH':
                    case DeviceSettings.Value of
                        '80mm':
                            _MediaWidth := _MediaWidth::"80mm";
                        '58mm':
                            _MediaWidth := _MediaWidth::"58mm";
                    end;
                'ENCODING':
                    case DeviceSettings.Value of
                        'Windows-874':
                            _EncodingCodepage := 874;
                        'Windows-1250':
                            _EncodingCodepage := 1250;
                        'Windows-1251':
                            _EncodingCodepage := 1251;
                        'Windows-1252':
                            _EncodingCodepage := 1252;
                        'Windows-1553':
                            _EncodingCodepage := 1253;
                        'Windows-1554':
                            _EncodingCodepage := 1254;
                        'Windows-1255':
                            _EncodingCodepage := 1255;
                        'Windows-1256':
                            _EncodingCodepage := 1256;
                        'Windows-1557':
                            _EncodingCodepage := 1257;
                        'Windows-1558':
                            _EncodingCodepage := 1258;
                        'dos-720':
                            _EncodingCodepage := 720;
                        'dos-862':
                            _EncodingCodepage := 862;
                        'dos-866':
                            _EncodingCodepage := 866;
                        'ibm290':
                            _EncodingCodepage := 20290;
                        'ibm437':
                            _EncodingCodepage := 437;
                        'ibm737':
                            _EncodingCodepage := 737;
                        'ibm775':
                            _EncodingCodepage := 775;
                        'ibm850':
                            _EncodingCodepage := 850;
                        'ibm852':
                            _EncodingCodepage := 852;
                        'ibm855':
                            _EncodingCodepage := 855;
                        'ibm857':
                            _EncodingCodepage := 857;
                        'ibm858':
                            _EncodingCodepage := 858;
                        'ibm860':
                            _EncodingCodepage := 860;
                        'ibm861':
                            _EncodingCodepage := 861;
                        'ibm863':
                            _EncodingCodepage := 863;
                        'ibm864':
                            _EncodingCodepage := 864;
                        'ibm865':
                            _EncodingCodepage := 865;
                        'ibm869':
                            _EncodingCodepage := 869;
                        'iso-8859-1':
                            _EncodingCodepage := 28591;
                        'iso-8859-7':
                            _EncodingCodepage := 28597;
                        'iso-8859-15':
                            _EncodingCodepage := 28605;
                    end;
                'DPI':
                    case DeviceSettings.Value of
                        '200':
                            _dpi := _dpi::"200";
                        '300':
                            _dpi := _dpi::"300";
                    end;
                else
                    Error(InvalidDeviceSettingErr, DeviceSettings.Value);
            end;
        until DeviceSettings.Next() = 0;
    end;

    local procedure InitializePrinter()
    begin
        // ESC @
        _DotNetStream.WriteByte(27); //ESC        
        AddStringToBuffer('@');
    end;

    procedure GeneratePulse(m: Integer; t1: Char; t2: Char)
    begin
        // ESC p %1 %2 %3
        _DotNetStream.WriteByte(27); //ESC 
        AddStringToBuffer('p' + Format(m) + Format(t1) + Format(t2));
    end;

    local procedure PrintBarCodeA(m: Char; "d1..dk": Text[30])
    begin
        // GS k %1 %2 NUL
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('k' + Format(m) + "d1..dk");
        _DotNetStream.WriteByte(0);
    end;

    local procedure PrintBarCodeB(m: Char; n: Char; "d1..dn": Text)
    begin
        // GS k m n d1..dn
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('k' + Format(m) + Format(n) + "d1..dn");
    end;

    local procedure QRSelectModel(pL: Char; pH: Char; cn: Char; fn: Char; n1: Char; n2: Char)
    begin
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(n1) + Format(n2));
    end;

    local procedure QRSelectSize(pL: Char; pH: Char; cn: Char; fn: Char; n: Char)
    begin
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(n));
    end;

    local procedure QRSelectErrorLevel(pL: Char; pH: Char; cn: Char; fn: Char; n: Char)
    begin
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(n));
    end;

    local procedure QRStoreData(pL: Char; pH: Char; cn: Char; fn: Char; m: Char; "d1..dk": Text)
    begin
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(m) + "d1..dk");
    end;

    local procedure QRPrintData(pL: Char; pH: Char; cn: Char; fn: Char; m: Char)
    begin
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(' + 'k' + Format(pL) + Format(pH) + Format(cn) + Format(fn) + Format(m));
    end;

    local procedure PrintGraphicsInBuffer()
    begin
        // GS ( L %1 %2 %3 %4        
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(L');
        _DotNetStream.WriteByte(2);
        _DotNetStream.WriteByte(0);
        _DotNetStream.WriteByte(48);
        _DotNetStream.WriteByte(50);
    end;

    procedure PrintNVGraphicsData(n: Char; m: Char)
    begin
        // FS p %1 %2
        _DotNetStream.WriteByte(28); //FS
        AddStringToBuffer('p' + Format(n) + Format(m));
    end;

    procedure PrintNVGraphicsDataNew(pL: Char; pH: Char; m: Char; fn: Char; kc1: Char; kc2: Char; x: Char; y: Char)
    begin
        // GS ( L %1 %2 %3 %4 %5 %6 %7 %8
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(L' + Format(pL) + Format(pH) + Format(m) + Format(fn) + Format(kc1) + Format(kc2) + Format(x) + Format(y));
    end;

    local procedure SelectCharacterCodeTable(n: Char)
    begin
        // ESC t %1
        _DotNetStream.WriteByte(27); //ESC 
        AddStringToBuffer('t' + Format(n));
    end;

    local procedure SelectCharacterFont(n: Char)
    begin
        // ESC M %1
        _DotNetStream.WriteByte(27); //ESC 
        AddStringToBuffer('M' + format(n));
    end;

    local procedure SelectCharacterSize(n: Char)
    begin
        // Bit 0-2 Height Magnification
        // Bit 3 Reserved
        // Bit 4-6 Width Magnification
        // Bit 7 reserved
        // GS ! %1
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('!' + Format(n));
    end;

    local procedure SelectCutModeAndCutPaper(m: Char; n: Char)
    begin
        // GS V %1 %2
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('V' + Format(m) + Format(n));
    end;

    local procedure SelectJustification(n: Integer)
    begin
        // ESC a %1
        _DotNetStream.WriteByte(27); //ESC 
        AddStringToBuffer('a' + Format(n));
    end;

    local procedure SetBarCodeHeight(n: Char)
    begin
        // GS h %1
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('h' + Format(n));
    end;

    local procedure SetBarCodeWidth(n: Char)
    begin
        // GS w %1
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('w' + Format(n));
    end;

    local procedure StoreGraphicsInBuffer(pL: Char; pH: Char; m: Char; fn: Char; a: Char; bx: Char; by: Char; c: Char; xL: Char; xH: Char; yL: Char; yH: Char)
    begin
        // https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=99
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('(L' + Format(pL) + Format(pH) + Format(m) + Format(fn) + Format(a) + Format(bx) + Format(by) + Format(c) + Format(xL) + Format(xH) + Format(yL) + Format(yH));
    end;

    local procedure TurnDoubleStrikeModeOnOff(n: Integer)
    begin
        // ESC G %1
        _DotNetStream.WriteByte(27); //ESC 
        AddStringToBuffer('G' + Format(n));
    end;

    local procedure TurnExphasizedModeOnOff(n: Integer)
    begin
        // ESC E %1
        _DotNetStream.WriteByte(27); //ESC 
        AddStringToBuffer('E' + Format(n));
    end;

    local procedure TurnUnderlineModeOnOff(n: Integer)
    begin
        // ESC - %1
        _DotNetStream.WriteByte(27); //ESC 
        AddStringToBuffer('-' + Format(n));
    end;

    local procedure InitBuffer()
    var
        OStream: OutStream;
    begin
        Clear(OStream);
        Clear(_PrintBuffer);
        Clear(_DotNetStream);
        Clear(_DotNetEncoding);
        _PrintBuffer.CreateOutStream(OStream);
        _DotNetEncoding.Encoding(_EncodingCodepage);
        _DotNetStream.FromOutStream(OStream);
    end;

    local procedure AddStringToBuffer(String: Text)
    var
        DotNetCharArray: Codeunit "DotNet_Array";
        DotNetByteArray: Codeunit "DotNet_Array";
        DotNetString: Codeunit "DotNet_String";
    begin
        //This function over allocates and is verbose, all because of the beautiful DotNet wrapper codeunits.

        DotNetString.Set(String);
        DotNetString.ToCharArray(0, DotNetString.Length(), DotNetCharArray);
        _DotNetEncoding.GetBytes(DotNetCharArray, 0, DotNetCharArray.Length(), DotNetByteArray);
        _DotNetStream.Write(DotNetByteArray, 0, DotNetByteArray.Length());
    end;

    local procedure AddStreamToBuffer(var IStream: InStream)
    var
        DotNetStream: Codeunit "DotNet_Stream";
        DotNetByteArray: Codeunit "DotNet_Array";
    begin
        DotNetStream.FromInStream(IStream);
        DotNetByteArray.ByteArray(DotNetStream.Length());
        DotNetStream.Read(DotNetByteArray, 0, DotNetStream.Length());
        _DotNetStream.Write(DotNetByteArray, 0, DotNetByteArray.Length());
    end;

    local procedure FormatJobForHTTP()
    var
        HexBuffer: Text;
        HexadecimalConvert: Codeunit "NPR Hexadecimal Convert";
    begin

        //formats job as per epson ePOS-Print XML specification:
        //https://reference.epson-biz.com/modules/ref_epos_print_xml_en/index.php?content_id=1

        HexBuffer := HexadecimalConvert.BlobAsHexadecimal(_PrintBuffer);

        _EncodingCodepage := 65001; //utf8
        InitBuffer();

        AddStringToBuffer(
        '<?xml version="1.0" encoding="utf-8"?>' +
        '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">' +
        '<s:Body>' +
        '<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">' +
            '<command>' + HexBuffer + '</command>' +
        '</epos-print>' +
        '</s:Body>' +
        '</s:Envelope>');
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
        AddOption(RetailList, 'CLEARFORMAT', '');
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(tmpRetailList, SettingMediawidthLbl, 'MEDIA_WIDTH');
        AddOption(tmpRetailList, SettingEncodingLbl, 'ENCODING');
        AddOption(tmpRetailList, SettingDpiLbl, 'DPI');
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
        ConsecutiveNumbers: Integer;
        CurrentMode: Option " ",CodeA,CodeB,CodeC;
        Buffer: Text;
        Integer: Integer;
    begin
        // This function builds a value using the following code128 code set logic:
        // Switch to Code C when: More than 4 digits at the start/end or 6 in the middle. Otherwise stay with last used code set if possible.
        // This is done to minimize the width of the final barcode and it's quite messy - the printer itself should do this work instead of us but it can't....

        Length := StrLen(Value);

        if Length = 0 then
            exit('');

        for i := 1 to Length do begin
#pragma warning disable AA0206
            Numeric := Evaluate(Integer, Value[i]);
#pragma warning restore

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
#pragma warning restore AA0139
}

