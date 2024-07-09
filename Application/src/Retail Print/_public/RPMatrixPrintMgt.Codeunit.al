codeunit 6014547 "NPR RP Matrix Print Mgt."
{
#pragma warning disable AA0139
    var
        TempGlobalBuffer: Record "NPR RP Print Buffer" temporary;
        CurrentLineNo: Integer;
        CurrentFont: Text[30];
        CurrentBold: Boolean;
        CurrentUnderLine: Boolean;
        CurrentDoubleStrike: Boolean;
        LineBuffer: Text[2048];
        HighestRootRecNo: Integer;
        PrintIterationFieldNo: Integer;
        Error_InvalidTableAttribute: Label 'Cannot print attributes from table %1';
        DecimalRounding: Option "2","3","4","5";
        Error_BoundsCheck: Label 'Number of prints too high: %1. Split into several requests';

    #region Programmatic Printing, instead of user configured.
    internal procedure AddTextField(X: Integer; Y: Integer; Align: Integer; Text: Text)
    begin
        UpdateField(X, Y, Align, 0, 0, 0, '', CopyStr(Text, 1, 100), false);
    end;

    internal procedure AddDecimalField(X: Integer; Y: Integer; Align: Integer; Decimal: Decimal)
    begin
        case DecimalRounding of
            DecimalRounding::"2":
                UpdateField(X, Y, Align, 0, 0, 0, '', Format(Decimal, 0, '<Precision,2:2><Standard Format,2>'), false);
            DecimalRounding::"3":
                UpdateField(X, Y, Align, 0, 0, 0, '', Format(Decimal, 0, '<Precision,3:3><Standard Format,2>'), false);
            DecimalRounding::"4":
                UpdateField(X, Y, Align, 0, 0, 0, '', Format(Decimal, 0, '<Precision,4:4><Standard Format,2>'), false);
            DecimalRounding::"5":
                UpdateField(X, Y, Align, 0, 0, 0, '', Format(Decimal, 0, '<Precision,5:5><Standard Format,2>'), false);
        end;
    end;

    internal procedure AddDateField(X: Integer; Y: Integer; Align: Integer; Date: Date)
    begin
        UpdateField(X, Y, Align, 0, 0, 0, '', Format(Date, 0), false);
    end;

    internal procedure AddBarcode(BarcodeType: Text[30]; BarcodeValue: Text[30]; BarcodeWidth: Integer; Align: Integer; HideHRI: Boolean)
    begin
        UpdateField(1, 0, Align, BarcodeWidth, 0, 0, BarcodeType, BarcodeValue, HideHRI);
    end;

    internal procedure NewLine()
    begin
        CurrentLineNo += 1;
    end;

    internal procedure SetFont(FontName: Text[30])
    begin
        CurrentFont := FontName;
    end;

    internal procedure SetBold(Bold: Boolean)
    begin
        CurrentBold := Bold;
    end;

    internal procedure SetUnderLine(UnderLine: Boolean)
    begin
        CurrentUnderLine := UnderLine;
    end;

    internal procedure SetDoubleStrike(DoubleStrike: Boolean)
    begin
        CurrentDoubleStrike := DoubleStrike;
    end;

    internal procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        DecimalRounding := DecimalRoundingIn;
    end;

    /// <summary>
    /// Process the buffered print job programmatically, via a dummy codeunit that carries output setup.
    /// </summary>
    /// <param name="CodeunitID">Parameter is only to have an object that users can setup output config for. It can be empty.</param>
    /// <param name="PrinterDevice">Which driver to use for job generation</param>
    internal procedure ProcessBuffer(CodeunitID: Integer; PrinterDevice: Enum "NPR Matrix Printer Device"; var PrinterDeviceSettings: Record "NPR Printer Device Settings")
    var
        TempDeviceSettings: Record "NPR RP Device Settings" temporary;
    begin

        if PrinterDeviceSettings.FindSet() then
            repeat
                TempDeviceSettings.Init();
                TempDeviceSettings.Template := '';
                TempDeviceSettings.Name := PrinterDeviceSettings.Name;
                TempDeviceSettings.Value := PrinterDeviceSettings.Value;
                TempDeviceSettings.Insert()
            until PrinterDeviceSettings.Next() = 0;

        PrintBuffer('', CodeunitId, 0, 1, PrinterDevice, TempDeviceSettings);
    end;
    #endregion    

    procedure ProcessTemplate(Template: Code[20]; var RecRef: RecordRef)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        Variant: Variant;
        Skip: Boolean;
    begin
        RPTemplateHeader.Get(Template);
        RPTemplateHeader.TestField("Printer Type", RPTemplateHeader."Printer Type"::Matrix);

        OnBeforePrintMatrix(RecRef, RPTemplateHeader, Skip);
        if Skip then
            exit;

        Variant := RecRef;
        if RPTemplateHeader."Pre Processing Codeunit" > 0 then
            if not CODEUNIT.Run(RPTemplateHeader."Pre Processing Codeunit", Variant) then
                exit;

        RunPrintEngine(RPTemplateHeader, RecRef);

        OnAfterPrintMatrix(RecRef, RPTemplateHeader);

        if RPTemplateHeader."Post Processing Codeunit" > 0 then
            CODEUNIT.Run(RPTemplateHeader."Post Processing Codeunit", Variant);
    end;

    procedure SetPrintIterationFieldNo(FieldNo: Integer)
    begin
        PrintIterationFieldNo := FieldNo;
    end;

    local procedure ProcessLayout(DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."; DataItems: Record "NPR RP Data Items"; TemplateHeader: Record "NPR RP Template Header")
    var
        RPTemplateLine: Record "NPR RP Template Line";
        i: Integer;
        "Integer": Integer;
        Itt: Integer;
        CurrentRecNo: Integer;
        Next: Boolean;
        UpperBound: Integer;
        MatrixPrinter: Interface "NPR IMatrix Printer";
        DeviceSettings: Record "NPR RP Device Settings";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        OutputLogging: Codeunit "NPR RP Templ. Output Log Mgt.";
    begin
        DeviceSettings.SetRange(Template, TemplateHeader.Code);

        MatrixPrinter := TemplateHeader."Matrix Device";

        if not DataJoinBuffer.FindBufferSet(DataItems.Name, CurrentRecNo) then
            exit;

        repeat
            TempGlobalBuffer.DeleteAll();

            UpperBound := DataJoinBuffer.FindSubset(CurrentRecNo, 0);
            DataJoinBuffer.SetBounds(CurrentRecNo, UpperBound);

            RPTemplateLine.SetRange("Template Code", TemplateHeader.Code);
            RPTemplateLine.SetRange(Type, RPTemplateLine.Type::Data);
            RPTemplateLine.SetRange(Level, 0);
            if RPTemplateLine.FindSet() then
                repeat
                    MergeField(RPTemplateLine, DataJoinBuffer);
                until RPTemplateLine.Next() = 0;

            Itt := 1;
            if PrintIterationFieldNo > 0 then begin
                if Evaluate(Integer, DataJoinBuffer.GetField(PrintIterationFieldNo, DataItems.Name), 9) then
                    Itt := Integer;
            end;

            if Itt > 2000 then
                Error(Error_BoundsCheck, Itt);

            for i := 1 to Itt do begin
                MatrixPrinter.InitJob(DeviceSettings);
                if TempGlobalBuffer.FindSet() then
                    repeat
                        MatrixPrinter.PrintData(TempGlobalBuffer);
                    until TempGlobalBuffer.Next() = 0;
                MatrixPrinter.EndJob();
            end;

            if HighestRootRecNo > 0 then begin
                Clear(i);
                repeat
                    Next := DataJoinBuffer.NextRecord(DataItems.Name, CurrentRecNo, 0);
                    i += 1;
                until (not Next) or (i = HighestRootRecNo);
                if Next then begin
                    DataJoinBuffer.SetBounds(0, CurrentRecNo - 1);
                    DataJoinBuffer.DeleteSet();
                    DataJoinBuffer.SetBounds(0, 0);
                end;
            end else
                Next := DataJoinBuffer.NextRecord(DataItems.Name, CurrentRecNo, 0);

        until not Next;

        ObjectOutputMgt.PrintMatrixJob(TemplateHeader.Code, CODEUNIT::"NPR RP Matrix Print Mgt.", 0, MatrixPrinter, 1);
        OutputLogging.LogMatrixPrintJob(TemplateHeader.Code, CODEUNIT::"NPR RP Matrix Print Mgt.", MatrixPrinter, 1);
    end;

    local procedure RunPrintEngine(TemplateHeader: Record "NPR RP Template Header"; var RecRef: RecordRef)
    var
        DataItems: Record "NPR RP Data Items";
        DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt.";
    begin
        TempGlobalBuffer.DeleteAll();
        SetDecimalRounding(TemplateHeader."Default Decimal Rounding");

        DataItems.SetRange(Code, TemplateHeader.Code);
        DataItems.SetRange(Level, 0);
        DataItems.FindFirst();
        DataJoinBuffer.AddFieldToMap(DataItems.Name, PrintIterationFieldNo);
        DataJoinBuffer.SetDecimalRounding(TemplateHeader."Default Decimal Rounding");
        if not DataJoinBuffer.ProcessDataJoin(RecRef, TemplateHeader.Code) then
            exit;
        ProcessLayout(DataJoinBuffer, DataItems, TemplateHeader);
    end;

    local procedure PrintBuffer(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; NoOfPrints: Integer; MatrixPrinter: Interface "NPR IMatrix Printer"; var DeviceSettings: Record "NPR RP Device Settings")
    var
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        OutputLogging: Codeunit "NPR RP Templ. Output Log Mgt.";
    begin
        DeviceSettings.SetRange(Template, TemplateCode);
        MatrixPrinter.InitJob(DeviceSettings);

        if TempGlobalBuffer.FindSet() then
            repeat
                MatrixPrinter.PrintData(TempGlobalBuffer);
            until TempGlobalBuffer.Next() = 0;

        MatrixPrinter.EndJob();

        ObjectOutputMgt.PrintMatrixJob(TemplateCode, CodeunitId, ReportId, MatrixPrinter, NoOfPrints);
        OutputLogging.LogMatrixPrintJob(TemplateCode, CodeunitId, MatrixPrinter, NoOfPrints);

        TempGlobalBuffer.DeleteAll();
    end;

    local procedure EvaluateFields(var TemplateLine: Record "NPR RP Template Line"; var DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."): Text[30]
    var
        Field1Val: Text[2048];
        Field2Val: Text[2048];
        Field1Dec: Decimal;
        Field2Dec: Decimal;
        ReturnResult: Decimal;
    begin
        if TemplateLine."Root Record No." > 0 then begin
            Field1Val := DataJoinBuffer.GetFieldFromRecordRootNo(TemplateLine.Field, TemplateLine."Root Record No.", TemplateLine."Data Item Name");
            Field2Val := DataJoinBuffer.GetFieldFromRecordRootNo(TemplateLine."Field 2", TemplateLine."Root Record No.", TemplateLine."Data Item Name");
        end else
            if TemplateLine."Data Item Record No." > 0 then begin
                Field1Val := DataJoinBuffer.GetFieldFromRecordIterationNo(TemplateLine.Field, TemplateLine."Data Item Record No.", TemplateLine."Data Item Name");
                Field2Val := DataJoinBuffer.GetFieldFromRecordIterationNo(TemplateLine."Field 2", TemplateLine."Data Item Record No.", TemplateLine."Data Item Name");
            end else begin
                Field1Val := DataJoinBuffer.GetField(TemplateLine.Field, TemplateLine."Data Item Name");
                Field2Val := DataJoinBuffer.GetField(TemplateLine."Field 2", TemplateLine."Data Item Name");
            end;

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

    local procedure MergeField(var TemplateLine: Record "NPR RP Template Line"; var DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt.")
    var
        RecID: RecordID;
        Handled: Boolean;
        Skip: Boolean;
        DecimalBuffer: Decimal;
        TmplLineLbl: Label '%1%2', Locked = true;
    begin
        if TemplateLine."Root Record No." > HighestRootRecNo then
            HighestRootRecNo := TemplateLine."Root Record No.";

        case true of
            TemplateLine.Field > 0:
                TemplateLine."Processing Value" := GetFieldValue(TemplateLine, DataJoinBuffer);
            TemplateLine.Attribute <> '':
                TemplateLine."Processing Value" := GetAttributeValue(TemplateLine, DataJoinBuffer);
        end;

        if TemplateLine."Processing Codeunit" > 0 then begin
            if TemplateLine."Data Item Name" <> '' then
                GetRecID(TemplateLine, DataJoinBuffer, RecID);

            OnFunction(TemplateLine."Processing Codeunit", TemplateLine."Processing Function ID", TemplateLine, RecID, Skip, Handled);
            if Skip then begin
                Clear(LineBuffer);
                exit;
            end;
        end;

        if TemplateLine."Start Char" > 0 then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", TemplateLine."Start Char");

        if TemplateLine."Blank Zero" then
            if Evaluate(DecimalBuffer, TemplateLine."Processing Value", 9) then
                if DecimalBuffer = 0 then
                    TemplateLine."Processing Value" := '';

        if TemplateLine."Default Value" <> '' then
            if TemplateLine."Processing Value" = '' then
                if TemplateLine."Default Value Record Required" then begin
                    if RecID.TableNo = 0 then //If not retrieved earlier
                        GetRecID(TemplateLine, DataJoinBuffer, RecID);
                    if RecID.TableNo <> 0 then
                        TemplateLine."Processing Value" := TemplateLine."Default Value";
                end else
                    TemplateLine."Processing Value" := TemplateLine."Default Value";

        //"Skip If Empty" overrules any buffer from previous lines
        if (StrLen(TemplateLine."Processing Value") = 0) and ((TemplateLine.Field > 0) or (TemplateLine.Attribute <> '')) then
            if (StrLen(LineBuffer) = 0) or TemplateLine."Skip If Empty" then begin
                Clear(LineBuffer);
                exit;
            end;

        if TemplateLine.Prefix <> '' then
            TemplateLine."Processing Value" := StrSubstNo(TmplLineLbl, TemplateLine.Prefix, TemplateLine."Processing Value");

        if TemplateLine.Postfix <> '' then
            TemplateLine."Processing Value" := StrSubstNo(TmplLineLbl, TemplateLine."Processing Value", TemplateLine.Postfix);

        if (TemplateLine."Max Length" > 0) and TemplateLine."Prefix Next Line" then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", 1, TemplateLine."Max Length");

        if LineBuffer <> '' then begin
            TemplateLine."Processing Value" := LineBuffer + TemplateLine."Processing Value";
            LineBuffer := '';
        end;

        if TemplateLine."Prefix Next Line" then begin
            LineBuffer := TemplateLine."Processing Value";
            TemplateLine."Processing Value" := '';
            exit;
        end;

        if TemplateLine."Max Length" > 0 then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", 1, TemplateLine."Max Length");

        UpdateField(TemplateLine.X,
                    TemplateLine.Y,
                    TemplateLine.Align,
                    TemplateLine.Width,
                    TemplateLine.Rotation,
                    TemplateLine.Height,
                    TemplateLine."Type Option",
                    TemplateLine."Processing Value",
                    TemplateLine."Hide HRI");
    end;

    local procedure UpdateField(X: Integer; Y: Integer; Align: Integer; Width: Integer; Rotation: Integer; Height: Integer; Font: Text[30]; Text: Text[2048]; HideHRI: Boolean)
    begin
        TempGlobalBuffer."Line No." := CurrentLineNo;
        TempGlobalBuffer.Text := Text;

        if Font = '' then
            TempGlobalBuffer.Font := CurrentFont
        else
            TempGlobalBuffer.Font := Font;

        TempGlobalBuffer.Width := Width;
        TempGlobalBuffer.X := X;
        TempGlobalBuffer.Y := Y;
        TempGlobalBuffer.Height := Height;
        TempGlobalBuffer.Bold := CurrentBold;
        TempGlobalBuffer.Underline := CurrentUnderLine;
        TempGlobalBuffer.DoubleStrike := CurrentDoubleStrike;
        TempGlobalBuffer.Rotation := Rotation;
        TempGlobalBuffer.Align := Align;
        TempGlobalBuffer."Hide HRI" := HideHRI;

        if not TempGlobalBuffer.Insert() then
            TempGlobalBuffer.Modify();

        CurrentLineNo += 1;
    end;

    local procedure GetFieldValue(TemplateLine: Record "NPR RP Template Line"; DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."): Text
    begin
        if TemplateLine."Field 2" = 0 then
            if TemplateLine."Root Record No." > 0 then
                exit(DataJoinBuffer.GetFieldFromRecordRootNo(TemplateLine.Field, TemplateLine."Root Record No.", TemplateLine."Data Item Name"))
            else
                if TemplateLine."Data Item Record No." > 0 then
                    exit(DataJoinBuffer.GetFieldFromRecordIterationNo(TemplateLine.Field, TemplateLine."Data Item Record No.", TemplateLine."Data Item Name"))
                else
                    exit(DataJoinBuffer.GetField(TemplateLine.Field, TemplateLine."Data Item Name"))
        else
            exit(EvaluateFields(TemplateLine, DataJoinBuffer));
    end;

    local procedure GetRecID(TemplateLine: Record "NPR RP Template Line"; DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."; var RecordID: RecordID)
    begin
        if TemplateLine."Root Record No." > 0 then
            DataJoinBuffer.GetRecIDFromRecordRootNo(TemplateLine."Root Record No.", TemplateLine."Data Item Name", RecordID)
        else
            if TemplateLine."Data Item Record No." > 0 then
                DataJoinBuffer.GetRecIDFromRecordIterationNo(TemplateLine."Data Item Record No.", TemplateLine."Data Item Name", RecordID)
            else
                DataJoinBuffer.GetRecID(TemplateLine."Data Item Name", RecordID);
    end;

    local procedure GetAttributeValue(TemplateLine: Record "NPR RP Template Line"; DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."): Text
    var
        AttributeManagement: Codeunit "NPR Attribute Management";
        AttributeID: Record "NPR Attribute ID";
        PKValue: Text[30];
        AttributeArray: array[40] of Text[100];
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
    begin
        AttributeID.SetRange(AttributeID."Table ID", TemplateLine."Data Item Table");
        AttributeID.SetRange(AttributeID."Attribute Code", TemplateLine.Attribute);
        if not AttributeID.FindSet() then
            exit('');

        RecRef.Open(TemplateLine."Data Item Table");
        KeyRef := RecRef.KeyIndex(RecRef.CurrentKeyIndex());
        if KeyRef.FieldCount > 1 then
            Error(Error_InvalidTableAttribute, RecRef.Caption);
        FieldRef := KeyRef.FieldIndex(1);
        PKValue := DataJoinBuffer.GetField(FieldRef.Number, TemplateLine."Data Item Name");
        if PKValue <> '' then begin
            AttributeManagement.GetMasterDataAttributeValue(AttributeArray, TemplateLine."Data Item Table", PKValue);
            exit(AttributeArray[AttributeID."Shortcut Attribute ID"]);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintMatrix(var RecRef: RecordRef; TemplateHeader: Record "NPR RP Template Header"; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrintMatrix(var RecRef: RecordRef; TemplateHeader: Record "NPR RP Template Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Replaced with explicit enum usage', '2023-06-28')]
    local procedure OnGetDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var DeviceType: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Replaced with interface for matrix printers', '2023-06-28')]
    local procedure OnSendPrintJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Matrix Printer Interf."; NoOfPrints: Integer)
    begin
    end;
#pragma warning restore AA0139
}

