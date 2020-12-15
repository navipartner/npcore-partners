codeunit 6151353 "NPR CS UI Store Count."
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
        Text009: Label 'No Phy. Inv. Journal found %1 %2';
        CSSessionId: Text;
        Text010: Label 'There are no locations for warehouse employee %1';
        Text011: Label 'Barcode length is exceeding Bin Code max length';
        Text012: Label 'Documents not found in filter\\ %1.';
        Text013: Label 'Bin Code %1 doesn''t exist on Location Code %2';
        Text014: Label 'Location %1';
        Text015: Label '%1';
        Text027: Label '%1 | %2';
        Text030: Label '%1 / %2 / %3';
        Text031: Label 'Store Journal %1 %2 is already scheduled for posting';

    local procedure ProcessSelection()
    var
        RecId: RecordID;
        FuncGroup: Record "NPR CS UI Function Group";
        TableNo: Integer;
        WhseEmployee: Record "Warehouse Employee";
        CSStockTakes: Record "NPR CS Stock-Takes";
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSStockTakes);
            RecRef.GetTable(CSStockTakes);
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
                    Register(CSStockTakes);
                    if Remark = '' then begin
                        CSCommunication.RunPreviousUI(DOMxmlin)
                    end else
                        SendForm(ActiveInputField, CSStockTakes);
                end;
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
            SendForm(ActiveInputField, CSStockTakes);
    end;

    local procedure PrepareData()
    var
        POSStore: Record "NPR POS Store";
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        RecId: RecordID;
        TableNo: Integer;
        CSStockTakes: Record "NPR CS Stock-Takes";
        ItemJournalBatch: Record "Item Journal Batch";
        CSSetup: Record "NPR CS Setup";
        TempItemJournalBatch: Record "Item Journal Batch" temporary;
        TestRecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
    begin
        RootNode.SelectSingleNode('Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        RecRef.Get(RecId);
        RecRef.SetTable(POSStore);

        SelectLatestVersion;

        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location, POSStore."Location Code");
        CSStockTakes.SetFilter("Journal Template Name", '<>%1', '');
        CSStockTakes.SetFilter("Journal Batch Name", '<>%1', '');
        CSStockTakes.SetRange(Closed, 0DT);
        CSStockTakes.SetRange("Journal Posted", false);
        if not CSStockTakes.FindFirst then begin
            CSManagement.SendError(StrSubstNo(Text009, CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name"));
            exit;
        end else begin
            CSSetup.Get;
            if CSSetup."Post with Job Queue" then begin
                ItemJournalBatch.Get(CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");
                TestRecRef.GetTable(ItemJournalBatch);
                Clear(CSPostingBuffer);
                CSPostingBuffer.SetRange("Table No.", TestRecRef.Number);
                CSPostingBuffer.SetRange("Record Id", TestRecRef.RecordId);
                CSPostingBuffer.SetRange(Executed, false);
                if CSPostingBuffer.FindSet then begin
                    CSManagement.SendError(StrSubstNo(Text031, CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name"));
                    exit;
                end else begin
                    RecRef.GetTable(CSStockTakes);
                    CSCommunication.SetRecRef(RecRef);
                    ActiveInputField := 1;
                    SendForm(ActiveInputField, CSStockTakes);
                end;
            end else begin
                RecRef.GetTable(CSStockTakes);
                CSCommunication.SetRecRef(RecRef);
                ActiveInputField := 1;
                SendForm(ActiveInputField, CSStockTakes);
            end;
        end;
    end;

    local procedure SendForm(InputField: Integer; CSStockTakes: Record "NPR CS Stock-Takes")
    var
        Records: XmlElement;
        RootElement: XmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        DOMxmlin.GetRoot(RootElement);
        if AddSummarize(Records, CSStockTakes) then
            RootElement.Add(Records);

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure Register(CSStockTakes: Record "NPR CS Stock-Takes")
    var
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        CSSetup: Record "NPR CS Setup";
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
        ItemJournalBatch: Record "Item Journal Batch";
        PostedCSStockTakes: Record "NPR CS Stock-Takes";
    begin
        Remark := '';
        CSStockTakes.TestField(Closed, 0DT);
        CSStockTakes.TestField("Journal Posted", false);

        ItemJournalBatch.Get(CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");

        CSSetup.Get;
        if CSSetup."Post with Job Queue" then begin
            PostingRecRef.GetTable(ItemJournalBatch);
            CSPostingBuffer.Init;
            CSPostingBuffer."Table No." := PostingRecRef.Number;
            CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
            CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Store Counting";
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

            CSStockTakes.Closed := CurrentDateTime;
            CSStockTakes."Closed By" := UserId;
            CSStockTakes."Journal Posted" := true;
            CSStockTakes.Modify(true);

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

    local procedure AddSummarize(var Records: XmlElement; CSStockTakes: Record "NPR CS Stock-Takes") NotEmptyResult: Boolean
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

        CSItemJournalLines.SetRange(Journal_Template_Name, CSStockTakes."Journal Template Name");
        CSItemJournalLines.SetRange(Journal_Batch_Name, CSStockTakes."Journal Batch Name");
        CSItemJournalLines.Open;
        while CSItemJournalLines.Read do begin

            NotEmptyResult := true;

            RecordElement := XmlElement.Create('Record');

            //CurrRecordID := '';
            //TableNo := '';

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

