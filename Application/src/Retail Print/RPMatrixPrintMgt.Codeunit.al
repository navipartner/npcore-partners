codeunit 6014547 "NPR RP Matrix Print Mgt."
{
    // Matrix Print Mgt.
    //  Work started by Nicolai Esbensen.
    // 
    //  Provides functionality for building and formatting
    //  a matrix based print buffer.
    // 
    //  Exposes methods for printing the formatted buffer, using the
    //  "Matrix Printer Interface".
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
    //  "SetBold(Bold : Boolean)"
    //   Request a bold print until disabled.
    // 
    //  "SetUnderLine(UnderLine : Boolean)"
    //   Request a undelined print until disabled.
    // 
    //  "SetDoubleStrike(DoubleStrike : Boolean)"
    //   Request a double-striked print until disabled.
    // 
    // -----------------------------------------------------------------------------
    // 
    // This object can either be used directly programmatically via the AddX and ProcessBufferForCodeunit()/ProcessBufferForReport() functions or via template setup.
    // The latter is recommended.
    // 
    // 
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0
    // NPR5.32/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.33/MMV /20170608 CASE 279696 Skip attribute print when blank.
    // NPR5.41/MMV /20180416 CASE 311633 Added support for more than 2 decimals.
    // NPR5.44/MMV /20180706 CASE 315362 Cleanup and refactoring.
    // NPR5.46/MMV /20180911 CASE 314067 Added support for only printing default value when data is found.
    // NPR5.48/MMV /20181205 CASE 327107 Added new event publishers.
    // NPR5.50/MMV /20190510 CASE 354821 Iterate buffer without upperbound to support several root data elements.
    // NPR5.51/MMV /20190627 CASE 359771 Rolled back 354821 change.
    // NPR5.51/MMV /20190801 CASE 360975 Buffer all template print data into one job.


    trigger OnRun()
    begin
    end;

    var
        GlobalBuffer: Record "NPR RP Print Buffer" temporary;
        CurrentLineNo: Integer;
        CurrentFont: Text[30];
        CurrentBold: Boolean;
        CurrentUnderLine: Boolean;
        CurrentDoubleStrike: Boolean;
        LineBuffer: Text[1024];
        HighestRootRecNo: Integer;
        PrintIterationFieldNo: Integer;
        Error_MissingDevice: Label 'Missing printer device type for: (template %1, codeunit %2, report %3)';
        Error_InvalidTableAttribute: Label 'Cannot print attributes from table %1';
        DecimalRounding: Option "2","3","4","5";
        Error_BoundsCheck: Label 'Number of prints too high: %1. Split into several requests';

    procedure AddTextField(X: Integer; Y: Integer; Align: Integer; Text: Text)
    begin
        UpdateField(X, Y, 0, Align, 0, 0, '', CopyStr(Text, 1, 100));
    end;

    procedure AddDecimalField(X: Integer; Y: Integer; Align: Integer; Decimal: Decimal)
    begin
        case DecimalRounding of
            DecimalRounding::"2":
                UpdateField(X, Y, 0, Align, 0, 0, '', Format(Decimal, 0, '<Precision,2:2><Standard Format,2>'));
            DecimalRounding::"3":
                UpdateField(X, Y, 0, Align, 0, 0, '', Format(Decimal, 0, '<Precision,3:3><Standard Format,2>'));
            DecimalRounding::"4":
                UpdateField(X, Y, 0, Align, 0, 0, '', Format(Decimal, 0, '<Precision,4:4><Standard Format,2>'));
            DecimalRounding::"5":
                UpdateField(X, Y, 0, Align, 0, 0, '', Format(Decimal, 0, '<Precision,5:5><Standard Format,2>'));
        end;
    end;

    procedure AddDateField(X: Integer; Y: Integer; Align: Integer; Date: Date)
    begin
        UpdateField(X, Y, 0, Align, 0, 0, '', Format(Date, 0));
    end;

    procedure AddBarcode(BarcodeType: Text[30]; BarcodeValue: Text[30]; BarcodeWidth: Integer; Align: Integer)
    begin
        UpdateField(1, 0, BarcodeWidth, Align, 0, 0, BarcodeType, BarcodeValue);
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

    procedure SetBold(Bold: Boolean)
    begin
        CurrentBold := Bold;
    end;

    procedure SetUnderLine(UnderLine: Boolean)
    begin
        CurrentUnderLine := UnderLine;
    end;

    procedure SetDoubleStrike(DoubleStrike: Boolean)
    begin
        CurrentDoubleStrike := DoubleStrike;
    end;

    procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        DecimalRounding := DecimalRoundingIn;
    end;

    procedure "// Global Print Functions"()
    begin
    end;

    procedure ProcessTemplate(Template: Code[20]; var RecRef: RecordRef)
    var
        TemplateHeader: Record "NPR RP Template Header";
        Variant: Variant;
        Skip: Boolean;
    begin
        // For printing via template setup

        TemplateHeader.Get(Template);
        TemplateHeader.TestField("Printer Type", TemplateHeader."Printer Type"::Matrix);

        //-NPR5.48 [327107]
        OnBeforePrintMatrix(RecRef, TemplateHeader, Skip);
        if Skip then
            exit;
        //+NPR5.48 [327107]

        Variant := RecRef;
        if TemplateHeader."Pre Processing Codeunit" > 0 then
            if not CODEUNIT.Run(TemplateHeader."Pre Processing Codeunit", Variant) then
                exit;

        if TemplateHeader."Print Processing Object ID" = 0 then
            RunPrintEngine(TemplateHeader, RecRef)
        else
            case TemplateHeader."Print Processing Object Type" of
                TemplateHeader."Print Processing Object Type"::Codeunit:
                    CODEUNIT.Run(TemplateHeader."Print Processing Object ID", Variant);
                TemplateHeader."Print Processing Object Type"::Report:
                    REPORT.Run(TemplateHeader."Print Processing Object ID", GuiAllowed, false, Variant);
            end;

        //-NPR5.48 [327107]
        OnAfterPrintMatrix(RecRef, TemplateHeader);
        //+NPR5.48 [327107]

        if TemplateHeader."Post Processing Codeunit" > 0 then
            CODEUNIT.Run(TemplateHeader."Post Processing Codeunit", Variant);
    end;

    procedure ProcessBufferForCodeunit(CodeunitID: Integer; NoOfPrints: Integer)
    begin
        PrintBuffer('', CodeunitID, 0, NoOfPrints);
        GlobalBuffer.DeleteAll();
    end;

    procedure ProcessBufferForReport(ReportID: Integer; NoOfPrints: Integer)
    begin
        PrintBuffer('', 0, ReportID, NoOfPrints);
        GlobalBuffer.DeleteAll();
    end;

    procedure SetPrintIterationFieldNo(FieldNo: Integer)
    begin
        PrintIterationFieldNo := FieldNo;
    end;

    local procedure "// Locals"()
    begin
    end;

    local procedure GetDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer): Text
    var
        DeviceType: Text;
        TemplateHeader: Record "NPR RP Template Header";
    begin
        if TemplateCode <> '' then begin
            TemplateHeader.Get(TemplateCode);
            if TemplateHeader."Printer Device" <> '' then
                exit(TemplateHeader."Printer Device");
        end;

        OnGetDeviceType(TemplateCode, CodeunitId, ReportId, DeviceType);
        if DeviceType = '' then
            Error(Error_MissingDevice, TemplateHeader.Code, CodeunitId, ReportId);

        exit(DeviceType);
    end;

    local procedure ProcessLayout(DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."; DataItems: Record "NPR RP Data Items"; TemplateHeader: Record "NPR RP Template Header")
    var
        TemplateLine: Record "NPR RP Template Line";
        i: Integer;
        "Integer": Integer;
        Itt: Integer;
        CurrentRecNo: Integer;
        Next: Boolean;
        UpperBound: Integer;
        MatrixPrinter: Codeunit "NPR RP Matrix Printer Interf.";
        DeviceType: Text;
        DeviceSettings: Record "NPR RP Device Settings";
    begin
        //-NPR5.51 [360975]
        DeviceType := GetDeviceType(TemplateHeader.Code, CODEUNIT::"NPR RP Matrix Print Mgt.", 0);
        DeviceSettings.SetRange(Template, TemplateHeader.Code);

        MatrixPrinter.Construct(DeviceType);
        //+NPR5.51 [360975]

        if not DataJoinBuffer.FindBufferSet(DataItems.Name, CurrentRecNo) then
            exit;

        repeat
            GlobalBuffer.DeleteAll();

            //-NPR5.51 [359771]
            UpperBound := DataJoinBuffer.FindSubset(CurrentRecNo, 0);
            DataJoinBuffer.SetBounds(CurrentRecNo, UpperBound);
            //    DataJoinBuffer.FindSubset(CurrentRecNo, 0);
            //+NPR5.51 [359771]

            TemplateLine.SetRange("Template Code", TemplateHeader.Code);
            TemplateLine.SetRange(Type, TemplateLine.Type::Data);
            TemplateLine.SetRange(Level, 0);
            if TemplateLine.FindSet() then
                repeat
                    MergeField(TemplateLine, DataJoinBuffer);
                until TemplateLine.Next() = 0;

            Itt := 1;
            if PrintIterationFieldNo > 0 then begin
                if Evaluate(Integer, DataJoinBuffer.GetField(PrintIterationFieldNo, DataItems.Name), 9) then
                    Itt := Integer;
            end;

            //-NPR5.51 [360975]
            //    IF Itt > 0 THEN
            //      PrintBuffer(TemplateHeader.Code, CODEUNIT::"RP Matrix Print Mgt.", 0, Itt);
            if Itt > 2000 then
                Error(Error_BoundsCheck, Itt);

            for i := 1 to Itt do begin
                MatrixPrinter.OnInitJob(DeviceSettings);
                if GlobalBuffer.FindSet() then
                    repeat
                        MatrixPrinter.OnPrintData(GlobalBuffer);
                    until GlobalBuffer.Next() = 0;
                MatrixPrinter.OnEndJob();
            end;
            //+NPR5.51 [360975]

            if HighestRootRecNo > 0 then begin
                //Delete the roots we passed over in the join buffer.
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

        //-NPR5.51 [360975]
        OnSendPrintJob(TemplateHeader.Code, CODEUNIT::"NPR RP Matrix Print Mgt.", 0, MatrixPrinter, 1);
        MatrixPrinter.Dispose();
        //+NPR5.51 [360975]
    end;

    local procedure RunPrintEngine(TemplateHeader: Record "NPR RP Template Header"; var RecRef: RecordRef)
    var
        DataItems: Record "NPR RP Data Items";
        DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt.";
    begin
        GlobalBuffer.DeleteAll();
        SetDecimalRounding(TemplateHeader."Default Decimal Rounding");

        DataItems.SetRange(Code, TemplateHeader.Code);
        DataItems.SetRange(Level, 0);
        DataItems.FindFirst();
        DataJoinBuffer.AddFieldToMap(DataItems.Name, PrintIterationFieldNo);
        DataJoinBuffer.SetDecimalRounding(TemplateHeader."Default Decimal Rounding");
        DataJoinBuffer.ProcessDataJoin(RecRef, TemplateHeader.Code);
        ProcessLayout(DataJoinBuffer, DataItems, TemplateHeader);
    end;

    local procedure PrintBuffer(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; NoOfPrints: Integer)
    var
        MatrixPrinter: Codeunit "NPR RP Matrix Printer Interf.";
        DeviceType: Text;
        DeviceSettings: Record "NPR RP Device Settings";
    begin
        DeviceType := GetDeviceType(TemplateCode, CodeunitId, ReportId);
        DeviceSettings.SetRange(Template, TemplateCode);

        MatrixPrinter.Construct(DeviceType);
        MatrixPrinter.OnInitJob(DeviceSettings);

        if GlobalBuffer.FindSet() then
            repeat
                MatrixPrinter.OnPrintData(GlobalBuffer);
            until GlobalBuffer.Next() = 0;

        MatrixPrinter.OnEndJob();
        OnSendPrintJob(TemplateCode, CodeunitId, ReportId, MatrixPrinter, NoOfPrints);
        MatrixPrinter.Dispose();
    end;

    local procedure EvaluateFields(var TemplateLine: Record "NPR RP Template Line"; var DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."): Text[30]
    var
        Field1Val: Text[250];
        Field2Val: Text[250];
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

            TemplateLine.OnFunction(TemplateLine."Processing Codeunit", TemplateLine."Processing Function ID", TemplateLine, RecID, Skip, Handled);
            if Skip then begin
                Clear(LineBuffer);
                exit;
            end;
            if not Handled then //Legacy
                CODEUNIT.Run(TemplateLine."Processing Codeunit", TemplateLine);
        end;

        if TemplateLine."Start Char" > 0 then
            TemplateLine."Processing Value" := CopyStr(TemplateLine."Processing Value", TemplateLine."Start Char");

        if TemplateLine."Blank Zero" then
            if Evaluate(DecimalBuffer, TemplateLine."Processing Value", 9) then
                if DecimalBuffer = 0 then
                    TemplateLine."Processing Value" := '';

        if TemplateLine."Default Value" <> '' then
            if TemplateLine."Processing Value" = '' then
                //-NPR5.46 [314067]
                //    TemplateLine."Processing Value" := TemplateLine."Default Value";
                if TemplateLine."Default Value Record Required" then begin
                    if RecID.TableNo = 0 then //If not retrieved earlier
                        GetRecID(TemplateLine, DataJoinBuffer, RecID);
                    if RecID.TableNo <> 0 then
                        TemplateLine."Processing Value" := TemplateLine."Default Value";
                end else
                    TemplateLine."Processing Value" := TemplateLine."Default Value";
        //+NPR5.46 [314067]

        //"Skip If Empty" overrules any buffer from previous lines
        if (StrLen(TemplateLine."Processing Value") = 0) and ((TemplateLine.Field > 0) or (TemplateLine.Attribute <> '')) then
            if (StrLen(LineBuffer) = 0) or TemplateLine."Skip If Empty" then begin
                Clear(LineBuffer);
                exit;
            end;

        if TemplateLine.Prefix <> '' then
            TemplateLine."Processing Value" := StrSubstNo('%1%2', TemplateLine.Prefix, TemplateLine."Processing Value");

        if TemplateLine.Postfix <> '' then
            TemplateLine."Processing Value" := StrSubstNo('%1%2', TemplateLine."Processing Value", TemplateLine.Postfix);

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
                    TemplateLine."Processing Value");
    end;

    local procedure UpdateField(X: Integer; Y: Integer; Align: Integer; Width: Integer; Rotation: Integer; Height: Integer; Font: Text[30]; Text: Text[100])
    begin
        GlobalBuffer."Line No." := CurrentLineNo;
        GlobalBuffer.Text := Text;

        if Font = '' then
            GlobalBuffer.Font := CurrentFont
        else
            GlobalBuffer.Font := Font;

        GlobalBuffer.Width := Width;
        GlobalBuffer.X := X;
        GlobalBuffer.Y := Y;
        GlobalBuffer.Height := Height;
        GlobalBuffer.Bold := CurrentBold;
        GlobalBuffer.Underline := CurrentUnderLine;
        GlobalBuffer.DoubleStrike := CurrentDoubleStrike;
        GlobalBuffer.Rotation := Rotation;
        GlobalBuffer.Align := Align;

        if not GlobalBuffer.Insert() then
            GlobalBuffer.Modify();

        CurrentLineNo += 1;
    end;

    local procedure GetFieldValue(TemplateLine: Record "NPR RP Template Line"; DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."): Text
    begin
        //-NPR5.46 [314067]
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
        //+NPR5.46 [314067]
    end;

    local procedure GetRecID(TemplateLine: Record "NPR RP Template Line"; DataJoinBuffer: Codeunit "NPR RP Data Join Buffer Mgt."; var RecordID: RecordID)
    begin
        //-NPR5.46 [314067]
        if TemplateLine."Root Record No." > 0 then
            DataJoinBuffer.GetRecIDFromRecordRootNo(TemplateLine."Root Record No.", TemplateLine."Data Item Name", RecordID)
        else
            if TemplateLine."Data Item Record No." > 0 then
                DataJoinBuffer.GetRecIDFromRecordIterationNo(TemplateLine."Data Item Record No.", TemplateLine."Data Item Name", RecordID)
            else
                DataJoinBuffer.GetRecID(TemplateLine."Data Item Name", RecordID);
        //+NPR5.46 [314067]
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
        //-NPR5.46 [314067]
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
        //+NPR5.46 [314067]
    end;

    local procedure "// Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var DeviceType: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSendPrintJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Matrix Printer Interf."; NoOfPrints: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintMatrix(var RecRef: RecordRef; TemplateHeader: Record "NPR RP Template Header"; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrintMatrix(var RecRef: RecordRef; TemplateHeader: Record "NPR RP Template Header")
    begin
    end;
}

