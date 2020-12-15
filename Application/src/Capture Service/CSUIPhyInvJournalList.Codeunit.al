codeunit 6151359 "NPR CS UI Phy.Inv.Journal List"
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
        Text027: Label '%1 | %2';
        Text030: Label '%1 / %2 / %3';

    local procedure ProcessSelection()
    var
        RecId: RecordID;
        FuncGroup: Record "NPR CS UI Function Group";
        TableNo: Integer;
        WhseEmployee: Record "Warehouse Employee";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(ItemJournalBatch);
            RecRef.GetTable(ItemJournalBatch);
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
                    Register(ItemJournalBatch);
                    if Remark = '' then begin
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField, ItemJournalBatch);
                end;
            FuncGroup.KeyDef::Reset:
                Reset(ItemJournalBatch);
            FuncGroup.KeyDef::First:
                begin
                    //Refresh UI
                end;
            FuncGroup.KeyDef::Input:
                begin
                    CSCommunication.IncreaseStack(DOMxmlin, CSUIHeader.Code);
                    CSCommunication.GetNextUI(CSUIHeader, CSUIHeader2);
                    CSUIHeader2.SaveXMLin(DOMxmlin);
                    CODEUNIT.Run(CSUIHeader2."Handling Codeunit", CSUIHeader2);
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Input, FuncGroup.KeyDef::Register]) then
            SendForm(ActiveInputField, ItemJournalBatch);
    end;

    local procedure PrepareData()
    var
        Location: Record Location;
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        RecId: RecordID;
        TableNo: Integer;
        CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.";
        ItemJournalBatch: Record "Item Journal Batch";
        CSSetup: Record "NPR CS Setup";
        TempItemJournalBatch: Record "Item Journal Batch" temporary;
        TestRecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
    begin
        RootNode.AsXmlElement().SelectSingleNode('Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Get(RecId);
        RecRef.SetTable(Location);

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");
        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name", Location.Code) then begin
            ItemJournalBatch.Init;
            ItemJournalBatch.Validate("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
            ItemJournalBatch.Validate(Name, Location.Code);
            ItemJournalBatch.Description := StrSubstNo(Text014, Location.Code);
            ItemJournalBatch.Validate("No. Series", CSSetup."Phys. Inv Jour No. Series");
            ItemJournalBatch.Insert(true);
        end;

        SelectLatestVersion;

        Clear(ItemJournalBatch);
        ItemJournalBatch.SetRange("Journal Template Name", CSSetup."Phys. Inv Jour Temp Name");
        ItemJournalBatch.SetRange(Name, Location.Code);
        if not ItemJournalBatch.FindFirst then begin
            if CSCommunication.GetNodeAttribute(ReturnedNode, 'RunReturn') = '0' then begin
                CSManagement.SendError(Text009);
                exit;
            end;
            CSCommunication.DecreaseStack(DOMxmlin, PreviousCode);
            CSUIHeader2.Get(PreviousCode);
            CSUIHeader2.SaveXMLin(DOMxmlin);
            CODEUNIT.Run(CSUIHeader2."Handling Codeunit", CSUIHeader2);
        end else begin
            CSSetup.Get;
            if CSSetup."Post with Job Queue" then begin
                TempItemJournalBatch.Reset;
                TempItemJournalBatch.DeleteAll;
                if ItemJournalBatch.FindFirst then begin
                    repeat
                        TestRecRef.GetTable(ItemJournalBatch);
                        Clear(CSPostingBuffer);
                        CSPostingBuffer.SetRange("Table No.", TestRecRef.Number);
                        CSPostingBuffer.SetRange("Record Id", TestRecRef.RecordId);
                        CSPostingBuffer.SetRange(Executed, false);
                        if not CSPostingBuffer.FindSet then begin
                            TempItemJournalBatch := ItemJournalBatch;
                            TempItemJournalBatch.Insert;
                        end;
                    until ItemJournalBatch.Next = 0;
                end;
                Clear(TempItemJournalBatch);
                if TempItemJournalBatch.FindSet then begin
                    RecRef.GetTable(TempItemJournalBatch);
                    CSCommunication.SetRecRef(RecRef);
                    ActiveInputField := 1;
                    SendForm(ActiveInputField, ItemJournalBatch);
                end else begin
                    CSCommunication.DecreaseStack(DOMxmlin, PreviousCode);
                    CSUIHeader2.Get(PreviousCode);
                    CSUIHeader2.SaveXMLin(DOMxmlin);
                    CODEUNIT.Run(CSUIHeader2."Handling Codeunit", CSUIHeader2);
                end;
            end else begin
                RecRef.GetTable(ItemJournalBatch);
                CSCommunication.SetRecRef(RecRef);
                ActiveInputField := 1;
                SendForm(ActiveInputField, ItemJournalBatch);
            end;
        end;
    end;

    local procedure SendForm(InputField: Integer; ItemJournalBatch: Record "Item Journal Batch")
    var
        Records: XmlElement;
        RootElement: XmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records, ItemJournalBatch) then begin
            DOMxmlin.GetRoot(RootElement);
            RootElement.Add(Records);
        end;

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure Register(ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        CSSetup: Record "NPR CS Setup";
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
    begin
        CSSetup.Get;
        if CSSetup."Post with Job Queue" then begin
            PostingRecRef.GetTable(ItemJournalBatch);
            CSPostingBuffer.Init;
            CSPostingBuffer."Table No." := PostingRecRef.Number;
            CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
            CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Phy. Inv. Journal";
            CSPostingBuffer."Job Queue Priority for Post" := 1;
            if CSPostingBuffer.Insert(true) then
                CSPostEnqueue.Run(CSPostingBuffer)
            else
                Remark := GetLastErrorText;
        end else begin
            ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
            ItemJnlTemplate.TestField("Force Posting Report", false);

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
            if ItemJournalLine.FindSet then begin
                repeat
                    ItemJnlPostBatch.Run(ItemJournalLine);
                until ItemJournalLine.Next = 0;
            end;
        end;
    end;

    local procedure Reset(ItemJournalBatch: Record "Item Journal Batch")
    var
        CSSetup: Record "NPR CS Setup";
        ItemJournalLine: Record "Item Journal Line";
    begin
        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.DeleteAll;
    end;

    local procedure AddSummarize(var Records: XmlElement; ItemJournalBatch: Record "Item Journal Batch") NotEmptyResult: Boolean
    var
        RecordElement: XmlElement;
        Line: XmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSSetup: Record "NPR CS Setup";
        Item: Record Item;
        CSItemJournalLines: Query "NPR CS Item Journal Lines";
    begin
        SelectLatestVersion;

        Records := XmlElement.Create('Records');

        CSItemJournalLines.SetRange(Journal_Template_Name, ItemJournalBatch."Journal Template Name");
        CSItemJournalLines.SetRange(Journal_Batch_Name, ItemJournalBatch.Name);
        CSItemJournalLines.Open;
        while CSItemJournalLines.Read do begin

            NotEmptyResult := true;

            RecordElement := XmlElement.Create('Record');

            if CSItemJournalLines.Changed_by_User then
                Indicator := 'ok'
            else
                Indicator := 'minus';


            if CSUIHeader."Expand Summary Items" then begin
                //1
                Line := XmlElement.Create('Line', '', CSItemJournalLines.Item_No);
                AddAttribute(Line, 'Descrip', 'No.');
                AddAttribute(Line, 'Indicator', Indicator);
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                AddAttribute(Line, 'CollapsItems', 'FALSE');
                RecordElement.Add(Line);

                //2
                Line := XmlElement.Create('Line', '',
                    StrSubstNo(Text030, CSItemJournalLines.Qty_Calculated, CSItemJournalLines.Qty_Phys_Inventory, CSItemJournalLines.Quantity));
                AddAttribute(Line, 'Descrip', 'Quantity');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                //3
                Line := XmlElement.Create('Line', '', CSItemJournalLines.Variant_Code);
                AddAttribute(Line, 'Descrip', 'Variant');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                //4
                Line := XmlElement.Create('Line', '', CSItemJournalLines.Unit_of_Measure_Code);
                AddAttribute(Line, 'Descrip', 'UoM');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                //5
                Item.Get(CSItemJournalLines.Item_No);
                Line := XmlElement.Create('Line', '', Item.Description);
                AddAttribute(Line, 'Descrip', 'ItemDesc');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                //6
                Line := XmlElement.Create('Line', '', '');
                AddAttribute(Line, 'Descrip', '');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);
            end else begin
                Line := XmlElement.Create('Line', '', StrSubstNo(Text015, CSItemJournalLines.Qty_Phys_Inventory));
                AddAttribute(Line, 'Descrip', 'Description');
                AddAttribute(Line, 'Indicator', Indicator);
                RecordElement.Add(Line);

                Line := XmlElement.Create('Line', '', CSItemJournalLines.Item_No);
                AddAttribute(Line, 'Descrip', 'No.');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                RecordElement.Add(Line);

                if (CSItemJournalLines.Variant_Code <> '') then begin
                    Line := XmlElement.Create('Line', '', CSItemJournalLines.Variant_Code);
                    AddAttribute(Line, 'Descrip', 'Variant');
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    RecordElement.Add(Line);
                end;
            end;
            Records.Add(RecordElement);
        end;
        CSItemJournalLines.Close;
        exit(NotEmptyResult);
    end;

    local procedure AddAttribute(var NewChild: XmlElement; AttribName: Text[250]; AttribValue: Text[250])
    begin
        NewChild.SetAttribute(AttribName, AttribValue);
    end;
}

