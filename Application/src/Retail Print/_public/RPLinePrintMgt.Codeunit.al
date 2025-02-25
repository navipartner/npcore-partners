codeunit 6014549 "NPR RP Line Print Mgt."
{
#pragma warning disable AA0139
    var
        TempBuffer: Record "NPR RP Print Buffer" temporary;
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
        Error_InvalidTableAttribute: Label 'Cannot print attributes from table %1';
        LineBuffer: Text;
        DecimalRounding: Option "2","3","4","5";
        SkipColumnsAboveNo: Integer;
        SkipRemainingColumns: Boolean;

    #region Programmatic Printing, instead of user configured.        
    internal procedure AddTextField(Column: Integer; Align: Integer; Text: Text)
    begin
        UpdateField(Column, Align, 0, '', CopyStr(Text, 1, 100), false, 0);
    end;

    internal procedure AddDecimalField(Column: Integer; Align: Integer; Decimal: Decimal)
    begin
        case DecimalRounding of
            DecimalRounding::"2":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,2:2><Standard Format,2>'), false, 0);
            DecimalRounding::"3":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,3:3><Standard Format,2>'), false, 0);
            DecimalRounding::"4":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,4:4><Standard Format,2>'), false, 0);
            DecimalRounding::"5":
                UpdateField(Column, Align, 0, '', Format(Decimal, 0, '<Precision,5:5><Standard Format,2>'), false, 0);
        end;
    end;

    internal procedure AddDateField(Column: Integer; Align: Integer; Date: Date)
    begin
        UpdateField(Column, Align, 0, '', Format(Date, 0), false, 0);
    end;

    internal procedure AddBarcode(BarcodeType: Text[30]; BarcodeValue: Text; BarcodeWidth: Integer; HideHRI: Boolean; BarcodeHeight: Integer)
    begin
        UpdateField(1, 0, BarcodeWidth, BarcodeType, BarcodeValue, HideHRI, BarcodeHeight);
    end;

    internal procedure AddLine(Text: Text; Alignment: Integer)
    begin
        UpdateField(1, Alignment, 0, '', CopyStr(Text, 1, 100), false, 0);
        NewLine();
    end;

    internal procedure NewLine()
    begin
        CurrentLineNo += 1;
    end;

    internal procedure SetFont(FontName: Text[30])
    begin
        CurrentFont := FontName;
    end;

    internal procedure SetAutoLineBreak(AutoLineBreakIn: Boolean)
    begin
        AutoLineBreak := AutoLineBreakIn;
    end;

    internal procedure SetBold(Bold: Boolean)
    begin
        CurrentBold := Bold;
    end;

    internal procedure SetUnderLine(UnderLine: Boolean)
    begin
        CurrentUnderLine := UnderLine;
    end;

    internal procedure SetTwoColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal)
    begin
        TwoColumnDistribution[1] := Col1Factor;
        TwoColumnDistribution[2] := Col2Factor;
    end;

    internal procedure SetThreeColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal; Col3Factor: Decimal)
    begin
        ThreeColumnDistribution[1] := Col1Factor;
        ThreeColumnDistribution[2] := Col2Factor;
        ThreeColumnDistribution[3] := Col3Factor;
    end;

    internal procedure SetFourColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal; Col3Factor: Decimal; Col4Factor: Decimal)
    begin
        FourColumnDistribution[1] := Col1Factor;
        FourColumnDistribution[2] := Col2Factor;
        FourColumnDistribution[3] := Col3Factor;
        FourColumnDistribution[4] := Col4Factor;
    end;

    internal procedure SetDoubleStrike(DoubleStrike: Boolean)
    begin
        CurrentDoubleStrike := DoubleStrike;
    end;

    internal procedure SetPadChar(Char: Text[1])
    begin
        PadChar := Char;
    end;

    internal procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        DecimalRounding := DecimalRoundingIn;
    end;

    /// <summary>
    /// Process the buffered print job programmatically with the codeunit ID carrying the output setup.
    /// </summary>
    /// <param name="CodeunitID">Parameter is only to have an object that users can setup output config for. It can be empty.</param>
    /// <param name="PrinterDevice">Which driver to use for job generation</param>
    ///
    internal procedure ProcessBuffer(CodeunitID: Integer; PrinterDevice: Enum "NPR Line Printer Device"; var PrinterDeviceSettings: Record "NPR Printer Device Settings")
    var
        TempRPDeviceSettings: Record "NPR RP Device Settings" temporary;
    begin
        if PrinterDeviceSettings.FindSet() then
            repeat
                TempRPDeviceSettings.Init();
                TempRPDeviceSettings.Template := '';
                TempRPDeviceSettings.Name := PrinterDeviceSettings.Name;
                TempRPDeviceSettings.Value := PrinterDeviceSettings.Value;
                TempRPDeviceSettings.Insert()
            until PrinterDeviceSettings.Next() = 0;

        PrintBuffer('', CodeunitId, 0, PrinterDevice, TempRPDeviceSettings);
    end;
    #endregion

    [Obsolete('Will become internal in next version', '2023-06-28')]
    procedure ProcessTemplate("Code": Code[20]; RecordVariant: Variant)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        ProcessTemplate(Code, RecRef);
    end;

    [Obsolete('Will become internal in next version', '2023-06-28')]
    procedure ProcessTemplate("Code": Code[20]; RecRef: RecordRef)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RecRefVariant: Variant;
    begin
        RPTemplateHeader.Get(Code);
        RPTemplateHeader.TestField("Printer Type", RPTemplateHeader."Printer Type"::Line);
        RecRefVariant := RecRef;

        if RPTemplateHeader."Pre Processing Codeunit" > 0 then begin
            if not CODEUNIT.Run(RPTemplateHeader."Pre Processing Codeunit", RecRefVariant) then
                exit;
        end;

        RunPrintEngine(RPTemplateHeader, RecRef);

        if RPTemplateHeader."Post Processing Codeunit" > 0 then
            CODEUNIT.Run(RPTemplateHeader."Post Processing Codeunit", RecRefVariant);
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

    local procedure RunPrintEngine(TemplateHeader: Record "NPR RP Template Header"; RecRef: RecordRef)
    var
        DeviceSettings: Record "NPR RP Device Settings";
        DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt.";
    begin
        SetDefaultDistributions();

        SetAutoLineBreak(true);
        SetDecimalRounding(TemplateHeader."Default Decimal Rounding");

        ParseColumnDistribution(TemplateHeader);
        DataJoinBuffer.SetDecimalRounding(TemplateHeader."Default Decimal Rounding");

        if not DataJoinBuffer.ProcessDataJoin(RecRef, TemplateHeader.Code) then //Pulls data from tables and joins on the linked fields.        
            exit;

        ProcessLayout(DataJoinBuffer, TemplateHeader.Code); //Merges layout with data join buffer
        PrintBuffer(TemplateHeader.Code, CODEUNIT::"NPR RP Line Print Mgt.", 0, TemplateHeader."Line Device", DeviceSettings); //Converts generic print buffer to device specific data.
    end;

    local procedure PrintBuffer(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; LinePrinter: Interface "NPR ILine Printer"; var DeviceSettings: Record "NPR RP Device Settings")
    var
        CurrentLine: Integer;
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        OutputLogging: Codeunit "NPR RP Templ. Output Log Mgt.";
    begin
        DeviceSettings.SetRange(Template, TemplateCode);
        LinePrinter.InitJob(DeviceSettings);

        if TempBuffer.FindSet() then
            repeat
                if CurrentLine <> TempBuffer."Line No." then
                    LinePrinter.LineFeed();
                PadBuffer(LinePrinter);
                LinePrinter.PrintData(TempBuffer);
                CurrentLine := TempBuffer."Line No.";
            until TempBuffer.Next() = 0;

        LinePrinter.EndJob();

        ObjectOutputMgt.PrintLineJob(TemplateCode, CodeunitId, ReportId, LinePrinter, 1);
        OutputLogging.LogLinePrintJob(TemplateCode, CodeunitId, ReportId, LinePrinter, 1);
    end;

    internal procedure GetColumnCount(var PrintBufferIn: Record "NPR RP Print Buffer" temporary) Columns: Integer
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
                            AddLine(TemplateLine."Type Option", TemplateLine.Align);
                        end;

                    TemplateLine.Type::Command:
                        begin
                            SetFont('COMMAND');
                            AddLine(TemplateLine."Type Option", 0);
                        end;

                    TemplateLine.Type::IfDataFound:
                        begin
                            if DataJoinBuffer.FindBufferSet(TemplateLine."Data Item Name", CurrentRecNo) then begin
                                RPTemplateLineChildren.SetCurrentKey("Template Code", Level, "Parent Line No.", "Line No.");
                                RPTemplateLineChildren.SetRange("Template Code", TemplateLine."Template Code");
                                RPTemplateLineChildren.SetRange(Level, TemplateLine.Level + 1);
                                RPTemplateLineChildren.SetRange("Parent Line No.", TemplateLine."Line No.");
                                UpperBound := DataJoinBuffer.FindSubset(CurrentRecNo, UpperBoundIn);
                                MergeBuffer(RPTemplateLineChildren, DataJoinBuffer, CurrentRecNo, UpperBound);
                                DataJoinBuffer.SetBounds(LowerBoundIn, UpperBoundIn);
                            end;
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
            OnFunction(TemplateLine."Processing Codeunit", TemplateLine."Processing Function ID", TemplateLine, RecID, Skip, Handled);
            if Skip then begin
                Clear(LineBuffer);
                exit;
            end;
        end;

        if TemplateLine."Start Char" > 0 then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", TemplateLine."Start Char");

        if TemplateLine."Blank Zero" then begin
            if Evaluate(DecimalBuffer, TemplateLine."Processing Value", 9) then
                if DecimalBuffer = 0 then
                    TemplateLine."Processing Value" := '';

            if Evaluate(DecimalBuffer, TemplateLine."Processing Value") then
                if DecimalBuffer = 0 then
                    TemplateLine."Processing Value" := '';
        end;

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
            TemplateLine."Processing Value" := TemplateLine.Prefix + TemplateLine."Processing Value";

        if TemplateLine.Postfix <> '' then
            TemplateLine."Processing Value" := TemplateLine."Processing Value" + TemplateLine.Postfix;

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

            UpdateField(TemplateLine."Template Column No.", TemplateLine.Align, TemplateLine.Width, TemplateLine."Type Option", TemplateLine."Processing Value", TemplateLine."Hide HRI", TemplateLine.Height);

            if TemplateLine."Pad Char" <> '' then
                NewLine();
        end;
    end;

    local procedure PadBuffer(LinePrinter: Interface "NPR ILine Printer")
    var
        FieldWidth: Decimal;
        PageWidth: Integer;
    begin
        if (UpperCase(TempBuffer.Font) in ['LOGO', 'COMMAND']) or (TempBuffer.Width <> 0) then
            exit;

        PageWidth := LinePrinter.GetPageWidth(TempBuffer.Font);

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

    internal procedure UpdateField(Column: Integer; Align: Integer; Width: Integer; Font: Text[30]; Text: Text[2048]; HideHRI: Boolean; Height: Integer)
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
        TempBuffer.Height := Height;
        TempBuffer."Pad Char" := PadChar;
        TempBuffer.Bold := CurrentBold;
        TempBuffer.Underline := CurrentUnderLine;
        TempBuffer.DoubleStrike := CurrentDoubleStrike;
        TempBuffer.Align := Align;
        TempBuffer."Hide HRI" := HideHRI;

        if not TempBuffer.Insert() then
            TempBuffer.Modify();

        LastColumnNo := Column;

        PadChar := ' ';
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Replaced with explicit enum usage', '2023-06-28')]
    local procedure OnGetDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var DeviceType: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Replaced with interface for line printers', '2023-06-28')]
    local procedure OnSendPrintJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Line Printer Interf."; NoOfPrints: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    begin
    end;
#pragma warning restore AA0139
}

