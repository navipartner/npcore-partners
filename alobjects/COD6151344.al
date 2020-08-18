codeunit 6151344 "CS Rfid Transfer Handling"
{
    // NPR5.55/CLVA/20200507  CASE 379709 Object created - NP Capture Service

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
            ProcessSelection;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "CS UI Header";
        CSUIHeader2: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSManagement: Codeunit "CS Management";
        ReturnedNode: DotNet npNetXmlNode;
        DOMxmlin: DotNet npNetXmlDocument;
        RootNode: DotNet npNetXmlNode;
        TextValue: Text[250];
        CSUserId: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        PreviousCode: Text[250];
        StackCode: Text[250];
        Remark: Text[250];
        ActiveInputField: Integer;
        RecRef: RecordRef;
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text006: Label 'No input Node found.';
        Text009: Label 'No Documents found.';
        CSSessionId: Text;
        Text010: Label 'There are no locations for warehouse employee %1';
        Text011: Label 'Barcode length is exceeding Bin Code max length';
        Text012: Label 'Documents not found in filter\\ %1.';
        Text013: Label 'Bin Code %1 doesn''t exist on Location Code %2';
        Text014: Label 'Location %1';
        Text015: Label '%1';
        Text026: Label '%1 / %2';
        Text027: Label '%1 | %2';
        Text030: Label '%1 / %2 / %3';
        Text031: Label 'Document can''t be posted when there is no tags collected';

    local procedure ProcessSelection()
    var
        RecId: RecordID;
        FuncGroup: Record "CS UI Function Group";
        TableNo: Integer;
        WhseEmployee: Record "Warehouse Employee";
        CSRfidHeader: Record "CS Rfid Header";
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSRfidHeader);
            RecRef.GetTable(CSRfidHeader);
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue);
        ActiveInputField := 1;

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                CSCommunication.RunPreviousUI(DOMxmlin);
            FuncGroup.KeyDef::Register:
                begin
                    Register(CSRfidHeader);
                    if Remark = '' then begin
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField, CSRfidHeader);
                end;
            FuncGroup.KeyDef::First:
                begin
                    SendForm(ActiveInputField, CSRfidHeader);
                end;
            FuncGroup.KeyDef::Reset:
                Reset(CSRfidHeader);
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Register, FuncGroup.KeyDef::First]) then
            SendForm(ActiveInputField, CSRfidHeader);
    end;

    local procedure PrepareData()
    var
        CSUserRec: Record "CS User";
        WhseEmployee: Record "Warehouse Employee";
        RecId: RecordID;
        TableNo: Integer;
        CSRfidHeader: Record "CS Rfid Header";
    begin
        XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Get(RecId);
        RecRef.SetTable(CSRfidHeader);
        RecRef.GetTable(CSRfidHeader);
        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField, CSRfidHeader);
    end;

    local procedure SendForm(InputField: Integer; CSRfidHeader: Record "CS Rfid Header")
    var
        Records: DotNet npNetXmlElement;
        CSSetup: Record "CS Setup";
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        CSSetup.Get;
        if CSSetup."Use Whse. Receipt" and (CSRfidHeader."Warehouse Receipt No." <> '') then begin
            if AddWhseReceiptSummarize(Records, CSRfidHeader) then
                DOMxmlin.DocumentElement.AppendChild(Records);
        end else begin
            if AddSummarize(Records, CSRfidHeader) then
                DOMxmlin.DocumentElement.AppendChild(Records);
        end;

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure Register(var CSRfidHeader: Record "CS Rfid Header")
    var
        CSRfidLines: Record "CS Rfid Lines";
        CSSetup: Record "CS Setup";
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
    begin
        Clear(CSRfidLines);
        CSRfidLines.SetRange(Id, CSRfidHeader.Id);
        if CSRfidLines.Count = 0 then
            Error(Text031);

        if CSRfidHeader."To Document No." = '' then begin
            CSRfidHeader.CreateSalesLinesByRfidDocLines();
            CSRfidHeader."Shipping Closed" := CurrentDateTime;
            CSRfidHeader."Shipping Closed By" := UserId;
            CSRfidHeader."Total Tags Shipped" := CSRfidLines.Count;
            CSRfidHeader.Modify(true);
        end else begin
            CSRfidHeader."Receiving Closed" := CurrentDateTime;
            CSRfidHeader."Receiving Closed By" := UserId;
            CSRfidLines.SetRange(Match, true);
            CSRfidHeader."Total Tags Received" := CSRfidLines.Count;
            CSRfidHeader.Modify(true);

            //  CSSetup.GET;
            //  IF CSSetup."Use Whse. Receipt" THEN BEGIN
            //    WhseReceiptHeader.GET(CSRfidHeader."Warehouse Receipt No.");
            //    WhseReceiptLine.SETRANGE("No.",WhseReceiptHeader."No.");
            //    IF WhseReceiptLine.FINDSET THEN BEGIN
            //      WhsePostReceipt.RUN(WhseReceiptLine);
            //      WhsePostReceipt.GetResultMessage;
            //      CLEAR(WhsePostReceipt);
            //    END
            //  END;

        end;
    end;

    local procedure Reset(CSRfidHeader: Record "CS Rfid Header")
    var
        CSRfidLines: Record "CS Rfid Lines";
        CSSetup: Record "CS Setup";
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        if CSRfidHeader."To Document No." = '' then begin
            Clear(CSRfidLines);
            CSRfidLines.SetRange(Id, CSRfidHeader.Id);
            CSRfidLines.DeleteAll;
        end else begin
            Clear(CSRfidLines);
            CSRfidLines.SetRange(Id, CSRfidHeader.Id);
            CSRfidLines.ModifyAll(Match, false, true);

            CSSetup.Get;
            if CSSetup."Use Whse. Receipt" then begin
                WhseReceiptHeader.Get(CSRfidHeader."Warehouse Receipt No.");
                WhseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
                if WhseReceiptLine.FindSet then begin
                    repeat
                        WhseReceiptLine.Validate("Qty. to Receive", 0);
                        WhseReceiptLine.Modify;
                    until WhseReceiptLine.Next = 0;
                end
            end;

        end;
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement; CSRfidHeader: Record "CS Rfid Header") NotEmptyResult: Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSRfidLinesQy: Query "CS Rfid Lines";
    begin
        SelectLatestVersion;

        Records := DOMxmlin.CreateElement('Records');

        CSRfidLinesQy.SetRange(Id, CSRfidHeader.Id);
        //CSRfidLinesQy.SETFILTER(Item_No_Filter,'<>%1','');
        CSRfidLinesQy.Open;
        while CSRfidLinesQy.Read do begin
            NotEmptyResult := true;

            Record := DOMxmlin.CreateElement('Record');

            if CSRfidHeader."To Document No." = '' then begin
                Indicator := 'ok'
            end else begin
                if CSRfidLinesQy.Match then
                    Indicator := 'ok'
                else
                    Indicator := 'minus';
            end;

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'No.');
            AddAttribute(Line, 'Indicator', Indicator);
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            AddAttribute(Line, 'CollapsItems', 'FALSE');
            Line.InnerText := CSRfidLinesQy.Item_No;
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'Count');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            Line.InnerText := Format(CSRfidLinesQy.Count_);
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'Variant');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            Line.InnerText := CSRfidLinesQy.Variant_Code;
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'VariantDesc');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            Line.InnerText := CSRfidLinesQy.Variant_Description;
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line, 'Descrip', 'ItemDesc');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            if CSRfidLinesQy.Item_Description <> '' then
                Line.InnerText := CSRfidLinesQy.Item_Description
            else
                Line.InnerText := 'UNKNOWN ITEM';
            Record.AppendChild(Line);

            Records.AppendChild(Record);
        end;

        exit(NotEmptyResult);
    end;

    local procedure AddWhseReceiptSummarize(var Records: DotNet npNetXmlElement; CSRfidHeader: Record "CS Rfid Header"): Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        WhseReceiptLine: Record "Warehouse Receipt Line";
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        Location: Record Location;
        WhseReceiptHeader: Record "Warehouse Receipt Header";
    begin
        SelectLatestVersion;

        WhseReceiptHeader.Get(CSRfidHeader."Warehouse Receipt No.");
        WhseReceiptLine.SetRange("No.", WhseReceiptHeader."No.");
        if WhseReceiptLine.FindSet then begin
            Records := DOMxmlin.CreateElement('Records');
            repeat
                Record := DOMxmlin.CreateElement('Record');

                CurrRecordID := WhseReceiptLine.RecordId;
                TableNo := CurrRecordID.TableNo;

                if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
                    Indicator := 'minus'
                else
                    if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
                        Indicator := 'ok'
                    else
                        Indicator := 'plus';

                if Indicator = 'minus' then begin
                    //1
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                    AddAttribute(Line, 'Indicator', Indicator);
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    AddAttribute(Line, 'CollapsItems', 'FALSE');
                    Line.InnerText := WhseReceiptLine."Bin Code";
                    Record.AppendChild(Line);

                    //2
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. Outstanding"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := StrSubstNo(Text026, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding");
                    Record.AppendChild(Line);

                    //3
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Item No."));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    if WhseReceiptLine."Variant Code" <> '' then
                        Line.InnerText := StrSubstNo(Text027, WhseReceiptLine."Item No.", WhseReceiptLine."Variant Code")
                    else
                        Line.InnerText := WhseReceiptLine."Item No.";
                    Record.AppendChild(Line);

                    //4
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := WhseReceiptLine."Unit of Measure Code";
                    Record.AppendChild(Line);

                    //5
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := WhseReceiptLine.Description;
                    Record.AppendChild(Line);

                    //6
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', '');
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := '';
                    Record.AppendChild(Line);

                    if Location.Get(WhseReceiptLine."Location Code") then
                        if Location."Bin Mandatory" then begin
                            Line := DOMxmlin.CreateElement('Line');
                            AddAttribute(Line, 'Descrip', 'Split Line..');
                            AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                            AddAttribute(Line, 'TableNo', Format(TableNo));
                            AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                            AddAttribute(Line, 'FuncName', 'SPLITLINE');
                            Record.AppendChild(Line);
                        end;

                    Records.AppendChild(Record);
                end;
            until WhseReceiptLine.Next = 0;

            if WhseReceiptLine.FindSet then begin
                repeat
                    Record := DOMxmlin.CreateElement('Record');

                    CurrRecordID := WhseReceiptLine.RecordId;
                    TableNo := CurrRecordID.TableNo;

                    if (WhseReceiptLine."Qty. to Receive" < WhseReceiptLine."Qty. Outstanding") then
                        Indicator := 'minus'
                    else
                        if (WhseReceiptLine."Qty. to Receive" = WhseReceiptLine."Qty. Outstanding") then
                            Indicator := 'ok'
                        else
                            Indicator := 'plus';

                    if Indicator <> 'minus' then begin
                        //1
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Indicator', Indicator);
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        AddAttribute(Line, 'CollapsItems', 'FALSE');
                        Line.InnerText := WhseReceiptLine."Bin Code";
                        Record.AppendChild(Line);

                        //2
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. Outstanding"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := StrSubstNo(Text026, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding");
                        Record.AppendChild(Line);

                        //3
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Item No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        if WhseReceiptLine."Variant Code" <> '' then
                            Line.InnerText := StrSubstNo(Text027, WhseReceiptLine."Item No.", WhseReceiptLine."Variant Code")
                        else
                            Line.InnerText := WhseReceiptLine."Item No.";
                        Record.AppendChild(Line);

                        //4
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := WhseReceiptLine."Unit of Measure Code";
                        Record.AppendChild(Line);

                        //5
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := WhseReceiptLine.Description;
                        Record.AppendChild(Line);

                        //6
                        Line := DOMxmlin.CreateElement('Line');
                        AddAttribute(Line, 'Descrip', '');
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        Line.InnerText := '';
                        Record.AppendChild(Line);

                        if Location.Get(WhseReceiptLine."Location Code") then
                            if Location."Bin Mandatory" then begin
                                Line := DOMxmlin.CreateElement('Line');
                                AddAttribute(Line, 'Descrip', 'Split Line..');
                                AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                                AddAttribute(Line, 'TableNo', Format(TableNo));
                                AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                                AddAttribute(Line, 'FuncName', 'SPLITLINE');
                                Record.AppendChild(Line);
                            end;

                        Records.AppendChild(Record);
                    end;
                until WhseReceiptLine.Next = 0;
            end;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild, AttribName, AttribValue) > 0 then
            Error(Text002, AttribName);
    end;

}

