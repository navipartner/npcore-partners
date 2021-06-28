codeunit 6014559 "NPR RP Ripac Device Lib."
{
    // This library is almost identical to Epsons as the printer also uses ESC/POS.
    // Differences are in characters per line, alignment and encoding.

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempPattern: Text[50];
        ESC: Codeunit "NPR RP Escape Code Library";
        PrintBuffer: Text;
        MediaWidth: Option "80mm","58mm";
        Error_UnsupportedFont: Label 'Unsupported font: %1';

    local procedure DeviceCode(): Text
    begin
        exit('RIPAC');
    end;

    procedure IsThisDevice(Text: Text): Boolean
    begin
        exit(StrPos(UpperCase(Text), DeviceCode()) > 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnInitJob', '', false, false)]
    local procedure OnInitJob(var DeviceSettings: Record "NPR RP Device Settings")
    begin
        Init(DeviceSettings);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnLineFeed', '', false, false)]
    local procedure OnLineFeed()
    begin
        LineFeed();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnPrintData', '', false, false)]
    local procedure OnPrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    begin
        PrintData(POSPrintBuffer.Text, POSPrintBuffer.Font, POSPrintBuffer.Bold, POSPrintBuffer.Underline, POSPrintBuffer.DoubleStrike, POSPrintBuffer.Align, POSPrintBuffer.Width);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnLookupFont', '', false, false)]
    local procedure OnLookupFont(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectFont(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnLookupCommand', '', false, false)]
    local procedure OnLookupCommand(var LookupOK: Boolean; var Value: Text)
    begin
        LookupOK := SelectCommand(Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetPageWidth', '', false, false)]
    local procedure OnGetPageWidth(FontFace: Text[30]; var Width: Integer)
    begin
        Width := GetPageWidth(FontFace);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetTargetEncoding', '', false, false)]
    local procedure OnGetTargetEncoding(var TargetEncoding: Text)
    begin
        TargetEncoding := 'utf-8';
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnGetPrintBytes', '', false, false)]
    local procedure OnGetPrintBytes(var PrintBytes: Text)
    begin
        PrintBytes := PrintBuffer;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnSetPrintBytes', '', false, false)]
    local procedure OnSetPrintBytes(var PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014548, 'OnBuildDeviceList', '', false, false)]
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
        Clear(PrintBuffer);
        Clear(MediaWidth);
        InitializePrinter();
        SelectCharacterCodeTable(16);
    end;

    procedure PrintData(Data: Text[100]; FontType: Text[10]; Bold: Boolean; UnderLine: Boolean; DoubleStrike: Boolean; Align: Integer; Width: Integer)
    begin
        if UpperCase(FontType) = 'CONTROL' then
            PrintControlChar(CopyStr(Data, 1, 1))
        else
            if UpperCase(FontType) = 'COMMAND' then
                SendCommand(Data)
            else
                if IsBarcodeFont(FontType) then
                    PrintBarcode(FontType, Data, Width, 40)
                else begin
                    SelectJustification(Align);
                    if Bold then TurnExphasizedModeOnOff(1);
                    if UnderLine then TurnUnderlineModeOnOff(1);
                    if DoubleStrike then TurnDoubleStrikeModeOnOff(1);

                    SetFontFace(FontType);
                    AddTextToBuffer(Data);

                    if Bold then TurnExphasizedModeOnOff(0);
                    if UnderLine then TurnUnderlineModeOnOff(0);
                    if DoubleStrike then TurnDoubleStrikeModeOnOff(0);
                end;
    end;

    procedure PrintBarcode(BarcodeType: Text[30]; Text: Text; Width: Integer; Height: Integer)
    var
        Code128: Text;
    begin
        SelectJustification(1);
        SetBarCodeWidth(Width);
        SetBarCodeHeight(Height);

        case BarcodeType of
            'UPC-A':
                PrintBarCodeA(0, Text);
            'UPC-E':
                PrintBarCodeA(1, Text);
            'EAN13':
                PrintBarCodeA(2, Text);
            'EAN8':
                PrintBarCodeA(3, Text);
            'CODE39':
                PrintBarCodeA(4, Text);
            'ITF':
                PrintBarCodeA(5, Text);
            'CODABAR':
                PrintBarCodeA(6, Text);
            'CODE128':
                begin
                    Code128 := BuildCommandC128(Text);
                    if StrLen(Code128) > 0 then
                        PrintBarCodeB(73, StrLen(Code128), Code128);
                end;
            'QR':
                begin
                    Error('Not implemented');
                end;
        end;

        AddTextToBuffer(Text);
        LineFeed();
        SelectJustification(0);
    end;

    procedure PrintBold(Text: Text[250])
    begin
        TurnExphasizedModeOnOff(1);
        AddTextToBuffer(Text);
        TurnExphasizedModeOnOff(0);
    end;

    procedure PrintUnderLine(Text: Text[250])
    begin
        TurnUnderlineModeOnOff(1);
        AddTextToBuffer(Text);
        TurnUnderlineModeOnOff(0);
    end;

    local procedure PrintControlChar(Char: Text[1])
    begin
        case Char of
            'G':
                PrintNVGraphicsData(1, 0);
            'P':
                SelectCutModeAndCutPaper(66, 3);
            'A':
                GeneratePulse(0, 25, 25);
            'B':
                GeneratePulse(0, 50, 50);
            'C':
                GeneratePulse(0, 75, 75);
            'D':
                GeneratePulse(0, 100, 100);
            'E':
                GeneratePulse(0, 125, 125);
            'a':
                GeneratePulse(1, 25, 25);
            'b':
                GeneratePulse(1, 50, 50);
            'c':
                GeneratePulse(1, 75, 75);
            'd':
                GeneratePulse(1, 100, 100);
            'e':
                GeneratePulse(1, 125, 125);
            'h':
                PrintNVGraphicsDataNew(6, 0, 48, 69, 48, 48, 1, 1);
        end;
    end;

    local procedure SendCommand(Command: Text)
    begin
        case UpperCase(Command) of
            'OPENDRAWER':
                GeneratePulse(0, 25, 25);
            'PAPERCUT':
                SelectCutModeAndCutPaper(66, 3);
            'STOREDLOGO_1':
                PrintNVGraphicsData(1, 0);
            'STOREDLOGO_2':
                PrintNVGraphicsData(2, 0);
        end;
    end;

    procedure SetFontStretch(Height: Integer; Width: Integer)
    var
        n: Char;
    begin
        TempPattern := '0' + ESC.GetBitPatternAndPad(Width, 3) + '0' + ESC.GetBitPatternAndPad(Height, 3);
        n := ESC.TranslateBitPattern(TempPattern);
        SelectCharacterSize(n);
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

    procedure SetPrintBytes(PrintBytes: Text)
    begin
        PrintBuffer := PrintBytes;
    end;

    procedure GetPrintBytes(): Text
    begin
        exit(PrintBuffer);
    end;

    procedure "// Base Functions"()
    begin
    end;

    procedure HorizontalTab()
    begin
        AddToBuffer('HT');
    end;

    procedure LineFeed()
    begin
        AddToBuffer('LF');
    end;

    local procedure InitializePrinter()
    begin
        TempPattern := 'ESC @';
        AddToBuffer(TempPattern);
    end;

    procedure GeneratePulse(m: Integer; t1: Char; t2: Char)
    begin
        TempPattern := 'ESC p %1 %2 %3';
        AddToBuffer(StrSubstNo(TempPattern, m, ESC.C2ESC(t1), ESC.C2ESC(t2)));
    end;

    local procedure PrintBarCodeA(m: Char; "d1..dk": Text[30])
    begin
        TempPattern := 'GS k %1 %2 NUL';
        AddToBuffer(StrSubstNo(TempPattern, ESC.C2ESC(m), "d1..dk"));
    end;

    local procedure PrintBarCodeB(m: Char; n: Char; "d1..dn": Text)
    begin
        AddToBuffer('GS k');
        AddTextToBuffer(Format(m) + Format(n) + "d1..dn");
    end;

    procedure PrintNVGraphicsData(n: Char; m: Char)
    begin
        TempPattern := 'FS p %1 %2';
        AddToBuffer(StrSubstNo(TempPattern, ESC.C2ESC(n), ESC.C2ESC(m)));
    end;

    procedure PrintNVGraphicsDataNew(pL: Char; pH: Char; m: Char; fn: Char; kc1: Char; kc2: Char; x: Char; y: Char)
    begin
        TempPattern := 'GS ( L %1 %2 %3 %4 %5 %6 %7 %8';
        AddToBuffer(StrSubstNo(TempPattern, ESC.C2ESC(pL), ESC.C2ESC(pH), ESC.C2ESC(m), ESC.C2ESC(fn), ESC.C2ESC(kc1), ESC.C2ESC(kc2), ESC.C2ESC(x), ESC.C2ESC(y)));
    end;

    local procedure SelectCharacterCodeTable(n: Char)
    begin
        TempPattern := 'ESC t %1';
        AddToBuffer(StrSubstNo(TempPattern, ESC.C2ESC(n)))
    end;

    local procedure SelectCharacterFont(n: Char)
    begin
        TempPattern := 'ESC M %1';
        AddToBuffer(StrSubstNo(TempPattern, ESC.C2ESC(n)));
    end;

    local procedure SelectCharacterSize(n: Char)
    begin
        TempPattern := 'GS ! %1';
        AddToBuffer(StrSubstNo(TempPattern, ESC.C2ESC(n)));
    end;

    local procedure SelectCutModeAndCutPaper(m: Char; n: Char)
    begin
        TempPattern := 'GS V %1 %2';
        AddToBuffer(StrSubstNo(TempPattern, ESC.C2ESC(m), ESC.C2ESC(n)));
    end;

    local procedure SelectJustification(n: Integer)
    begin
        TempPattern := 'ESC a %1';
        AddToBuffer(StrSubstNo(TempPattern, n));
    end;

    local procedure SetBarCodeHeight(n: Char)
    begin
        TempPattern := 'GS h %1';
        AddToBuffer(StrSubstNo(TempPattern, n));
    end;

    local procedure SetBarCodeWidth(n: Char)
    begin
        TempPattern := 'GS w %1';
        AddToBuffer(StrSubstNo(TempPattern, n));
    end;

    local procedure TurnDoubleStrikeModeOnOff(n: Integer)
    begin
        TempPattern := 'ESC G %1';
        AddToBuffer(StrSubstNo(TempPattern, n));
    end;

    local procedure TurnExphasizedModeOnOff(n: Integer)
    begin
        TempPattern := 'ESC E %1';
        AddToBuffer(StrSubstNo(TempPattern, n));
    end;

    local procedure TurnUnderlineModeOnOff(n: Integer)
    begin
        TempPattern := 'ESC - %1';
        AddToBuffer(StrSubstNo(TempPattern, n));
    end;

    procedure "// Info Functions"()
    begin
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        case FontFace[1] of
            'A':
                case FontFace[2] of
                    '1':
                        exit(48);
                    '2':
                        exit(24);
                end;
            'B':
                case FontFace[2] of
                    '1':
                        exit(64);
                    '2':
                        exit(32);
                end;
        end;
        Error(Error_UnsupportedFont, FontFace);
    end;

    local procedure IsBarcodeFont(Font: Text): Boolean
    begin
        Font := UpperCase(Font);

        if Font in ['UPC-A', 'UPC-E', 'EAN13', 'EAN8', 'CODE39', 'ITF', 'CODABAR', 'CODE128', 'QR'] then
            exit(true);
    end;

    local procedure AddToBuffer(Text: Text[1024])
    begin
        ESC.WriteSequenceToBuffer(Text, PrintBuffer);
    end;

    local procedure AddTextToBuffer(Text: Text)
    begin
        PrintBuffer += Text;
    end;

    procedure "// Lookup Functions"()
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

    procedure SelectCommand(var Value: Text): Boolean
    var
        RetailList: Record "NPR Retail List" temporary;
    begin
        ConstructCommandSelectionList(RetailList);
        if PAGE.RunModal(PAGE::"NPR Retail List", RetailList) = ACTION::LookupOK then begin
            Value := RetailList.Choice;
            exit(true);
        end;
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
    end;

    procedure ConstructCommandSelectionList(var RetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(RetailList, 'OPENDRAWER', '');
        AddOption(RetailList, 'PAPERCUT', '');
        AddOption(RetailList, 'STOREDLOGO_1', '');
        AddOption(RetailList, 'STOREDLOGO_2', '');
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
        DummyDecimal: Decimal;
        ConsecutiveNumbers: Integer;
        CurrentMode: Option " ",CodeA,CodeB,CodeC;
        Buffer: Text;
    begin
        // This function builds a value using the following code128 code set logic:
        // Switch to Code C when: More than 4 digits at the start/end or 6 in the middle. Otherwise stay with last used code set if possible.
        // This is done to minimize the width of the final barcode and it's quite messy - the printer itself should do this work instead of us but it can't....

        Length := StrLen(Value);

        if Length = 0 then
            exit('');

        for i := 1 to Length do begin
            Numeric := Evaluate(DummyDecimal, Value[i]);
            Clear(DummyDecimal);

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
}

