codeunit 6014544 "RP Citizen CLP Device Library"
{
    // Citizen CLP Command Library.
    //  Work started by Michael Thulin.
    //  Contributions providing function interfaces for valid
    //  CLP language functional sequences are welcome. Functionality
    //  for other printer languages should be put in a library on its own.
    // 
    //  All functions write CLP code to a string buffer which can
    //  be sent to a printer or stored to a file.
    // 
    //  Functionality of this library is build
    //  with reference to
    //    - CITIZEN CLP Series
    //      Label & Barcode Printers
    //      Command Reference Manual
    // 
    //  Manual is located at
    //  "N:\UDV\POS Devices\Tutorials\CLP programming reference\clp-cmrf.pdf"
    // 
    // NPR5.32/MMV /20170410 CASE 241995 Retail Print 2.0
    // NPR5.51/MMV /20190801 CASE 360975 Buffer all template print data into one job.
    // NPR5.55/MITH/20200727 CASE 415706 Added target encoding (ibm850) to prevent errors related to the hardware connector.

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempPattern: Text[50];
        ESC: Codeunit "RP Escape Code Library";
        HashTable: Record "NPR - TEMP Buffer" temporary;
        err0001: Label 'Unsupported Font';
        err0002: Label 'Barcode does not exist.';
        PrintBuffer: Text;

    local procedure "// Interface implementation"()
    begin
    end;

    local procedure DeviceCode(): Text
    begin
        exit('CITIZEN');
    end;

    procedure IsThisDevice(Text: Text): Boolean
    begin
        exit(StrPos(UpperCase(Text), DeviceCode) > 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "RP Device Settings")
    begin
        InitJob();
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
    local procedure OnLookupFont(var LookupOK: Boolean;var Value: Text)
    begin
        LookupOK := SelectFont(Value);
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

    [EventSubscriber(ObjectType::Codeunit, 6014546, 'OnGetTargetEncoding', '', false, false)]
    local procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
        //-NPR5.55 [415706]
        TargetEncoding := 'ibm850';
        //+NPR5.55 [415706]
    end;

    procedure "// ShortHandFunctions"()
    begin
    end;

    procedure InitJob()
    var
        STX: Text[10];
    begin
        //-NPR5.51 [360975]
        //PrintBuffer := '';
        //+NPR5.51 [360975]

        if HashTable.IsEmpty then
          ConstructHashTable;

        STX := ESC."02";
        AddToBuffer(STX + 'm');     // Set units to mm.
        AddToBuffer(STX + 'M1200'); // Set Max Length
        AddToBuffer(STX + 'L');     // Set to Label mode.
        AddToBuffer('D11');         // Set (hv) pixel size.
        AddToBuffer('Q0001');       // Set (xxxx) label quantity.
    end;

    procedure EndJob()
    begin
        // Ref sheet 59 (1-56)
        TempPattern := 'E';
        AddToBuffer(TempPattern);
    end;

    procedure PrintData(TextIn: Text[100];FontType: Text[30];Align: Integer;Rotation: Integer;Height: Integer;Width: Integer;X: Integer;Y: Integer)
    var
        StringLib: Codeunit "String Library";
        FontParam: Code[10];
        FixedHeight: Text[3];
        FixedX: Text[4];
        FixedY: Text[4];
        FontSize: Integer;
    begin
        FixedHeight := PadStrLeft(Format(Height), 3, '0');
        FixedX := PadStrLeft(Format(X), 4, '0');
        FixedY := PadStrLeft(Format(Y), 4, '0');

        Rotation += 1;

        if FixedHeight = '000' then
          FixedHeight := '050';

        if UpperCase(CopyStr(FontType,1,6)) = 'CODE39' then
          Barcode(Rotation,'A','1','1',FixedHeight,FixedY,FixedX,TextIn)
        else if CopyStr(FontType,1,5) = 'EAN13' then
          Barcode(Rotation,'F','1','1',FixedHeight,FixedY,FixedX,TextIn)
        else if CopyStr(FontType,1,5) = 'UPCA' then
          Barcode(Rotation,'B','1','1',FixedHeight,FixedY,FixedX,TextIn)
        else if CopyStr(FontType,1,7) = 'BARCODE'  then begin
          PrintBarcode(TextIn,FontType,Rotation,FixedHeight,FixedX,FixedY)
        end else if CopyStr(FontType,1,4) = 'Font' then begin
          StringLib.Construct(FontType);
          FontParam := StringLib.SelectStringSep(2,' ');
          Evaluate(FontSize, FontParam);
          Character(Rotation, FontSize, '1', '1', '000', FixedY, FixedX, TextIn);
        end else if CopyStr(FontType,1,11) = 'Smooth Font' then begin
          StringLib.Construct(FontType);
          FontParam := StringLib.SelectStringSep(3,' ');
          Evaluate(FontSize, FontParam);
          FontParam := PadStrLeft(Format(FontSize), 3, '0');
          Character(Rotation, 9, '1', '1', FontParam, FixedY, FixedX, TextIn);
        end else if CopyStr(FontType,1,9) = 'Bold Font' then begin
          StringLib.Construct(FontType);
          FontParam := StringLib.SelectStringSep(3,' ');
          Evaluate(FontSize, FontParam);
          FontSize += 120;
          FontParam := PadStrLeft(Format(FontSize), 3, '0');
          Character(Rotation, 9, '1', '1', FontParam, FixedY, FixedX, TextIn);
        end else begin
          Error(err0001);
        end;
    end;

    procedure PrintBarcode(TextIn: Text[100];FontType: Text[30];Rotation: Integer;Height: Text[3];X: Text[4];Y: Text[4])
    var
        StringLib: Codeunit "String Library";
        Thick: Text[1];
        Narrow: Text[1];
        FontCode: Text[1];
    begin
        StringLib.Construct(FontType);
        case true of
          StrLen(TextIn) = 13 : FontCode := 'F';        // EAN13
          StrLen(TextIn) = 12 : FontCode := 'B';        // UPC-A
          StrLen(TextIn) in [9..11] : FontCode := '1';  // Text
          StrLen(TextIn) < 9  : FontCode := 'A';        // Code39
        end;
        // Init Narrow/Thick (default)
        Narrow := '2';
        Thick  := '2';

        if StringLib.CountOccurences(' ') > 0 then begin
          if IsBarcodeFont(StringLib.SelectStringSep(2,' ')) then begin
            // Find Barcode
            FontCode  := GetLineHashTable(StringLib.SelectStringSep(2,' '));
            if StringLib.CountOccurences(' ') = 2 then begin
              // Replace current string to handle modifiers
              StringLib.Construct(StringLib.SelectStringSep(3,' '));
              // Break up Modifiers
              Thick := StringLib.SelectStringSep(1,':');
              Narrow := StringLib.SelectStringSep(2,':');
            end
          end else begin
            // Replace current string to handle modifiers
            StringLib.Construct(StringLib.SelectStringSep(2,' '));
            // Break up Modifiers
            Thick := StringLib.SelectStringSep(1,':');
            Narrow := StringLib.SelectStringSep(2,':');
          end
        end;

        if FontCode = '1' then
          Character(Rotation,3,'1','1','000',Y,X,TextIn)
        else
          Barcode(Rotation,FontCode,Thick,Narrow,Height,Y,X,TextIn);
    end;

    procedure GetPrintBytes(): Text
    begin
        exit(PrintBuffer);
    end;

    procedure SetPrintBytes(PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    procedure "// Info Functions"()
    begin
    end;

    procedure IsBarcodeFont(FontCode: Text): Boolean
    begin
        exit (FontCode in ['CODE39','UPCA','UPCE','S2OF5','CODE128','EAN13','EAN8','HIBC','CODABAR','I2OF5','PLESSEY','CASECODE',
                           'UPC2DA','UPC5DA','CODE93','ZIP','EAN128','EAN128KMART','EAN128RND','TELEPEN','MAXICODE','FIM','PDF417'])
    end;

    procedure "// Advanced Functions"()
    begin
    end;

    local procedure Barcode(rotate: Integer;font: Text[1];thick: Text[1];narrow: Text[1];height: Text[3];row: Text[4];column: Text[4];d: Text[30])
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

        TempPattern := '%1%2%3%4%5%6%7%8';
        AddToBuffer(StrSubstNo(TempPattern,rotate,font,thick,narrow,height,row,column,d));
    end;

    procedure Character(rotate: Integer;font: Integer;hexp: Text[1];vexp: Text[1];point: Text[3];row: Text[4];column: Text[4];d: Text[30])
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

        TempPattern := '%1%2%3%4%5%6%7%8';
        AddToBuffer(StrSubstNo(TempPattern,rotate,font,hexp,vexp,point,row,column,d));
    end;

    procedure TrueType()
    begin
        Error('NOT IMPLEMENTED!');
    end;

    local procedure "// Aux Functions"()
    begin
    end;

    local procedure AddToBuffer(Text: Text[1024])
    begin
        AddTextToBuffer(LatinConvert(Text));
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

    procedure PadStrLeft(Input: Text[30];Length: Integer;PadChr: Text[1]) Output: Text[30]
    var
        PadLength: Integer;
    begin
        PadLength := Length - StrLen(Input);

        if PadLength <= 0 then
          exit(Input);

        exit(PadStr('', PadLength, PadChr) + Input);
    end;

    procedure "// Lookup Functions"()
    begin
    end;

    procedure SelectFont(var Value: Text): Boolean
    var
        RetailList: Record "Retail List" temporary;
    begin
        ConstructFontSelectionList(RetailList);
        if PAGE.RunModal(PAGE ::"Retail List",RetailList) = ACTION::LookupOK then begin
          Value := RetailList.Choice;
          exit(true);
        end;
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "Retail List" temporary)
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

    procedure AddOption(var RetailList: Record "Retail List" temporary;Value: Text[50])
    begin
        RetailList.Number += 1;
        RetailList.Choice := Value;
        RetailList.Insert;
    end;

    procedure ConstructHashTable()
    begin
        AddLineHashTable('CODE39', 'A');
        AddLineHashTable('UPCA', 'B');
        AddLineHashTable('UPCE', 'C');
        AddLineHashTable('S2OF5', 'D');
        AddLineHashTable('CODE128', 'E');
        AddLineHashTable('EAN13', 'F');
        AddLineHashTable('EAN8', 'G');
        AddLineHashTable('HIBC', 'H');
        AddLineHashTable('CODABAR', 'I');
        AddLineHashTable('I2OF5', 'J');
        AddLineHashTable('PLESSEY', 'K');
        AddLineHashTable('CASECODE', 'L');
        AddLineHashTable('UPC2DA', 'M');
        AddLineHashTable('UPC5DA', 'N');
        AddLineHashTable('CODE93', 'O');
        AddLineHashTable('ZIP', 'P');
        AddLineHashTable('EAN128', 'Q');
        AddLineHashTable('EAN128KMART', 'R');
        AddLineHashTable('EAN128RND', 'S');
        AddLineHashTable('TELEPEN', 'T');
        AddLineHashTable('MAXICODE', 'u');
        AddLineHashTable('FIM', 'v');
        AddLineHashTable('PDF417', 'z');
    end;

    procedure AddLineHashTable(Name: Code[50];Value: Code[50])
    begin
        HashTable.Template    := Name;
        HashTable."Code 1"    := Value;
        HashTable.Insert;
    end;

    procedure GetLineHashTable(Name: Code[50]) Value: Code[50]
    begin
        HashTable.SetRange(HashTable.Template, Name);
        if HashTable.FindFirst then
          exit(HashTable."Code 1")
        else
          Error(err0002);
    end;
}

