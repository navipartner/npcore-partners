codeunit 6014549 "NPR RP Line Print Mgt."
{
    // 
    // Line Print Buffer Mgt.
    //  Work started by Nicolai Esbensen.
    // 
    //  Provides functionality for building and formatting
    //  a line base print buffer.
    // 
    //  Exposes methods for printing the formatted buffer, using the
    //  "Line Printer Interface".
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    //  All integer arguments with name align follow the convention;
    //  0 = Left, 1 = Center and 2 = Right.
    // 
    //  "AddTextField(Column : Integer;Align : Integer;Text : Text[50])"
    //   Adds the text to the buffer on the current line, at the given column.
    // 
    //  "AddDecimalField(Column : Integer;Align : Integer;Decimal : Decimal)"
    //   Adds the decimal to the buffer on the current line, at the given column,
    //   using a formatting of two decimals.
    // 
    //  "AddDateField(Column : Integer;Align : Integer;Date : Date)"
    //   Adds the date to the buffer on the current line, at the given column, using default
    //   system formatting.
    // 
    //  "AddBarcode(BarcodeType : Text[30];BarcodeValue : Text[30];BarcodeWidth : Integer)"
    //   Adds a barcode print to the buffer. All barcodes are printer by themselves.
    // 
    //  "AddLine(Text : Text[50])"
    //   Adds a line with the given text, left aligned an moves cursor to new line.
    // 
    //  "NewLine()"
    //   Increments the line count. Can be used to manually go to new line. Note
    //   multiple repetitive calls will only generate 1 linebreak. For multiple
    //   linebreaks use AddLine with an empty argument.
    // 
    // -----------------------------------------------------------------------------
    // Global Style Modifiers
    // 
    //  "SetFont(FontName : Text[10])"
    //   Sets font to the fontname specified.
    // 
    //  "SetAutoLineBreak(AutoLineBreakIn : Boolean)"
    //   Automatically invokes newline, when a column, with an
    //   index lower than the last addressed, is acessed.
    // 
    //  "SetBold(Bold : Boolean)"
    //   Request a bold print until disabled.
    // 
    //  "SetUnderLine(UnderLine : Boolean)"
    //   Request a undelined print until disabled.
    // 
    //  "SetDoubleStrike(DoubleStrike : Boolean)"
    //   Request a double-striked print until disabled.
    // 
    //  "SetPadChar(Char : Text[1])"
    //   Changes the padding char from space to the one given,
    // 
    //  "SetTwoColumnDistribution(Col1Factor : Decimal;Col2Factor : Decimal)"
    //  "SetThreeColumnDistribution(Col1Factor : Decimal..Col3Factor : Decimal)"
    //  "SetFourColumnDistribution(Col1Factor : Decimal..Col4Factor : Decimal)"
    //   Sets the column distribution width for the columns in the print. The alteration
    //   is global for the print, and can not be altered more than once. Column
    //   factors should sum to 1.0.
    // 
    // -----------------------------------------------------------------------------
    // 
    // This object can either be used directly programmatically via the AddX and ProcessBufferForCodeunit()/ProcessBufferForReport() functions or via template setup.
    // The latter is recommended.
    // 
    // NPR4.15/MMV/20151002 CASE 223893 Added support for Master/Slave printing
    // NPR4.16/MMV/20151020 CASE 225257 Added check on printer name with error if no match.
    // NPR4.16/MMV/20151020 CASE 223893 Added support for Master/Slave printing
    // NPR4.18/MMV/20160119 CASE 230218 Support for RecordRef
    // NPR4.18/MMV/20160128 CASE 224257 Allow custom width for barcodes
    // NPR5.20/MMV/20160225 CASE 233229 Moved print method logic away from device codeunits.
    //                                  Also removed old case comments, along with small cleanup/renaming.
    // NPR5.20/MMV/20160317 CASE 237229 Removed error on text overflow.
    // NPR5.26/MMV /20160905 CASE 250407 Added function ClearBuffer()
    //                                   Removed old in-line comments.
    // NPR5.32/MMV /20170324 CASE 241995 Retail Print 2.0
    // NPR5.33/MMV /20170602 CASE 278792 Added function ProcessBufferOnReportOutput();
    //                                   Made some local functions really local.
    // NPR5.33/MMV /20170608 CASE 279696 Skip attribute print when blank.
    // NPR5.34/MMV /20170724 CASE 284505 Expose all column distributions for custom setup.
    // NPR5.37/MMV /20171002 CASE 269767 Implemented commands properly.
    // NPR5.40/MMV /20180209 CASE 304639 Skip if empty data buffer.
    // NPR5.41/MMV /20180416 CASE 311633 Added support for more than 2 decimals.
    // NPR5.44/MMV /20180706 CASE 315362 Changed function signatuer in data join buffer.
    //                                   Cleanup and refactoring.
    // NPR5.54/MITH/20200207 CASE 369235 Changed length of FontName(input) in SetFont and CurrentFont(var) from 10 to 30.
    // NPR5.55/MMV /20200220 CASE 391841 Added support for skipping remaining columns on a line if blank.

    SingleInstance = true;

    var
        TempBuffer: Record "NPR RP Print Buffer" temporary;
        LinePrinter: Codeunit "NPR RP Line Printer Interf.";
        CurrentLineNo: Integer;
        CurrentFont: Text[30];
        PadChar: Text[1];
        AutoLineBreak: Boolean;
        CurrentBold: Boolean;
        CurrentUnderLine: Boolean;
        CurrentDoubleStrike: Boolean;
        LastColumnNo: Integer;
        TwoColumnDistribution: array[2] of Decimal;
        ThreeColumnDistribution: array[3] of Decimal;
        FourColumnDistribution: array[4] of Decimal;
        Error_MissingDevice: Label 'Missing printer device type for: (template %1, codeunit %2, report %3)';
        Error_InvalidTableAttribute: Label 'Cannot print attributes from table %1';
        LineBuffer: Text;
        DecimalRounding: Option "2","3","4","5";
        SkipColumnsAboveNo: Integer;
        SkipRemainingColumns: Boolean;

    procedure AddTextField(Column: Integer; Align: Integer; Text: Text)
    begin
        UpdateField(Column, Align, 0, '', CopyStr(Text, 1, 100));
    end;

    procedure AddDecimalField(Column: Integer; Align: Integer; Decimal: Decimal)
    begin
        case DecimalRounding of
            DecimalRounding::"2":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,2:2><Standard Format,2>'));
            DecimalRounding::"3":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,3:3><Standard Format,2>'));
            DecimalRounding::"4":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,4:4><Standard Format,2>'));
            DecimalRounding::"5":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,5:5><Standard Format,2>'));
        end;
    end;

    procedure AddDateField(Column: Integer; Align: Integer; Date: Date)
    begin
        UpdateField(Column, Align, 0, '', Format(Date, 0));
    end;

    procedure AddBarcode(BarcodeType: Text[30]; BarcodeValue: Text; BarcodeWidth: Integer)
    begin
        UpdateField(1, 0, BarcodeWidth, BarcodeType, BarcodeValue);
    end;

    procedure AddLine(Text: Text)
    begin
        UpdateField(1, 0, 0, '', CopyStr(Text, 1, 100));
        NewLine();
    end;

    procedure NewLine()
    begin
        CurrentLineNo += 1;
    end;

    procedure "// Global Style Modifiers"()
    begin
    end;

    procedure SetFont(FontName: Text[30])
    begin
        CurrentFont := FontName;
    end;

    procedure SetAutoLineBreak(AutoLineBreakIn: Boolean)
    begin
        AutoLineBreak := AutoLineBreakIn;
    end;

    procedure SetBold(Bold: Boolean)
    begin
        CurrentBold := Bold;
    end;

    procedure SetUnderLine(UnderLine: Boolean)
    begin
        CurrentUnderLine := UnderLine;
    end;

    procedure SetTwoColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal)
    begin
        TwoColumnDistribution[1] := Col1Factor;
        TwoColumnDistribution[2] := Col2Factor;
    end;

    procedure SetThreeColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal; Col3Factor: Decimal)
    begin
        ThreeColumnDistribution[1] := Col1Factor;
        ThreeColumnDistribution[2] := Col2Factor;
        ThreeColumnDistribution[3] := Col3Factor;
    end;

    procedure SetFourColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal; Col3Factor: Decimal; Col4Factor: Decimal)
    begin
        FourColumnDistribution[1] := Col1Factor;
        FourColumnDistribution[2] := Col2Factor;
        FourColumnDistribution[3] := Col3Factor;
        FourColumnDistribution[4] := Col4Factor;
    end;

    procedure SetDoubleStrike(DoubleStrike: Boolean)
    begin
        CurrentDoubleStrike := DoubleStrike;
    end;

    procedure SetPadChar(Char: Text[1])
    begin
        PadChar := Char;
    end;

    procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        DecimalRounding := DecimalRoundingIn;
    end;

    procedure "// Global Print Functions"()
    begin
    end;

    procedure ProcessTemplate("Code": Code[20]; "Table": Variant)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        ClearState();

        RPTemplateHeader.Get(Code);
        RPTemplateHeader.TestField("Printer Type", RPTemplateHeader."Printer Type"::Line);

        if RPTemplateHeader."Pre Processing Codeunit" > 0 then begin
            if not CODEUNIT.Run(RPTemplateHeader."Pre Processing Codeunit", Table) then
                exit;
            ClearState();
        end;

        if RPTemplateHeader."Print Processing Object ID" = 0 then
            RunPrintEngine(RPTemplateHeader, Table)
        else
            case RPTemplateHeader."Print Processing Object Type" of
                RPTemplateHeader."Print Processing Object Type"::Codeunit:
                    CODEUNIT.Run(RPTemplateHeader."Print Processing Object ID", Table);
                RPTemplateHeader."Print Processing Object Type"::Report:
                    REPORT.Run(RPTemplateHeader."Print Processing Object ID", GuiAllowed, false, Table);
            end;

        if RPTemplateHeader."Post Processing Codeunit" > 0 then
            CODEUNIT.Run(RPTemplateHeader."Post Processing Codeunit", Table);

        ClearState();
    end;

    procedure ProcessBufferForCodeunit(CodeunitID: Integer; TemplateCode: Code[20])
    begin
        PrintBuffer(TemplateCode, CodeunitID, 0);
        ClearState();
    end;

    procedure ProcessBufferForReport(ReportID: Integer; TemplateCode: Code[20])
    begin
        PrintBuffer(TemplateCode, 0, ReportID);
        ClearState();
    end;

    procedure ClearBuffer()
    begin
        TempBuffer.DeleteAll();
    end;

    procedure ProcessCodeunit(CodeunitID: Integer; "Table": Variant)
    begin
        // DEPRECATED FUNCTION - DO NOT USE.
        // This function takes advantage of the fact that this codeunit is single instance, which will be removed eventually.
        // Use the AddX functions and end with ProcessBufferForCodeunit() instead for new functionality if you need to hardcode printing.

        ClearState();
        SetDefaultDistributions();

        if Table.IsRecord or Table.IsRecordRef then
            CODEUNIT.Run(CodeunitID, Table)
        else
            CODEUNIT.Run(CodeunitID);

        PrintBuffer('', CodeunitID, 0);

        ClearState();
    end;

    local procedure GetDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer): Text
    var
        DeviceType: Text;
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if TemplateCode <> '' then begin
            RPTemplateHeader.Get(TemplateCode);
            if RPTemplateHeader."Printer Device" <> '' then
                exit(RPTemplateHeader."Printer Device");
        end;

        OnGetDeviceType(TemplateCode, CodeunitId, ReportId, DeviceType);
        if DeviceType = '' then
            Error(Error_MissingDevice, RPTemplateHeader.Code, CodeunitId, ReportId);

        exit(DeviceType);
    end;

    local procedure ProcessLayout(DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."; TemplateCode: Text)
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        RPTemplateLine.SetCurrentKey("Template Code", Level, "Parent Line No.", "Line No.");
        RPTemplateLine.SetRange("Template Code", TemplateCode);
        RPTemplateLine.SetRange(Level, 0);
        RPTemplateLine.SetRange("Parent Line No.", 0);
        MergeBuffer(RPTemplateLine, DataJoinBuffer, 0, 0);
    end;

    local procedure RunPrintEngine(TemplateHeader: Record "NPR RP Template Header"; "Table": Variant)
    var
        RecRef: RecordRef;
        DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt.";
    begin
        SetDefaultDistributions();

        if Table.IsRecord then
            RecRef.GetTable(Table)
        else
            RecRef := Table;

        SetAutoLineBreak(true);
        SetDecimalRounding(TemplateHeader."Default Decimal Rounding");

        ParseColumnDistribution(TemplateHeader);
        DataJoinBuffer.SetDecimalRounding(TemplateHeader."Default Decimal Rounding");
        DataJoinBuffer.ProcessDataJoin(RecRef, TemplateHeader.Code); //Pulls data from tables and joins on the linked fields.
        if DataJoinBuffer.IsEmpty() then
            exit;
        ProcessLayout(DataJoinBuffer, TemplateHeader.Code); //Merges layout with data join buffer
        PrintBuffer(TemplateHeader.Code, CODEUNIT::"NPR RP Line Print Mgt.", 0); //Converts generic print buffer to device specific data.
    end;

    local procedure PrintBuffer(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer)
    var
        CurrentLine: Integer;
        DeviceType: Text;
        DeviceSettings: Record "NPR RP Device Settings";
    begin
        DeviceType := GetDeviceType(TemplateCode, CodeunitId, ReportId);
        DeviceSettings.SetRange(Template, TemplateCode);

        LinePrinter.Construct(DeviceType);
        LinePrinter.OnInitJob(DeviceSettings);

        if TempBuffer.FindSet() then
            repeat
                if CurrentLine <> TempBuffer."Line No." then
                    LinePrinter.OnLineFeed();
                PadBuffer();
                LinePrinter.OnPrintData(TempBuffer);
                CurrentLine := TempBuffer."Line No.";
            until TempBuffer.Next() = 0;

        LinePrinter.OnEndJob();
        OnSendPrintJob(TemplateCode, CodeunitId, ReportId, LinePrinter, 1);
        LinePrinter.Dispose();
    end;

    local procedure GetColumnCount(var PrintBufferIn: Record "NPR RP Print Buffer" temporary) Columns: Integer
    begin
        PrintBufferIn.SetRange("Line No.", PrintBufferIn."Line No.");
        Columns := PrintBufferIn.Count();
        PrintBufferIn.SetRange("Line No.");
    end;

    local procedure MergeBuffer(var TemplateLine: Record "NPR RP Template Line"; var DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."; LowerBoundIn: Integer; UpperBoundIn: Integer)
    var
        RPTemplateLineChildren: Record "NPR RP Template Line";
        CurrentRecNo: Integer;
        UpperBound: Integer;
    begin
        DataJoinBuffer.SetBounds(LowerBoundIn, UpperBoundIn);

        if TemplateLine.FindSet() then
            repeat
                case TemplateLine.Type of
                    TemplateLine.Type::Loop:
                        if DataJoinBuffer.FindBufferSet(TemplateLine."Data Item Name", CurrentRecNo) then begin
                            RPTemplateLineChildren.SetCurrentKey("Template Code", Level, "Parent Line No.", "Line No.");
                            RPTemplateLineChildren.SetRange("Template Code", TemplateLine."Template Code");
                            RPTemplateLineChildren.SetRange(Level, TemplateLine.Level + 1);
                            RPTemplateLineChildren.SetRange("Parent Line No.", TemplateLine."Line No.");
                            repeat
                                UpperBound := DataJoinBuffer.FindSubset(CurrentRecNo, UpperBoundIn);
                                MergeBuffer(RPTemplateLineChildren, DataJoinBuffer, CurrentRecNo, UpperBound);
                            until not DataJoinBuffer.NextRecord(TemplateLine."Data Item Name", CurrentRecNo, UpperBoundIn);
                            DataJoinBuffer.SetBounds(LowerBoundIn, UpperBoundIn);
                        end;

                    TemplateLine.Type::FieldCaption,
                  TemplateLine.Type::Data:
                        PrintLine(TemplateLine, DataJoinBuffer);

                    TemplateLine.Type::Logo:
                        begin
                            SetFont('Logo');
                            AddLine(TemplateLine."Type Option");
                        end;

                    TemplateLine.Type::Command:
                        begin
                            SetFont('COMMAND');
                            AddLine(TemplateLine."Type Option");
                        end;
                end;
            until TemplateLine.Next() = 0;
    end;

    local procedure EvaluateFields(TemplateLine: Record "NPR RP Template Line"; var DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."): Text[30]
    var
        Field1Val: Text[250];
        Field2Val: Text[250];
        Field1Dec: Decimal;
        Field2Dec: Decimal;
        ReturnResult: Decimal;
    begin
        Field1Val := DataJoinBuffer.GetField(TemplateLine.Field, TemplateLine."Data Item Name");
        Field2Val := DataJoinBuffer.GetField(TemplateLine."Field 2", TemplateLine."Data Item Name");

        if not (Evaluate(Field1Dec, Field1Val, 9) and Evaluate(Field2Dec, Field2Val, 9)) then
            exit('');

        case TemplateLine.Operator of
            TemplateLine.Operator::"+":
                ReturnResult := Field1Dec + Field2Dec;
            TemplateLine.Operator::"-":
                ReturnResult := Field1Dec - Field2Dec;
            TemplateLine.Operator::"/":
                begin
                    if Field2Dec = 0 then
                        ReturnResult := Field1Dec
                    else
                        ReturnResult := Field1Dec / Field2Dec;
                end;
            TemplateLine.Operator::"*":
                ReturnResult := Field1Dec * Field2Dec;
        end;

        case DecimalRounding of
            DecimalRounding::"2":
                exit(Format(ReturnResult, 0, '<Precision,2:2><Standard Format,2>'));
            DecimalRounding::"3":
                exit(Format(ReturnResult, 0, '<Precision,3:3><Standard Format,2>'));
            DecimalRounding::"4":
                exit(Format(ReturnResult, 0, '<Precision,4:4><Standard Format,2>'));
            DecimalRounding::"5":
                exit(Format(ReturnResult, 0, '<Precision,5:5><Standard Format,2>'));
        end;
    end;

    local procedure PrintLine(TemplateLine: Record "NPR RP Template Line"; var DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt.")
    var
        Font: Text[30];
        AttributeManagement: Codeunit "NPR Attribute Management";
        AttributeID: Record "NPR Attribute ID";
        AttributeLookupValue: Record "NPR Attribute Lookup Value";
        RecRef: RecordRef;
        PKValue: Text[30];
        AttributeArray: array[40] of Text[100];
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        RecID: RecordID;
        Handled: Boolean;
        Skip: Boolean;
        DecimalBuffer: Decimal;
        TmplLineLbl: Label '%1%2', Locked = true;
    begin
        if TemplateLine."Template Column No." < 1 then begin
            TemplateLine."Template Column No." := 1;
        end;

        if SkipRemainingColumns then begin
            if (not TemplateLine."Prefix Next Line") then begin
                if TemplateLine."Template Column No." > SkipColumnsAboveNo then begin
                    exit;
                end else begin
                    SkipRemainingColumns := false;
                end;
            end;
        end;

        case TemplateLine.Type of
            TemplateLine.Type::Data:
                begin
                    if TemplateLine.Field > 0 then
                        if TemplateLine."Field 2" = 0 then
                            TemplateLine."Processing Value" := DataJoinBuffer.GetField(TemplateLine.Field, TemplateLine."Data Item Name")
                        else
                            TemplateLine."Processing Value" := EvaluateFields(TemplateLine, DataJoinBuffer)
                    else
                        if TemplateLine.Attribute <> '' then begin
                            AttributeID.SetRange(AttributeID."Table ID", TemplateLine."Data Item Table");
                            AttributeID.SetRange(AttributeID."Attribute Code", TemplateLine.Attribute);
                            if AttributeID.FindFirst() then begin
                                RecRef.Open(TemplateLine."Data Item Table");
                                KeyRef := RecRef.KeyIndex(RecRef.CurrentKeyIndex());
                                if KeyRef.FieldCount > 1 then
                                    Error(Error_InvalidTableAttribute, RecRef.Caption);
                                FieldRef := KeyRef.FieldIndex(1);
                                PKValue := DataJoinBuffer.GetField(FieldRef.Number, TemplateLine."Data Item Name");
                                if PKValue <> '' then begin
                                    AttributeManagement.GetMasterDataAttributeValue(AttributeArray, TemplateLine."Data Item Table", PKValue);
                                    TemplateLine."Processing Value" := AttributeArray[AttributeID."Shortcut Attribute ID"];
                                end;
                            end;
                        end;
                end;

            TemplateLine.Type::FieldCaption:
                begin
                    if TemplateLine.Field > 0 then begin
                        RecRef.Open(TemplateLine."Data Item Table");
                        FieldRef := RecRef.Field(TemplateLine.Field);
                        TemplateLine."Processing Value" := FieldRef.Caption();
                    end else
                        if TemplateLine.Attribute <> '' then begin
                            AttributeID.SetRange(AttributeID."Table ID", TemplateLine."Data Item Table");
                            AttributeID.SetRange(AttributeID."Attribute Code", TemplateLine.Attribute);
                            if AttributeID.FindFirst() then begin
                                AttributeLookupValue.SetRange("Attribute Code", AttributeID."Attribute Code");
                                AttributeLookupValue.FindFirst();
                                TemplateLine."Processing Value" := AttributeLookupValue."Attribute Value Name";
                            end;
                        end;
                end;

            else
                exit;
        end;

        if TemplateLine."Processing Codeunit" > 0 then begin
            if StrLen(TemplateLine."Data Item Name") > 0 then
                DataJoinBuffer.GetRecID(TemplateLine."Data Item Name", RecID);
            TemplateLine.OnFunction(TemplateLine."Processing Codeunit", TemplateLine."Processing Function ID", TemplateLine, RecID, Skip, Handled);
            if Skip then begin
                Clear(LineBuffer);
                exit;
            end;
            if not Handled then
                CODEUNIT.Run(TemplateLine."Processing Codeunit", TemplateLine);
        end;

        if TemplateLine."Start Char" > 0 then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", TemplateLine."Start Char");

        if TemplateLine."Blank Zero" then
            if Evaluate(DecimalBuffer, TemplateLine."Processing Value", 9) then
                if DecimalBuffer = 0 then
                    TemplateLine."Processing Value" := '';

        if StrLen(TemplateLine."Default Value") > 0 then
            if StrLen(TemplateLine."Processing Value") = 0 then
                TemplateLine."Processing Value" := TemplateLine."Default Value";

        //"Skip If Empty" overrules any buffer or columns for the same output line.
        if (StrLen(TemplateLine."Processing Value") = 0) and ((TemplateLine.Field > 0) or (TemplateLine.Attribute <> '')) then begin
            if TemplateLine."Skip If Empty" then begin
                Clear(LineBuffer);
                if (TemplateLine."Template Column No." > LastColumnNo) and (not TemplateLine."Prefix Next Line") then begin
                    TempBuffer.SetRange("Line No.", CurrentLineNo);
                    TempBuffer.DeleteAll();
                    TempBuffer.SetRange("Line No.");
                end;
                SkipColumnsAboveNo := TemplateLine."Template Column No.";
                SkipRemainingColumns := true;
            end;
            if (StrLen(LineBuffer) = 0) then begin
                Clear(LineBuffer);
                exit;
            end;
        end;

        if TemplateLine.Prefix <> '' then
            TemplateLine."Processing Value" := StrSubstNo(TmplLineLbl, TemplateLine.Prefix, TemplateLine."Processing Value");

        if TemplateLine.Postfix <> '' then
            TemplateLine."Processing Value" := StrSubstNo(TmplLineLbl, TemplateLine."Processing Value", TemplateLine.Postfix);

        if TemplateLine."Type Option" <> '' then
            Font := TemplateLine."Type Option";

        if (TemplateLine."Max Length" > 0) and TemplateLine."Prefix Next Line" then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", 1, TemplateLine."Max Length");

        if LineBuffer <> '' then begin
            TemplateLine."Processing Value" := LineBuffer + TemplateLine."Processing Value";
            Clear(LineBuffer);
        end;

        if TemplateLine."Prefix Next Line" then begin
            LineBuffer := TemplateLine."Processing Value";
            TemplateLine."Processing Value" := '';
            exit;
        end;

        if TemplateLine."Max Length" > 0 then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", 1, TemplateLine."Max Length");

        if (TemplateLine."Processing Value" <> '') or (TemplateLine."Pad Char" <> '') then begin
            SetBold(TemplateLine.Bold);
            SetPadChar(TemplateLine."Pad Char");
            SetUnderLine(TemplateLine.Underline);
            SetFont(TemplateLine."Type Option");

            UpdateField(TemplateLine."Template Column No.", TemplateLine.Align, TemplateLine.Width, TemplateLine."Type Option", TemplateLine."Processing Value");

            if TemplateLine."Pad Char" <> '' then
                NewLine();
        end;
    end;

    local procedure PadBuffer()
    var
        FieldWidth: Decimal;
        PageWidth: Integer;
    begin
        if (UpperCase(TempBuffer.Font) in ['CONTROL', 'LOGO', 'COMMAND']) or (TempBuffer.Width <> 0) then
            exit;

        LinePrinter.OnGetPageWidth(TempBuffer.Font, PageWidth);

        case GetColumnCount(TempBuffer) of
            1:
                FieldWidth := PageWidth;
            2:
                case TempBuffer."Column No." of
                    1:
                        FieldWidth := PageWidth * TwoColumnDistribution[1];
                    2:
                        FieldWidth := PageWidth * TwoColumnDistribution[2];
                end;
            3:
                case TempBuffer."Column No." of
                    1:
                        FieldWidth := PageWidth * ThreeColumnDistribution[1];
                    2:
                        FieldWidth := PageWidth * ThreeColumnDistribution[2];
                    3:
                        FieldWidth := PageWidth * ThreeColumnDistribution[3];
                end;
            4:
                case TempBuffer."Column No." of
                    1:
                        FieldWidth := PageWidth * FourColumnDistribution[1];
                    2:
                        FieldWidth := PageWidth * FourColumnDistribution[2];
                    3:
                        FieldWidth := PageWidth * FourColumnDistribution[3];
                    4:
                        FieldWidth := PageWidth * FourColumnDistribution[4];
                end;
            else
                exit;
        end;

        if TempBuffer."Pad Char" = '' then
            TempBuffer."Pad Char" := ' ';

        FieldWidth := Round(FieldWidth, 1.0, '<');

        if FieldWidth < StrLen(TempBuffer.Text) then
            TempBuffer.Text := CopyStr(TempBuffer.Text, 1, FieldWidth)
        else
            case TempBuffer.Align of
                TempBuffer.Align::Left:
                    TempBuffer.Text := PadStr(TempBuffer.Text, FieldWidth, TempBuffer."Pad Char");

                TempBuffer.Align::Center:
                    ; //Do nothing, pass align to printer interface instead

                TempBuffer.Align::Right:
                    TempBuffer.Text := PadStr('', FieldWidth - StrLen(TempBuffer.Text), TempBuffer."Pad Char") + TempBuffer.Text;
            end;
    end;

    local procedure ParseColumnDistribution(TemplateHeader: Record "NPR RP Template Header")
    begin
        if (TemplateHeader."Two Column Width 1" <> 0) or (TemplateHeader."Two Column Width 2" <> 0) then
            SetTwoColumnDistribution(TemplateHeader."Two Column Width 1", TemplateHeader."Two Column Width 2");

        if (TemplateHeader."Three Column Width 1" <> 0) or (TemplateHeader."Three Column Width 2" <> 0) or (TemplateHeader."Three Column Width 3" <> 0) then
            SetThreeColumnDistribution(TemplateHeader."Three Column Width 1", TemplateHeader."Three Column Width 2", TemplateHeader."Three Column Width 3");

        if (TemplateHeader."Four Column Width 1" <> 0) or (TemplateHeader."Four Column Width 2" <> 0) or (TemplateHeader."Four Column Width 3" <> 0) or (TemplateHeader."Four Column Width 4" <> 0) then
            SetFourColumnDistribution(TemplateHeader."Four Column Width 1", TemplateHeader."Four Column Width 2", TemplateHeader."Four Column Width 3", TemplateHeader."Four Column Width 4");
    end;

    local procedure SetDefaultDistributions()
    begin
        if TwoColumnDistribution[1] = 0 then
            TwoColumnDistribution[1] := 0.5;
        if TwoColumnDistribution[2] = 0 then
            TwoColumnDistribution[2] := 0.5;

        if ThreeColumnDistribution[1] = 0 then
            ThreeColumnDistribution[1] := 0.5;
        if ThreeColumnDistribution[2] = 0 then
            ThreeColumnDistribution[2] := 0.25;
        if ThreeColumnDistribution[3] = 0 then
            ThreeColumnDistribution[3] := 0.25;

        if FourColumnDistribution[1] = 0 then
            FourColumnDistribution[1] := 0.25;
        if FourColumnDistribution[2] = 0 then
            FourColumnDistribution[2] := 0.25;
        if FourColumnDistribution[3] = 0 then
            FourColumnDistribution[3] := 0.25;
        if FourColumnDistribution[4] = 0 then
            FourColumnDistribution[4] := 0.25;
    end;

    local procedure UpdateField(Column: Integer; Align: Integer; Width: Integer; Font: Text[30]; Text: Text[100])
    begin
        if AutoLineBreak and (LastColumnNo >= Column) then begin
            LastColumnNo := 0;
            NewLine();
        end;

        TempBuffer."Line No." := CurrentLineNo;
        TempBuffer."Column No." := Column;
        TempBuffer.Text := Text;
        if Font = '' then
            TempBuffer.Font := CurrentFont
        else
            TempBuffer.Font := Font;
        TempBuffer.Width := Width;
        TempBuffer."Pad Char" := PadChar;
        TempBuffer.Bold := CurrentBold;
        TempBuffer.Underline := CurrentUnderLine;
        TempBuffer.DoubleStrike := CurrentDoubleStrike;
        TempBuffer.Align := Align;
        if not TempBuffer.Insert() then
            TempBuffer.Modify();

        LastColumnNo := Column;

        PadChar := ' ';
    end;

    local procedure ClearState()
    begin
        //Can be deleted when this CU is no longer single instance.
        TempBuffer.DeleteAll();
        Clear(TempBuffer);
        Clear(LinePrinter);
        Clear(CurrentLineNo);
        Clear(CurrentFont);
        Clear(PadChar);
        Clear(AutoLineBreak);
        Clear(CurrentBold);
        Clear(CurrentUnderLine);
        Clear(CurrentDoubleStrike);
        Clear(LastColumnNo);
        Clear(TwoColumnDistribution);
        Clear(ThreeColumnDistribution);
        Clear(FourColumnDistribution);
        Clear(LineBuffer);
        Clear(DecimalRounding);
        //-NPR5.55 [391841]
        Clear(SkipColumnsAboveNo);
        Clear(SkipRemainingColumns);
        //+NPR5.55 [391841]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var DeviceType: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSendPrintJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Line Printer Interf."; NoOfPrints: Integer)
    begin
    end;
}

