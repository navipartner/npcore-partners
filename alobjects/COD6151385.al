codeunit 6151385 "CS UI Stock-Take WorkSheet"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180511 CASE 307239 Added show/hide invalid barcode alert on device
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          MiniformHeader,Rec,DOMxmlin,ReturnedNode,
          RootNode,XMLDOMMgt,CSCommunication,CSUserId,
          CurrentCode,StackCode,WhseEmpId,LocationFilter,CSSessionId);

        if Code <> CurrentCode then
          PrepareData
        else
          ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSManagement: Codeunit "CS Management";
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
        MiniformHeader2: Record "CS UI Header";
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
        FuncGroup: Record "CS UI Function Group";
        RecId: RecordID;
        TextValue: Text[250];
        TableNo: Integer;
        FldNo: Integer;
        Lookup: Integer;
        Item: Record Item;
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo2: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Qty: Integer;
        QtyTxt: Text;
        QtyVal: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        CSSetup: Record "CS Setup";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        SessionName: Text[40];
        StockTakeMgr: Codeunit "Stock-Take Manager";
        StockTakeWorkSheetLine: Record "Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        LineNo: Integer;
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(StockTakeWorksheet);
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code,TextValue);
        ActiveInputField := 1;

        //-NPR5.43
        CSSetup.Get;
        //+NPR5.43

        case FuncGroup.KeyDef of
          FuncGroup.KeyDef::Esc:
            CSCommunication.RunPreviousUI(DOMxmlin);
          FuncGroup.KeyDef::"Function":
            begin
              Evaluate(FuncTableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncTableNo'));
              FuncRecRef.Open(FuncTableNo);
              Evaluate(FuncRecId,CSCommunication.GetNodeAttribute(ReturnedNode,'FuncRecordID'));
              if FuncRecRef.Get(FuncRecId) then begin
                FuncRecRef.SetTable(StockTakeWorkSheetLine);
                StockTakeWorkSheetLine.Delete(true);
                //WhseActivityLine.SplitLine(WhseActivityLine);
              end;
            end;
          FuncGroup.KeyDef::Input:
            begin

              Qty := 1;
              QtyTxt := CSCommunication.GetNodeAttribute(ReturnedNode,'valueTwo');
              if QtyTxt <> '' then
                if Evaluate(QtyVal,QtyTxt) then
                  if QtyVal > 0 then
                    Qty := QtyVal;

              //IF TextValue = '' THEN BEGIN
              //  Remark := Text011;
              //END ELSE BEGIN
                if StrLen(TextValue) <= MaxStrLen(Item."No.") then //BEGIN
                  if BarcodeLibrary.TranslateBarcodeToItemVariant(TextValue, ItemNo2, VariantCode, ResolvingTable, true) then// BEGIN
                    if not Item.Get(ItemNo2) then
                      //-NPR5.43
                      if CSSetup."Error On Invalid Barcode" then
                      //+NPR5.43
                        Remark := StrSubstNo(Text014,TextValue);
                  //END ELSE
                    //Remark := STRSUBSTNO(Text013,TextValue);
                //END ELSE
                  //Remark := STRSUBSTNO(Text010,TextValue);
              //END;

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
                //StockTakeWorkSheetLine."Shelf  No." := Shelf;
                StockTakeWorkSheetLine."Qty. (Counted)" := Qty;
                StockTakeWorkSheetLine."Session Name" := SessionName;
                StockTakeWorkSheetLine."Date of Inventory" := WorkDate;
                StockTakeWorkSheetLine.Insert(true);

                if StockTakeWorkSheetLine."Item Translation Source" = 0 then
                  Remark := StrSubstNo(Text010,TextValue);

                StockTakeMgr.ImportPostHandler(StockTakeWorksheet);

              end;

            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        RecId: RecordID;
        TableNo: Integer;
        Lookup: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
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
        Records: DotNet npNetXmlElement;
    begin
        // Prepare Miniform
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);

        //DebugTxt := DOMxmlin.OuterXml;

        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild,AttribName,AttribValue) > 0 then
          Error(Text002,AttribName);
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement): Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        StockTakeWorkSheetLine: Record "Stock-Take Worksheet Line";
    begin
        RecRef.SetTable(StockTakeWorksheet);
        StockTakeWorkSheetLine.SetRange("Stock-Take Config Code",StockTakeWorksheet."Stock-Take Config Code");
        StockTakeWorkSheetLine.SetRange("Worksheet Name",StockTakeWorksheet.Name);
        if StockTakeWorkSheetLine.FindSet then begin
          Records := DOMxmlin.CreateElement('Records');
          repeat
            Record := DOMxmlin.CreateElement('Record');

            StockTakeWorkSheetLine.CalcFields("Item Description","Variant Description");

            CurrRecordID := StockTakeWorkSheetLine.RecordId;
            TableNo := CurrRecordID.TableNo;

            if StockTakeWorkSheetLine."Item Translation Source" = 0 then
              Indicator := 'minus'
            else
              Indicator := 'ok';

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Description');
            AddAttribute(Line,'Indicator',Indicator);
            if (Indicator = 'ok') then
              Line.InnerText := StrSubstNo(Text015,StockTakeWorkSheetLine."Qty. (Counted)",StockTakeWorkSheetLine."Item No.",StockTakeWorkSheetLine."Item Description")
            else
              Line.InnerText := StrSubstNo(Text016,StockTakeWorkSheetLine."Qty. (Counted)", StockTakeWorkSheetLine.Barcode);
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Delete..');
            AddAttribute(Line,'Type',Format(LineType::BUTTON));
            AddAttribute(Line,'TableNo',Format(TableNo));
            AddAttribute(Line,'RecordID',Format(CurrRecordID));
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',StockTakeWorkSheetLine.FieldCaption(Barcode));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := StockTakeWorkSheetLine.Barcode;
            Record.AppendChild(Line);

            if (Indicator = 'ok') then begin
              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',StockTakeWorkSheetLine.FieldCaption("Variant Code"));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := StockTakeWorkSheetLine."Variant Code";
              Record.AppendChild(Line);

              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip',StockTakeWorkSheetLine.FieldCaption("Variant Description"));
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := StockTakeWorkSheetLine."Variant Description";
              Record.AppendChild(Line);
            end;

            Records.AppendChild(Record);
          until StockTakeWorkSheetLine.Next = 0;
          exit(true);
        end else
          exit(false);
    end;

    trigger DOMxmlin::NodeInserting(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeInserted(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoving(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoved(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanging(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanged(sender: Variant;e: DotNet npNetXmlNodeChangedEventArgs)
    begin
    end;
}

