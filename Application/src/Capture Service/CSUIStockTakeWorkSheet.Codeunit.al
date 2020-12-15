codeunit 6151385 "NPR CS UI Stock-Take WorkSheet"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180511 CASE 307239 Added show/hide invalid barcode alert on device
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
    begin
        MiniformMgmt.Initialize(
          MiniformHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSManagement: Codeunit "NPR CS Management";
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
        MiniformHeader2: Record "NPR CS UI Header";
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text004: Label 'Invalid %1.';
        Text006: Label 'No input Node found.';
        Text007: Label 'Record not found.';
        Text008: Label 'End of Document.';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'barcode is blank';
        Text012: Label 'No Lines available.';
        Text013: Label 'Item with barcode %1 doesn''t exist';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1 : %2 %3';
        DebugTxt: Text;
        Text016: Label '%1 : %2';
        CSSessionId: Text;

    local procedure ProcessInput()
    var
        FuncGroup: Record "NPR CS UI Function Group";
        RecId: RecordID;
        TextValue: Text[250];
        TableNo: Integer;
        FldNo: Integer;
        Lookup: Integer;
        Item: Record Item;
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo2: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Qty: Integer;
        QtyTxt: Text;
        QtyVal: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        CSSetup: Record "NPR CS Setup";
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        SessionName: Text[40];
        StockTakeMgr: Codeunit "NPR Stock-Take Manager";
        StockTakeWorkSheetLine: Record "NPR Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
        LineNo: Integer;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(StockTakeWorksheet);
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code, TextValue);
        ActiveInputField := 1;

        CSSetup.Get;

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                CSCommunication.RunPreviousUI(DOMxmlin);
            FuncGroup.KeyDef::"Function":
                begin
                    Evaluate(FuncTableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncTableNo'));
                    FuncRecRef.Open(FuncTableNo);
                    Evaluate(FuncRecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncRecordID'));
                    if FuncRecRef.Get(FuncRecId) then begin
                        FuncRecRef.SetTable(StockTakeWorkSheetLine);
                        StockTakeWorkSheetLine.Delete(true);
                    end;
                end;
            FuncGroup.KeyDef::Input:
                begin

                    Qty := 1;
                    QtyTxt := CSCommunication.GetNodeAttribute(ReturnedNode, 'valueTwo');
                    if QtyTxt <> '' then
                        if Evaluate(QtyVal, QtyTxt) then
                            if QtyVal > 0 then
                                Qty := QtyVal;

                    if StrLen(TextValue) <= MaxStrLen(Item."No.") then
                        if BarcodeLibrary.TranslateBarcodeToItemVariant(TextValue, ItemNo2, VariantCode, ResolvingTable, true) then// BEGIN
                            if not Item.Get(ItemNo2) then
                                if CSSetup."Error On Invalid Barcode" then
                                    Remark := StrSubstNo(Text014, TextValue);

                    if Remark = '' then begin

                        SessionName := Format(CurrentDateTime(), 0, 9);

                        StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

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
                        StockTakeWorkSheetLine.Validate(Barcode, TextValue);
                        StockTakeWorkSheetLine."Qty. (Counted)" := Qty;
                        StockTakeWorkSheetLine."Session Name" := SessionName;
                        StockTakeWorkSheetLine."Date of Inventory" := WorkDate;
                        StockTakeWorkSheetLine.Insert(true);

                        if StockTakeWorkSheetLine."Item Translation Source" = 0 then
                            Remark := StrSubstNo(Text010, TextValue);

                        StockTakeMgr.ImportPostHandler(StockTakeWorksheet);

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
        RecId: RecordID;
        TableNo: Integer;
        Lookup: Integer;
    begin
        RootNode.AsXmlElement().SelectSingleNode('Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(StockTakeWorksheet);
            CSCommunication.SetRecRef(RecRef);
            ActiveInputField := 1;
            SendForm(ActiveInputField);
        end else
            Error(Text007);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: XmlElement;
        RootElement: XmlElement;
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);

        CSCommunication.GetReturnXML(DOMxmlin);

        DOMxmlin.GetRoot(RootElement);
        if AddSummarize(Records) then
            RootElement.Add(Records);

        CSManagement.SendXMLReply(DOMxmlin);
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
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        StockTakeWorkSheetLine: Record "NPR Stock-Take Worksheet Line";
    begin
        RecRef.SetTable(StockTakeWorksheet);
        StockTakeWorkSheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        StockTakeWorkSheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
        if StockTakeWorkSheetLine.FindSet then begin
            Records := XmlElement.Create('Records');
            repeat
                RecordElement := XmlElement.Create('Record');

                StockTakeWorkSheetLine.CalcFields("Item Description", "Variant Description");

                CurrRecordID := StockTakeWorkSheetLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                if StockTakeWorkSheetLine."Item Translation Source" = 0 then
                    Indicator := 'minus'
                else
                    Indicator := 'ok';

                if (Indicator = 'ok') then
                    Line := XmlElement.Create('Line', '',
                        StrSubstNo(Text015, StockTakeWorkSheetLine."Qty. (Counted)", StockTakeWorkSheetLine."Item No.", StockTakeWorkSheetLine."Item Description"))
                else
                    Line := XmlElement.Create('Line', '',
                        StrSubstNo(Text016, StockTakeWorkSheetLine."Qty. (Counted)", StockTakeWorkSheetLine.Barcode));
                AddAttribute(Line, 'Descrip', 'Description');
                AddAttribute(Line, 'Indicator', Indicator);
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line');
                AddAttribute(Line, 'Descrip', 'Delete..');
                AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                AddAttribute(Line, 'TableNo', Format(TableNo));
                AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', StockTakeWorkSheetLine.Barcode);
                AddAttribute(Line, 'Descrip', StockTakeWorkSheetLine.FieldCaption(Barcode));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                if (Indicator = 'ok') then begin
                    Line := XmlElement.Create('Line', '', StockTakeWorkSheetLine."Variant Code");
                    AddAttribute(Line, 'Descrip', StockTakeWorkSheetLine.FieldCaption("Variant Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    Line := XmlElement.Create('Line', '', StockTakeWorkSheetLine."Variant Description");
                    AddAttribute(Line, 'Descrip', StockTakeWorkSheetLine.FieldCaption("Variant Description"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);
                end;

                Records.Add(RecordElement);
            until StockTakeWorkSheetLine.Next = 0;
            exit(true);
        end else
            exit(false);
    end;
}

