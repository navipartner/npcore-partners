codeunit 6014544 "NPR RP Citizen CLP Device Lib." implements "NPR IMatrix Printer"
{
#pragma warning disable AA0139
    Access = Internal;

    var
        _PrintBuffer: Codeunit "Temp Blob";
        UnsupportedFontErr: Label 'Unsupported Font';
        BarcodeDoesNotExistErr: Label 'Unknown barcode font %1';
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;


    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        InitBuffer();

        _DotNetStream.WriteByte(2); //STX
        AddStringToBuffer('m');     // Set units to mm.
        _DotNetStream.WriteByte(2);
        AddStringToBuffer('M1200'); // Set Max Length
        _DotNetStream.WriteByte(2);
        AddStringToBuffer('L');     // Set to Label mode.
        AddStringToBuffer('D11');         // Set (hv) pixel size.
        AddStringToBuffer('Q0001');       // Set (xxxx) label quantity.
    end;

    procedure EndJob()
    begin
        // Ref sheet 59 (1-56)
        AddStringToBuffer('E');
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    var
        StringLib: Codeunit "NPR String Library";
        FontParam: Code[10];
        FixedHeight: Text[3];
        FixedX: Text[4];
        FixedY: Text[4];
        FontSize: Integer;
    begin
        FixedHeight := PadStrLeft(Format(POSPrintBuffer.Height), 3, '0');
        FixedX := PadStrLeft(Format(POSPrintBuffer.X), 4, '0');
        FixedY := PadStrLeft(Format(POSPrintBuffer.Y), 4, '0');

        POSPrintBuffer.Rotation += 1;

        if FixedHeight = '000' then
            FixedHeight := '050';

        if UpperCase(CopyStr(POSPrintBuffer.Font, 1, 6)) = 'CODE39' then
            Barcode(POSPrintBuffer.Rotation, 'A', '1', '1', FixedHeight, FixedY, FixedX, POSPrintBuffer.Text)
        else
            if CopyStr(POSPrintBuffer.Font, 1, 5) = 'EAN13' then
                Barcode(POSPrintBuffer.Rotation, 'F', '1', '1', FixedHeight, FixedY, FixedX, POSPrintBuffer.Text)
            else
                if CopyStr(POSPrintBuffer.Font, 1, 5) = 'UPCA' then
                    Barcode(POSPrintBuffer.Rotation, 'B', '1', '1', FixedHeight, FixedY, FixedX, POSPrintBuffer.Text)
                else
                    if CopyStr(POSPrintBuffer.Font, 1, 7) = 'BARCODE' then begin
                        PrintBarcode(POSPrintBuffer.Text, POSPrintBuffer.Font, POSPrintBuffer.Rotation, FixedHeight, FixedX, FixedY)
                    end else
                        if CopyStr(POSPrintBuffer.Font, 1, 4) = 'Font' then begin
                            StringLib.Construct(POSPrintBuffer.Font);
                            FontParam := StringLib.SelectStringSep(2, ' ');
                            Evaluate(FontSize, FontParam);
                            Character(POSPrintBuffer.Rotation, FontSize, '1', '1', '000', FixedY, FixedX, POSPrintBuffer.Text);
                        end else
                            if CopyStr(POSPrintBuffer.Font, 1, 11) = 'Smooth Font' then begin
                                StringLib.Construct(POSPrintBuffer.Font);
                                FontParam := StringLib.SelectStringSep(3, ' ');
                                Evaluate(FontSize, FontParam);
                                FontParam := PadStrLeft(Format(FontSize), 3, '0');
                                Character(POSPrintBuffer.Rotation, 9, '1', '1', FontParam, FixedY, FixedX, POSPrintBuffer.Text);
                            end else
                                if CopyStr(POSPrintBuffer.Font, 1, 9) = 'Bold Font' then begin
                                    StringLib.Construct(POSPrintBuffer.Font);
                                    FontParam := StringLib.SelectStringSep(3, ' ');
                                    Evaluate(FontSize, FontParam);
                                    FontSize += 120;
                                    FontParam := PadStrLeft(Format(FontSize), 3, '0');
                                    Character(POSPrintBuffer.Rotation, 9, '1', '1', FontParam, FixedY, FixedX, POSPrintBuffer.Text);
                                end else begin
                                    Error(UnsupportedFontErr);
                                end;
    end;

    procedure LookupFont(var Value: Text): Boolean
    begin
        exit(SelectFont(Value));
    end;

    procedure LookupCommand(var Value: Text): Boolean;
    begin
        Value := '';
        exit(false);
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
            _DotNetEncoding.Encoding(850);
            _DotNetStream.FromOutStream(OStream);
        end;
    end;

    local procedure AddStringToBuffer(String: Text)
    var
        DotNetCharArray: Codeunit "DotNet_Array";
        DotNetByteArray: Codeunit "DotNet_Array";
        DotNetString: Codeunit "DotNet_String";
        TypeHelper: Codeunit "Type Helper";
    begin
        //This function over allocates and is verbose, all because of the beautiful DotNet wrapper codeunits.

        DotNetString.Set(String + TypeHelper.CRLFSeparator());
        DotNetString.ToCharArray(0, DotNetString.Length(), DotNetCharArray);
        _DotNetEncoding.GetBytes(DotNetCharArray, 0, DotNetCharArray.Length(), DotNetByteArray);
        _DotNetStream.Write(DotNetByteArray, 0, DotNetByteArray.Length());
    end;

    procedure PrintBarcode(TextIn: Text[100]; FontType: Text[30]; Rotation: Integer; Height: Text[3]; X: Text[4]; Y: Text[4])
    var
        StringLib: Codeunit "NPR String Library";
        Thick: Text[1];
        Narrow: Text[1];
        FontCode: Text[1];
    begin
        StringLib.Construct(FontType);
        case true of
            StrLen(TextIn) = 13:
                FontCode := 'F';        // EAN13
            StrLen(TextIn) = 12:
                FontCode := 'B';        // UPC-A
            StrLen(TextIn) in [9 .. 11]:
                FontCode := '1';  // Text
            StrLen(TextIn) < 9:
                FontCode := 'A';        // Code39
        end;
        // Init Narrow/Thick (default)
        Narrow := '2';
        Thick := '2';

        if StringLib.CountOccurences(' ') > 0 then begin
            if IsBarcodeFont(StringLib.SelectStringSep(2, ' ')) then begin
                // Find Barcode
                FontCode := GetBarcodeFont(StringLib.SelectStringSep(2, ' '));
                if StringLib.CountOccurences(' ') = 2 then begin
                    // Replace current string to handle modifiers
                    StringLib.Construct(StringLib.SelectStringSep(3, ' '));
                    // Break up Modifiers
                    Thick := StringLib.SelectStringSep(1, ':');
                    Narrow := StringLib.SelectStringSep(2, ':');
                end
            end else begin
                // Replace current string to handle modifiers
                StringLib.Construct(StringLib.SelectStringSep(2, ' '));
                // Break up Modifiers
                Thick := StringLib.SelectStringSep(1, ':');
                Narrow := StringLib.SelectStringSep(2, ':');
            end
        end;

        if FontCode = '1' then
            Character(Rotation, 3, '1', '1', '000', Y, X, TextIn)
        else
            Barcode(Rotation, FontCode, Thick, Narrow, Height, Y, X, TextIn);
    end;

    procedure IsBarcodeFont(FontCode: Text): Boolean
    begin
        exit(FontCode in ['CODE39', 'UPCA', 'UPCE', 'S2OF5', 'CODE128', 'EAN13', 'EAN8', 'HIBC', 'CODABAR', 'I2OF5', 'PLESSEY', 'CASECODE',
                           'UPC2DA', 'UPC5DA', 'CODE93', 'ZIP', 'EAN128', 'EAN128KMART', 'EAN128RND', 'TELEPEN', 'MAXICODE', 'FIM', 'PDF417'])
    end;

    local procedure Barcode(rotate: Integer; font: Text[1]; thick: Text[1]; narrow: Text[1]; height: Text[3]; row: Text[4]; column: Text[4]; d: Text[30])
    begin
        // Ref sheet 81-82 (1-78, 1-79)
        // rotate   :   Orientation,                [1,2,3,4] -> [0º,90º,180º,270º]
        // font     :   Barcode type,               see table 3 for details.
        // thick    :   Sets thick bar width,       1-9, A-O (A-O corresponds to 10-24)
        // narrow   :   Sets narrow bar width,      1-9, A-O (A-O corresponds to 10-24)
        // height   :   Sets height of the barcode, 001-999
        // row      :   Row address (y)             0000-9999
        // column   :   Column address (x)          0000-9999
        // d        :   Barcode data

        AddStringToBuffer(StrSubstNo('%1%2%3%4%5%6%7%8', rotate, font, thick, narrow, height, row, column, d));
    end;

    procedure Character(rotate: Integer; font: Integer; hexp: Text[1]; vexp: Text[1]; point: Text[3]; row: Text[4]; column: Text[4]; d: Text[30])
    begin
        // Ref sheet 77-79 (1-74, 1-75, 1-76)
        // rotate   :   Orientation,                [1,2,3,4] -> [0º,90º,180º,270º]
        // font     :   Font type,                  see table 1 and 2 for details.
        // hexp     :   Sets expansion rate (horz), 1-9, A-O (A-O corresponds to 10-24)
        // vexp     :   Sets expansion rate (vert), 1-9, A-O (A-O corresponds to 10-24)
        // point    :   Sets size of smooth font,   See table 2 for details.
        // row      :   Row address (y)             0000-9999
        // column   :   Column address (x)          0000-9999
        // d        :   data

        AddStringToBuffer(StrSubstNo('%1%2%3%4%5%6%7%8', rotate, font, hexp, vexp, point, row, column, d));
    end;

    procedure PadStrLeft(Input: Text[30]; Length: Integer; PadChr: Text[1]) Output: Text[30]
    var
        PadLength: Integer;
    begin
        PadLength := Length - StrLen(Input);

        if PadLength <= 0 then
            exit(Input);

        exit(PadStr('', PadLength, PadChr) + Input);
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
        AddOption(RetailList, 'Font 0');
        AddOption(RetailList, 'Font 1');
        AddOption(RetailList, 'Font 2');
        AddOption(RetailList, 'Font 3');
        AddOption(RetailList, 'Font 4');
        AddOption(RetailList, 'Font 5');
        AddOption(RetailList, 'Font 6');
        AddOption(RetailList, 'Font 7');
        AddOption(RetailList, 'Font 8');

        // Font 9 normal (A)
        AddOption(RetailList, 'Smooth Font 1');
        AddOption(RetailList, 'Smooth Font 2');
        AddOption(RetailList, 'Smooth Font 3');
        AddOption(RetailList, 'Smooth Font 4');
        AddOption(RetailList, 'Smooth Font 5');
        AddOption(RetailList, 'Smooth Font 6');
        AddOption(RetailList, 'Smooth Font 7');
        AddOption(RetailList, 'Smooth Font 8');
        AddOption(RetailList, 'Smooth Font 9');
        AddOption(RetailList, 'Smooth Font 10');

        // Font 9 bold (C)
        AddOption(RetailList, 'Bold Font 1');
        AddOption(RetailList, 'Bold Font 2');
        AddOption(RetailList, 'Bold Font 3');
        AddOption(RetailList, 'Bold Font 4');
        AddOption(RetailList, 'Bold Font 5');
        AddOption(RetailList, 'Bold Font 6');
        AddOption(RetailList, 'Bold Font 7');
        AddOption(RetailList, 'Bold Font 8');
        AddOption(RetailList, 'Bold Font 9');
        AddOption(RetailList, 'Bold Font 10');

        //Barcodes
        AddOption(RetailList, 'BARCODE EAN13 1:1');
        AddOption(RetailList, 'BARCODE CODE39');
    end;

    procedure AddOption(var RetailList: Record "NPR Retail List" temporary; Value: Text[50])
    begin
        RetailList.Number += 1;
        RetailList.Choice := Value;
        RetailList.Insert();
    end;

    local procedure GetBarcodeFont(ParamBarcode: Text): Text
    begin
        case ParamBarcode of
            'CODE39':
                exit('A');
            'UPCA':
                exit('B');
            'UPCE':
                exit('C');
            'S2OF5':
                exit('D');
            'CODE128':
                exit('E');
            'EAN13':
                exit('F');
            'EAN8':
                exit('G');
            'HIBC':
                exit('H');
            'CODABAR':
                exit('I');
            'I2OF5':
                exit('J');
            'PLESSEY':
                exit('K');
            'CASECODE':
                exit('L');
            'UPC2DA':
                exit('M');
            'UPC5DA':
                exit('N');
            'CODE93':
                exit('O');
            'ZIP':
                exit('P');
            'EAN128':
                exit('Q');
            'EAN128KMART':
                exit('R');
            'EAN128RND':
                exit('S');
            'TELEPEN':
                exit('T');
            'MAXICODE':
                exit('u');
            'FIM':
                exit('v');
            'PDF417':
                exit('z');
            else
                Error(BarcodeDoesNotExistErr);
        end
    end;
#pragma warning restore AA0139
}

