codeunit 6014545 "NPR RP Blaster CPL Device Lib." implements "NPR IMatrix Printer"
{
#pragma warning disable AA0139
    Access = Internal;

    var
        _PrintBuffer: Codeunit "Temp Blob";
        _Initialized: Boolean;
        MediaSizeSettingLbl: Label 'Dimensions of media - syntax: width[0-500],height[0-500]';
        InvalidDeviceSettingErr: Label 'Invalid device setting: %1';
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;

    #region Interface Implementation

    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        _Initialized := false;
        InitBuffer();

        if DeviceSettings.FindSet() then
            repeat
                case DeviceSettings.Name of
                    'MEDIA_SIZE':
                        InitializePrinter(DeviceSettings.Value);
                    else
                        Error(InvalidDeviceSettingErr, DeviceSettings.Name);
                end;
            until DeviceSettings.Next() = 0;
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    var
        StringLib: Codeunit "NPR String Library";
        FontParam: Text;
    begin
        if not _Initialized then //Legacy support for when the template lines contained setup commands.
            InitializePrinter(POSPrintBuffer.Font);

        if POSPrintBuffer.Align > 0 then
            case POSPrintBuffer.Align of
                1:
                    Justify('CENTER');
                2:
                    Justify('RIGHT');
            end;

        if UpperCase(CopyStr(POSPrintBuffer.Font, 1, 6)) = 'CODE39' then
            Barcode('CODE39', POSPrintBuffer.X, POSPrintBuffer.Y, 50, POSPrintBuffer.Text)
        else
            if CopyStr(POSPrintBuffer.Font, 1, 5) = 'EAN13' then
                Barcode('EAN13', POSPrintBuffer.X, POSPrintBuffer.Y, 50, POSPrintBuffer.Text)
            else
                if CopyStr(POSPrintBuffer.Font, 1, 4) = 'UPCA' then
                    Barcode('UPCA', POSPrintBuffer.X, POSPrintBuffer.Y, 50, POSPrintBuffer.Text)
                else
                    if CopyStr(POSPrintBuffer.Font, 1, 7) = 'BARCODE' then begin
                        PrintBarcode(POSPrintBuffer.Text, POSPrintBuffer.Font, POSPrintBuffer.Align, POSPrintBuffer.Rotation, POSPrintBuffer.Height, POSPrintBuffer.X, POSPrintBuffer.Y)
                    end else
                        if CopyStr(POSPrintBuffer.Font, 1, 6) = 'STRING' then begin
                            StringLib.Construct(POSPrintBuffer.Font);
                            FontParam := StringLib.SelectStringSep(2, ' ');
                            String(FontParam, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text)
                        end else
                            if CopyStr(POSPrintBuffer.Font, 1, 4) = 'TEXT' then begin
                                StringLib.Construct(POSPrintBuffer.Font);
                                FontParam := StringLib.SelectStringSep(2, ' ');
                                Text(FontParam, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text)
                            end else
                                if CopyStr(POSPrintBuffer.Font, 1, 9) = 'ULTRAFONT' then begin
                                    PrintUltraFont(POSPrintBuffer.Font, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text)
                                end else
                                    if CopyStr(POSPrintBuffer.Font, 1, 4) = 'LINE' then begin
                                        DrawLine(POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Width);
                                    end else
                                        if CopyStr(POSPrintBuffer.Font, 1, 5) = 'SETUP' then begin
                                            //Do nothing - Only Setup possible atm is 'SETUP HEIGHT' which is handled by InitializePrinter()
                                            exit;
                                        end else begin
                                            Error('Unsupported Font');
                                        end;

        if POSPrintBuffer.Align > 0 then
            Justify('LEFT');
    end;

    procedure EndJob()
    begin
        AddStringToBuffer('END');
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
    #endregion

    local procedure InitializePrinter(SizeCommand: Text)
    var
        StringLib: Codeunit "NPR String Library";
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
        _Initialized := true;
    end;

    procedure PrintBarcode(TextIn: Text[100]; FontType: Text[30]; Align: Integer; Rotation: Integer; Height: Integer; X: Integer; Y: Integer)
    var
        StringLib: Codeunit "NPR String Library";
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
        StringLib: Codeunit "NPR String Library";
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
            _DotNetEncoding.Encoding(858);
            _DotNetStream.FromOutStream(OStream);
        end;
    end;

    local procedure AddStringToBuffer(ParamString: Text)
    var
        DotNetCharArray: Codeunit "DotNet_Array";
        DotNetByteArray: Codeunit "DotNet_Array";
        DotNetString: Codeunit "DotNet_String";
        TypeHelper: Codeunit "Type Helper";
    begin
        //This function over allocates and is verbose, all because of the beautiful DotNet wrapper codeunits.

        DotNetString.Set(ParamString + TypeHelper.CRLFSeparator());
        DotNetString.ToCharArray(0, DotNetString.Length(), DotNetCharArray);
        _DotNetEncoding.GetBytes(DotNetCharArray, 0, DotNetCharArray.Length(), DotNetByteArray);
        _DotNetStream.Write(DotNetByteArray, 0, DotNetByteArray.Length());
    end;

    #region Info Functions
    procedure IsBarcodeFont(FontCode: Text): Boolean
    begin
        exit(FontCode in ['UPCA', 'UPCE', 'UPCE1', 'UPCA+', 'EAN8', 'EAN13', 'EAN8+', 'EAN13+', 'EAN128', 'ADD2', 'ADD5', 'CODE39',
                           'I2OF5', 'S2OF5', 'D2OF5', 'CODE128A', 'CODE128B', 'CODE128C', 'CODABAR', 'PLESSEY', 'MSI', 'MSI1', 'CODE93', 'POSTNET',
                           'CODE16K', 'MAXICODE', 'PDF417'])
    end;
    #endregion

    #region Advanced Functions
    local procedure Barcode(type: Text[30]; x: Integer; y: Integer; h: Integer; characters: Text[30])
    begin
        // Ref sheet 22-26
        // Rnnn in [0,90,180,270] (Optional)
        // Type in [UPCA,UPCE,UPCE1,UPCA+,EAN8,EAN13,EAN8+,EAN13+,EAN128,ADD2,ADD5,CODE39,
        //          I2OF5,S2OF5,D2OF5,CODE128A,CODE128B,CODE128C,CODABAR,PLESSEY,MSI,MSI1,CODE93,POSTNET,
        //          CODE16K,MAXICODE,PDF417]
        // h in [1:256]
        AddStringToBuffer(StrSubstNo('BARCODE %1 %2 %3 %4 %5', type, x, y, h, characters));
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
        AddStringToBuffer(StrSubstNo('BARCODE[%1] %2%3 %4 %5 %6 %7', Rnnn, type, modifiers, x, y, h, characters));
    end;

    local procedure DrawLine(x: Integer; y: Integer; w: Integer)
    begin
        // Not in ref sheet
        // Command syntax: DRAW_LINE x1 y1 x2 y2 Thickness Color
        // Thickness and Color are optional
        // Hardcoded y2 so the lines can only be horizontal
        AddStringToBuffer(StrSubstNo('DRAW_LINE %1 %2 %3 %4 %5', x, y, x + w, y, 2));
    end;

    local procedure HeaderLine(mode: Text[2]; x: Integer; dottime: Integer; maxY: Integer; numlbls: Integer)
    begin
        // Ref sheet 51-54
        // mode in [!,@,!#,#,!*,!+,!A]
        AddStringToBuffer(StrSubstNo('%1 %2 %3 %4 %5', mode, x, dottime, maxY, numlbls));
    end;

    local procedure Justify(alignment: Text[6])
    begin
        // Ref sheet 56-57
        // Alignment in [LEFT,RIGHT,CENTER]
        AddStringToBuffer(StrSubstNo('JUSTIFY %1', alignment));
    end;

    local procedure String(type: Text[10]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 74-77
        // type in [3X5,5X7,8X8,9X12,12X16,18X23,24X31]
        AddStringToBuffer(StrSubstNo('STRING %1 %2 %3 %4', type, x, y, characters));
    end;

    local procedure Text(fontID: Text[1]; x: Integer; y: Integer; characters: Text[250])
    begin
        // Ref sheet 78-80
        // fontID in [1:6]
        AddStringToBuffer(StrSubstNo('TEXT %1 %2 %3 %4', fontID, x, y, characters));
    end;

    local procedure UltraFont(T: Text[1]; nnn: Text[10]; x: Integer; y: Integer; char: Text[250])
    begin
        // Ref sheet 74-77
        // T in [A,B,C]
        // nnn in IntXInt (HeightXWidth)
        AddStringToBuffer(StrSubstNo('ULTRA_FONT %1%2 %3 %4 %5', T, nnn, x, y, char));
    end;

    local procedure UltraFont2(T: Text[1]; nnn: Text[10]; Italic: Boolean; Bold: Text[3]; Space: Text[3]; x: Integer; y: Integer; char: Text[250])
    var
        ItalicText: Text[1];
    begin
        // Ref sheet 87-89
        // type in [3X5,5X7,8X8,9X12,12X16,18X23,24X31]'
        if Italic then ItalicText := 'I';

        AddStringToBuffer(StrSubstNo('ULTRA_FONT %1%2 %3G2(%4,%5,0) %6 %7 %8', T, nnn, ItalicText, Bold, Space, x, y, char));
    end;
    #endregion

    #region Lookup Functions
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

    local procedure SelectCommand(var Value: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        ConstructCommandList(TempRetailList);
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
                'MEDIA_SIZE':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Text;
            end;
            exit(tmpDeviceSetting.Insert());
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "NPR Retail List" temporary)
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

    local procedure ConstructCommandList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(tmpRetailList, 'LINE', '');
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(tmpRetailList, MediaSizeSettingLbl, 'MEDIA_SIZE');
    end;

    procedure AddOption(var RetailList: Record "NPR Retail List" temporary; Choice: Text; Value: Text)
    begin
        RetailList.Number += 1;
        RetailList.Choice := Choice;
        RetailList.Value := Value;
        RetailList.Insert();
    end;
    #endregion
#pragma warning restore AA0139
}
