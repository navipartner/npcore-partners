codeunit 6014601 "NPR RP Boca FGL Device Lib."
{
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
    // 
    // ----------------------------------------------------------------------------------
    // 
    // Graphics/Logo information:
    // 
    // ----------------------------------------------------------------------------------
    // NPR5.54/JAKUBV/20200408  CASE 369235 Transport NPR5.54 - 8 April 2020
    // NPR5.55/MITH/20200511  CASE 403786 Added centering of barcode functionality
    // NPR5.55/MITH/20200511  CASE 404276 Added print of bitmap from Retail logo functionality

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        //PrintMethodMgt.PrintBytesLocal('Boca (redirected 28)','<SP200,60><RC600,280><RL><F8><HW1,1>ab æÆ bc ¢¥ cd åÅ - $£<p>','ibm850');
    end;

    var
        SETTING_MEDIAWIDTH: Label 'Width of media.';
        MediaWidth: Option "80mm","58mm";
        SETTING_ENCODING: Label 'Text encoding.';
        SETTING_DPI: Label 'DPI of device.';
        Error_InvalidDeviceSetting: Label 'Invalid device setting: %1';
        Encoding: Option ibm850;
        PrintBuffer: Codeunit "Temp Blob";
        PrintBufferOutStream: OutStream;
        FontHeight: Integer;
        FontWidth: Integer;
        HeightModifier: Integer;
        WidthModifier: Integer;
        PageWidth: Integer;
        DotSize: Decimal;
        DPI: Option "200","300","600";
        PrintMargin: Integer;
        yCoord: Integer;
        ySpace: Integer;

    local procedure DeviceCode(): Text
    begin
        exit('BOCA');
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
        PrintData(POSPrintBuffer.Text, POSPrintBuffer.Font, POSPrintBuffer.Bold, POSPrintBuffer.Underline, POSPrintBuffer.DoubleStrike, POSPrintBuffer.Align, POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer."Column No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Printer Interf.", 'OnEndJob', '', false, false)]
    local procedure OnEndJob()
    begin
        AddTextToBuffer('<p>');
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
        TargetEncoding := 'ibm850';
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

    procedure "// ShortHandFunctions"()
    begin
    end;

    procedure Init(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        //-NPR5.40 [284505]
        //CLEAR(PrintBuffer);
        InitBuffer();
        //+NPR5.40 [284505]
        Clear(MediaWidth);
        Clear(Encoding);
        Clear(DPI);

        if DeviceSettings.FindSet() then
            repeat
                case DeviceSettings.Name of
                    'MEDIA_WIDTH':
                        case DeviceSettings.Value of
                            '80mm':
                                MediaWidth := MediaWidth::"80mm";
                            '58mm':
                                MediaWidth := MediaWidth::"58mm";
                        end;
                    'ENCODING':
                        Encoding := Encoding::ibm850;
                    'DPI':
                        case DeviceSettings.Value of
                            '200':
                                DPI := DPI::"200";
                            '300':
                                DPI := DPI::"300";
                            '600':
                                DPI := DPI::"600";
                        end;
                    else
                        Error(Error_InvalidDeviceSetting, DeviceSettings.Value);
                end;
            until DeviceSettings.Next() = 0;

        //InitializePrinter;
        case DPI of
            DPI::"200":
                DotSize := 0.00492;
            DPI::"300":
                DotSize := 0.00328;
            DPI::"600":
                DotSize := 0.0015;
        end;

        PrintMargin := Mm2In(1.25) div DotSize;

        case MediaWidth of
            //MediaWidth::"80mm" : PageWidth := (Mm2In(79) DIV DotSize) - PrintMargin;
            MediaWidth::"80mm":
                PageWidth := (Mm2In(78) div DotSize) - PrintMargin; // this looks nicer, due to added margin
            MediaWidth::"58mm":
                PageWidth := (Mm2In(57) div DotSize) - PrintMargin;
        end;


        yCoord := 0; // start position
    end;

    procedure PrintData(Data: Text[100]; FontType: Text[30]; Bold: Boolean; UnderLine: Boolean; DoubleStrike: Boolean; Align: Integer; Width: Integer; Height: Integer; Column: Integer)
    var
        StringLib: Codeunit "NPR String Library";
        PrintDataLbl: Label '<RC%1,%2>', Locked = true;
        PrintData2Lbl: Label '<HW%1,%2>', Locked = true;
        PrintData3Lbl: Label '<CTR%1>~', Locked = true;
    begin
        if UpperCase(FontType) = 'COMMAND' then
            SendCommand(Data)
        else
            if IsBarcodeFont(FontType) then
                PrintBarcode(FontType, Data, Width, 10, Align)
            else
                if FontType = 'Logo' then
                    PrintBitmapFromKeyword(Data, '')
                else begin
                    if Column = 1 then begin
                        AddTextToBuffer(StrSubstNo(PrintDataLbl, PageWidth, yCoord));
                        AddTextToBuffer('<RL>'); // Orientation, perhaps set this as an option later?
                    end;
                    StringLib.Construct(FontType);
                    AddTextToBuffer('<' + StringLib.SelectStringSep(1, ' ') + '>');

                    AddTextToBuffer(StrSubstNo(PrintData2Lbl, HeightModifier, WidthModifier)); // text modifier

                    if Column = 1 then begin
                        case Align of
                            1:
                                AddTextToBuffer(StrSubstNo(PrintData3Lbl, PageWidth));
                        end;
                    end;

                    AddTextToBuffer(Data);

                    if Column = 1 then begin
                        case Align of
                            1:
                                AddTextToBuffer('~');
                        end;
                    end;

                    if Data <> '' then
                        ySpace := FontHeight
                    else
                        ySpace := 0;
                end;
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
            if PageWidth > BarcodeXCoord then
                BarcodeXCoord := PageWidth - BarcodeXCoord // Position of the barcode is starting from the righthand side.
            else
                BarcodeXCoord := PageWidth;
            // TEMP
            AddTextToBuffer(StrSubstNo(PrintBarcodeLbl, BarcodeXCoord, yCoord));
            // Alignment, will only work on new firmware 150+
            case Alignment of
                1:
                    AddTextToBuffer(StrSubstNo(PrintBarcode2Lbl, PageWidth));
            end;
            //+NPR5.55 [403786]

            AddTextToBuffer('<BI>');

            if Width > 1 then
                AddTextToBuffer(StrSubstNo(PrintBarcode3Lbl, Width)); // set after DPI?

            AddTextToBuffer('<RL>'); // Orientation

            case BarcodeType of
                'EAN13':
                    begin
                        if Height > 1 then
                            AddTextToBuffer(StrSubstNo(PrintBarcode4Lbl, Height))
                        else
                            AddTextToBuffer('<eL>');
                        AddTextToBuffer(StrSubstNo(PrintBarcode5Lbl, CopyStr(Text, 1, 1), CopyStr(Text, 2, 6), CopyStr(Text, 8, 6)));
                    end;
                'CODE128':
                    begin
                        if Height > 1 then
                            AddTextToBuffer(StrSubstNo(PrintBarcode6Lbl, Height))
                        else
                            AddTextToBuffer('<oL>');
                        AddTextToBuffer(StrSubstNo(PrintBarcode7Lbl, Text));
                    end;
            end;

            if Height > 1 then
                ySpace := Height * 10
            else
                ySpace := 40;

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
                AddTextToBuffer(StrSubstNo(QRPrintVersionLbl, QRBarcodeVers));

                if (Width >= 3) and (Width <= 16) then
                    QRWidth := Width
                else
                    QRWidth := 6; // default

                AddTextToBuffer('<RL>'); // Orientation

                // Overrule width to center
                case QRBarcodeVers of
                    2:
                        begin
                            ySpace := (QRWidth * 25);
                            QRCenter := (PageWidth + ySpace) DIV 2
                        end;
                    7:
                        begin
                            ySpace := (QRWidth * 45);
                            QRCenter := (PageWidth + ySpace) DIV 2
                        end;
                    11:
                        begin
                            ySpace := (QRWidth * 61);
                            QRCenter := (PageWidth + ySpace) DIV 2
                        end;
                    15:
                        begin
                            ySpace := (QRWidth * 77);
                            QRCenter := (PageWidth + ySpace) DIV 2
                        end;
                end;

                AddTextToBuffer(StrSubstNo(PrintBarcodeLbl, QRCenter, yCoord));
                AddTextToBuffer(StrSubstNo(QRPrintBarcodeLbl, QRWidth, 0, 0, QRBarcodeErrLvl, Text));

                yCoord += ySpace + 10;

                AddTextToBuffer('<RL>');
                AddTextToBuffer(StrSubstNo(PrintBarcodeLbl, PageWidth, yCoord));
                AddTextToBuffer('<F8>');
                AddTextToBuffer(StrSubstNo(PrintBarcode2Lbl, PageWidth));
                AddTextToBuffer('~' + Text + '~');
                ySpace := 40;
            end;
        end;
    end;

    local procedure PrintStoredLogo(ID: Integer; Height: Integer)
    var
        PrintStoredLogoLbl: Label '<SP%1,%2>', Locked = true;
        PrintStoredLogo2Lbl: Label '<LD%1>', Locked = true;
    begin
        // 200dpi
        AddTextToBuffer(StrSubstNo(PrintStoredLogoLbl, 570, yCoord));
        AddTextToBuffer('<RL>');
        AddTextToBuffer(StrSubstNo(PrintStoredLogo2Lbl, ID));
        if Height > 0 then
            ySpace := Height
        else
            ySpace := 100;
    end;

    local procedure PrintVerticalSpace(Height: Integer)
    begin
        ySpace := Height;
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

        HeightModifier := Height;
        WidthModifier := Width;
    end;

    procedure SetFontFace(FontFace: Text[30])
    begin
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

    local procedure LineFeed()
    begin
        yCoord += ySpace;
    end;

    local procedure PrintBitmapFromKeyword(Keyword: Code[20]; RegisterNo: Code[10])
    var
        RetailLogoMgt: Codeunit "NPR Retail Logo Mgt.";
        LogoAsText: Text;
        InStream: InStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        NetEncoding: DotNet NPRNetEncoding;
        RetailLogo: Record "NPR Retail Logo";
        StreamReader: DotNet NPRNetStreamReader;
        PrintBitmapFromKeywordLbl: Label '<SP%1,%2><RL><bmp><G%3>%4', Locked = true;
    begin
        RetailLogo.SetAutoCalcFields(OneBitLogo);

        if RetailLogoMgt.GetRetailLogo(Keyword, RegisterNo, RetailLogo) then
            repeat
                if RetailLogo.OneBitLogo.HasValue() then begin
                    RetailLogo.OneBitLogo.CreateInStream(InStream);
                    MemoryStream := InStream;
                    MemoryStream.Position := 0;
                    StreamReader := StreamReader.StreamReader(MemoryStream, NetEncoding.GetEncoding('ibm850'));
                    LogoAsText := StreamReader.ReadToEnd();

                    AddTextToBuffer(StrSubstNo(PrintBitmapFromKeywordLbl, (PageWidth div 1.077), yCoord, RetailLogo.OneBitLogoByteSize, LogoAsText)); // Might need to update placement of logo in the future
                    yCoord += RetailLogo.Height + 30; // Might need to make this dynamic in the future
                end;
            until RetailLogo.Next() = 0;
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
                    FontHeight := 8 * HeightModifier;
                    FontWidth := 7 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F2':
                begin
                    FontHeight := 18 * HeightModifier;
                    FontWidth := 10 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F3':
                begin
                    FontHeight := 33 * HeightModifier;
                    FontWidth := 20 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F4':
                begin
                    FontHeight := 11 * HeightModifier;
                    FontWidth := 7 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F5':
                begin
                    FontHeight := 18 * HeightModifier;
                    FontWidth := 10 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F6':
                begin
                    FontHeight := 56 * HeightModifier;
                    FontWidth := 34 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F7':
                begin
                    FontHeight := 31 * HeightModifier;
                    FontWidth := 20 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F8':
                begin
                    FontHeight := 30 * HeightModifier;
                    FontWidth := 20 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F9':
                begin
                    FontHeight := 22 * HeightModifier;
                    FontWidth := 13 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F10':
                begin
                    FontHeight := 41 * HeightModifier;
                    FontWidth := 28 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F11':
                begin
                    FontHeight := 49 * HeightModifier;
                    FontWidth := 26 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F12':
                begin
                    FontHeight := 91 * HeightModifier;
                    FontWidth := 47 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
            'F13':
                begin
                    FontHeight := 42 * HeightModifier;
                    FontWidth := 20 * WidthModifier;
                    exit(PageWidth div FontWidth);
                end;
        end;
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

    procedure "// Lookup Functions"()
    begin
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

        //AddOption(RetailList, 'OPENDRAWER', '');
        //AddOption(RetailList, 'PAPERCUT', '');
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
}

