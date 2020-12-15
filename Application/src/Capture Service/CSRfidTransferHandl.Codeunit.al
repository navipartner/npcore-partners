codeunit 6151344 "NPR CS Rfid Transfer Handl."
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
            ProcessSelection;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "NPR CS UI Header";
        CSUIHeader2: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSManagement: Codeunit "NPR CS Management";
        ReturnedNode: XmlNode;
        DOMxmlin: XmlDocument;
        RootNode: XmlNode;
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
        FuncGroup: Record "NPR CS UI Function Group";
        TableNo: Integer;
        WhseEmployee: Record "Warehouse Employee";
        CSRfidHeader: Record "NPR CS Rfid Header";
    begin
        if RootNode.AsXmlElement().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
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
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        RecId: RecordID;
        TableNo: Integer;
        CSRfidHeader: Record "NPR CS Rfid Header";
    begin
        RootNode.AsXmlElement().SelectSingleNode('Header/Input', ReturnedNode);

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

    local procedure SendForm(InputField: Integer; CSRfidHeader: Record "NPR CS Rfid Header")
    var
        Records: XmlElement;
        RootElement: XmlElement;
        CSSetup: Record "NPR CS Setup";
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        CSSetup.Get;
        if CSSetup."Use Whse. Receipt" and (CSRfidHeader."Warehouse Receipt No." <> '') then begin
            if AddWhseReceiptSummarize(Records, CSRfidHeader) then begin
                //DOMxmlin.DocumentElement.AppendChild(Records);
            end
        end else begin
            if AddSummarize(Records, CSRfidHeader) then begin
                DOMxmlin.GetRoot(RootElement);
                RootElement.Add(Records);
            end
        end;

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure Register(var CSRfidHeader: Record "NPR CS Rfid Header")
    var
        CSRfidLines: Record "NPR CS Rfid Lines";
        CSSetup: Record "NPR CS Setup";
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
        end;
    end;

    local procedure Reset(CSRfidHeader: Record "NPR CS Rfid Header")
    var
        CSRfidLines: Record "NPR CS Rfid Lines";
        CSSetup: Record "NPR CS Setup";
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

    local procedure AddSummarize(var Records: XmlElement; CSRfidHeader: Record "NPR CS Rfid Header") NotEmptyResult: Boolean
    var
        RecordElement: XmlElement;
        Line: XmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSRfidLinesQy: Query "NPR CS Rfid Lines";
    begin
        SelectLatestVersion;

        Records := XmlElement.Create('Records');

        CSRfidLinesQy.SetRange(Id, CSRfidHeader.Id);
        CSRfidLinesQy.Open;
        while CSRfidLinesQy.Read do begin
            NotEmptyResult := true;

            RecordElement := XmlElement.Create('Record');

            if CSRfidHeader."To Document No." = '' then begin
                Indicator := 'ok'
            end else begin
                if CSRfidLinesQy.Match then
                    Indicator := 'ok'
                else
                    Indicator := 'minus';
            end;

            Line := XmlElement.Create('Line', '', CSRfidLinesQy.Item_No);
            AddAttribute(Line, 'Descrip', 'No.');
            AddAttribute(Line, 'Indicator', Indicator);
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            AddAttribute(Line, 'CollapsItems', 'FALSE');
            RecordElement.Add(Line);

            Line := XmlElement.Create('Line', '', Format(CSRfidLinesQy.Count_));
            AddAttribute(Line, 'Descrip', 'Count');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            Line := XmlElement.Create('Line', '', CSRfidLinesQy.Variant_Code);
            AddAttribute(Line, 'Descrip', 'Variant');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            Line := XmlElement.Create('Line', '', CSRfidLinesQy.Variant_Description);
            AddAttribute(Line, 'Descrip', 'VariantDesc');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            if CSRfidLinesQy.Item_Description <> '' then
                Line := XmlElement.Create('Line', '', CSRfidLinesQy.Item_Description)
            else
                Line := XmlElement.Create('Line', '', 'UNKNOWN ITEM');
            AddAttribute(Line, 'Descrip', 'ItemDesc');
            AddAttribute(Line, 'Type', Format(LineType::TEXT));
            RecordElement.Add(Line);

            Records.Add(RecordElement);
        end;

        exit(NotEmptyResult);
    end;

    local procedure AddWhseReceiptSummarize(var Records: XmlElement; CSRfidHeader: Record "NPR CS Rfid Header"): Boolean
    var
        RecordElement: XmlElement;
        Line: XmlElement;
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
            Records := XmlElement.Create('Records');

            repeat
                RecordElement := XmlElement.Create('Record');

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
                    Line := XmlElement.Create('Line', '', WhseReceiptLine."Bin Code");
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                    AddAttribute(Line, 'Indicator', Indicator);
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    AddAttribute(Line, 'CollapsItems', 'FALSE');
                    RecordElement.Add(Line);

                    //2
                    Line := XmlElement.Create('Line', '',
                        StrSubstNo(Text026, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding"));
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. Outstanding"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    //3
                    if WhseReceiptLine."Variant Code" <> '' then
                        Line := XmlElement.Create('Line', '', StrSubstNo(Text027, WhseReceiptLine."Item No.", WhseReceiptLine."Variant Code"))
                    else
                        Line := XmlElement.Create('Line', '', WhseReceiptLine."Item No.");
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Item No."));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    //4
                    Line := XmlElement.Create('Line', '', WhseReceiptLine."Unit of Measure Code");
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    //5
                    Line := XmlElement.Create('Line', '', WhseReceiptLine.Description);
                    AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    //6
                    Line := XmlElement.Create('Line', '', '');
                    AddAttribute(Line, 'Descrip', '');
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);

                    if Location.Get(WhseReceiptLine."Location Code") then
                        if Location."Bin Mandatory" then begin
                            Line := XmlElement.Create('Line');
                            AddAttribute(Line, 'Descrip', 'Split Line..');
                            AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                            AddAttribute(Line, 'TableNo', Format(TableNo));
                            AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                            AddAttribute(Line, 'FuncName', 'SPLITLINE');
                            RecordElement.Add(Line);
                        end;

                    Records.Add(RecordElement);
                end;
            until WhseReceiptLine.Next = 0;

            if WhseReceiptLine.FindSet then begin
                repeat
                    RecordElement := XmlElement.Create('Record');

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
                        Line := XmlElement.Create('Line', '', WhseReceiptLine."Bin Code");
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Indicator', Indicator);
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        AddAttribute(Line, 'CollapsItems', 'FALSE');
                        RecordElement.Add(Line);

                        //2
                        Line := XmlElement.Create('Line', '',
                            StrSubstNo(Text026, WhseReceiptLine."Qty. to Receive", WhseReceiptLine."Qty. Outstanding"));
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Qty. Outstanding"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //3
                        if WhseReceiptLine."Variant Code" <> '' then
                            Line := XmlElement.Create('Line', '', StrSubstNo(Text027, WhseReceiptLine."Item No.", WhseReceiptLine."Variant Code"))
                        else
                            Line := XmlElement.Create('Line', '', WhseReceiptLine."Item No.");
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Item No."));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //4
                        Line := XmlElement.Create('Line', '', WhseReceiptLine."Unit of Measure Code");
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption("Unit of Measure Code"));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //5
                        Line := XmlElement.Create('Line', '', WhseReceiptLine.Description);
                        AddAttribute(Line, 'Descrip', WhseReceiptLine.FieldCaption(Description));
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        //6
                        Line := XmlElement.Create('Line', '', '');
                        AddAttribute(Line, 'Descrip', '');
                        AddAttribute(Line, 'Type', Format(LineType::TEXT));
                        RecordElement.Add(Line);

                        if Location.Get(WhseReceiptLine."Location Code") then
                            if Location."Bin Mandatory" then begin
                                Line := XmlElement.Create('Line');
                                AddAttribute(Line, 'Descrip', 'Split Line..');
                                AddAttribute(Line, 'Type', Format(LineType::BUTTON));
                                AddAttribute(Line, 'TableNo', Format(TableNo));
                                AddAttribute(Line, 'RecordID', Format(CurrRecordID));
                                AddAttribute(Line, 'FuncName', 'SPLITLINE');
                                RecordElement.Add(Line);
                            end;

                        Records.Add(RecordElement);
                    end;
                until WhseReceiptLine.Next = 0;
            end;
            exit(true);
        end else
            exit(false);
    end;

    local procedure AddAttribute(var NewChild: XmlElement; AttribName: Text[250]; AttribValue: Text[250])
    begin
        NewChild.SetAttribute(AttribName, AttribValue);
    end;
}
