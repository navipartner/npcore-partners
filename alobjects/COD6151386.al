codeunit 6151386 "CS UI Stock-Take Handling"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/CLVA/20180511 CASE 307239 Added show/hide invalid barcode alert on device
    // NPR5.43/CLVA/20180604 CASE 304872 Added previous value to qty
    // NPR5.44/CLVA/20180719 CASE 315503 Added functionality to support defaults from last record
    // NPR5.47/CLVA/20181026 CASE 307282 Added support for Rfid tags
    // NPR5.48/CLVA/20181109 CASE 335606 Handling data transfer
    // NPR5.51/CLVA/20190625 CASE 359375 Added Stock-Take transfer handling

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          CSUIHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, XMLDOMMgt, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSMgt: Codeunit "CS Management";
        RecRef: RecordRef;
        DOMxmlin: DotNet npNetXmlDocument;
        ReturnedNode: DotNet npNetXmlNode;
        RootNode: DotNet npNetXmlNode;
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
        StockTakeMgr: Codeunit "Stock-Take Manager";

    local procedure ProcessInput()
    var
        FuncGroup: Record "CS UI Function Group";
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
        CSStockTakeCounting: Record "CS Stock-Take Handling";
        CSStockTakeCounting2: Record "CS Stock-Take Handling";
        CSFieldDefaults: Record "CS Field Defaults";
        CommaString: DotNet npNetString;
        Values: DotNet npNetArray;
        Separator: DotNet npNetString;
        Value: Text;
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
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

        //-NPR5.47 [307282]
        //FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code,TextValue);
        if StrLen(TextValue) < 250 then
            FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue)
        else
            FuncGroup.KeyDef := FuncGroup.KeyDef::Input;
        //+NPR5.47 [307282]

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
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        CSStockTakeCounting: Record "CS Stock-Take Handling";
        RecId: RecordID;
        TableNo: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode);

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
        Records: DotNet npNetXmlElement;
        CSSetup: Record "CS Setup";
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        CSSetup.Get;
        if CSSetup."Aggregate Stock-Take Summarize" then begin
            if AddAggSummarize(Records) then
                DOMxmlin.DocumentElement.AppendChild(Records);
        end else
            if AddSummarize(Records) then
                DOMxmlin.DocumentElement.AppendChild(Records);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSStockTakePlaceholder: Record "CS Stock-Take Handling"; InputValue: Text)
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

    local procedure CheckShelfNo(var CSStockTakePlaceholder: Record "CS Stock-Take Handling"; InputValue: Text)
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

    local procedure CheckQty(var CSStockTakePlaceholder: Record "CS Stock-Take Handling"; InputValue: Text)
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

    local procedure CreateDataLine(var CSStockTakeCounting: Record "CS Stock-Take Handling"; RecordVariant: Variant)
    var
        NewCSStockTakeCounting: Record "CS Stock-Take Handling";
        LineNo: Integer;
        RecRefByVariant: RecordRef;
        CSStockTakeCountingByVar: Record "CS Stock-Take Handling";
        StockTakeWorksheetByVar: Record "Stock-Take Worksheet";
        CSUIHeader: Record "CS UI Header";
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

        //-NPR5.44 [315503]
        if CSUIHeader.Get(CurrentCode) then begin
            if CSUIHeader."Set defaults from last record" then begin
                //+NPR5.44 [315503]
                //-NPR5.43 [304872]
                CSStockTakeCounting.Qty := NewCSStockTakeCounting.Qty;
                //+NPR5.43 [304872]
                //-NPR5.44 [315503]
            end;
        end;
        //+NPR5.44 [315503]

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

    local procedure UpdateDataLine(var CSStockTakeCounting: Record "CS Stock-Take Handling")
    var
        LineNo: Integer;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        CSFieldDefaults: Record "CS Field Defaults";
        CSSetup: Record "CS Setup";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if StrLen(CSStockTakeCounting.Barcode) > MaxStrLen(ItemCrossReference."Cross-Reference No.") then
            CSStockTakeCounting.Barcode := CopyStr(CSStockTakeCounting.Barcode, 5);

        if BarcodeLibrary.TranslateBarcodeToItemVariant(CSStockTakeCounting.Barcode, ItemNo, VariantCode, ResolvingTable, true) then begin
            CSStockTakeCounting."Item No." := ItemNo;
            CSStockTakeCounting."Variant Code" := VariantCode;
        end else begin
            //-NPR5.43
            CSSetup.Get;
            if CSSetup."Error On Invalid Barcode" then
                //+NPR5.43
                Remark := StrSubstNo(Text010, CSStockTakeCounting.Barcode);
        end;

        CSStockTakeCounting.Handled := true;
        CSStockTakeCounting.Modify(true);
    end;

    local procedure DeleteEmptyDataLines(var CurrCSStockTakeHandling: Record "CS Stock-Take Handling")
    var
        CSStockTakeCounting: Record "CS Stock-Take Handling";
    begin
        CSStockTakeCounting.SetRange(Id, CSSessionId);
        CSStockTakeCounting.SetRange("Stock-Take Config Code", CurrCSStockTakeHandling."Stock-Take Config Code");
        CSStockTakeCounting.SetRange("Worksheet Name", CurrCSStockTakeHandling."Worksheet Name");
        CSStockTakeCounting.SetRange(Handled, false);
        CSStockTakeCounting.SetRange("Transferred to Worksheet", false);
        CSStockTakeCounting.DeleteAll(true);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild, AttribName, AttribValue) > 0 then
            Error(Text002, AttribName);
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement): Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        SummarizeCounting: Record "CS Stock-Take Handling";
    begin
        SummarizeCounting.SetAscending("Line No.", false);
        SummarizeCounting.SetRange(Id, CSSessionId);
        SummarizeCounting.SetRange(Handled, true);
        SummarizeCounting.SetRange("Transferred to Worksheet", false);
        if SummarizeCounting.FindSet then begin
            Records := DOMxmlin.CreateElement('Records');
            repeat
                Record := DOMxmlin.CreateElement('Record');

                SummarizeCounting.CalcFields("Item Description", "Variant Description");

                CurrRecordID := SummarizeCounting.RecordId;
                TableNo := CurrRecordID.TableNo;

                if SummarizeCounting."Item No." = '' then
                    Indicator := 'minus'
                else
                    Indicator := 'ok';

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'Description');
                AddAttribute(Line, 'Indicator', Indicator);
                if (Indicator = 'ok') then
                    Line.InnerText := StrSubstNo(Text015, SummarizeCounting.Qty, SummarizeCounting."Item No.", SummarizeCounting."Item Description")
                else
                    Line.InnerText := StrSubstNo(Text016, SummarizeCounting.Qty, SummarizeCounting.Barcode);
                Record.AppendChild(Line);

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'Delete..');
                AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                AddAttribute(Line, 'TableNo', Format(TableNo));
                AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                AddAttribute(Line, 'FuncName', 'DELETELINE');
                Record.AppendChild(Line);

                if (Indicator = 'ok') then begin
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', SummarizeCounting.FieldCaption(Barcode));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := SummarizeCounting.Barcode;
                    Record.AppendChild(Line);
                end;

                if (SummarizeCounting."Variant Code" <> '') then begin
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', SummarizeCounting.FieldCaption("Variant Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := SummarizeCounting."Variant Code";
                    Record.AppendChild(Line);

                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', SummarizeCounting.FieldCaption("Variant Description"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := SummarizeCounting."Variant Description";
                    Record.AppendChild(Line);
                end;

                Records.AppendChild(Record);
            until SummarizeCounting.Next = 0;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAggSummarize(var Records: DotNet npNetXmlElement) NotEmptyResult: Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        SummarizeCounting: Query "CS Stock-Take Summarize";
    begin
        Records := DOMxmlin.CreateElement('Records');

        SummarizeCounting.SetRange(Id, CSSessionId);
        SummarizeCounting.SetRange(Handled, true);
        SummarizeCounting.SetRange(Transferred_to_Worksheet, false);
        SummarizeCounting.Open;
        while SummarizeCounting.Read do begin

            NotEmptyResult := true;
            Record := DOMxmlin.CreateElement('Record');

            //CurrRecordID := SummarizeCounting.RECORDID;
            //TableNo := CurrRecordID.TABLENO;

            if SummarizeCounting.Item_No = '' then
                Indicator := 'minus'
            else
                Indicator := 'ok';

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'Description');
            AddAttribute(Line, 'Indicator', Indicator);
            if (Indicator = 'ok') then
                Line.InnerText := StrSubstNo(Text015, SummarizeCounting.Count_, SummarizeCounting.Item_No, SummarizeCounting.Item_Description)
            else
                Line.InnerText := StrSubstNo(Text016, SummarizeCounting.Count_, 'Unknown Tag Id');
            Record.AppendChild(Line);

            //    Line := DOMxmlin.CreateElement('Line');
            //    AddAttribute(Line,'Descrip','Delete..');
            //    AddAttribute(Line,'Type',FORMAT(LineType::BUTTON));
            //    AddAttribute(Line,'TableNo',FORMAT(TableNo));
            //    AddAttribute(Line,'RecordID',FORMAT(CurrRecordID));
            //    AddAttribute(Line,'FuncName','DELETELINE');
            //    Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'No.');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            Line.InnerText := SummarizeCounting.Item_No;
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'Name');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            Line.InnerText := SummarizeCounting.Item_Description;
            Record.AppendChild(Line);

            if (SummarizeCounting.Variant_Code <> '') then begin
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'Variant');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                Line.InnerText := SummarizeCounting.Variant_Code + ' - ' + SummarizeCounting.Variant_Description;
                Record.AppendChild(Line);
            end;

            Records.AppendChild(Record);
        end;

        SummarizeCounting.Close;

        exit(NotEmptyResult);
    end;

    local procedure Reset(var CurrCSStockTakeHandling: Record "CS Stock-Take Handling")
    var
        CSStockTakeCounting: Record "CS Stock-Take Handling";
    begin
        Clear(CSStockTakeCounting);
        CSStockTakeCounting.SetRange(Id, CSSessionId);
        CSStockTakeCounting.SetRange("Stock-Take Config Code", CurrCSStockTakeHandling."Stock-Take Config Code");
        CSStockTakeCounting.SetRange("Worksheet Name", CurrCSStockTakeHandling."Worksheet Name");
        CSStockTakeCounting.SetRange(Handled, true);
        CSStockTakeCounting.SetRange("Transferred to Worksheet", false);
        CSStockTakeCounting.DeleteAll(true);
    end;

    local procedure Register(var CurrCSStockTakeHandling: Record "CS Stock-Take Handling")
    var
        CSStockTakeCounting: Record "CS Stock-Take Handling";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
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
          //-NPR5.51 [359375]
          StockTakeWorksheet.Validate(Status,StockTakeWorksheet.Status::READY_TO_TRANSFER);
          StockTakeWorksheet.Modify(true);
          OK := StartSession(SessionID, CODEUNIT::"CS UI WH Counting Handling", CompanyName, StockTakeWorksheet);
          if not OK then
            Remark :=  GetLastErrorText;
          //+NPR5.51 [359375]
        end;
    end;

    local procedure TransferDataLine(var CSStockTakeCounting: Record "CS Stock-Take Handling"; StockTakeWorksheet: Record "Stock-Take Worksheet"): Boolean
    var
        StockTakeWorkSheetLine: Record "Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        LineNo: Integer;
    begin
        //StockTakeWorksheet.GET(CSStockTakeCounting."Stock-Take Config Code",CSStockTakeCounting."Worksheet Name");
        //StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

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

        //StockTakeMgr.ImportPostHandler(StockTakeWorksheet);

        exit(true);
    end;
}

