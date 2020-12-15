codeunit 6151380 "NPR CS UI Whse. Rcpt. Line"
{
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
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(WhseReceiptHeader);
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code, TextValue);
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
                                    Remark := StrSubstNo(Text014, TextValue);

                    if Remark = '' then begin
                        WhseReceiptLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                        WhseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
                        WhseReceiptLine.SetRange("Item No.", Item."No.");
                        if WhseReceiptLine.FindSet then begin
                            if WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding" then
                                Error(Text016);
                            WhseReceiptLine.Validate("Qty. to Receive", WhseReceiptLine."Qty. to Receive" + 1);
                            WhseReceiptLine.Modify(true);
                        end else
                            Remark := StrSubstNo(Text013, ItemNo2, WhseReceiptHeader."No.");
                    end;
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Register]) then
            SendForm(ActiveInputField);
    end;

    local procedure Reset(var WhseReceiptHeader: Record "Warehouse Receipt Header")
    var
        WhseReceiptLine2: Record "Warehouse Receipt Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        Remark := '';
        WhseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
        if WhseReceiptLine.FindSet then begin
            repeat
                WhseReceiptLine.Validate("Qty. to Receive", 0);
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
        WhseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
        if WhseReceiptLine.FindSet then begin
            if MiniformHeader."Update Posting Date" then begin
                WhseReceiptHeader.Validate("Posting Date", Today);
                WhseReceiptHeader.Modify(true);
            end;

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
        RootNode.SelectSingleNode('Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(WhseReceiptHeader);
            WhseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
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
        Records: XmlElement;
        RootElement: XmlElement;
    begin
        // Prepare Miniform
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        DOMxmlin.GetRoot(RootElement);
        if AddSummarize(Records) then
            RootElement.Add(Records);

        CSManagement.SendXMLReply(DOMxmlin);
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
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
    begin
        RecRef.SetTable(WhseReceiptHeader);
        WhseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
        if WhseReceiptLine.FindSet then begin
            Records := XmlElement.Create('Records');
            repeat
                RecordElement := XmlElement.Create('Record');

                if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
                    Indicator := 'minus'
                else
                    if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
                        Indicator := 'ok'
                    else
                        Indicator := 'plus';

                Line := XmlElement.Create('Line', '',
                    StrSubstNo(Text015, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding",
                        WhseReceiptLine."Item No.", WhseReceiptLine.Description));
                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                AddAttribute(Line, 'Indicator', Indicator);
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', WhseReceiptLine.Description);
                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', Format(WhseReceiptLine."Source Document"));
                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Source Document"));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', WhseReceiptLine."Source No.");
                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Source No."));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', WhseReceiptLine."Unit of Measure Code");
                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', WhseReceiptLine."Qty. per Unit of Measure");
                AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. per Unit of Measure"));
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                Records.Add(RecordElement);
            until WhseReceiptLine.Next = 0;
            exit(true);
        end else
            exit(false);
    end;
}
