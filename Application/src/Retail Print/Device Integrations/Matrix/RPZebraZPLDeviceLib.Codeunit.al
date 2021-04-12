codeunit 6014542 "NPR RP Zebra ZPL Device Lib."
{
    // NPR5.32/MMV /20170410 CASE 241995 Retail Print 2.0
    // NPR5.34/MMV /20170707 CASE 269396 Support for aligning while rotating.
    // NPR5.48/MMV /20181126 CASE 327107 Added QR support
    //                                   Added RFID support
    //                                   Added utf-8 support (not default to guarantee backwards comp. with older zebra printers).
    // NPR5.50/MMV /20190417 CASE 351975 Barcode parameter parse fix.
    // NPR5.51/MMV /20190801 CASE 360975 Buffer all template print data into one job.
    // NPR5.52/MMV /20191017 CASE 371935 Added inverse color and graphic box support.
    // NPR5.53/MMV /20200113 CASE 381166 Added support for sensor select command

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempPattern: Text[50];
        ESC: Codeunit "NPR RP Escape Code Library";
        HashTable: Record "NPR TEMP Buffer" temporary;
        PrintBuffer: Text;
        err0002: Label 'Barcode does not exist.';
        Error_InvalidDeviceSetting: Label 'Invalid device setting: %1';
        SETTING_LABELHOME: Label 'Set label home position - syntax: x[0-32000],y[0-32000]';
        SETTING_LABELLENGTH: Label 'Set label length - value between 0 and 32000';
        SETTING_MEDIADARKNESS: Label 'Set print darkness - value between -30 and 30';
        SETTING_MEDIATYPE: Label 'Set media type. T = Thermal transfer, D = Direct Thermal';
        SETTING_PRINTORIENTATION: Label 'Set print orientation. N = Normal, I = Invert';
        SETTING_PRINTRATE: Label 'Set print rate - syntax: Print[1-14],Slew[2-14],Backfeed[2-14]';
        SETTING_PRINTWIDTH: Label 'Set print width - value between 2 and label width';
        SETTING_SETDARKNESS: Label 'Set darkness - value between 00 and 30';
        SETTING_RFID_EPC_MEM: Label 'Set EPC memory structure - Comma separated integers';
        SETTING_ENCODING: Label 'Set encoding for data.';
        SETTING_LABELREVERSE: Label 'Reverse print colors. Y = Yes, N = No';
        SETTING_SENSOR_SELECT: Label 'Sensor Select. A = Auto, R = Reflective, T = Transmissive';
        ERR_FONT: Label 'Unsupported print font: %1';
        ERR_INVALID_COMMAND: Label 'Invalid command: %1';
        Encoding: Option "Windows-1252","UTF-8";
        ERR_ENCODING: Label 'Unknown encoding: %1';

    local procedure "// Interface implementation"()
    begin
    end;

    local procedure DeviceCode(): Text
    begin
        exit('ZEBRA');
    end;

    procedure IsThisDevice(Text: Text): Boolean
    begin
        exit(StrPos(UpperCase(Text), DeviceCode) > 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        Init(DeviceSettings);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnEndJob', '', false, false)]
    local procedure OnEndJob()
    begin
        EndJob();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnPrintData', '', false, false)]
    local procedure OnPrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    begin
        PrintData(POSPrintBuffer.Text, POSPrintBuffer.Font, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.Height, POSPrintBuffer.Width, POSPrintBuffer.X, POSPrintBuffer.Y);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnLookupFont', '', false, false)]
    local procedure OnLookupFont(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectFont(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnLookupDeviceSetting', '', false, false)]
    local procedure OnLookupDeviceSetting(var LookupOK: Boolean; var tmpDeviceSetting: Record "NPR RP Device Settings" temporary)
    begin
        LookupOK := SelectDeviceSetting(tmpDeviceSetting);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnGetPageWidth', '', false, false)]
    local procedure OnGetPageWidth(FontFace: Text[30]; var Width: Integer)
    begin
        Width := GetPageWidth(FontFace);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnGetTargetEncoding', '', false, false)]
    local procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
        TargetEncoding := GetEncoding();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnPrepareJobForHTTP', '', false, false)]
    local procedure OnPrepareJobForHTTP(var FormattedTargetEncoding: Text; var HTTPEndpoint: Text; var Supported: Boolean)
    begin
        FormattedTargetEncoding := GetEncoding();
        HTTPEndpoint := '/pstprnt';
        Supported := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnPrepareJobForBluetooth', '', false, false)]
    local procedure OnPrepareJobForBluetooth(var FormattedTargetEncoding: Text; var Supported: Boolean)
    begin
        FormattedTargetEncoding := GetEncoding();
        Supported := true;
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
    var
        CustomEncoding: Text;
    begin
        if HashTable.IsEmpty then
            ConstructHashTable;

        AddToBuffer('^XA'); // Ref sheet 372

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
                    //-NPR5.52 [371935]
                    'LABEL_REVERSE':
                        Setup('LR', DeviceSettings.Value);
                    //+NPR5.52 [371935]
                    //-NPR5.53 [381166]
                    'SENSOR_SELECT':
                        Setup('JS', DeviceSettings.Value);
                    //+NPR5.53 [381166]
                    'ENCODING':
                        CustomEncoding := DeviceSettings.Value;
                    else
                        Error(Error_InvalidDeviceSetting, DeviceSettings.Name);
                end;
            until DeviceSettings.Next() = 0;

        SetEncoding(CustomEncoding);
    end;

    procedure EndJob()
    begin
        // Ref sheet 377
        TempPattern := '^XZ';
        AddToBuffer(TempPattern);
    end;

    procedure PrintData(TextIn: Text[100]; FontType: Text[30]; Align: Integer; Rotation: Integer; Height: Integer; Width: Integer; X: Integer; Y: Integer)
    var
        StringLib: Codeunit "NPR String Library";
        FontParam: Code[10];
        FontParam2: Code[10];
    begin
        case true of
            (UpperCase(CopyStr(FontType, 1, 6)) = 'CODE39'):
                PrintBarcodeLegacy(Rotation, '3', Height, 'Y', 'N', 'N', X, Y, TextIn);
            (CopyStr(FontType, 1, 5) = 'EAN13'):
                PrintBarcodeLegacy(Rotation, 'E', Height, 'Y', 'N', 'N', X, Y, TextIn);
            (CopyStr(FontType, 1, 4) = 'UPCA'):
                PrintBarcodeLegacy(Rotation, 'U', Height, 'Y', 'N', 'N', X, Y, TextIn);
            (CopyStr(FontType, 1, 7) = 'BARCODE'):
                ParseBarcodeParameters(TextIn, FontType, Rotation, Height, Width, X, Y);
            //-NPR5.52 [371935]
            (UpperCase(CopyStr(FontType, 1, 4)) = 'LINE'):
                GraphicBox(Width, Height, 1, 'B', 0, X, Y);
            (UpperCase(CopyStr(FontType, 1, 3)) = 'BOX'):
                ParseGraphicBox(FontType, Width, Height, X, Y);
            //+NPR5.52 [371935]
            (CopyStr(FontType, 1, 4) = 'Font'):
                begin
                    StringLib.Construct(FontType);
                    FontParam := StringLib.SelectStringSep(2, ' ');
                    Text(FontParam, Align, Rotation, X, Y, TextIn);
                end;
            (CopyStr(FontType, 1, 10) = 'Scale Font'):
                begin
                    StringLib.Construct(FontType);
                    FontParam := StringLib.SelectStringSep(3, ' ');
                    ScaleText(FontParam, Align, Rotation, X, Y, TextIn);
                end;
            (CopyStr(FontType, 1, 4) = 'RFID'):
                begin
                    ParseRFIDParameters(TextIn, FontType);
                end;
            (CopyStr(FontType, 1, 5) = 'Setup'): //Legacy support for when the template lines contained setup commands.
                begin
                    StringLib.Construct(FontType);
                    FontParam := StringLib.SelectStringSep(2, ' ');
                    FontParam2 := StringLib.SelectStringSep(3, ' ');
                    Setup(FontParam, FontParam2);
                end;
            else
                Error(ERR_FONT, FontType);
        end;
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
                FontCode := GetLineHashTable(AfterSpace);
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
                    AddToBuffer('^RFW,H,,,A^FD' + TextIn + '^FS');
                end;
            'EPC_ASCII':
                begin
                    AddToBuffer('^RFW,A,,,A^FD' + TextIn + '^FS');
                end;
            'EPC_STD':
                begin
                    AddToBuffer('^RFW,E,,,A^FD' + TextIn + '^FS');
                end;
            else
                Error(ERR_INVALID_COMMAND, FontType);
        end;
    end;

    procedure GetPrintBytes(): Text
    begin
        exit(PrintBuffer);
    end;

    procedure SetPrintBytes(PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    procedure "-- Info Functions"()
    begin
    end;

    procedure IsBarcodeFont(FontCode: Text): Boolean
    begin
        // Ref sheet 59 - 147
        exit(FontCode in ['Aztec', 'CODE11', 'INTER2OF5', 'CODE39', 'CODE49', 'PLANETCODE', 'PDF417', 'EAN8', 'UPCE', 'CODE93', 'CODABLOCK', 'CODE128', 'MAXICODE', 'EAN13', 'MICROPDF417',
                           'INDUS2OF5', 'STD2OF5', 'CODABAR', 'LOGMARS', 'MSI', 'PLESSEY', 'QR', 'GS1DATA', 'UPCEXTEND', 'TLC39', 'UPCA', 'MATRIX', 'POSTAL']);
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        exit(0);
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
            //Font = 'E'  : EXIT(20);
            Font = 'F':
                exit(16);
            Font = 'G':
                exit(48);
            //Font = 'H'  : EXIT(19);
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

    procedure "-- Advanced Functions"()
    begin
    end;

    procedure PrintBarcodeLegacy(Rotate: Integer; Type: Text[1]; Height: Integer; Line: Text[1]; LineAbove: Text[1]; Check: Text[1]; X: Integer; Y: Integer; Data: Text[100])
    var
        Rotation: Text[1];
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

        AddToBuffer(StrSubstNo(TempPattern, Type, Rotation, Height, Line, LineAbove, Check));

        FieldData(Data);

        FieldSeparator();
    end;

    procedure PrintBarcode(Rotation: Option N,R,I,B; Type: Text[1]; Height: Integer; Width: Integer; FirstParam: Text; SecondParam: Text; LineAbove: Text[1]; Check: Text[1]; X: Integer; Y: Integer; Data: Text[100])
    begin
        FieldOrigin(X, Y);

        case Type of
            '3': //CODE39
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddToBuffer(StrSubstNo('^B%1%2,%6,%3,%4,%5', Type, Format(Rotation), Height, SecondParam, LineAbove, Check));
                end;
            'E': //EAN13
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddToBuffer(StrSubstNo('^B%1%2,%3,%4,%5', Type, Format(Rotation), Height, SecondParam, LineAbove, Check));
                end;
            'U': //UPC-A
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddToBuffer(StrSubstNo('^B%1%2,%3,%4,%5,%6', Type, Format(Rotation), Height, SecondParam, LineAbove, Check));
                end;
            'C': //CODE128 in automatic subset mode
                begin
                    BarcodeFieldDefault(Width, FirstParam, Height);
                    AddToBuffer(StrSubstNo('^B%1%2,%3,%4,%5,%6,A', Type, Format(Rotation), Height, SecondParam, LineAbove, Check));
                end;
            'Q': //QR, model 2, alphanumeric input - FirstParam: Magnification, SecondParam: Error correction
                begin
                    AddToBuffer(StrSubstNo('^BQ%1,%2,%3', Format(Rotation), '2', FirstParam));
                    Data := SecondParam + 'M,A' + DelChr(UpperCase(Data), '=', DelChr(UpperCase(Data), '=', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$%*+-./:'));
                end;
        end;

        FieldData(Data);
        FieldSeparator();
    end;

    procedure BarcodeFieldDefault(Width: Integer; WideNarrowRatio: Code[3]; Height: Integer)
    begin
        // Ref sheet 144
        TempPattern := '^BY%1,%2,%3';
        AddToBuffer(StrSubstNo(TempPattern, Width, WideNarrowRatio, Height));
    end;

    procedure ChangeDefaultFont(Font: Code[2]; Height: Integer; Width: Integer)
    begin
        // Ref sheet 150
        TempPattern := '^CF%1,%2,%3';
        AddToBuffer(StrSubstNo(TempPattern, Font, Height, Width));
    end;

    procedure FieldBlock(Width: Integer; Lines: Integer; Spacing: Integer; Justification: Text[1]; Indent: Integer)
    begin
        // Ref sheet 183
        TempPattern := '^FB%1,%2,%3,%4,%5';
        AddToBuffer(StrSubstNo(TempPattern, Width, Lines, Spacing, Justification, Indent));
    end;

    procedure FieldData(Data: Text[100])
    begin
        // Ref sheet 187
        AddToBuffer('^FD' + DelChr(Data, '=', '^~'));
    end;

    procedure FieldOrigin(x: Integer; y: Integer)
    begin
        // Ref sheet 197
        TempPattern := '^FO%1,%2';
        AddToBuffer(StrSubstNo(TempPattern, x, y));
    end;

    procedure FieldSeparator()
    begin
        // Ref sheet 200
        AddToBuffer('^FS');
    end;

    procedure GraphicBox(Width: Integer; Height: Integer; Thickness: Integer; Color: Text[1]; Rounding: Integer; X: Integer; Y: Integer)
    begin
        // Ref sheet 207

        FieldOrigin(X, Y);

        TempPattern := '^GB%1,%2,%3,%4,%5';
        AddToBuffer(StrSubstNo(TempPattern, Width, Height, Thickness, Color, Rounding));

        FieldSeparator();
    end;

    procedure LabelLength(Length: Integer)
    begin
        // Ref sheet 290
        TempPattern := '^LL%1';
        AddToBuffer(StrSubstNo(TempPattern, Length));
    end;

    procedure LabelHome(X: Integer; Y: Integer)
    begin
        // Ref sheet 289
        TempPattern := '^LH%1,%2';
        AddToBuffer(StrSubstNo(TempPattern, X, Y));
    end;

    local procedure LabelReverse(Active: Text)
    begin
        //-NPR5.52 [371935]
        case Active of
            'Y':
                AddToBuffer('^LRY');
            'N':
                AddToBuffer('^LRN');
        end;
        //+NPR5.52 [371935]
    end;

    local procedure SensorSelect(Value: Text)
    begin
        //-NPR5.53 [381166]
        case Value of
            'A':
                AddToBuffer('^JSA');
            'R':
                AddToBuffer('^JSR');
            'T':
                AddToBuffer('^JST');
        end;
        //+NPR5.53 [381166]
    end;

    local procedure ParseGraphicBox(FontType: Text; Width: Integer; Height: Integer; X: Integer; Y: Integer)
    var
        StringLib: Codeunit "NPR String Library";
        AfterSpace: Text;
        Thickness: Integer;
        Color: Text;
        Rounding: Integer;
    begin
        //-NPR5.52 [371935]
        StringLib.Construct(FontType);
        AfterSpace := StringLib.SelectStringSep(2, ' ');
        StringLib.Construct(AfterSpace);

        Evaluate(Thickness, StringLib.SelectStringSep(1, ','));
        Color := StringLib.SelectStringSep(2, ',');
        Evaluate(Rounding, StringLib.SelectStringSep(3, ','));

        GraphicBox(Width, Height, Thickness, Color, Rounding, X, Y);
        //+NPR5.52 [371935]
    end;

    procedure MediaDarkness(Darkness: Integer)
    begin
        // Ref sheet 297
        TempPattern := '^MD%1';
        AddToBuffer(StrSubstNo(TempPattern, Darkness));
    end;

    procedure MediaType(Type: Text[1])
    begin
        // Ref sheet 306
        TempPattern := '^MT%1';
        AddToBuffer(StrSubstNo(TempPattern, Type));
    end;

    procedure PrintRate(PrintSpeed: Code[2]; SlewSpeed: Code[2]; BackSpeed: Code[2])
    begin
        // Ref sheet 328
        TempPattern := '^PR%1,%2,%3';
        AddToBuffer(StrSubstNo(TempPattern, PrintSpeed, SlewSpeed, BackSpeed));
    end;

    procedure PrintWidth(Width: Integer)
    begin
        // Ref sheet 332
        TempPattern := '^PW%1';
        AddToBuffer(StrSubstNo(TempPattern, Width));
    end;

    procedure PrintOrientation(Orientation: Text[1])
    begin
        // Ref sheet 325
        TempPattern := '^PO%1';
        AddToBuffer(StrSubstNo(TempPattern, Orientation));
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
            Error(ERR_FONT, HeightText + WidthText);

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
        TempPattern := '^A%1%2,%3,%4';
        AddToBuffer(StrSubstNo(TempPattern, '0', Rotation, Height, Width));

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
        // Ref sheet 336
        TempPattern := '~SD%1';
        AddToBuffer(StrSubstNo(TempPattern, Darkness));
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
        TempPattern := '^A%1%2';
        AddToBuffer(StrSubstNo(TempPattern, Type, Rotation));

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

    local procedure SetEncoding(CustomEncoding: Text)
    begin
        //-NPR5.48 [327107]
        if CustomEncoding = '' then
            CustomEncoding := 'Windows-1252'; //Legacy default

        case CustomEncoding of
            'utf-8':
                begin
                    AddToBuffer('^CI28');
                    Encoding := Encoding::"UTF-8";
                end;
            'Windows-1252':
                begin
                    AddToBuffer('^CI27');
                    Encoding := Encoding::"Windows-1252";
                end;
            else
                Error(ERR_ENCODING, CustomEncoding);
        end;
        //+NPR5.48 [327107]
    end;

    local procedure GetEncoding(): Text
    begin
        //-NPR5.48 [327107]
        case Encoding of
            Encoding::"Windows-1252":
                exit('Windows-1252');
            Encoding::"UTF-8":
                exit('utf-8');
        end;
        //+NPR5.48 [327107]
    end;

    procedure "-- Lookup Functions"()
    begin
    end;

    procedure SelectFont(var Value: Text): Boolean
    var
        RetailList: Record "NPR Retail List" temporary;
    begin
        ConstructFontSelectionList(RetailList);
        if PAGE.RunModal(PAGE::"NPR Retail List", RetailList) = ACTION::LookupOK then begin
            Value := RetailList.Choice;
            exit(true);
        end;
    end;

    local procedure SelectDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean
    var
        tmpRetailList: Record "NPR Retail List" temporary;
        RetailList: Page "NPR Retail List";
    begin
        ConstructDeviceSettingList(tmpRetailList);
        RetailList.SetShowValue(true);
        RetailList.SetRec(tmpRetailList);
        RetailList.LookupMode(true);
        if RetailList.RunModal() = ACTION::LookupOK then begin
            RetailList.GetRec(tmpRetailList);
            tmpDeviceSetting.Name := tmpRetailList.Value;
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
                //-NPR5.48 [327107]
                'RFID_EPC_MEMORY':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Text;
                'ENCODING':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'Windows-1252,utf-8';
                    end;
                //+NPR5.48 [327107]
                //-NPR5.52 [371935]
                'LABEL_REVERSE':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'N,Y';
                    end;
                //+NPR5.52 [371935]
                //-NPR5.53 [381166]
                'SENSOR_SELECT':
                    begin
                        tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Option;
                        tmpDeviceSetting.Options := 'A,R,T';
                    end;
            //+NPR5.53 [381166]
            end;
            exit(tmpDeviceSetting.Insert);
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
        //-NPR5.48 [327107]
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
        //-NPR5.52 [371935]
        AddOption(RetailList, 'LINE', '');
        AddOption(RetailList, 'BOX 1,B,0', '');
        //+NPR5.52 [371935]
        //+NPR5.48 [327107]
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(tmpRetailList, SETTING_LABELHOME, 'LABEL_HOME');
        AddOption(tmpRetailList, SETTING_LABELLENGTH, 'LABEL_LENGTH');
        AddOption(tmpRetailList, SETTING_MEDIADARKNESS, 'MEDIA_DARKNESS');
        AddOption(tmpRetailList, SETTING_MEDIATYPE, 'MEDIA_TYPE');
        AddOption(tmpRetailList, SETTING_PRINTORIENTATION, 'PRINT_ORIENTATION');
        AddOption(tmpRetailList, SETTING_PRINTRATE, 'PRINT_RATE');
        AddOption(tmpRetailList, SETTING_PRINTWIDTH, 'PRINT_WIDTH');
        AddOption(tmpRetailList, SETTING_SETDARKNESS, 'SET_DARKNESS');
        //-NPR5.48 [327107]
        AddOption(tmpRetailList, SETTING_RFID_EPC_MEM, 'RFID_EPC_MEMORY');
        AddOption(tmpRetailList, SETTING_ENCODING, 'ENCODING');
        //+NPR5.48 [327107]
        //-NPR5.52 [371935]
        AddOption(tmpRetailList, SETTING_LABELREVERSE, 'LABEL_REVERSE');
        //+NPR5.52 [371935]
        //-NPR5.53 [381166]
        AddOption(tmpRetailList, SETTING_SENSOR_SELECT, 'SENSOR_SELECT');
        //+NPR5.53 [381166]
    end;

    procedure AddOption(var RetailList: Record "NPR Retail List" temporary; Choice: Text; Value: Text)
    begin
        RetailList.Number += 1;
        RetailList.Choice := Choice;
        RetailList.Value := Value;
        RetailList.Insert();
    end;

    procedure ConstructHashTable()
    begin
        AddLineHashTable('AZTEC', '0');
        AddLineHashTable('CODE11', '1');
        AddLineHashTable('INTER2OF5', '2');
        AddLineHashTable('CODE39', '3');
        AddLineHashTable('CODE49', '4');
        AddLineHashTable('PLANETCODE', '5');
        AddLineHashTable('PDF417', '7');
        AddLineHashTable('EAN8', '8');
        AddLineHashTable('UPCE', '9');
        AddLineHashTable('CODE93', 'A');
        AddLineHashTable('CODABLOCK', 'B');
        AddLineHashTable('CODE128', 'C');
        AddLineHashTable('MAXICODE', 'D');
        AddLineHashTable('EAN13', 'E');
        AddLineHashTable('MICOPDF417', 'F');
        AddLineHashTable('INDUS2OF5', 'I');
        AddLineHashTable('STD2OF5', 'J');
        AddLineHashTable('CODABAR', 'K');
        AddLineHashTable('LOGMARS', 'L');
        AddLineHashTable('MSI', 'M');
        AddLineHashTable('PLESSEY', 'P');
        AddLineHashTable('QR', 'Q');
        AddLineHashTable('GS1DATA', 'R');
        AddLineHashTable('UPCEXTEND', 'S');
        AddLineHashTable('TLC39', 'T');
        AddLineHashTable('UPCA', 'U');
        AddLineHashTable('MATRIX', 'X');
        AddLineHashTable('POSTAL', 'Z');
    end;

    procedure AddLineHashTable(Name: Code[50]; Value: Code[50])
    begin
        HashTable.Template := Name;
        HashTable."Code 1" := Value;
        HashTable.Insert();
    end;

    procedure GetLineHashTable(Name: Code[50]) Value: Code[50]
    begin
        HashTable.SetRange(HashTable.Template, Name);
        if HashTable.FindFirst() then
            exit(HashTable."Code 1")
        else
            Error(err0002);
    end;

    local procedure "-- Aux Functions"()
    begin
    end;

    local procedure AddToBuffer(Text: Text)
    begin
        AddTextToBuffer(Text);
    end;

    local procedure AddCharToBuffer(CharCode: Integer)
    begin
        PrintBuffer += Format(CharCode);
    end;

    local procedure AddTextToBuffer(Text: Text)
    begin
        PrintBuffer += Text + ESC.CR + ESC.LF;
    end;
}

