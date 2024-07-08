codeunit 6014601 "NPR RP Boca FGL Device Lib." implements "NPR ILine Printer"
{
#pragma warning disable AA0139
    Access = Internal;
    // Line print..
    // ----------------------------------------------------------------------------------
    // 
    // dpi information:
    //   - 200 dpi = 203.2 dpi | dotsize: 0.00492 in
    //   - 300 dpi = 304.9 dpi | dotsize: 0.00328 in
    //   - 600 dpi = 600.0 dpi | dotsize: 0.00150 in
    // 
    // ----------------------------------------------------------------------------------
    // 
    // 0.03937007874 in = 1 mm
    // 
    // ----------------------------------------------------------------------------------
    // 
    // Paper information:
    //   - Normal: 80 mm = 3.14961 in
    //     // actually only 79mm: 3.11024 in
    //   - Narrow: 58 mm = 2.28346 in
    //     // actually only 57mm: 2.24409 in
    // 
    // Note: The printer usually reserves a small margin around the perimetre
    //       of the ticket in which no printing can appear.
    //       - I believe that this is like 5 dots on each side
    // 
    // ----------------------------------------------------------------------------------
    // 
    // Font information (Default):
    // <F1>  Font1 characters  (5x7)           | Boxsize: (7x8)
    // <F2>  Font2 characters  (8x16)          | Boxsize: (10x18)
    // <F3>  OCRB              (17x31)         | Boxsize: (20x33)
    // <F4>  OCRA              (5x9)           | Boxsize: (7x11)           It is not recommended for use on 200 dpi printers!! Non-rotated character set (no extended graphics characters). It does not include lower-case letters in either rotation or the OC
    // <F5>  Font2 characters  (8x16)          | Boxsize: (10x18)          Obsolete?
    // <F6>  Large OCRB        (30x52)         | Boxsize: (34x56)
    // <F7>  OCRA              (15x29)         | Boxsize: (20x31)
    // <F8>  Courier           (20x40)(18x30)  | Boxsize: (20x33)(20x30)   2nd values are for FGL2
    // <F9>  Small OCRB        (13x20)         | Boxsize: (13x22)
    // <F10> Prestige          (25x41)         | Boxsize: (28x41)          This is a bold Prestige font containing the condensed German and British character sets.
    // <F11> Script            (25x49)         | Boxsize: (26x49)          This is a Script font.
    // <F12> Orator            (46x91)         | Boxsize: (47x91)          Orator font for tall, bold lettering. The šlower› case characters are supported from font SA00 and newer.
    // <F13> Courier           (20x40)         | Boxsize: (20x42)          Courier styled international character set (223 characters).
    // <F14>                   (9x20)          | Boxsize: (10x22)          For Miltope users only
    // <F15>                   (18x24)         | Boxsize: (20x26)          For Miltope users only
    // <F16> Cyrillic          (18x31)         | Boxsize: (20x33)          Cyrillic font
    // 
    // Note:
    //   1: Boxsize <BSx,y> determines the char padding. (area around the text)
    //   2: Height/Width <HWh,w> is used as a font modifier,
    //      by multiplying the height/width of the the font characters by the modifier.
    //      Will also modify the boxsize!
    // 
    // ----------------------------------------------------------------------------------
    // 
    // Rotation information:
    // <NR> No rotation
    // <RR> Rotate right (+90)
    // <RU> Rotate upside down (+180)
    // <RL> Rotate left (+270 or - 90)
    // 
    // ----------------------------------------------------------------------------------
    // 
    // Barcode information:
    // Will only implement EAN13 and Code 128.
    // 
    // a= u (for upc and ean8)
    // a= e (for ean-13)
    // a= n (for three of nine)
    // a= f (for interleaved two of five)
    // a= c (for uss-codabar)
    // a= o (for code 128)
    // a= s (for softstrip)
    // 
    // Orientation:
    // B= P (for picket-fence) (lines are stacked horizontally)
    // B= L (for ladder)       (lines are stacked vertically)
    // 
    // Human Readable Interpretation (HRI):
    //   <BI>: printed as font1, size depends on the barcode size (Automatically adjusted).
    // 
    // Note:
    //   Rotations will affect barcodes.    

    var
        _MediaWidth: Option "80mm","58mm";
        _PrintBuffer: Codeunit "Temp Blob";
        _FontHeight: Integer;
        _FontWidth: Integer;
        _HeightModifier: Integer;
        _WidthModifier: Integer;
        _PageWidth: Integer;
        _DotSize: Decimal;
        _DPI: Option "200","300","600";
        _PrintMargin: Integer;
        _yCoord: Integer;
        _ySpace: Integer;
        SettingMediawidthLbl: Label 'Width of media.';
        SettingEncodingLbl: Label 'Text encoding.';
        SettingDpiLbl: Label 'DPI of device.';
        InvalidDeviceSettingErr: Label 'Invalid device setting: %1';
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;

    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        InitBuffer();
        Clear(_MediaWidth);
        Clear(_DPI);

        if DeviceSettings.FindSet() then
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
                        ;
                    'DPI':
                        case DeviceSettings.Value of
                            '200':
                                _DPI := _DPI::"200";
                            '300':
                                _DPI := _DPI::"300";
                            '600':
                                _DPI := _DPI::"600";
                        end;
                    else
                        Error(InvalidDeviceSettingErr, DeviceSettings.Value);
                end;
            until DeviceSettings.Next() = 0;

        //InitializePrinter;
        case _DPI of
            _DPI::"200":
                _DotSize := 0.00492;
            _DPI::"300":
                _DotSize := 0.00328;
            _DPI::"600":
                _DotSize := 0.0015;
        end;

        _PrintMargin := Mm2In(1.25) div _DotSize;

        case _MediaWidth of
            _MediaWidth::"80mm":
                _PageWidth := (Mm2In(78) div _DotSize) - _PrintMargin; // this looks nicer, due to added margin
            _MediaWidth::"58mm":
                _PageWidth := (Mm2In(57) div _DotSize) - _PrintMargin;
        end;
        _yCoord := 0; // start position
    end;

    procedure LineFeed()
    begin
        _yCoord += _ySpace;
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    var
        StringLib: Codeunit "NPR String Library";
        PrintDataLbl: Label '<RC%1,%2>', Locked = true;
        PrintData2Lbl: Label '<HW%1,%2>', Locked = true;
        PrintData3Lbl: Label '<CTR%1>~', Locked = true;
    begin
        if UpperCase(POSPrintBuffer.Font) = 'COMMAND' then
            SendCommand(POSPrintBuffer.Text)
        else
            if IsBarcodeFont(POSPrintBuffer.Font) then
                PrintBarcode(POSPrintBuffer.Font, POSPrintBuffer.Text, POSPrintBuffer.Width, 10, POSPrintBuffer.Align)
            else
                if POSPrintBuffer.Font = 'Logo' then
                    PrintBitmapFromKeyword(POSPrintBuffer.Text)
                else begin
                    if POSPrintBuffer."Column No." = 1 then begin
                        AddStringToBuffer(StrSubstNo(PrintDataLbl, _PageWidth, _yCoord));
                        AddStringToBuffer('<RL>'); // Orientation, perhaps set this as an option later?
                    end;
                    StringLib.Construct(POSPrintBuffer.Font);
                    AddStringToBuffer('<' + StringLib.SelectStringSep(1, ' ') + '>');

                    AddStringToBuffer(StrSubstNo(PrintData2Lbl, _HeightModifier, _WidthModifier)); // text modifier

                    if POSPrintBuffer."Column No." = 1 then begin
                        case POSPrintBuffer.Align of
                            1:
                                AddStringToBuffer(StrSubstNo(PrintData3Lbl, _PageWidth));
                        end;
                    end;

                    AddStringToBuffer(POSPrintBuffer.Text);

                    if POSPrintBuffer."Column No." = 1 then begin
                        case POSPrintBuffer.Align of
                            1:
                                AddStringToBuffer('~');
                        end;
                    end;

                    if POSPrintBuffer.Text <> '' then
                        _ySpace := _FontHeight
                    else
                        _ySpace := 0;
                end;
    end;

    procedure EndJob()
    begin
        AddStringToBuffer('<p>');
    end;

    procedure LookupFont(var Value: Text): Boolean
    begin
        exit(SelectFont(Value));
    end;

    procedure LookupCommand(var Value: Text): Boolean
    begin
        exit(SelectCommand(Value));
    end;

    procedure LookupDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean
    begin
        exit(SelectDeviceSetting(tmpDeviceSetting));
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    var
        StringLib: Codeunit "NPR String Library";
        TextModifierW: Integer;
        TextModifierH: Integer;
    begin
        // Set default font modifier
        SetFontStretch(1, 1);

        // Check if a font modifier has been added
        StringLib.Construct(FontFace);
        if StringLib.CountOccurences(' ') > 0 then begin
            FontFace := StringLib.SelectStringSep(1, ' ');
            StringLib.Construct(StringLib.SelectStringSep(2, ' '));
            if StringLib.CountOccurences(',') > 0 then begin
                if (Evaluate(TextModifierH, StringLib.SelectStringSep(1, ',')) and Evaluate(TextModifierW, StringLib.SelectStringSep(2, ','))) then
                    SetFontStretch(TextModifierH, TextModifierW);
            end;
        end;

        // Calculate receipt width
        case FontFace of
            'F1':
                begin
                    _FontHeight := 8 * _HeightModifier;
                    _FontWidth := 7 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F2':
                begin
                    _FontHeight := 18 * _HeightModifier;
                    _FontWidth := 10 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F3':
                begin
                    _FontHeight := 33 * _HeightModifier;
                    _FontWidth := 20 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F4':
                begin
                    _FontHeight := 11 * _HeightModifier;
                    _FontWidth := 7 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F5':
                begin
                    _FontHeight := 18 * _HeightModifier;
                    _FontWidth := 10 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F6':
                begin
                    _FontHeight := 56 * _HeightModifier;
                    _FontWidth := 34 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F7':
                begin
                    _FontHeight := 31 * _HeightModifier;
                    _FontWidth := 20 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F8':
                begin
                    _FontHeight := 30 * _HeightModifier;
                    _FontWidth := 20 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F9':
                begin
                    _FontHeight := 22 * _HeightModifier;
                    _FontWidth := 13 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F10':
                begin
                    _FontHeight := 41 * _HeightModifier;
                    _FontWidth := 28 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F11':
                begin
                    _FontHeight := 49 * _HeightModifier;
                    _FontWidth := 26 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F12':
                begin
                    _FontHeight := 91 * _HeightModifier;
                    _FontWidth := 47 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
            'F13':
                begin
                    _FontHeight := 42 * _HeightModifier;
                    _FontWidth := 20 * _WidthModifier;
                    exit(_PageWidth div _FontWidth);
                end;
        end;
    end;

    procedure PrepareJobForHTTP(var HTTPEndpoint: Text): Boolean
    begin
        HTTPEndpoint := '';
        exit(false);
    end;

    procedure PrepareJobForBluetooth(): Boolean
    begin
        exit(false);
    end;

    procedure GetPrintBufferAsBase64(): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
    begin
        _PrintBuffer.CreateInStream(IStream);
        exit(Base64Convert.ToBase64(IStream));
    end;

    procedure PrintBarcode(BarcodeType: Text[30]; Text: Text; Width: Integer; Height: Integer; Alignment: Integer)
    var
        StringLib: Codeunit "NPR String Library";
        BarcodeXCoord: Integer;
        PrintBarcodeLbl: Label '<RC%1,%2>', Locked = true;
        PrintBarcode2Lbl: Label '<CTR%1>', Locked = true;
        PrintBarcode3Lbl: Label '<X%1>', Locked = true;
        PrintBarcode4Lbl: Label '<eL%1>', Locked = true;
        PrintBarcode5Lbl: Label '%1J%2K%3L', Locked = true;
        PrintBarcode6Lbl: Label '<oL%1>', Locked = true;
        PrintBarcode7Lbl: Label '^%1^', Locked = true;
        QRBarcodeVers: Integer;
        QRBarcodeErrLvl: Integer;
        QRMaxLength: Integer;
        QRPrintVersionLbl: Label '<QRV%1>', Locked = true;
        QRPrintBarcodeLbl: Label '<QR%1,%2,%3,%4>{%5}', Locked = true;
        QRWidth: Integer;
        QRCenter: Integer;
    begin
        StringLib.Construct(BarcodeType);

        if StringLib.CountOccurences(' ') = 1 then begin
            BarcodeType := StringLib.SelectStringSep(1, ' ');
            if Evaluate(BarcodeXCoord, StringLib.SelectStringSep(2, ' ')) then;
        end;

        if CopyStr(BarcodeType, 1, 2) <> 'QR' then begin
            // Probably need to check if negative
            if _PageWidth > BarcodeXCoord then
                BarcodeXCoord := _PageWidth - BarcodeXCoord // Position of the barcode is starting from the righthand side.
            else
                BarcodeXCoord := _PageWidth;
            // TEMP
            AddStringToBuffer(StrSubstNo(PrintBarcodeLbl, BarcodeXCoord, _yCoord));
            // Alignment, will only work on new firmware 150+
            case Alignment of
                1:
                    AddStringToBuffer(StrSubstNo(PrintBarcode2Lbl, _PageWidth));
            end;
            //+NPR5.55 [403786]
            AddStringToBuffer('<BI>');

            if Width > 1 then
                AddStringToBuffer(StrSubstNo(PrintBarcode3Lbl, Width)); // set after DPI?

            AddStringToBuffer('<RL>'); // Orientation

            case BarcodeType of
                'EAN13':
                    begin
                        if Height > 1 then
                            AddStringToBuffer(StrSubstNo(PrintBarcode4Lbl, Height))
                        else
                            AddStringToBuffer('<eL>');
                        AddStringToBuffer(StrSubstNo(PrintBarcode5Lbl, CopyStr(Text, 1, 1), CopyStr(Text, 2, 6), CopyStr(Text, 8, 6)));
                    end;
                'CODE128':
                    begin
                        if Height > 1 then
                            AddStringToBuffer(StrSubstNo(PrintBarcode6Lbl, Height))
                        else
                            AddStringToBuffer('<oL>');
                        AddStringToBuffer(StrSubstNo(PrintBarcode7Lbl, Text));
                    end;
            end;

            if Height > 1 then
                _ySpace := Height * 10
            else
                _ySpace := 40;

        end else begin // QR
            if StrPos(BarcodeType, '7') > 0 then
                QRBarcodeVers := 7
            else
                if StrPos(BarcodeType, '11') > 0 then
                    QRBarcodeVers := 11
                else
                    if StrPos(BarcodeType, '15') > 0 then
                        QRBarcodeVers := 15
                    else
                        QRBarcodeVers := 2;

            case CopyStr(BarcodeType, strlen(BarcodeType)) of
                'L':
                    QRBarcodeErrLvl := 1;
                'H':
                    QRBarcodeErrLvl := 2;
                'Q':
                    QRBarcodeErrLvl := 3;
                else
                    QRBarcodeErrLvl := 0;
            end;

            QRMaxLength := CheckMaxLengthQR(QRBarcodeVers, QRBarcodeErrLvl);

            if StrLen(Text) > QRMaxLength then
                Error('The value of the QR code exceeds the max limit for current QR settings. Try Lowering the Error Correction Level or increasing the QR version.')
            else begin
                AddStringToBuffer(StrSubstNo(QRPrintVersionLbl, QRBarcodeVers));

                if (Width >= 3) and (Width <= 16) then
                    QRWidth := Width
                else
                    QRWidth := 6; // default

                AddStringToBuffer('<RL>'); // Orientation

                // Overrule width to center
                case QRBarcodeVers of
                    2:
                        begin
                            _ySpace := (QRWidth * 25);
                            QRCenter := (_PageWidth + _ySpace) DIV 2
                        end;
                    7:
                        begin
                            _ySpace := (QRWidth * 45);
                            QRCenter := (_PageWidth + _ySpace) DIV 2
                        end;
                    11:
                        begin
                            _ySpace := (QRWidth * 61);
                            QRCenter := (_PageWidth + _ySpace) DIV 2
                        end;
                    15:
                        begin
                            _ySpace := (QRWidth * 77);
                            QRCenter := (_PageWidth + _ySpace) DIV 2
                        end;
                end;

                AddStringToBuffer(StrSubstNo(PrintBarcodeLbl, QRCenter, _yCoord));
                AddStringToBuffer(StrSubstNo(QRPrintBarcodeLbl, QRWidth, 0, 0, QRBarcodeErrLvl, Text));

                _yCoord += _ySpace + 10;

                AddStringToBuffer('<RL>');
                AddStringToBuffer(StrSubstNo(PrintBarcodeLbl, _PageWidth, _yCoord));
                AddStringToBuffer('<F8>');
                AddStringToBuffer(StrSubstNo(PrintBarcode2Lbl, _PageWidth));
                AddStringToBuffer('~' + Text + '~');
                _ySpace := 40;
            end;
        end;
    end;

    local procedure PrintStoredLogo(ID: Integer; Height: Integer)
    var
        PrintStoredLogoLbl: Label '<SP%1,%2>', Locked = true;
        PrintStoredLogo2Lbl: Label '<LD%1>', Locked = true;
    begin
        // 200dpi
        AddStringToBuffer(StrSubstNo(PrintStoredLogoLbl, 570, _yCoord));
        AddStringToBuffer('<RL>');
        AddStringToBuffer(StrSubstNo(PrintStoredLogo2Lbl, ID));
        if Height > 0 then
            _ySpace := Height
        else
            _ySpace := 100;
    end;

    local procedure PrintVerticalSpace(Height: Integer)
    begin
        _ySpace := Height;
    end;

    local procedure SendCommand(Command: Text)
    var
        StringLib: Codeunit "NPR String Library";
        Height: Integer;
    begin
        StringLib.Construct(Command);

        if StringLib.CountOccurences(' ') = 1 then begin
            Command := StringLib.SelectStringSep(1, ' ');
            if Evaluate(Height, StringLib.SelectStringSep(2, ' ')) then;
        end;

        case UpperCase(Command) of
            //'OPENDRAWER' : GeneratePulse(0,25,25);
            //'PAPERCUT' : SelectCutModeAndCutPaper(66,3);
            'STOREDLOGO_1':
                PrintStoredLogo(1, Height);
            'STOREDLOGO_2':
                PrintStoredLogo(2, Height);
            'VERTICAL_SPACE':
                PrintVerticalSpace(Height);
        end;
    end;

    procedure SetFontStretch(Height: Integer; Width: Integer)
    begin
        if Height > 16 then
            Height := 16;

        if Width > 16 then
            Width := 16;

        _HeightModifier := Height;
        _WidthModifier := Width;
    end;

    local procedure PrintBitmapFromKeyword(Keyword: Code[20])
    var
        LogoAsText: Text;
        InStream: InStream;
        Encoding: Codeunit "DotNet_Encoding";
        RetailLogo: Record "NPR Retail Logo";
        StreamReader: Codeunit "DotNet_StreamReader";
        PrintBitmapFromKeywordLbl: Label '<SP%1,%2><RL><bmp><G%3>%4', Locked = true;
    begin
        RetailLogo.SetAutoCalcFields(OneBitLogo);
        RetailLogo.SetRange(Keyword, Keyword);
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        if RetailLogo.FindSet() then
            repeat
                if RetailLogo.OneBitLogo.HasValue() then begin
                    RetailLogo.OneBitLogo.CreateInStream(InStream);
                    Encoding.Encoding(850);
                    StreamReader.StreamReader(InStream, Encoding);
                    LogoAsText := StreamReader.ReadToEnd();
                    AddStringToBuffer(StrSubstNo(PrintBitmapFromKeywordLbl, (_PageWidth div 1.077), _yCoord, RetailLogo.OneBitLogoByteSize, LogoAsText)); // Might need to update placement of logo in the future
                    _yCoord += RetailLogo.Height + 30; // Might need to make this dynamic in the future
                end;
            until RetailLogo.Next() = 0;
    end;


    local procedure IsBarcodeFont(Font: Text): Boolean
    var
        StringLib: Codeunit "NPR String Library";
    begin
        Font := UpperCase(Font);

        StringLib.Construct(Font);
        Font := StringLib.SelectStringSep(1, ' ');

        if Font in ['EAN13', 'CODE128',
                    'QR', 'QR2L', 'QR2M', 'QR2Q', 'QR2H', 'QR7L', 'QR7M', 'QR7Q', 'QR7H', 'QR11L', 'QR11M', 'QR11Q', 'QR11H', 'QR15L', 'QR15M', 'QR15Q', 'QR15H'] then
            exit(true);
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
        _DotNetEncoding.Encoding(850);
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
                        tmpDeviceSetting.Options := 'ibm850';
                    end;
                'DPI':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := '200,300,600';
                    end;
            end;
            exit(tmpDeviceSetting.Insert());
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "NPR Retail List" temporary)
    begin
        // Fonts:
        // F8
        AddOption(RetailList, 'F8', '');
        AddOption(RetailList, 'F8 2,1', '');
        AddOption(RetailList, 'F8 1,2', '');
        AddOption(RetailList, 'F8 2,2', '');
        // F13
        AddOption(RetailList, 'F13', '');
        AddOption(RetailList, 'F13 2,1', '');
        AddOption(RetailList, 'F13 1,2', '');
        AddOption(RetailList, 'F13 2,2', '');

        // Barcodes:
        // EAN-13
        AddOption(RetailList, 'EAN13', '');
        AddOption(RetailList, 'EAN13 50', '');
        AddOption(RetailList, 'EAN13 100', '');
        AddOption(RetailList, 'EAN13 150', '');
        // Code128
        AddOption(RetailList, 'CODE128', '');
        AddOption(RetailList, 'CODE128 50', '');
        AddOption(RetailList, 'CODE128 100', '');
        AddOption(RetailList, 'CODE128 150', '');
        // QR
        AddOption(RetailList, 'QR', '');
        AddOption(RetailList, 'QR2L', '');
        AddOption(RetailList, 'QR2M', '');
        AddOption(RetailList, 'QR2Q', '');
        AddOption(RetailList, 'QR2H', '');
        AddOption(RetailList, 'QR7L', '');
        AddOption(RetailList, 'QR7M', '');
        AddOption(RetailList, 'QR7Q', '');
        AddOption(RetailList, 'QR7H', '');
        AddOption(RetailList, 'QR11L', '');
        AddOption(RetailList, 'QR11M', '');
        AddOption(RetailList, 'QR11Q', '');
        AddOption(RetailList, 'QR11H', '');
        AddOption(RetailList, 'QR15L', '');
        AddOption(RetailList, 'QR15M', '');
        AddOption(RetailList, 'QR15Q', '');
        AddOption(RetailList, 'QR15H', '');


        // Fonts without Æ Ø Å:
        AddOption(RetailList, 'F1', '');
        AddOption(RetailList, 'F2', '');
        AddOption(RetailList, 'F3', '');
        AddOption(RetailList, 'F4', '');
        AddOption(RetailList, 'F5', '');
        AddOption(RetailList, 'F6', '');
        AddOption(RetailList, 'F7', '');
        AddOption(RetailList, 'F9', '');
        AddOption(RetailList, 'F10', '');
        AddOption(RetailList, 'F11', '');
        AddOption(RetailList, 'F12', '');
    end;

    procedure ConstructCommandSelectionList(var RetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(RetailList, 'STOREDLOGO_1', '');
        AddOption(RetailList, 'STOREDLOGO_1 150', '');
        AddOption(RetailList, 'STOREDLOGO_2', '');
        AddOption(RetailList, 'STOREDLOGO_2 150', '');
        AddOption(RetailList, 'VERTICAL_SPACE 10', '');
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

    local procedure Mm2In(mm: Decimal): Decimal
    begin
        exit(mm * 0.03937007874);
    end;

    local procedure CheckMaxLengthQR(QRVersion: Integer; QRErrorCorrectionLevel: Integer): Integer
    begin
        case QRVersion of
            2:
                case QRErrorCorrectionLevel of
                    0:
                        exit(26);
                    1:
                        exit(32);
                    2:
                        exit(14);
                    3:
                        exit(20);
                end;
            7:
                case QRErrorCorrectionLevel of
                    0:
                        exit(122);
                    1:
                        exit(154);
                    2:
                        exit(64);
                    3:
                        exit(86);
                end;
            11:
                case QRErrorCorrectionLevel of
                    0:
                        exit(251);
                    1:
                        exit(321);
                    2:
                        exit(137);
                    3:
                        exit(177);
                end;
            15:
                case QRErrorCorrectionLevel of
                    0:
                        exit(412);
                    1:
                        exit(520);
                    2:
                        exit(220);
                    3:
                        exit(292);
                end;
        end;
    end;
#pragma warning restore AA0139
}

