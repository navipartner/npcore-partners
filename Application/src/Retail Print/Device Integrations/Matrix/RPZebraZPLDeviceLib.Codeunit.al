codeunit 6014542 "NPR RP Zebra ZPL Device Lib." implements "NPR IMatrix Printer"
{
#pragma warning disable AA0139
    Access = Internal;

    var
        _Encoding: Option "Windows-1252","UTF-8";
        _PrintBuffer: Codeunit "Temp Blob";
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;
        BarcodeMissingErr: Label 'Unknown barcode type %1';
        InvalidDeviceSettingErr: Label 'Invalid device setting: %1';
        SettingLabelHomeLbl: Label 'Set label home position - syntax: x[0-32000],y[0-32000]';
        SettingLabelLengthLbl: Label 'Set label length - value between 0 and 32000';
        SettingMediaDarknessLbl: Label 'Set print darkness - value between -30 and 30';
        SettingMediaTypeLbl: Label 'Set media type. T = Thermal transfer, D = Direct Thermal';
        SettingPrintOrientationLbl: Label 'Set print orientation. N = Normal, I = Invert';
        SettingPrintRateLbl: Label 'Set print rate - syntax: Print[1-14],Slew[2-14],Backfeed[2-14]';
        SettingPrintWidthLbl: Label 'Set print width - value between 2 and label width';
        SettingSetDarknessLbl: Label 'Set darkness - value between 00 and 30';
        SettingRfidEpcMemLbl: Label 'Set EPC memory structure - Comma separated integers';
        SettingEncodingLbl: Label 'Set encoding for data.';
        SettingLabelReverseLbl: Label 'Reverse print colors. Y = Yes, N = No';
        SettingSensorSelectLbl: Label 'Sensor Select. A = Auto, R = Reflective, T = Transmissive';
        FontErr: Label 'Unsupported print font: %1';
        InvalidCommandErr: Label 'Invalid command: %1';
        EncodingErr: Label 'Unknown encoding: %1';


    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        SetEncodingAndInitBuffer(DeviceSettings);

        if DeviceSettings.FindSet() then
            repeat
                case DeviceSettings.Name of
                    'PRINT_RATE':
                        Setup('PR', DeviceSettings.Value);
                    'PRINT_WIDTH':
                        Setup('PW', DeviceSettings.Value);
                    'SET_DARKNESS':
                        Setup('SD', DeviceSettings.Value);
                    'MEDIA_DARKNESS':
                        Setup('MD', DeviceSettings.Value);
                    'LABEL_LENGTH':
                        Setup('LL', DeviceSettings.Value);
                    'MEDIA_TYPE':
                        Setup('MT', DeviceSettings.Value);
                    'PRINT_ORIENTATION':
                        Setup('PO', DeviceSettings.Value);
                    'LABEL_HOME':
                        Setup('LH', DeviceSettings.Value);
                    'RFID_EPC_MEMORY':
                        Setup('RB', DeviceSettings.Value);
                    'LABEL_REVERSE':
                        Setup('LR', DeviceSettings.Value);
                    'SENSOR_SELECT':
                        Setup('JS', DeviceSettings.Value);
                    'ENCODING':
                        ; // do nothing, as we handle this separately.
                    else
                        Error(InvalidDeviceSettingErr, DeviceSettings.Name);
                end;
            until DeviceSettings.Next() = 0;
    end;

    procedure EndJob()
    begin
        AddStringToBuffer('^XZ');
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    var
        StringLib: Codeunit "NPR String Library";
        FontParam: Code[10];
    begin
        case true of
            (UpperCase(CopyStr(POSPrintBuffer.Font, 1, 6)) = 'CODE39'):
                PrintBarcodeLegacy(POSPrintBuffer.Rotation, '3', POSPrintBuffer.Height, 'Y', 'N', 'N', POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
            (CopyStr(POSPrintBuffer.Font, 1, 5) = 'EAN13'):
                PrintBarcodeLegacy(POSPrintBuffer.Rotation, 'E', POSPrintBuffer.Height, 'Y', 'N', 'N', POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
            (CopyStr(POSPrintBuffer.Font, 1, 4) = 'UPCA'):
                PrintBarcodeLegacy(POSPrintBuffer.Rotation, 'U', POSPrintBuffer.Height, 'Y', 'N', 'N', POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
            (CopyStr(POSPrintBuffer.Font, 1, 7) = 'BARCODE'):
                ParseBarcodeParameters(POSPrintBuffer.Text, POSPrintBuffer.Font, POSPrintBuffer.Rotation, POSPrintBuffer.Height, POSPrintBuffer.Width, POSPrintBuffer.X, POSPrintBuffer.Y);
            (UpperCase(CopyStr(POSPrintBuffer.Font, 1, 4)) = 'LINE'):
                GraphicBox(POSPrintBuffer.Width, POSPrintBuffer.Height, 1, 'B', 0, POSPrintBuffer.X, POSPrintBuffer.Y);
            (UpperCase(CopyStr(POSPrintBuffer.Font, 1, 3)) = 'BOX'):
                ParseGraphicBox(POSPrintBuffer.Font, POSPrintBuffer.Width, POSPrintBuffer.Height, POSPrintBuffer.X, POSPrintBuffer.Y);
            (UpperCase(CopyStr(POSPrintBuffer.Font, 1, 7)) = 'GRAPHIC'):
                ParseGraphicField(POSPrintBuffer.Font, POSPrintBuffer.Height, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
            (CopyStr(POSPrintBuffer.Font, 1, 4) = 'Font'):
                begin
                    StringLib.Construct(POSPrintBuffer.Font);
                    FontParam := StringLib.SelectStringSep(2, ' ');
                    Text(FontParam, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
                end;
            (CopyStr(POSPrintBuffer.Font, 1, 10) = 'Scale Font'):
                begin
                    StringLib.Construct(POSPrintBuffer.Font);
                    FontParam := StringLib.SelectStringSep(3, ' ');
                    ScaleText(FontParam, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
                end;
            (CopyStr(POSPrintBuffer.Font, 1, 4) = 'RFID'):
                begin
                    ParseRFIDParameters(POSPrintBuffer.Text, POSPrintBuffer.Font);
                end;
            else
                Error(FontErr, POSPrintBuffer.Font);
        end;
    end;

    procedure LookupFont(var Value: Text): Boolean
    begin
        exit(SelectFont(Value));
    end;

    procedure LookupDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean
    begin
        exit(SelectDeviceSetting(tmpDeviceSetting));
    end;

    procedure PrepareJobForHTTP(var HTTPEndpoint: Text): Boolean
    begin
        HTTPEndpoint := '/pstprnt';
        exit(true);
    end;

    procedure PrepareJobForBluetooth(): Boolean
    begin
        exit(true);
    end;

    procedure LookupCommand(var Value: Text): Boolean;
    begin
        Value := '';
        exit(false);
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
            case _Encoding of
                _Encoding::"Windows-1252":
                    _DotNetEncoding.Encoding(1252);
                _Encoding::"UTF-8":
                    _DotNetEncoding.UTF8();
            end;
            _DotNetStream.FromOutStream(OStream);
        end
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

    procedure ParseBarcodeParameters(TextIn: Text[100]; FontType: Text[30]; Rotation: Integer; Height: Integer; Width: Integer; X: Integer; Y: Integer)
    var
        StringLib: Codeunit "NPR String Library";
        FontCode: Text;
        FirstParam: Text;
        SecondParam: Text;
        SpaceCount: Integer;
        AfterSpace: Text;
    begin
        //Used for settings different barcode parameters like width, wide to narrow bar ratio and interpretation line.
        StringLib.Construct(FontType);

        //Default barcode type unless specified: - not recommended to depend on this
        case true of
            StrLen(TextIn) = 13:
                FontCode := 'E';        // EAN13
            StrLen(TextIn) = 12:
                FontCode := 'U';        // UPC-A
            StrLen(TextIn) in [9 .. 11]:
                FontCode := '1';        // Text
            StrLen(TextIn) < 9:
                FontCode := '3';        // Code39
        end;

        SpaceCount := StringLib.CountOccurences(' ');
        if SpaceCount > 0 then begin
            AfterSpace := StringLib.SelectStringSep(2, ' ');
            if IsBarcodeFont(AfterSpace) then begin
                FontCode := GetBarcodeFont(AfterSpace);
                if SpaceCount = 2 then begin
                    StringLib.Construct(StringLib.SelectStringSep(3, ' '));
                    FirstParam := StringLib.SelectStringSep(1, ',');
                    SecondParam := StringLib.SelectStringSep(2, ',');
                end;
            end else begin
                StringLib.Construct(AfterSpace);
                FirstParam := StringLib.SelectStringSep(1, ',');
                SecondParam := StringLib.SelectStringSep(2, ',');
            end;
        end;

        PrintBarcode(Rotation, FontCode, Height, Width, FirstParam, SecondParam, 'N', 'N', X, Y, TextIn);
    end;

    local procedure ParseRFIDParameters(TextIn: Text; FontType: Text)
    var
        StringLib: Codeunit "NPR String Library";
        AfterSpace: Text;
    begin
        //EPC Class1Gen2 is implied for all commands.
        //EPC_STD command requires that device setting ^RB is also used to define the EPC memory structure.

        StringLib.Construct(FontType);
        AfterSpace := StringLib.SelectStringSep(2, ' ');
        case AfterSpace of
            'EPC_HEX':
                begin
                    AddStringToBuffer('^RFW,H,,,A^FD' + TextIn + '^FS');
                end;
            'EPC_ASCII':
                begin
                    AddStringToBuffer('^RFW,A,,,A^FD' + TextIn + '^FS');
                end;
            'EPC_STD':
                begin
                    AddStringToBuffer('^RFW,E,,,A^FD' + TextIn + '^FS');
                end;
            else
                Error(InvalidCommandErr, FontType);
        end;
    end;

    procedure IsBarcodeFont(FontCode: Text): Boolean
    begin
        exit(FontCode in ['Aztec', 'CODE11', 'INTER2OF5', 'CODE39', 'CODE49', 'PLANETCODE', 'PDF417', 'EAN8', 'UPCE', 'CODE93', 'CODABLOCK', 'CODE128', 'MAXICODE', 'EAN13', 'MICROPDF417',
                           'INDUS2OF5', 'STD2OF5', 'CODABAR', 'LOGMARS', 'MSI', 'PLESSEY', 'QR', 'GS1DATA', 'UPCEXTEND', 'TLC39', 'UPCA', 'MATRIX', 'POSTAL']);
    end;

    procedure GetFontWidth(Font: Text[2]) Width: Integer
    begin
        // Ref sheet 1098 - 1099
        // Font width in dots.
        //
        // A,B,C,D,F and G are precise values from the ref sheet.
        // GS,P,Q,R,S,T,U,V and 0 are rounded up estimates based on testing.
        //
        // Font E and H are excluded because their size in dots vary with the different zebra models.

        case true of
            Font = 'A':
                exit(6);
            Font = 'B':
                exit(9);
            Font = 'C':
                exit(12);
            Font = 'D':
                exit(12);
            Font = 'F':
                exit(16);
            Font = 'G':
                exit(48);
            Font = 'GS':
                exit(48);
            Font = 'P':
                exit(9);
            Font = 'Q':
                exit(13);
            Font = 'R':
                exit(17);
            Font = 'S':
                exit(19);
            Font = 'T':
                exit(22);
            Font = 'U':
                exit(28);
            Font = 'V':
                exit(35);
            Font = '0':
                exit(7);
        end;
    end;

    procedure PrintBarcodeLegacy(Rotate: Integer; Type: Text[1]; Height: Integer; Line: Text[1]; LineAbove: Text[1]; Check: Text[1]; X: Integer; Y: Integer; Data: Text[100])
    var
        Rotation: Text[1];
        TempPattern: Text;
    begin
        // Ref sheet 65, 105, 138, 144
        // Type      :   Barcode type,               All barcodes use a ^BX command where X is the barcode type.
        // Height    :   Sets height of the barcode, 00001-32000
        // Line      :   Print interpretation line
        // LineAbove :   Print interpretation line above barcode
        // Check     :   Use check digit if applicable to the barcode type
        // X         :                               00000-32000
        // Y         :                               00000-32000
        // Data      :   Barcode data

        FieldOrigin(X, Y);

        case Type of
            '3':
                TempPattern := '^B%1%2,%6,%3,%4,%5'; //CODE39
            'E':
                TempPattern := '^B%1%2,%3,%4,%5';    //EAN13
            'U':
                TempPattern := '^B%1%2,%3,%4,%5,%6'; //UPC-A
            'C':
                TempPattern := '^B%1%2,%3,%4,%5,%6,A'; //CODE128 in automatic subset mode
        end;

        case Rotate of
            0:
                Rotation := 'N';
            1:
                Rotation := 'R';
            2:
                Rotation := 'I';
            3:
                Rotation := 'B';
        end;

        AddStringToBuffer(StrSubstNo(TempPattern, Type, Rotation, Height, Line, LineAbove, Check));

        FieldData(Data);

        FieldSeparator();
    end;

    procedure PrintBarcode(Rotation: Option N,R,I,B; Type: Text[1]; Height: Integer; Width: Integer; FirstParam: Text; SecondParam: Text; LineAbove: Text[1]; Check: Text[1]; X: Integer; Y: Integer; Data: Text[100])
    var
        PrintBarcodeLbl: Label '^B%1%2,%6,%3,%4,%5', Locked = true;
        PrintBarcode2Lbl: Label '^B%1%2,%3,%4,%5', Locked = true;
        PrintBarcode3Lbl: Label '^B%1%2,%3,%4,%5,%6', Locked = true;
        PrintBarcode4Lbl: Label '^B%1%2,%3,%4,%5,%6,A', Locked = true;
        PrintBarcode5Lbl: Label '^BQ%1,%2,%3', Locked = true;
    begin
        FieldOrigin(X, Y);

        case Type of
            '3': //CODE39
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddStringToBuffer(StrSubstNo(PrintBarcodeLbl, Type, Format(Rotation), Height, SecondParam, LineAbove, Check));
                end;
            'E': //EAN13
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddStringToBuffer(StrSubstNo(PrintBarcode2Lbl, Type, Format(Rotation), Height, SecondParam, LineAbove));
                end;
            'U': //UPC-A
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddStringToBuffer(StrSubstNo(PrintBarcode3Lbl, Type, Format(Rotation), Height, SecondParam, LineAbove, Check));
                end;
            'C': //CODE128 in automatic subset mode
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddStringToBuffer(StrSubstNo(PrintBarcode4Lbl, Type, Format(Rotation), Height, SecondParam, LineAbove, Check));
                end;
            'Q': //QR, model 2, alphanumeric input - FirstParam: Magnification, SecondParam: Error correction
                begin
                    AddStringToBuffer(StrSubstNo(PrintBarcode5Lbl, Format(Rotation), '2', FirstParam));
                    Data := SecondParam + 'M,A' + DelChr(UpperCase(Data), '=', DelChr(UpperCase(Data), '=', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$%*+-./:'));
                end;
        end;

        FieldData(Data);
        FieldSeparator();
    end;

    procedure BarcodeFieldDefault(Width: Integer; WideNarrowRatio: Code[3]; Height: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^BY%1,%2,%3', Width, WideNarrowRatio, Height));
    end;

    procedure ChangeDefaultFont(Font: Code[2]; Height: Integer; Width: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^CF%1,%2,%3', Font, Height, Width));
    end;

    procedure FieldBlock(Width: Integer; Lines: Integer; Spacing: Integer; Justification: Text[1]; Indent: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^FB%1,%2,%3,%4,%5', Width, Lines, Spacing, Justification, Indent));
    end;

    procedure FieldData(Data: Text[100])
    begin
        AddStringToBuffer('^FD' + DelChr(Data, '=', '^~'));
    end;

    procedure FieldOrigin(x: Integer; y: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^FO%1,%2', x, y));
    end;

    procedure FieldSeparator()
    begin
        AddStringToBuffer('^FS');
    end;

    procedure GraphicBox(Width: Integer; Height: Integer; Thickness: Integer; Color: Text[1]; Rounding: Integer; X: Integer; Y: Integer)
    begin
        FieldOrigin(X, Y);

        AddStringToBuffer(StrSubstNo('^GB%1,%2,%3,%4,%5', Width, Height, Thickness, Color, Rounding));

        FieldSeparator();
    end;

    procedure GraphicField(X: Integer; Y: Integer; CompressionType: Text[1]; BinaryByteCount: Integer; GraphicFieldCount: Integer; BytesPerRow: Integer; Data: Text)
    begin
        FieldOrigin(X, Y);

        AddStringToBuffer(StrSubstNo('^GF%1,%2,%3,%4,%5', CompressionType, BinaryByteCount, GraphicFieldCount, BytesPerRow, Data));

        FieldSeparator();
    end;

    procedure LabelLength(Length: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^LL%1', Length));
    end;

    procedure LabelHome(X: Integer; Y: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^LH%1,%2', X, Y));
    end;

    local procedure LabelReverse(Active: Text)
    begin
        case Active of
            'Y':
                AddStringToBuffer('^LRY');
            'N':
                AddStringToBuffer('^LRN');
        end;
    end;

    local procedure SensorSelect(Value: Text)
    begin
        case Value of
            'A':
                AddStringToBuffer('^JSA');
            'R':
                AddStringToBuffer('^JSR');
            'T':
                AddStringToBuffer('^JST');
        end;
    end;

    local procedure ParseGraphicBox(FontType: Text; Width: Integer; Height: Integer; X: Integer; Y: Integer)
    var
        StringLib: Codeunit "NPR String Library";
        AfterSpace: Text;
        Thickness: Integer;
        Color: Text;
        Rounding: Integer;
    begin
        StringLib.Construct(FontType);
        AfterSpace := StringLib.SelectStringSep(2, ' ');
        StringLib.Construct(AfterSpace);

        Evaluate(Thickness, StringLib.SelectStringSep(1, ','));
        Color := StringLib.SelectStringSep(2, ',');
        Evaluate(Rounding, StringLib.SelectStringSep(3, ','));

        GraphicBox(Width, Height, Thickness, Color, Rounding, X, Y);
    end;

    local procedure ParseGraphicField(FontType: Text; Height: Integer; X: Integer; Y: Integer; Data: Text)
    var
        CompressionType: Text[1];
        FontAndParams: List of [Text];
        HexSize: Integer;
        ErrImplementationLbl: Label 'Compression Type %1 has not been implemented.', Comment = '%1 = Compression Type.';
        ErrNoDataLbl: Label 'No graphical data provided.';
        ErrNoHeightLbl: Label 'Height must be a positive number.';
        ErrParamsLbl: Label 'Unable to resolve parameters for font GRAPHIC.';
    begin
        if (Data = '') then
            Error(ErrNoDataLbl);

        if (Height <= 0) then
            Error(ErrNoHeightLbl);

        FontAndParams := FontType.Split(' ');
        if FontAndParams.Count() <> 2 then
            Error(ErrParamsLbl);

        CompressionType := FontAndParams.Get(2); // Error if length of param > 1

        case CompressionType of
            'A':
                begin
                    HexSize := (StrLen(Data) div 2); // two characters per dot
                    GraphicField(X, Y, CompressionType, HexSize, HexSize, (HexSize div Height), Data);
                end;
            else
                Error(ErrImplementationLbl, CompressionType);
        end;

    end;

    procedure MediaDarkness(Darkness: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^MD%1', Darkness));
    end;

    procedure MediaType(Type: Text[1])
    begin
        AddStringToBuffer(StrSubstNo('^MT%1', Type));
    end;

    procedure PrintRate(PrintSpeed: Code[2]; SlewSpeed: Code[2]; BackSpeed: Code[2])
    begin
        AddStringToBuffer(StrSubstNo('^PR%1,%2,%3', PrintSpeed, SlewSpeed, BackSpeed));
    end;

    procedure PrintWidth(Width: Integer)
    begin
        AddStringToBuffer(StrSubstNo('^PW%1', Width));
    end;

    procedure PrintOrientation(Orientation: Text[1])
    begin
        AddStringToBuffer(StrSubstNo('^PO%1', Orientation));
    end;

    procedure ScaleText(ScaleSize: Code[10]; Align: Integer; Rotate: Integer; X: Integer; Y: Integer; TextIn: Text[100])
    var
        HeightText: Code[10];
        WidthText: Code[10];
        Height: Integer;
        Width: Integer;
        StringLib: Codeunit "NPR String Library";
        StrLength: Integer;
        Justify: Text[1];
        Rotation: Text[1];
        HorzStart: Integer;
    begin
        //For use with the scaleable font 0
        // Align     :   Alignment of text
        // Rotate    :   Orientation,                [1,2,3,4] -> [0º,90º,180º,270º]
        // Type      :   Font Type
        // Height    :   Character height
        // Width     :   Character width
        // X         :                               00000-32000
        // Y         :                               00000-32000
        // TextIn    :   String content

        StringLib.Construct(ScaleSize);

        HeightText := StringLib.SelectStringSep(1, ',');
        WidthText := StringLib.SelectStringSep(2, ',');
        if not Evaluate(Height, HeightText) or not Evaluate(Width, WidthText) then
            Error(FontErr, HeightText + WidthText);

        if Align > 0 then begin
            StrLength := Round(((GetFontWidth('0') / 10) * Width * StrLen(TextIn)), 1, '=') div 1;

            case Align of
                1:
                    case Rotate of
                        0, 2:
                            HorzStart := X - (Round((StrLength / 2), 1, '=') div 1);
                        1, 3:
                            HorzStart := Y - (Round((StrLength / 2), 1, '=') div 1);
                    end;
                2:
                    case Rotate of
                        0, 2:
                            HorzStart := X - StrLength;
                        1, 3:
                            HorzStart := Y - StrLength;
                    end;
            end;
            if HorzStart < 0 then begin
                StrLength := StrLength + HorzStart;
                HorzStart := 0;
            end;

            case Rotate of
                0, 2:
                    X := HorzStart;
                1, 3:
                    Y := HorzStart;
            end;
        end;

        case Rotate of
            0:
                Rotation := 'N';
            1:
                Rotation := 'R';
            2:
                Rotation := 'I';
            3:
                Rotation := 'B';
        end;

        //^FO
        FieldOrigin(X, Y);

        //^A
        AddStringToBuffer(StrSubstNo('^A%1%2,%3,%4', '0', Rotation, Height, Width));

        //^FB
        case Align of
            1:
                Justify := 'C';
            2:
                Justify := 'R';
        end;

        if Align > 0 then
            FieldBlock(StrLength, 1, 0, Justify, 0);

        //^FD
        FieldData(TextIn);

        //^FS
        FieldSeparator();
    end;

    procedure Setup(Setting: Text[10]; Value: Text[20])
    var
        IntegerValue: Integer;
        IntegerValue2: Integer;
        StringLib: Codeunit "NPR String Library";
    begin
        //Used for setting the following printer settings:
        //^PR, ^PW, ~SD, ^MD, ^LL, ^MT, ^PO, ^LH

        StringLib.Construct(Value);

        case Setting of
            'PR':
                PrintRate(StringLib.SelectStringSep(1, ','), StringLib.SelectStringSep(2, ','), StringLib.SelectStringSep(3, ','));
            'PW':
                if Evaluate(IntegerValue, Value) then
                    PrintWidth(IntegerValue);
            'SD':
                if Evaluate(IntegerValue, Value) then
                    SetDarkness(IntegerValue);
            'MD':
                if Evaluate(IntegerValue, Value) then
                    MediaDarkness(IntegerValue);
            'LL':
                if Evaluate(IntegerValue, Value) then
                    LabelLength(IntegerValue);
            'MT':
                MediaType(CopyStr(Value, 1, 1));
            'PO':
                PrintOrientation(CopyStr(Value, 1, 1));
            'LH':
                if Evaluate(IntegerValue, StringLib.SelectStringSep(1, ',')) and
                   Evaluate(IntegerValue2, StringLib.SelectStringSep(2, ',')) then
                    LabelHome(IntegerValue, IntegerValue2);
            'CF':
                if Evaluate(IntegerValue, StringLib.SelectStringSep(2, ',')) and
                   Evaluate(IntegerValue2, StringLib.SelectStringSep(3, ',')) then
                    ChangeDefaultFont(StringLib.SelectStringSep(1, ','), IntegerValue, IntegerValue2);
            //-NPR5.52 [371935]
            'LR':
                LabelReverse(CopyStr(Value, 1, 1));
            //+NPR5.52 [371935]
            //-NPR5.53 [381166]
            'JS':
                SensorSelect(CopyStr(Value, 1, 1));
        //+NPR5.53 [381166]
        end;
    end;

    procedure SetDarkness(Darkness: Integer)
    begin
        AddStringToBuffer(StrSubstNo('~SD%1', Darkness));
    end;

    procedure Text(Type: Text[2]; Align: Integer; Rotate: Integer; X: Integer; Y: Integer; TextIn: Text[100])
    var
        StrLength: Integer;
        Justify: Text[1];
        Rotation: Text[1];
        MaxLength: Integer;
        CharLength: Integer;
        HorzStart: Integer;
    begin
        // Ref sheet 55
        // Align     :   Alignment of text
        // Rotate    :   Orientation,                [1,2,3,4] -> [0º,90º,180º,270º]
        // Type      :   Font Type
        // Height    :   Character height
        // Width     :   Character width
        // X         :                               00000-32000
        // Y         :                               00000-32000
        // Data      :   String content

        //-NPR5.34 [269396]
        // IF Align > 0 THEN
        //  StrLength := GetFontWidth(Type) * STRLEN(TextIn);

        // CASE Align OF
        //  1 : X := ROUND(X - (StrLength / 2),1,'=') DIV 1;
        //  2 : X := X - StrLength;
        // END;
        // IF X < 0 THEN BEGIN //If the alignment results in a start position outside the left side of label
        //    MaxLength  := StrLength + X;
        //    CharLength := GetFontWidth(Type);
        //    REPEAT
        //      StrLength := StrLength - CharLength;
        //      TextIn    := COPYSTR(TextIn,2);
        //    UNTIL StrLength <= MaxLength;
        //    StrLength := MaxLength; //StrLength is set to the MaxLength to fix any small variance.
        //    X := 0;
        // END;

        if Align > 0 then begin
            StrLength := GetFontWidth(Type) * StrLen(TextIn);

            case Align of
                1:
                    case Rotate of
                        0, 2:
                            HorzStart := Round(X - (StrLength / 2), 1, '=') div 1;
                        1, 3:
                            HorzStart := Round(Y - (StrLength / 2), 1, '=') div 1;
                    end;
                2:
                    case Rotate of
                        0, 2:
                            HorzStart := X - StrLength;
                        1, 3:
                            HorzStart := Y - StrLength;
                    end;
            end;
            if HorzStart < 0 then begin
                MaxLength := StrLength + HorzStart;
                CharLength := GetFontWidth(Type);
                repeat
                    StrLength := StrLength - CharLength;
                    TextIn := CopyStr(TextIn, 2);
                until StrLength <= MaxLength;
                StrLength := MaxLength;
                HorzStart := 0;
            end;

            case Rotate of
                0, 2:
                    X := HorzStart;
                1, 3:
                    Y := HorzStart;
            end;
        end;
        //+NPR5.34 [269396]

        case Rotate of
            0:
                Rotation := 'N';
            1:
                Rotation := 'R';
            2:
                Rotation := 'I';
            3:
                Rotation := 'B';
        end;

        //^FO
        FieldOrigin(X, Y);

        //^A
        AddStringToBuffer(StrSubstNo('^A%1%2', Type, Rotation));

        //^FB
        case Align of
            1:
                Justify := 'C';
            2:
                Justify := 'R';
        end;

        if Align > 0 then
            FieldBlock(StrLength, 1, 0, Justify, 0);

        //^FD
        FieldData(TextIn);

        //^FS
        FieldSeparator();
    end;

    local procedure SetEncodingAndInitBuffer(var DeviceSettings: Record "NPR RP Device Settings")
    var
        Encoding: Text;
    begin
        DeviceSettings.SetRange(Name, 'ENCODING');
        if DeviceSettings.FindFirst() then begin
            Encoding := DeviceSettings.Value;
        end else begin
            Encoding := 'Windows-1252' //default
        end;
        DeviceSettings.SetRange(Name);

        case Encoding of
            'utf-8':
                begin
                    _Encoding := _Encoding::"UTF-8";
                    InitBuffer();
                    AddStringToBuffer('^XA');
                    AddStringToBuffer('^CI28');
                end;
            'Windows-1252':
                begin
                    _Encoding := _Encoding::"Windows-1252";
                    InitBuffer();
                    AddStringToBuffer('^XA');
                    AddStringToBuffer('^CI27');
                end;
            else
                Error(EncodingErr, Encoding);
        end;
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
                'LABEL_HOME':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Text;
                'LABEL_LENGTH':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Integer;
                'MEDIA_DARKNESS':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Integer;
                'MEDIA_TYPE':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'T,D';
                    end;
                'PRINT_ORIENTATION':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'N,I';
                    end;
                'PRINT_RATE':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Text;
                'PRINT_WIDTH':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Integer;
                'SET_DARKNESS':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Integer;
                'RFID_EPC_MEMORY':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Text;
                'ENCODING':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'Windows-1252,utf-8';
                    end;
                'LABEL_REVERSE':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'N,Y';
                    end;
                'SENSOR_SELECT':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'A,R,T';
                    end;
            end;
            exit(tmpDeviceSetting.Insert());
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(RetailList, 'Font A', '');
        AddOption(RetailList, 'Font B', '');
        AddOption(RetailList, 'Font D', '');
        AddOption(RetailList, 'Font F', '');
        AddOption(RetailList, 'Font G', '');
        AddOption(RetailList, 'Font GS', '');
        AddOption(RetailList, 'Font P', '');
        AddOption(RetailList, 'Font Q', '');
        AddOption(RetailList, 'Font R', '');
        AddOption(RetailList, 'Font S', '');
        AddOption(RetailList, 'Font T', '');
        AddOption(RetailList, 'Font U', '');
        AddOption(RetailList, 'Font V', '');
        AddOption(RetailList, 'Scale Font 19,15', '');
        AddOption(RetailList, 'Scale Font 21,18', '');
        AddOption(RetailList, 'Scale Font 25,18', '');
        AddOption(RetailList, 'Scale Font 19,16', '');
        AddOption(RetailList, 'Scale Font 19,16', '');
        AddOption(RetailList, 'BARCODE EAN13', '');
        AddOption(RetailList, 'BARCODE EAN13 2.0,N', '');
        AddOption(RetailList, 'BARCODE EAN13 2.0,Y', '');
        AddOption(RetailList, 'BARCODE EAN13 3.0,N', '');
        AddOption(RetailList, 'BARCODE EAN13 3.0,Y', '');
        AddOption(RetailList, 'BARCODE CODE39', '');
        AddOption(RetailList, 'BARCODE CODE39 2.0,N', '');
        AddOption(RetailList, 'BARCODE CODE39 2.0,Y', '');
        AddOption(RetailList, 'BARCODE CODE39 3.0,N', '');
        AddOption(RetailList, 'BARCODE CODE39 3.0,Y', '');
        AddOption(RetailList, 'BARCODE CODE128', '');
        AddOption(RetailList, 'BARCODE CODE128 2.0,N', '');
        AddOption(RetailList, 'BARCODE CODE128 2.0,Y', '');
        AddOption(RetailList, 'BARCODE CODE128 3.0,N', '');
        AddOption(RetailList, 'BARCODE CODE128 3.0,Y', '');
        AddOption(RetailList, 'BARCODE QR 1,H', '');
        AddOption(RetailList, 'BARCODE QR 9,H', '');
        AddOption(RetailList, 'BARCODE QR 1,Q', '');
        AddOption(RetailList, 'BARCODE QR 9,Q', '');
        AddOption(RetailList, 'BARCODE QR 1,M', '');
        AddOption(RetailList, 'BARCODE QR 9,M', '');
        AddOption(RetailList, 'BARCODE QR 1,L', '');
        AddOption(RetailList, 'BARCODE QR 9,L', '');
        AddOption(RetailList, 'RFID EPC_HEX', '');
        AddOption(RetailList, 'RFID EPC_ASCII', '');
        AddOption(RetailList, 'RFID EPC_STD', '');
        AddOption(RetailList, 'LINE', '');
        AddOption(RetailList, 'BOX 1,B,0', '');
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(tmpRetailList, SettingLabelHomeLbl, 'LABEL_HOME');
        AddOption(tmpRetailList, SettingLabelLengthLbl, 'LABEL_LENGTH');
        AddOption(tmpRetailList, SettingMediaDarknessLbl, 'MEDIA_DARKNESS');
        AddOption(tmpRetailList, SettingMediaTypeLbl, 'MEDIA_TYPE');
        AddOption(tmpRetailList, SettingPrintOrientationLbl, 'PRINT_ORIENTATION');
        AddOption(tmpRetailList, SettingPrintRateLbl, 'PRINT_RATE');
        AddOption(tmpRetailList, SettingPrintWidthLbl, 'PRINT_WIDTH');
        AddOption(tmpRetailList, SettingSetDarknessLbl, 'SET_DARKNESS');
        AddOption(tmpRetailList, SettingRfidEpcMemLbl, 'RFID_EPC_MEMORY');
        AddOption(tmpRetailList, SettingEncodingLbl, 'ENCODING');
        AddOption(tmpRetailList, SettingLabelReverseLbl, 'LABEL_REVERSE');
        AddOption(tmpRetailList, SettingSensorSelectLbl, 'SENSOR_SELECT');
    end;

    procedure AddOption(var RetailList: Record "NPR Retail List" temporary; Choice: Text; Value: Text)
    begin
        RetailList.Number += 1;
        RetailList.Choice := Choice;
        RetailList.Value := Value;
        RetailList.Insert();
    end;

    local procedure GetBarcodeFont(Barcode: Text): Text
    begin
        case Barcode of
            'AZTEC':
                exit('0');
            'CODE11':
                exit('1');
            'INTER2OF5':
                exit('2');
            'CODE39':
                exit('3');
            'CODE49':
                exit('4');
            'PLANETCODE':
                exit('5');
            'PDF417':
                exit('7');
            'EAN8':
                exit('8');
            'UPCE':
                exit('9');
            'CODE93':
                exit('A');
            'CODABLOCK':
                exit('B');
            'CODE128':
                exit('C');
            'MAXICODE':
                exit('D');
            'EAN13':
                exit('E');
            'MICOPDF417':
                exit('F');
            'INDUS2OF5':
                exit('I');
            'STD2OF5':
                exit('J');
            'CODABAR':
                exit('K');
            'LOGMARS':
                exit('L');
            'MSI':
                exit('M');
            'PLESSEY':
                exit('P');
            'QR':
                exit('Q');
            'GS1DATA':
                exit('R');
            'UPCEXTEND':
                exit('S');
            'TLC39':
                exit('T');
            'UPCA':
                exit('U');
            'MATRIX':
                exit('X');
            'POSTAL':
                exit('Z');
            else
                Error(BarcodeMissingErr, Barcode);
        end
    end;

    procedure FieldHex()
    begin
        AddStringToBuffer('^FH');
    end;
#pragma warning restore AA0139
}

