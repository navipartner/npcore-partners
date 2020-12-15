codeunit 6151386 "NPR CS UI StockTake Handl."
{
    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
    begin
        MiniformMgmt.Initialize(
          CSUIHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSMgt: Codeunit "NPR CS Management";
        RecRef: RecordRef;
        DOMxmlin: XmlDocument;
        ReturnedNode: XmlNode;
        RootNode: XmlNode;
        CSUserId: Text[250];
        Remark: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        ActiveInputField: Integer;
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text004: Label 'Invalid %1.';
        Text005: Label 'Barcode is blank';
        Text006: Label 'No input Node found.';
        Text007: Label 'Record not found.';
        Text008: Label 'Input value Length Error';
        Text009: Label 'Shelf  No. is blank';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'Qty. is blank';
        Text012: Label 'No Lines available.';
        CSSessionId: Text;
        Text013: Label 'Input value is not valid';
        Text015: Label '%1 : %2 %3';
        Text016: Label '%1 : %2';
        Text020: Label 'Variant is not a record';
        StockTakeMgr: Codeunit "NPR Stock-Take Manager";

    local procedure ProcessInput()
    var
        FuncGroup: Record "NPR CS UI Function Group";
        RecId: RecordID;
        TextValue: Text;
        TableNo: Integer;
        FldNo: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        FuncFieldId: Integer;
        FuncName: Code[10];
        FuncValue: Text;
        CSStockTakeCounting: Record "NPR CS Stock-Take Handling";
        CSStockTakeCounting2: Record "NPR CS Stock-Take Handling";
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CommaString: DotNet NPRNetString;
        Values: DotNet NPRNetArray;
        Separator: DotNet NPRNetString;
        Value: Text;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSStockTakeCounting);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        if StrLen(TextValue) < 250 then
            FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue)
        else
            FuncGroup.KeyDef := FuncGroup.KeyDef::Input;

        ActiveInputField := 1;

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    DeleteEmptyDataLines(CSStockTakeCounting);
                    CSCommunication.RunPreviousUI(DOMxmlin);
                end;
            FuncGroup.KeyDef::"Function":
                begin
                    FuncName := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncName');
                    case FuncName of
                        'DEFAULT':
                            begin
                                FuncValue := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncValue');
                                Evaluate(FuncFieldId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));
                                if CSFieldDefaults.Get(CSUserId, CurrentCode, FuncFieldId) then begin
                                    CSFieldDefaults.Value := FuncValue;
                                    CSFieldDefaults.Modify;
                                end else begin
                                    Clear(CSFieldDefaults);
                                    CSFieldDefaults.Id := CSUserId;
                                    CSFieldDefaults."Use Case Code" := CurrentCode;
                                    CSFieldDefaults."Field No" := FuncFieldId;
                                    CSFieldDefaults.Insert;
                                    CSFieldDefaults.Value := FuncValue;
                                    CSFieldDefaults.Modify;
                                end;
                            end;
                        'DELETELINE':
                            begin
                                Evaluate(FuncTableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncTableNo'));
                                FuncRecRef.Open(FuncTableNo);
                                Evaluate(FuncRecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncRecordID'));
                                if FuncRecRef.Get(FuncRecId) then begin
                                    FuncRecRef.SetTable(CSStockTakeCounting2);
                                    CSStockTakeCounting2.Delete(true);
                                end;
                            end;
                    end;
                end;
            FuncGroup.KeyDef::Reset:
                Reset(CSStockTakeCounting);
            FuncGroup.KeyDef::Register:
                begin
                    Register(CSStockTakeCounting);
                    if Remark = '' then begin
                        DeleteEmptyDataLines(CSStockTakeCounting);
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField);
                end;
            FuncGroup.KeyDef::Input:
                begin
                    Evaluate(FldNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));

                    CommaString := TextValue;
                    Separator := ',';
                    Values := CommaString.Split(Separator.ToCharArray());

                    foreach Value in Values do begin

                        if Value <> '' then begin

                            case FldNo of
                                CSStockTakeCounting.FieldNo(Barcode):
                                    CheckBarcode(CSStockTakeCounting, Value);
                                CSStockTakeCounting.FieldNo("Shelf  No."):
                                    CheckShelfNo(CSStockTakeCounting, Value);
                                CSStockTakeCounting.FieldNo(Qty):
                                    CheckQty(CSStockTakeCounting, Value);
                                else begin
                                        CSCommunication.FieldSetvalue(RecRef, FldNo, Value);
                                    end;
                            end;

                            CSStockTakeCounting.Modify;

                            RecRef.GetTable(CSStockTakeCounting);
                            CSCommunication.SetRecRef(RecRef);
                            ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode, FldNo);
                            if Remark = '' then
                                if CSCommunication.LastEntryField(CurrentCode, FldNo) then begin

                                    Clear(CSFieldDefaults);
                                    CSFieldDefaults.SetRange(Id, CSUserId);
                                    CSFieldDefaults.SetRange("Use Case Code", CurrentCode);
                                    if CSFieldDefaults.FindSet then begin
                                        repeat
                                            CSCommunication.FieldSetvalue(RecRef, CSFieldDefaults."Field No", CSFieldDefaults.Value);
                                            RecRef.SetTable(CSStockTakeCounting);
                                            RecRef.SetRecFilter;
                                            CSCommunication.SetRecRef(RecRef);
                                        until CSFieldDefaults.Next = 0;
                                    end;

                                    UpdateDataLine(CSStockTakeCounting);
                                    CreateDataLine(CSStockTakeCounting2, CSStockTakeCounting);
                                    RecRef.GetTable(CSStockTakeCounting2);
                                    CSCommunication.SetRecRef(RecRef);

                                    Clear(CSStockTakeCounting);
                                    CSStockTakeCounting := CSStockTakeCounting2;

                                    ActiveInputField := 1;
                                end else
                                    ActiveInputField += 1;
                        end;
                    end;
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Register]) then
            SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        CSStockTakeCounting: Record "NPR CS Stock-Take Handling";
        RecId: RecordID;
        TableNo: Integer;
    begin
        RootNode.AsXmlElement().SelectSingleNode('Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Open(TableNo);
        RecRef.Get(RecId);
        RecRef.SetTable(StockTakeWorksheet);

        DeleteEmptyDataLines(CSStockTakeCounting);
        CreateDataLine(CSStockTakeCounting, StockTakeWorksheet);

        RecRef.Close;

        RecId := CSStockTakeCounting.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: XmlElement;
        RootElement: XmlElement;
        CSSetup: Record "NPR CS Setup";
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        CSSetup.Get;
        DOMxmlin.GetRoot(RootElement);
        if CSSetup."Aggregate Stock-Take Summarize" then begin
            if AddAggSummarize(Records) then
                RootElement.Add(Records);
        end else
            if AddSummarize(Records) then
                RootElement.Add(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSStockTakePlaceholder: Record "NPR CS Stock-Take Handling"; InputValue: Text)
    var
        QtyToHandle: Decimal;
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSStockTakePlaceholder.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        CSStockTakePlaceholder.Barcode := InputValue;
    end;

    local procedure CheckShelfNo(var CSStockTakePlaceholder: Record "NPR CS Stock-Take Handling"; InputValue: Text)
    var
        QtyToHandle: Decimal;
    begin
        if InputValue = '' then begin
            Remark := Text009;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSStockTakePlaceholder."Shelf  No.") then begin
            Remark := Text008;
            exit;
        end;

        CSStockTakePlaceholder."Shelf  No." := InputValue;
    end;

    local procedure CheckQty(var CSStockTakePlaceholder: Record "NPR CS Stock-Take Handling"; InputValue: Text)
    var
        Qty: Decimal;
    begin
        if InputValue = '' then begin
            Remark := Text011;
            exit;
        end;

        if not Evaluate(Qty, InputValue) then begin
            Remark := Text013;
            exit;
        end;

        CSStockTakePlaceholder.Qty := Qty;
    end;

    local procedure CreateDataLine(var CSStockTakeCounting: Record "NPR CS Stock-Take Handling"; RecordVariant: Variant)
    var
        NewCSStockTakeCounting: Record "NPR CS Stock-Take Handling";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSStockTakeCountingByVar: Record "NPR CS Stock-Take Handling";
        StockTakeWorksheetByVar: Record "NPR Stock-Take Worksheet";
        CSUIHeader: Record "NPR CS UI Header";
    begin
        if not RecordVariant.IsRecord then
            Error(Text020);

        Clear(NewCSStockTakeCounting);
        NewCSStockTakeCounting.SetRange(Id, CSSessionId);
        if NewCSStockTakeCounting.FindLast then
            LineNo := NewCSStockTakeCounting."Line No." + 1
        else
            LineNo := 1;

        CSStockTakeCounting.Init;
        CSStockTakeCounting.Id := CSSessionId;
        CSStockTakeCounting."Line No." := LineNo;
        CSStockTakeCounting."Created By" := UserId;
        CSStockTakeCounting.Created := CurrentDateTime;

        if CSUIHeader.Get(CurrentCode) then begin
            if CSUIHeader."Set defaults from last record" then begin
                CSStockTakeCounting.Qty := NewCSStockTakeCounting.Qty;
            end;
        end;

        RecRefByVariant.GetTable(RecordVariant);

        CSStockTakeCounting."Table No." := RecRefByVariant.Number;

        if RecRefByVariant.Number = 6014662 then begin
            StockTakeWorksheetByVar := RecordVariant;
            CSStockTakeCounting."Stock-Take Config Code" := StockTakeWorksheetByVar."Stock-Take Config Code";
            CSStockTakeCounting."Worksheet Name" := StockTakeWorksheetByVar.Name;
            CSStockTakeCounting."Record Id" := StockTakeWorksheetByVar.RecordId;
        end else begin
            CSStockTakeCountingByVar := RecordVariant;
            CSStockTakeCounting."Stock-Take Config Code" := CSStockTakeCountingByVar."Stock-Take Config Code";
            CSStockTakeCounting."Worksheet Name" := CSStockTakeCountingByVar."Worksheet Name";
            CSStockTakeCounting."Record Id" := CSStockTakeCountingByVar.RecordId;
        end;

        CSStockTakeCounting.Insert(true);
    end;

    local procedure UpdateDataLine(var CSStockTakeCounting: Record "NPR CS Stock-Take Handling")
    var
        LineNo: Integer;
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CSSetup: Record "NPR CS Setup";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if StrLen(CSStockTakeCounting.Barcode) > MaxStrLen(ItemCrossReference."Cross-Reference No.") then
            CSStockTakeCounting.Barcode := CopyStr(CSStockTakeCounting.Barcode, 5);

        if BarcodeLibrary.TranslateBarcodeToItemVariant(CSStockTakeCounting.Barcode, ItemNo, VariantCode, ResolvingTable, true) then begin
            CSStockTakeCounting."Item No." := ItemNo;
            CSStockTakeCounting."Variant Code" := VariantCode;
        end else begin
            CSSetup.Get;
            if CSSetup."Error On Invalid Barcode" then
                Remark := StrSubstNo(Text010, CSStockTakeCounting.Barcode);
        end;

        CSStockTakeCounting.Handled := true;
        CSStockTakeCounting.Modify(true);
    end;

    local procedure DeleteEmptyDataLines(var CurrCSStockTakeHandling: Record "NPR CS Stock-Take Handling")
    var
        CSStockTakeCounting: Record "NPR CS Stock-Take Handling";
    begin
        CSStockTakeCounting.SetRange(Id, CSSessionId);
        CSStockTakeCounting.SetRange("Stock-Take Config Code", CurrCSStockTakeHandling."Stock-Take Config Code");
        CSStockTakeCounting.SetRange("Worksheet Name", CurrCSStockTakeHandling."Worksheet Name");
        CSStockTakeCounting.SetRange(Handled, false);
        CSStockTakeCounting.SetRange("Transferred to Worksheet", false);
        CSStockTakeCounting.DeleteAll(true);
    end;

    local procedure AddAttribute(var NewChild: XmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        NewChild.AsXmlElement().SetAttribute(AttribName, AttribValue);
    end;

    local procedure AddAttribute(var NewChild: XmlElement; AttribName: Text[250]; AttribValue: Text[250])
    begin
        NewChild.SetAttribute(AttribName, AttribValue);
    end;

    local procedure AddSummarize(var Records: XmlElement): Boolean
    var
        RecordElement: XmlElement;
        Line: XmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        SummarizeCounting: Record "NPR CS Stock-Take Handling";
    begin
        SummarizeCounting.SetAscending("Line No.", false);
        SummarizeCounting.SetRange(Id, CSSessionId);
        SummarizeCounting.SetRange(Handled, true);
        SummarizeCounting.SetRange("Transferred to Worksheet", false);
        if SummarizeCounting.FindSet then begin
            Records := XmlElement.Create('Records');
            repeat
                RecordElement := XmlElement.Create('Record');

                SummarizeCounting.CalcFields("Item Description", "Variant Description");

                CurrRecordID := SummarizeCounting.RecordId;
                TableNo := CurrRecordID.TableNo;

                if SummarizeCounting."Item No." = '' then
                    Indicator := 'minus'
                else
                    Indicator := 'ok';


                if (Indicator = 'ok') then
                    Line := XmlElement.Create('Line', '',
                        StrSubstNo(Text015, SummarizeCounting.Qty, SummarizeCounting."Item No.", SummarizeCounting."Item Description"))
                else
                    Line := XmlElement.Create('Line', '', StrSubstNo(Text016, SummarizeCounting.Qty, SummarizeCounting.Barcode));
                AddAttribute(Line, 'Descrip', 'Description');
                AddAttribute(Line, 'Indicator', Indicator);
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line');
                AddAttribute(Line, 'Descrip', 'Delete..');
                AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                AddAttribute(Line, 'TableNo', Format(TableNo));
                AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                AddAttribute(Line, 'FuncName', 'DELETELINE');
                RecordElement.Add(Line);

                if (Indicator = 'ok') then begin
                    Line := XmlElement.Create('Line', '', SummarizeCounting.Barcode);
                    AddAttribute(Line, 'Descrip', SummarizeCounting.FieldCaption(Barcode));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);
                end;

                if (SummarizeCounting."Variant Code" <> '') then begin
                    Line := XmlElement.Create('Line', '', SummarizeCounting."Variant Code");
                    AddAttribute(Line, 'Descrip', SummarizeCounting.FieldCaption("Variant Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Line := XmlElement.Create('Line', '', SummarizeCounting."Variant Description");
                    AddAttribute(Line, 'Descrip', SummarizeCounting.FieldCaption("Variant Description"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);
                end;

                Records.Add(RecordElement);
            until SummarizeCounting.Next = 0;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAggSummarize(var Records: XmlElement) NotEmptyResult: Boolean
    var
        RecordElement: XmlElement;
        Line: XmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        SummarizeCounting: Query "NPR CS Stock-Take Summarize";
    begin
        Records := XmlElement.Create('Records');

        SummarizeCounting.SetRange(Id, CSSessionId);
        SummarizeCounting.SetRange(Handled, true);
        SummarizeCounting.SetRange(Transferred_to_Worksheet, false);
        SummarizeCounting.Open;
        while SummarizeCounting.Read do begin

            NotEmptyResult := true;
            RecordElement := XmlElement.Create('Record');

            if SummarizeCounting.Item_No = '' then
                Indicator := 'minus'
            else
                Indicator := 'ok';

            if (Indicator = 'ok') then
                Line := XmlElement.Create('Line', '', StrSubstNo(Text015, SummarizeCounting.Count_, SummarizeCounting.Item_No, SummarizeCounting.Item_Description))
            else
                Line := XmlElement.Create('Line', StrSubstNo(Text016, SummarizeCounting.Count_, 'Unknown Tag Id'));
            AddAttribute(Line, 'Descrip', 'Description');
            AddAttribute(Line, 'Indicator', Indicator);
            RecordElement.Add(Line);

            Line := XmlElement.Create('Line', '', SummarizeCounting.Item_No);
            AddAttribute(Line, 'Descrip', 'No.');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            Line := XmlElement.Create('Line', '', SummarizeCounting.Item_Description);
            AddAttribute(Line, 'Descrip', 'Name');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            if (SummarizeCounting.Variant_Code <> '') then begin
                Line := XmlElement.Create('Line', '', SummarizeCounting.Variant_Code + ' - ' + SummarizeCounting.Variant_Description);
                AddAttribute(Line, 'Descrip', 'Variant');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);
            end;

            Records.Add(RecordElement);
        end;
        SummarizeCounting.Close;
        exit(NotEmptyResult);
    end;

    local procedure Reset(var CurrCSStockTakeHandling: Record "NPR CS Stock-Take Handling")
    var
        CSStockTakeCounting: Record "NPR CS Stock-Take Handling";
    begin
        Clear(CSStockTakeCounting);
        CSStockTakeCounting.SetRange(Id, CSSessionId);
        CSStockTakeCounting.SetRange("Stock-Take Config Code", CurrCSStockTakeHandling."Stock-Take Config Code");
        CSStockTakeCounting.SetRange("Worksheet Name", CurrCSStockTakeHandling."Worksheet Name");
        CSStockTakeCounting.SetRange(Handled, true);
        CSStockTakeCounting.SetRange("Transferred to Worksheet", false);
        CSStockTakeCounting.DeleteAll(true);
    end;

    local procedure Register(var CurrCSStockTakeHandling: Record "NPR CS Stock-Take Handling")
    var
        CSStockTakeCounting: Record "NPR CS Stock-Take Handling";
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        OK: Boolean;
        SessionID: Integer;
    begin
        CSStockTakeCounting.SetRange(Id, CSSessionId);
        CSStockTakeCounting.SetRange("Stock-Take Config Code", CurrCSStockTakeHandling."Stock-Take Config Code");
        CSStockTakeCounting.SetRange("Worksheet Name", CurrCSStockTakeHandling."Worksheet Name");
        CSStockTakeCounting.SetRange(Handled, true);
        CSStockTakeCounting.SetRange("Transferred to Worksheet", false);
        if CSStockTakeCounting.FindSet then begin
            StockTakeWorksheet.Get(CSStockTakeCounting."Stock-Take Config Code", CSStockTakeCounting."Worksheet Name");
            StockTakeMgr.ImportPreHandler(StockTakeWorksheet);
            repeat
                if TransferDataLine(CSStockTakeCounting, StockTakeWorksheet) then begin
                    CSStockTakeCounting."Transferred to Worksheet" := true;
                    CSStockTakeCounting.Modify(true);
                end;
            until CSStockTakeCounting.Next = 0;
            StockTakeMgr.ImportPostHandler(StockTakeWorksheet);
            StockTakeWorksheet.Validate(Status, StockTakeWorksheet.Status::READY_TO_TRANSFER);
            StockTakeWorksheet.Modify(true);
            OK := StartSession(SessionID, CODEUNIT::"NPR CS UI WH Count. Handl.", CompanyName, StockTakeWorksheet);
            if not OK then
                Remark := GetLastErrorText;
        end;
    end;

    local procedure TransferDataLine(var CSStockTakeCounting: Record "NPR CS Stock-Take Handling"; StockTakeWorksheet: Record "NPR Stock-Take Worksheet"): Boolean
    var
        StockTakeWorkSheetLine: Record "NPR Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
        LineNo: Integer;
    begin
        Clear(NewStockTakeWorksheetLine);
        NewStockTakeWorksheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        NewStockTakeWorksheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
        LineNo := 0;
        if NewStockTakeWorksheetLine.FindLast then
            LineNo := NewStockTakeWorksheetLine."Line No." + 1000
        else
            LineNo := 1000;

        Clear(StockTakeWorkSheetLine);
        StockTakeWorkSheetLine."Stock-Take Config Code" := StockTakeWorksheet."Stock-Take Config Code";
        StockTakeWorkSheetLine."Worksheet Name" := StockTakeWorksheet.Name;
        StockTakeWorkSheetLine."Line No." := LineNo;
        StockTakeWorkSheetLine.Validate(Barcode, CSStockTakeCounting.Barcode);
        StockTakeWorkSheetLine."Shelf  No." := CSStockTakeCounting."Shelf  No.";
        StockTakeWorkSheetLine."Qty. (Counted)" := CSStockTakeCounting.Qty;
        StockTakeWorkSheetLine."Session Name" := CSStockTakeCounting.Id;
        StockTakeWorkSheetLine."Date of Inventory" := WorkDate;
        StockTakeWorkSheetLine.Insert(true);
        exit(true);
    end;
}
