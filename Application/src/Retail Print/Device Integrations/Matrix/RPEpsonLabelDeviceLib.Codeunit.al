codeunit 6014537 "NPR RP Epson Label Device Lib." implements "NPR IMatrix Printer"
{
#pragma warning disable AA0139
    Access = Internal;

    var
        _PrintBuffer: Codeunit "Temp Blob";
        _PrinterInitialized: Boolean;
        _LabelHeight: Integer;
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;

    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        _PrinterInitialized := false;
        InitBuffer();
    end;

    procedure EndJob()
    begin
        PrintDataInPageMode();
        FeedLabelToPosition(2, 0, 65, 49); //Feed to label peeling position - This command also makes the next print backfeed to begin with.
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    var
        Err00001: Label 'Font ''%1'' is not supported';
        FontParam: Text;
        StringLib: Codeunit "NPR String Library";
    begin
        if not _PrinterInitialized then
            InitializePrinter(POSPrintBuffer.Font);

        if UpperCase(CopyStr(POSPrintBuffer.Font, 1, 6)) = 'CODE39' then
            PrintBarcode(POSPrintBuffer.Font, POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text)
        else
            if CopyStr(POSPrintBuffer.Font, 1, 5) = 'EAN13' then
                PrintBarcode(POSPrintBuffer.Font, POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text)
            else
                if CopyStr(POSPrintBuffer.Font, 1, 4) = 'UPC-A' then
                    PrintBarcode(POSPrintBuffer.Font, POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text)
                else
                    if UpperCase(CopyStr(POSPrintBuffer.Font, 1, 7)) = 'BARCODE' then begin
                        case true of
                            StrLen(POSPrintBuffer.Text) = 13:
                                PrintBarcode('EAN13', POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
                            StrLen(POSPrintBuffer.Text) = 12:
                                PrintBarcode('UPC-A', POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
                            StrLen(POSPrintBuffer.Text) < 12:
                                PrintBarcode('CODE39', POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
                        end;
                    end else
                        if CopyStr(POSPrintBuffer.Font, 1, 4) = 'Font' then begin
                            StringLib.Construct(POSPrintBuffer.Font);
                            FontParam := StringLib.SelectStringSep(2, ' ');
                            PrintText(FontParam, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Height, false, POSPrintBuffer.Text);
                        end else
                            if CopyStr(POSPrintBuffer.Font, 1, 9) = 'Bold Font' then begin
                                StringLib.Construct(POSPrintBuffer.Font);
                                FontParam := StringLib.SelectStringSep(3, ' ');
                                PrintText(FontParam, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Height, true, POSPrintBuffer.Text);
                            end else
                                if CopyStr(POSPrintBuffer.Font, 1, 5) = 'SETUP' then
                                    exit
                                else
                                    Error(Err00001, POSPrintBuffer.Font);
    end;

    procedure LookupFont(var Value: Text): Boolean
    begin
        exit(SelectFont(Value));
    end;

    procedure LookupCommand(var Value: Text): Boolean
    begin
        Value := '';
        exit(False);
    end;

    procedure LookupDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean;
    begin
        exit(false);
    end;

    procedure PrepareJobForHTTP(var HTTPEndpoint: Text): Boolean;
    begin
        HTTPEndpoint := '';
        exit(false);
    end;

    procedure PrepareJobForBluetooth(): Boolean;
    begin
        exit(False);
    end;

    procedure GetPrintBufferAsBase64(): Text;
    var
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
    begin
        _PrintBuffer.CreateInStream(IStream);
        exit(Base64Convert.ToBase64(IStream));
    end;

    local procedure InitBuffer()
    var
        OStream: OutStream;
    begin
        if not _PrintBuffer.HasValue() then begin
            Clear(OStream);
            Clear(_PrintBuffer);
            Clear(_DotNetStream);
            Clear(_DotNetEncoding);
            _PrintBuffer.CreateOutStream(OStream);
            _DotNetEncoding.Encoding(1252);
            _DotNetStream.FromOutStream(OStream);
        end;
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

    procedure PrintBarcode(BarcodeType: Text[30]; Width: Integer; Height: Integer; Align: Integer; Rotation: Integer; X: Integer; Y: Integer; Text: Text[30])
    var
        TypeHelper: Codeunit "Type Helper";
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
    begin
        case UpperCase(BarcodeType) of
            'UPC-A':
                BarcodeId := 0;
            'UPC-1':
                BarcodeId := 1;
            'EAN13':
                BarcodeId := 2;
            'JAN8':
                BarcodeId := 3;
            'CODE39':
                BarcodeId := 4;
            'ITF':
                BarcodeId := 5;
            'CODABAR':
                BarcodeId := 6;
        end;

        SelectPrintDirectInPageMode(Rotation);

        if (_LabelHeight - Y) > 0 then
            AreaHeight := _LabelHeight - Y
        else
            AreaHeight := _LabelHeight - 1;

        lowX := TypeHelper.BitwiseAnd(X, 255);
        highX := (X - lowX) / 256;

        lowY := TypeHelper.BitwiseAnd(Y, 255);
        highY := (Y - lowY) / 256;

        lowH := TypeHelper.BitwiseAnd(AreaHeight, 255);
        highH := (AreaHeight - lowH) / 256;

        //width is maxed (255 in each) since horizontal limit doesn't affect print
        SetPrintAreaInPageMode(lowX, highX, lowY, highY, 255, 255, lowH, highH);

        SetBarCodeWidth(Width);
        SetBarCodeHeight(Height);

        //Calc low & high byte for print pos
        if Height > 0 then begin
            lowP := TypeHelper.BitwiseAnd(Height, 255);
            highP := (Height - lowP) / 256;
            SetRelativeVerticalPrintPos(lowP, highP);
        end;

        PrintBarCodeA(BarcodeId, Text);
        LineFeed();

        if Rotation > 0 then
            SelectPrintDirectInPageMode(0);
    end;

    procedure PrintDefaultLogo()
    begin
        PrintNVGraphicsData(1, 0);
    end;

    procedure PrintAltDefaultLogo()
    begin
        PrintNVGraphicsDataNew(6, 0, 48, 69, 48, 48, 1, 1);
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

    procedure LineFeed()
    begin
        // Ref sheet 103, Print And Line Feed
        _DotNetStream.WriteByte(10); //LF
    end;

    local procedure FeedLabelToPosition(pL: Char; pH: Char; fn: Char; m: Char)
    begin
        _DotNetStream.WriteByte(28); //FS
        AddStringToBuffer(StrSubstNo('(L%1%2%3%4', pL, pH, fn, m));
    end;

    local procedure InitializePrinter(FontType: Text)
    var
        StringLib: Codeunit "NPR String Library";
    begin
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('@');

        StringLib.Construct(FontType);
        if (CopyStr(FontType, 1, 12) = 'SETUP HEIGHT') then //Syntax: SETUP HEIGHT y
            Evaluate(_LabelHeight, StringLib.SelectStringSep(3, ' '))
        else
            _LabelHeight := 330;

        SelectPageMode();
        SelectCharacterCodeTable(16);
        SetHorzAndVertMotionUnits(0, 0);
        SelectDefaultLineSpacing();
        _PrinterInitialized := true;
    end;

    local procedure PrintBarCodeA(m: Char; "d1..dk": Text[30])
    begin
        // GS k %1 %2 NUL
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('k');
        AddStringToBuffer(Format(m) + "d1..dk");
        _DotNetStream.WriteByte(0);
    end;

    local procedure PrintDataInPageMode()
    begin
        _DotNetStream.WriteByte(27); //ESC
        _DotNetStream.WriteByte(12);
    end;

    procedure PrintNVGraphicsData(n: Char; m: Char)
    begin
        // FS p %1 %2
        _DotNetStream.WriteByte(28); //FS
        AddStringToBuffer('p' + Format(n) + Format(m));
    end;

    procedure PrintNVGraphicsDataNew(pL: Char; pH: Char; m: Char; fn: Char; kc1: Char; kc2: Char; x: Char; y: Char)
    begin
        //GS ( L %1 %2 %3 %4 %5 %6 %7 %8
        _DotNetStream.WriteByte(29);
        AddStringToBuffer('(L' + format(pL) + format(pH) + format(m) + format(fn) + format(kc1) + format(kc2) + format(x) + format(y));
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

    local procedure SelectDefaultLineSpacing()
    begin
        //ESC 2        
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('2');
    end;

    local procedure SelectPageMode()
    begin
        //ESC L
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('L');
    end;

    local procedure SelectPrintDirectInPageMode(n: Integer)
    begin
        //ESC T %1
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('T' + format(n));
    end;

    local procedure SetBarCodeHeight(n: Char)
    begin
        // GS h %1
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('h');
        AddStringToBuffer(Format(n));
    end;

    local procedure SetBarCodeWidth(n: Char)
    begin
        // GS w %1
        _DotNetStream.WriteByte(29); //GS
        AddStringToBuffer('w');
        AddStringToBuffer(Format(n));
    end;

    local procedure SetHorzAndVertMotionUnits(x: Char; y: Char)
    begin
        //GS P %1 %2
        _DotNetStream.WriteByte(29);
        AddStringToBuffer('P' + format(x) + format(y));
    end;

    local procedure SetPrintAreaInPageMode(xL: Char; xH: Char; yL: Char; yH: Char; dxL: Char; dxH: Char; dyL: Char; dyH: Char)
    begin
        //ESC W        
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('W' + format(xL) + format(xH) + format(yL) + format(yH) + format(dxL) + format(dxH) + format(dyL) + format(dyH));
    end;

    local procedure SetRelativeVerticalPrintPos(nL: Char; nH: Char)
    begin
        //GS \ %1 %2        
        _DotNetStream.WriteByte(29);
        AddStringToBuffer('\' + format(nL) + format(nH));
    end;

    local procedure PrintText(Type: Text; Rotation: Integer; X: Integer; Y: Integer; Height: Integer; Bold: Boolean; TextIn: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        highY: Integer;
        lowY: Integer;
        highX: Integer;
        lowX: Integer;
        highH: Integer;
        lowH: Integer;
        AreaHeight: Integer;
        highP: Integer;
        lowP: Integer;
    begin
        // Align     :   Alignment of text
        // Rotate    :   Orientation,                [0,1,2,3] -> [0º,90º,180º,270º]
        // Type      :   Font Type
        // Height    :   Character height
        // Width     :   Character width
        // X         :
        // Y         :
        // TextIn    :   String content

        if Bold then
            TurnExphasizedModeOnOff(1);

        if (_LabelHeight - Y) > 0 then
            AreaHeight := _LabelHeight - Y
        else
            AreaHeight := _LabelHeight - 1;

        lowX := TypeHelper.BitwiseAnd(X, 255);
        highX := (X - lowX) / 256;

        lowY := TypeHelper.BitwiseAnd(Y, 255);
        highY := (Y - lowY) / 256;

        lowH := TypeHelper.BitwiseAnd(AreaHeight, 255);
        highH := (AreaHeight - lowH) / 256;

        //width is maxed (255 in each) since horizontal limit doesn't affect print
        SetPrintAreaInPageMode(lowX, highX, lowY, highY, 255, 255, lowH, highH);

        SelectPrintDirectInPageMode(Rotation);

        SetFontFace(Type);

        if Height > 0 then begin
            lowP := TypeHelper.BitwiseAnd(Height, 255);
            highP := (Height - lowP) / 256;
            SetRelativeVerticalPrintPos(lowP, highP);
        end;

        AddStringToBuffer(TextIn);
        LineFeed();

        if Bold then
            TurnExphasizedModeOnOff(0);

        if Rotation > 0 then
            SelectPrintDirectInPageMode(0);
    end;

    local procedure TurnExphasizedModeOnOff(n: Integer)
    begin
        // Ref sheet 117 (n in [0,1])        
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('E' + format(n));
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

    procedure ConstructFontSelectionList(var RetailList: Record "NPR Retail List" temporary)
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

        AddOption(RetailList, 'BARCODE EAN13');
        AddOption(RetailList, 'BACRODE CODE39');
    end;

    procedure AddOption(var RetailList: Record "NPR Retail List" temporary; Value: Text[50])
    begin
        RetailList.Number += 1;
        RetailList.Choice := Value;
        RetailList.Insert();
    end;
#pragma warning restore AA0139
}
