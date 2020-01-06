codeunit 6151359 "CS UI Phy. Inv. Journal List"
{
    // NPR5.51/CLVA  /20190820  CASE 365659 Object created - NP Capture Service
    // NPR5.52/CLVA  /20190904  CASE 365967 added "Post with Job Queue" functionality

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
        Text027: Label '%1 | %2';
        Text030: Label '%1 / %2 / %3';

    local procedure ProcessSelection()
    var
        RecId: RecordID;
        FuncGroup: Record "CS UI Function Group";
        TableNo: Integer;
        WhseEmployee: Record "Warehouse Employee";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
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

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Input,FuncGroup.KeyDef::Register]) then
            SendForm(ActiveInputField, ItemJournalBatch);
    end;

    local procedure PrepareData()
    var
        Location: Record Location;
        CSUserRec: Record "CS User";
        WhseEmployee: Record "Warehouse Employee";
        RecId: RecordID;
        TableNo: Integer;
        CSPhysInventoryHandling: Record "CS Phys. Inventory Handling";
        ItemJournalBatch: Record "Item Journal Batch";
        CSSetup: Record "CS Setup";
        TempItemJournalBatch: Record "Item Journal Batch" temporary;
        TestRecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
    begin
        XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        // IF TableNo = 6151396 THEN BEGIN
        //  IF RecRef.GET(RecId) THEN BEGIN
        //    RecRef.SETTABLE(CSPhysInventoryHandling);
        //    RecRef.GETTABLE(CSPhysInventoryHandling);
        //    Location.GET(CSPhysInventoryHandling."Location Code");
        //    RecRef.CLOSE;
        //    RecId := Location.RECORDID;
        //    TableNo := RecId.TABLENO;
        //    RecRef.OPEN(TableNo);
        //  END ELSE BEGIN
        //    CSCommunication.RunPreviousUI(DOMxmlin);
        //    EXIT;
        //  END;
        // END;

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

        //-NPR5.52 [365967]
        SelectLatestVersion;
        //+NPR5.52 [365967]

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
          //-NPR5.52 [365967]
          CSSetup.Get;
          if CSSetup."Post with Job Queue" then begin
            TempItemJournalBatch.Reset;
            TempItemJournalBatch.DeleteAll;
            if ItemJournalBatch.FindFirst then begin
              repeat
                TestRecRef.GetTable(ItemJournalBatch);
                Clear(CSPostingBuffer);
                CSPostingBuffer.SetRange("Table No.",TestRecRef.Number);
                CSPostingBuffer.SetRange("Record Id",TestRecRef.RecordId);
                CSPostingBuffer.SetRange(Executed,false);
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
              SendForm(ActiveInputField,ItemJournalBatch);
            end else begin
              CSCommunication.DecreaseStack(DOMxmlin,PreviousCode);
              CSUIHeader2.Get(PreviousCode);
              CSUIHeader2.SaveXMLin(DOMxmlin);
              CODEUNIT.Run(CSUIHeader2."Handling Codeunit",CSUIHeader2);
            end;
          end else begin
          //+NPR5.52 [365967]
            RecRef.GetTable(ItemJournalBatch);
            CSCommunication.SetRecRef(RecRef);
            ActiveInputField := 1;
            SendForm(ActiveInputField,ItemJournalBatch);
          //-NPR5.52 [365967]
          end;
          //+NPR5.52 [365967]
        end;
    end;

    local procedure SendForm(InputField: Integer; ItemJournalBatch: Record "Item Journal Batch")
    var
        Records: DotNet npNetXmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records, ItemJournalBatch) then
            DOMxmlin.DocumentElement.AppendChild(Records);

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure Register(ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        CSSetup: Record "CS Setup";
        CSPostingBuffer: Record "CS Posting Buffer";
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "CS Post - Enqueue";
    begin
        //-NPR5.52 [365967]
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
        //+NPR5.52 [365967]
          ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
          ItemJnlTemplate.TestField("Force Posting Report",false);

          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
          if ItemJournalLine.FindSet then begin
            repeat
              ItemJnlPostBatch.Run(ItemJournalLine);
            until ItemJournalLine.Next = 0;
          end;
        //-NPR5.52 [365967]
        end;
        //+NPR5.52 [365967]
    end;

    local procedure Reset(ItemJournalBatch: Record "Item Journal Batch")
    var
        CSSetup: Record "CS Setup";
        ItemJournalLine: Record "Item Journal Line";
    begin
        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.DeleteAll;
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement; ItemJournalBatch: Record "Item Journal Batch") NotEmptyResult: Boolean
    var
        "Record": DotNet npNetXmlElement;
        Line: DotNet npNetXmlElement;
        Indicator: Text;
        LineType: Option TEXT,BUTTON;
        CurrRecordID: RecordID;
        TableNo: Integer;
        CSSetup: Record "CS Setup";
        Item: Record Item;
        CSItemJournalLines: Query "CS Item Journal Lines";
    begin
        SelectLatestVersion;

        Records := DOMxmlin.CreateElement('Records');

        CSItemJournalLines.SetRange(Journal_Template_Name, ItemJournalBatch."Journal Template Name");
        CSItemJournalLines.SetRange(Journal_Batch_Name, ItemJournalBatch.Name);
        CSItemJournalLines.Open;
        while CSItemJournalLines.Read do begin

            NotEmptyResult := true;

            Record := DOMxmlin.CreateElement('Record');

            //CurrRecordID := '';
            //TableNo := '';

            if CSItemJournalLines.Changed_by_User then
                Indicator := 'ok'
            else
                Indicator := 'minus';


            if CSUIHeader."Expand Summary Items" then begin
                //1
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'No.');
                AddAttribute(Line, 'Indicator', Indicator);
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                AddAttribute(Line, 'CollapsItems', 'FALSE');
                Line.InnerText := CSItemJournalLines.Item_No;
                Record.AppendChild(Line);

                //2
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'Quantity');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                //Line.InnerText := FORMAT(CSItemJournalLines.Qty_Phys_Inventory);
                Line.InnerText := StrSubstNo(Text030, CSItemJournalLines.Qty_Calculated, CSItemJournalLines.Qty_Phys_Inventory, CSItemJournalLines.Quantity);
                Record.AppendChild(Line);

                //3
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'Variant');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                Line.InnerText := CSItemJournalLines.Variant_Code;
                Record.AppendChild(Line);

                //4
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'UoM');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                Line.InnerText := CSItemJournalLines.Unit_of_Measure_Code;
                Record.AppendChild(Line);

                //5
                Item.Get(CSItemJournalLines.Item_No);
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'ItemDesc');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                Line.InnerText := Item.Description;
                Record.AppendChild(Line);

                //6
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', '');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                Line.InnerText := '';
                Record.AppendChild(Line);
            end else begin
                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'Description');
                AddAttribute(Line, 'Indicator', Indicator);
                Line.InnerText := StrSubstNo(Text015, CSItemJournalLines.Qty_Phys_Inventory);
                Record.AppendChild(Line);

                Line := DOMxmlin.CreateElement('Line');
                AddAttribute(Line, 'Descrip', 'No.');
                AddAttribute(Line, 'Type', Format(LineType::TEXT));
                Line.InnerText := CSItemJournalLines.Item_No;
                Record.AppendChild(Line);

                if (CSItemJournalLines.Variant_Code <> '') then begin
                    Line := DOMxmlin.CreateElement('Line');
                    AddAttribute(Line, 'Descrip', 'Variant');
                    AddAttribute(Line, 'Type', Format(LineType::TEXT));
                    Line.InnerText := CSItemJournalLines.Variant_Code;
                    Record.AppendChild(Line);
                end;

            end;

            Records.AppendChild(Record);
        end;

        CSItemJournalLines.Close;

        exit(NotEmptyResult);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode; AttribName: Text[250]; AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild, AttribName, AttribValue) > 0 then
            Error(Text002, AttribName);
    end;
}

