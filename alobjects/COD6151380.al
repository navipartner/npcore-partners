codeunit 6151380 "CS UI Whse. Rcpt. Line"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
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
        DOMxmlin: DotNet XmlDocument;
        ReturnedNode: DotNet XmlNode;
        RootNode: DotNet XmlNode;
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
        Text009: Label 'Qty. does not match.';
        Text011: Label 'Invalid Quantity.';
        Text012: Label 'No Lines available.';
        Text013: Label 'Item %1 not found on doc. %2';
        Text014: Label 'Item %1 doesn''t exist';
        Text015: Label '%1/%2 : %3 %4';
        Text016: Label 'Qty. to Receive exceed Outstanding Qty.';
        CSSessionId: Text;

    local procedure ProcessInput()
    var
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
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
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(WhseReceiptHeader);
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code,TextValue);
        ActiveInputField := 1;

        case FuncGroup.KeyDef of
          FuncGroup.KeyDef::Esc:
            CSCommunication.RunPreviousUI(DOMxmlin);
          FuncGroup.KeyDef::Reset:
            Reset(WhseReceiptHeader);
          FuncGroup.KeyDef::Register:
            begin
              Register(WhseReceiptHeader);
              if Remark = '' then
                CSCommunication.RunPreviousUI(DOMxmlin)
              else
                SendForm(ActiveInputField);
            end;
          FuncGroup.KeyDef::Input:
            begin
              if TextValue <> '' then
                if StrLen(TextValue) <= MaxStrLen(Item."No.") then
                  if BarcodeLibrary.TranslateBarcodeToItemVariant(TextValue, ItemNo2, VariantCode, ResolvingTable, true) then
                    if not Item.Get(ItemNo2) then
                      Remark := StrSubstNo(Text014,TextValue);

              if Remark = '' then begin
                WhseReceiptLine.SetCurrentKey("Source Type","Source Subtype","Source No.","Source Line No.");
                WhseReceiptLine.SetRange("No.",WhseReceiptHeader."No.");
                WhseReceiptLine.SetRange("Item No.",Item."No.");
                if WhseReceiptLine.FindSet then begin
                  if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding" then
                    Error(Text016);
                  WhseReceiptLine.Validate("Qty. to Receive",WhseReceiptLine."Qty. to Receive" + 1);
                  WhseReceiptLine.Modify(true);
                end else
                  Remark := StrSubstNo(Text013,ItemNo2,WhseReceiptHeader."No.");
              end;
            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField);
    end;

    local procedure Reset(var WhseReceiptHeader: Record "Warehouse Receipt Header")
    var
        WhseReceiptLine2: Record "Warehouse Receipt Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Remark := '';
        WhseReceiptLine.SetRange("No.",WhseReceiptHeader."No.");
        if WhseReceiptLine.FindSet then begin
          repeat
              WhseReceiptLine.Validate("Qty. to Receive",0);
              WhseReceiptLine.Modify;
          until WhseReceiptLine.Next = 0;
        end else
          Error(Text007);

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
    end;

    local procedure Register(var WhseReceiptHeader: Record "Warehouse Receipt Header")
    var
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Remark := '';
        WhseReceiptLine.SetRange("No.",WhseReceiptHeader."No.");
        if WhseReceiptLine.FindSet then begin
          repeat
            WhsePostReceipt.Run(WhseReceiptLine);
            WhsePostReceipt.GetResultMessage;
            Clear(WhsePostReceipt);
          until WhseReceiptLine.Next = 0;
        end else
          Error(Text007);
    end;

    local procedure PrepareData()
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        RecId: RecordID;
        TableNo: Integer;
        Lookup: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(WhseReceiptHeader);
          WhseReceiptLine.SetRange("No.",WhseReceiptHeader."No.");
          if not WhseReceiptLine.FindSet then begin
            CSManagement.SendError(Text012);
            exit;
          end;
          CSCommunication.SetRecRef(RecRef);
          ActiveInputField := 1;
          SendForm(ActiveInputField);
        end else
          Error(Text007);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: DotNet XmlElement;
    begin
        // Prepare Miniform
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure AddAttribute(var NewChild: DotNet XmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild,AttribName,AttribValue) > 0 then
          Error(Text002,AttribName);
    end;

    local procedure AddSummarize(var Records: DotNet XmlElement): Boolean
    var
        "Record": DotNet XmlElement;
        Line: DotNet XmlElement;
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
    begin
        RecRef.SetTable(WhseReceiptHeader);
        WhseReceiptLine.SetRange("No.",WhseReceiptHeader."No.");
        if WhseReceiptLine.FindSet then begin
          Records := DOMxmlin.CreateElement('Records');
          repeat
            Record := DOMxmlin.CreateElement('Record');

            if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
              Indicator := 'minus'
            else if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
              Indicator := 'ok'
            else
              Indicator := 'plus';

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption(Description));
            AddAttribute(Line,'Indicator',Indicator);
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := StrSubstNo(Text015,WhseReceiptLine."Qty. to Receive",WhseReceiptLine."Qty. Outstanding",WhseReceiptLine."Item No.",WhseReceiptLine.Description);
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption(Description));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := WhseReceiptLine.Description;
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Source Document"));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := Format(WhseReceiptLine."Source Document");
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Source No."));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := WhseReceiptLine."Source No.";
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Unit of Measure Code"));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := WhseReceiptLine."Unit of Measure Code";
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip',WhseReceiptLine.FieldCaption("Qty. per Unit of Measure"));
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := Format(WhseReceiptLine."Qty. per Unit of Measure");
            Record.AppendChild(Line);
            Records.AppendChild(Record);
          until WhseReceiptLine.Next = 0;
          exit(true);
        end else
          exit(false);
    end;

    trigger DOMxmlin::NodeInserting(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeInserted(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoving(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoved(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanging(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanged(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;
}

