codeunit 6014545 "RP Blaster CPL Device Library"
{
    // Blaster CPL Command Library.
    //  Work started by Nicolai Esbensen.
    //  Contributions providing function interfaces for valid
    //  the CPL language functional sequences are welcome. Functionality
    //  for other printer languages should be put in a library on its own.
    // 
    //  All functions write CPL code to a string buffer which can
    //  be sent to a printer or stored to a file.
    // 
    //  Functionality of this library is build
    //  with reference to
    //    - Cognitive Programming Language (CPL)
    //      Programmers Guide
    //      105-008-02 Revision C2 - 3/17/2006
    // 
    //  Manual is located at
    //  "N:\UDV\POS Devices\Tutorials\CLP programming reference\105-008-02_ProgrammingManual_REVC2"
    // 
    // NPR5.32/MMV /20170410 CASE 241995 Retail Print 2.0
    // NPR5.51/MMV /20190801 CASE 360975 Buffer all template print data into one job.

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempPattern: Text[50];
        ESC: Codeunit "RP Escape Code Library";
        PrintBuffer: Text;
        Initialized: Boolean;
        SETTING_MEDIASIZE: Label 'Dimensions of media - syntax: width[0-500],height[0-500]';
        Error_InvalidDeviceSetting: Label 'Invalid device setting: %1';

    local procedure "// Interface implementation"()
    begin
    end;

    local procedure DeviceCode(): Text
    begin
        exit('BLASTER');
    end;

    procedure IsThisDevice(Text: Text): Boolean
    begin
        exit(StrPos(UpperCase(Text), DeviceCode) > 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "RP Device Settings")
    begin
        InitJob(DeviceSettings);
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
    local procedure OnLookupFont(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectFont(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnLookupCommand', '', false, false)]
    local procedure OnLookupCommand(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectCommand(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnLookupDeviceSetting', '', false, false)]
    local procedure OnLookupDeviceSetting(var LookupOK: Boolean; var tmpDeviceSetting: Record "RP Device Settings" temporary)
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
        TargetEncoding := 'IBM00858';
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

    procedure "// ShortHandFunctions"()
    begin
    end;

    procedure InitJob(var DeviceSettings: Record "RP Device Settings")
    begin
        //-NPR5.51 [360975]
        //PrintBuffer := '';
        //+NPR5.51 [360975]
        Initialized := false;

        if DeviceSettings.FindSet then
            repeat
                case DeviceSettings.Name of
                    'MEDIA_SIZE':
                        InitializePrinter(DeviceSettings.Value);
                    else
                        Error(Error_InvalidDeviceSetting, DeviceSettings.Name);
                end;
            until DeviceSettings.Next = 0;
    end;

    local procedure InitializePrinter(SizeCommand: Text)
    var
        StringLib: Codeunit "String Library";
        Dimensions: Text;
        Width: Integer;
        Height: Integer;
    begin
        StringLib.Construct(SizeCommand);
        if (CopyStr(SizeCommand, 1, 10) = 'SETUP SIZE') then begin //Syntax: SETUP SIZE Width,Height
            Dimensions := StringLib.SelectStringSep(3, ' ');
            StringLib.Construct(Dimensions);
            if Evaluate(Width, StringLib.SelectStringSep(1, ',')) and Evaluate(Height, StringLib.SelectStringSep(2, ',')) then
                HeaderLine('!', 0, Width, Height, 1);
        end else
            HeaderLine('!', 0, 100, 225, 1);
        Initialized := true;
    end;

    procedure EndJob()
    begin
        // Ref sheet 42
        TempPattern := 'END';
        AddToBuffer(TempPattern);
    end;

    procedure PrintData(TextIn: Text[100]; FontType: Text[30]; Align: Integer; Rotation: Integer; Height: Integer; Width: Integer; X: Integer; Y: Integer)
    var
        StringLib: Codeunit "String Library";
        FontParam: Code[10];
    begin
        if not Initialized then //Legacy support for when the template lines contained setup commands.
            InitializePrinter(FontType);

        if Align > 0 then
            case Align of
                1:
                    Justify('CENTER');
                2:
                    Justify('RIGHT');
            end;

        if UpperCase(CopyStr(FontType, 1, 6)) = 'CODE39' then
            Barcode('CODE39', X, Y, 50, TextIn)
        else
            if CopyStr(FontType, 1, 5) = 'EAN13' then
                Barcode('EAN13', X, Y, 50, TextIn)
            else
                if CopyStr(FontType, 1, 4) = 'UPCA' then
                    Barcode('UPCA', X, Y, 50, TextIn)
                else
                    if CopyStr(FontType, 1, 7) = 'BARCODE' then begin
                        PrintBarcode(TextIn, FontType, Align, Rotation, Height, X, Y)
                    end else
                        if CopyStr(FontType, 1, 6) = 'STRING' then begin
                            StringLib.Construct(FontType);
                            FontParam := StringLib.SelectStringSep(2, ' ');
                            String(FontParam, X, Y, TextIn)
                        end else
                            if CopyStr(FontType, 1, 4) = 'TEXT' then begin
                                StringLib.Construct(FontType);
                                FontParam := StringLib.SelectStringSep(2, ' ');
                                Text(FontParam, X, Y, TextIn)
                            end else
                                if CopyStr(FontType, 1, 9) = 'ULTRAFONT' then begin
                                    PrintUltraFont(FontType, X, Y, TextIn)
                                end else
                                    if CopyStr(FontType, 1, 4) = 'LINE' then begin
                                        DrawLine(X, Y, Width);
                                    end else
                                        if CopyStr(FontType, 1, 5) = 'SETUP' then begin
                                            //Do nothing - Only Setup possible atm is 'SETUP HEIGHT' which is handled by InitializePrinter()
                                            exit;
                                        end else begin
                                            Error('Unsupported Font');
                                        end;

        if Align > 0 then
            Justify('LEFT');
    end;

    procedure PrintBarcode(TextIn: Text[100]; FontType: Text[30]; Align: Integer; Rotation: Integer; Height: Integer; X: Integer; Y: Integer)
    var
        StringLib: Codeunit "String Library";
        Modifiers: Text;
        FontCode: Text;
    begin
        StringLib.Construct(FontType);

        if Height = 0 then
            Height := 50;

        case true of
            StrLen(TextIn) = 13:
                FontCode := 'EAN13';
            StrLen(TextIn) = 12:
                FontCode := 'UPCA';
            StrLen(TextIn) < 12:
                FontCode := 'CODE39';
        end;

        if StringLib.CountOccurences(' ') > 0 then begin
            if IsBarcodeFont(StringLib.SelectStringSep(2, ' ')) then begin
                FontCode := StringLib.SelectStringSep(2, ' ');
                if StringLib.CountOccurences(' ') = 2 then
                    Modifiers := StringLib.SelectStringSep(3, ' ');
            end else
                Modifiers := StringLib.SelectStringSep(2, ' ');
        end;

        Barcode2(Rotation, FontCode, Modifiers, X, Y, Height, TextIn);
    end;

    procedure PrintUltraFont(FontParam: Text[30]; X: Integer; Y: Integer; TextIn: Text[100])
    var
        StringLib: Codeunit "String Library";
        FontType: Text[1];
        FontSize: Text[10];
        Italic: Boolean;
        Space: Text[3];
        Bold: Text[3];
    begin
        TextIn := ConvertStr(TextIn, '¢', '×');

        StringLib.Construct(FontParam);
        if (StringLib.CountOccurences(' ') = 4) then begin
            FontType := CopyStr(StringLib.SelectStringSep(2, ' '), 1, 1);
            FontSize := CopyStr(StringLib.SelectStringSep(2, ' '), 2);
            if StringLib.SelectStringSep(3, ' ') = 'I' then
                Italic := true;
            Bold := StringLib.SelectStringSep(4, ' ');
            Space := StringLib.SelectStringSep(5, ' ');

            UltraFont2(FontType, FontSize, Italic, Bold, Space, X, Y, TextIn);
        end else begin
            FontParam := StringLib.SelectStringSep(2, ' ');
            UltraFont(CopyStr(FontParam, 1, 1), CopyStr(FontParam, 2), X, Y, TextIn);
        end;
    end;

    procedure GetPrintBytes(): Text
    begin
        //-NPR5.20
        exit(PrintBuffer);
        //+NPR5.20
    end;

    procedure SetPrintBytes(PrintBytes: Text)
    begin
        //-NPR5.20
        PrintBuffer := PrintBytes;
        //+NPR5.20
    end;

    procedure "// Info Functions"()
    begin
    end;

    procedure IsBarcodeFont(FontCode: Text): Boolean
    begin
        exit(FontCode in ['UPCA', 'UPCE', 'UPCE1', 'UPCA+', 'EAN8', 'EAN13', 'EAN8+', 'EAN13+', 'EAN128', 'ADD2', 'ADD5', 'CODE39',
                           'I2OF5', 'S2OF5', 'D2OF5', 'CODE128A', 'CODE128B', 'CODE128C', 'CODABAR', 'PLESSEY', 'MSI', 'MSI1', 'CODE93', 'POSTNET',
                           'CODE16K', 'MAXICODE', 'PDF417'])
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        exit(0);
    end;

    local procedure "// Advanced Functions"()
    begin
    end;

    local procedure Adjust(variable: Text[30]; nnn: Integer)
    begin
        // Ref sheet 18
        TempPattern := 'ADJUST %1 %2';
        AddToBuffer(StrSubstNo(TempPattern, variable, nnn));
    end;

    local procedure AdjustDUP(nnn: Integer)
    begin
        // Ref sheet 20
        TempPattern := 'ADJUST_DUP %1';
        AddToBuffer(StrSubstNo(TempPattern, nnn));
    end;

    local procedure AreaClear(x: Integer; y: Integer; w: Integer; h: Integer)
    begin
        // Ref sheet 21
        TempPattern := 'AREA_CLEAR %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, x, y, w, h));
    end;

    local procedure Barcode(type: Text[30]; x: Integer; y: Integer; h: Integer; characters: Text[30])
    begin
        // Ref sheet 22-26
        // Rnnn in [0,90,180,270] (Optional)
        // Type in [UPCA,UPCE,UPCE1,UPCA+,EAN8,EAN13,EAN8+,EAN13+,EAN128,ADD2,ADD5,CODE39,
        //          I2OF5,S2OF5,D2OF5,CODE128A,CODE128B,CODE128C,CODABAR,PLESSEY,MSI,MSI1,CODE93,POSTNET,
        //          CODE16K,MAXICODE,PDF417]
        // h in [1:256]
        TempPattern := 'BARCODE %1 %2 %3 %4 %5';
        AddToBuffer(StrSubstNo(TempPattern, type, x, y, h, characters));
    end;

    local procedure Barcode2(Rnnn: Integer; type: Text[30]; modifiers: Text[30]; x: Integer; y: Integer; h: Integer; characters: Text[30])
    begin
        // Ref sheet 22-26
        // Rnnn in [0,90,180,270] (Optional)
        // Type in [UPCA,UPCE,UPCE1,UPCA+,EAN8,EAN13,EAN8+,EAN13+,EAN128,ADD2,ADD5,CODE39,
        //          I2OF5,S2OF5,D2OF5,CODE128A,CODE128B,CODE128C,CODABAR,PLESSEY,MSI,MSI1,CODE93,POSTNET,
        //          CODE16K,MAXICODE,PDF417]
        // modifiers in [+,-,(n:w),W,X]
        // h in [1:256]
        TempPattern := 'BARCODE[%1] %2%3 %4 %5 %6 %7';
        AddToBuffer(StrSubstNo(TempPattern, Rnnn, type, modifiers, x, y, h, characters));
    end;

    local procedure BarcodeFont(type: Text[30])
    begin
        // Ref sheet 27
        // Type, refer to table 3 in documentation.
        TempPattern := 'BARCODE_FONT %1';
        AddToBuffer(StrSubstNo(TempPattern, type));
    end;

    local procedure BarcodePDF417(x: Integer; y: Integer; w: Integer; AspectRatio: Boolean; h: Integer; ec: Integer; ErrorCorrectionPct: Boolean; rows: Integer; UseSymbolAspectRatio: Boolean; cols: Integer; bytes: Integer; T: Integer; M: Integer; date: Text[1024])
    begin
        // Ref sheet 30-33
        // Type, refer to table 3 in documentation.
        Error('Not Implemented!');
    end;

    local procedure BarcodeUPS(x: Integer; y: Integer; mode: Integer; data: Text[30])
    begin
        // Ref sheet 34-37
        // mode in [0-6]
        TempPattern := 'BARCODE UPS %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, x, y, mode, data));
    end;

    local procedure Comment(characters: Text[30])
    begin
        // Ref sheet 38
        TempPattern := 'COMMENT %1';
        AddToBuffer(StrSubstNo(TempPattern, characters));
    end;

    local procedure Double()
    begin
        // Ref sheet 39
        Error('Not Implemented!');
    end;

    local procedure DrawBox(x: Integer; y: Integer; w: Integer; h: Integer; t: Integer)
    begin
        // Ref sheet 40
        TempPattern := 'DRAWBOX %1 %2 %3 %4 %4';
        AddToBuffer(StrSubstNo(TempPattern, x, y, w, h, t));
    end;

    local procedure DrawLine(x: Integer; y: Integer; w: Integer)
    begin
        // Not in ref sheet
        // Command syntax: DRAW_LINE x1 y1 x2 y2 Thickness Color
        // Thickness and Color are optional
        // Hardcoded y2 so the lines can only be horizontal
        TempPattern := 'DRAW_LINE %1 %2 %3 %4 %5';
        AddToBuffer(StrSubstNo(TempPattern, x, y, x + w, y, 2));
    end;

    local procedure FillBox(x: Integer; y: Integer; w: Integer; h: Integer)
    begin
        // Ref sheet 43
        TempPattern := 'FILL_BOX %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, x, y, w, h));
    end;

    local procedure Halt()
    begin
        // Ref sheet 42
        TempPattern := 'HALT';
        AddToBuffer(TempPattern);
    end;

    local procedure HeaderLine(mode: Text[2]; x: Integer; dottime: Integer; maxY: Integer; numlbls: Integer)
    begin
        // Ref sheet 51-54
        // mode in [!,@,!#,#,!*,!+,!A]
        TempPattern := '%1 %2 %3 %4 %5';
        AddToBuffer(StrSubstNo(TempPattern, mode, x, dottime, maxY, numlbls));
    end;

    local procedure Index(mode: Text[2]; x: Integer; dottime: Integer; maxY: Integer; numlbls: Integer)
    begin
        // Ref sheet 55
        TempPattern := 'INDEX';
        AddToBuffer(TempPattern);
    end;

    local procedure Justify(alignment: Text[6])
    begin
        // Ref sheet 56-57
        // Alignment in [LEFT,RIGHT,CENTER]
        TempPattern := 'JUSTIFY %1';
        AddToBuffer(StrSubstNo(TempPattern, alignment));
    end;

    local procedure Multiple(nnn: Integer)
    begin
        // Ref sheet 60-6
        // nnn in [2:9]
        TempPattern := 'MULTIPLE %1';
        AddToBuffer(StrSubstNo(TempPattern, nnn));
    end;

    local procedure NoIndex(mode: Text[2]; x: Integer; dottime: Integer; maxY: Integer; numlbls: Integer)
    begin
        // Ref sheet 55
        TempPattern := 'NOINDEX';
        AddToBuffer(TempPattern);
    end;

    local procedure Pitch(nnn: Integer)
    begin
        // Ref sheet 63-64
        TempPattern := 'PITCH %1';
        AddToBuffer(StrSubstNo(TempPattern, nnn));
    end;

    local procedure Quantity(numlabels: Integer)
    begin
        // Ref sheet 65
        TempPattern := 'QUANTITY %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, numlabels));
    end;

    local procedure Rotate90(type: Text[5]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 72-73
        TempPattern := 'R90 %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, type, x, y, characters));
    end;

    local procedure Rotate180(type: Text[5]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 72-73
        TempPattern := 'R180 %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, type, x, y, characters));
    end;

    local procedure Rotate270(type: Text[5]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 72-73
        TempPattern := 'R270 %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, type, x, y, characters));
    end;

    local procedure String(type: Text[10]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 74-77
        // type in [3X5,5X7,8X8,9X12,12X16,18X23,24X31]
        TempPattern := 'STRING %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, type, x, y, characters));
    end;

    local procedure String2(eximage: Integer; exspace: Integer; xmult: Integer; ymult: Integer; type: Text[5]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 74-77
        // Version including optional parameters
        // type in [3X5,5X7,8X8,9X12,12X16,18X23,24X31]
        TempPattern := 'STRING (%1,%2,%3,%4) %5 %6 %7 %8';
        AddToBuffer(StrSubstNo(TempPattern, eximage, exspace, xmult, ymult, type, x, y, characters));
    end;

    local procedure Text(fontID: Text[1]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 78-80
        // fontID in [1:6]
        TempPattern := 'TEXT %1 %2 %3 %4';
        AddToBuffer(StrSubstNo(TempPattern, fontID, x, y, characters));
    end;

    local procedure Text2(spacing: Integer; rotation: Integer; xmult: Integer; ymult: Integer; fontID: Integer; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 78-80
        // fontID in [1:6]
        TempPattern := 'TEXT (%1,%2,%3,%4) %5 %6 %7 %8';
        AddToBuffer(StrSubstNo(TempPattern, spacing, rotation, xmult, ymult, fontID, x, y, characters));
    end;

    local procedure UniversalClear(characters: Text[30])
    begin
        // Ref sheet 86
        TempPattern := '23 23 23 23 23 CLEAR 23 23 23 23 23';
        AddToBuffer(ESC.Get(TempPattern));
    end;

    local procedure UltraFont(T: Text[1]; nnn: Text[10]; x: Integer; y: Integer; char: Text[250])
    begin
        // Ref sheet 74-77
        // T in [A,B,C]
        // nnn in IntXInt (HeightXWidth)
        TempPattern := 'ULTRA_FONT %1%2 %3 %4 %5';
        AddToBuffer(StrSubstNo(TempPattern, T, nnn, x, y, char));
    end;

    local procedure UltraFont2(T: Text[1]; nnn: Text[10]; Italic: Boolean; Bold: Text[3]; Space: Text[3]; x: Integer; y: Integer; char: Text[250])
    var
        ItalicText: Text[1];
    begin
        // Ref sheet 87-89
        // type in [3X5,5X7,8X8,9X12,12X16,18X23,24X31]'
        if Italic then ItalicText := 'I';

        TempPattern := 'ULTRA_FONT %1%2 %3G2(%4,%5,0) %6 %7 %8';
        AddToBuffer(StrSubstNo(TempPattern, T, nnn, ItalicText, Bold, Space, x, y, char));
    end;

    local procedure Width(nnn: Integer)
    begin
        // Ref sheet 92-93
        TempPattern := 'WIDTH %1';
        AddToBuffer(StrSubstNo(TempPattern, nnn));
    end;

    local procedure "-- Aux Functions"()
    begin
    end;

    local procedure AddToBuffer(Text: Text[1024])
    begin
        AddTextToBuffer(Text);
    end;

    local procedure AddCharToBuffer(CharCode: Integer)
    begin
        PrintBuffer += Format(CharCode);
    end;

    local procedure AddTextToBuffer(Text: Text[1024])
    begin
        PrintBuffer += Text + ESC.CR + ESC.LF;
    end;

    procedure LatinConvert(Input: Text[1024]) Output: Text[1024]
    var
        txtTo: Label 'ÈÛ¹ÉßÄ®ÃÙÚ²â¿';
        txtFrom: Label '‘›†’«Ž™š‚ÔŠ';
    begin
        Output := ConvertStr(Input, txtFrom, txtTo);
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

    local procedure SelectCommand(var Value: Text): Boolean
    var
        tmpRetailList: Record "Retail List" temporary;
    begin
        ConstructCommandList(tmpRetailList);
        if PAGE.RunModal(PAGE::"Retail List", tmpRetailList) = ACTION::LookupOK then begin
            Value := tmpRetailList.Choice;
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
                'MEDIA_SIZE':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Text;
            end;
            exit(tmpDeviceSetting.Insert);
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "Retail List" temporary)
    begin
        AddOption(RetailList, 'STRING 3X5', '');
        AddOption(RetailList, 'STRING 5X7', '');
        AddOption(RetailList, 'STRING 8X8', '');
        AddOption(RetailList, 'STRING 9X12', '');
        AddOption(RetailList, 'STRING 12X16', '');
        AddOption(RetailList, 'STRING 18X23', '');
        AddOption(RetailList, 'STRING 24X31', '');
        AddOption(RetailList, 'TEXT 0', '');
        AddOption(RetailList, 'TEXT 1', '');
        AddOption(RetailList, 'TEXT 2', '');
        AddOption(RetailList, 'TEXT 3', '');
        AddOption(RetailList, 'TEXT 4', '');
        AddOption(RetailList, 'TEXT 5', '');
        AddOption(RetailList, 'TEXT 6', '');
        AddOption(RetailList, 'ULTRAFONT A9X12', '');
        AddOption(RetailList, 'ULTRAFONT A12X16', '');
        AddOption(RetailList, 'ULTRAFONT A18X23', '');
        AddOption(RetailList, 'ULTRAFONT B9X12', '');
        AddOption(RetailList, 'ULTRAFONT B12X16', '');
        AddOption(RetailList, 'ULTRAFONT B18X23', '');
        AddOption(RetailList, 'ULTRAFONT C9X12', '');
        AddOption(RetailList, 'ULTRAFONT C12X16', '');
        AddOption(RetailList, 'ULTRAFONT C18X23', '');
        AddOption(RetailList, 'BARCODE EAN13 (2:6)', '');
        AddOption(RetailList, 'BARCODE EAN13', '');
        AddOption(RetailList, 'BARCODE CODE39', '');
    end;

    local procedure ConstructCommandList(var tmpRetailList: Record "Retail List" temporary)
    begin
        AddOption(tmpRetailList, 'LINE', '');
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "Retail List" temporary)
    begin
        AddOption(tmpRetailList, SETTING_MEDIASIZE, 'MEDIA_SIZE');
    end;

    procedure AddOption(var RetailList: Record "Retail List" temporary; Choice: Text; Value: Text)
    begin
        RetailList.Number += 1;
        RetailList.Choice := Choice;
        RetailList.Value := Value;
        RetailList.Insert;
    end;
}

