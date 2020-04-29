codeunit 6151353 "CS UI Store Counting"
{
    // NPR5.52/CLVA/20190906  CASE 365967 Object created - NP Capture Service

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          CSUIHeader,Rec,DOMxmlin,ReturnedNode,
          RootNode,XMLDOMMgt,CSCommunication,CSUserId,
          CurrentCode,StackCode,WhseEmpId,LocationFilter,CSSessionId);

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
        FuncGroup: Record "CS UI Function Group";
        TableNo: Integer;
        WhseEmployee: Record "Warehouse Employee";
        CSStockTakes: Record "CS Stock-Takes";
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(CSStockTakes);
          RecRef.GetTable(CSStockTakes);
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code,TextValue);
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
                SendForm(ActiveInputField,CSStockTakes);
            end;
          //FuncGroup.KeyDef::Reset:
          //  Reset(ItemJournalBatch);
          FuncGroup.KeyDef::First:
            begin
              //Refresh UI
            end;
          FuncGroup.KeyDef::Input:
            begin
              CSCommunication.IncreaseStack(DOMxmlin,CSUIHeader.Code);
              CSCommunication.GetNextUI(CSUIHeader,CSUIHeader2);
              CSUIHeader2.SaveXMLin(DOMxmlin);
              CODEUNIT.Run(CSUIHeader2."Handling Codeunit",CSUIHeader2);
            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Input,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField,CSStockTakes);
    end;

    local procedure PrepareData()
    var
        POSStore: Record "POS Store";
        CSUserRec: Record "CS User";
        WhseEmployee: Record "Warehouse Employee";
        RecId: RecordID;
        TableNo: Integer;
        CSStockTakes: Record "CS Stock-Takes";
        ItemJournalBatch: Record "Item Journal Batch";
        CSSetup: Record "CS Setup";
        TempItemJournalBatch: Record "Item Journal Batch" temporary;
        TestRecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));

        RecRef.Get(RecId);
        RecRef.SetTable(POSStore);

        //-NPR5.52 [365967]
        SelectLatestVersion;
        //+NPR5.52 [365967]

        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,POSStore."Location Code");
        CSStockTakes.SetFilter("Journal Template Name", '<>%1', '');
        CSStockTakes.SetFilter("Journal Batch Name", '<>%1', '');
        CSStockTakes.SetRange(Closed,0DT);
        CSStockTakes.SetRange("Journal Posted",false);
        if not CSStockTakes.FindFirst then begin
          //IF CSCommunication.GetNodeAttribute(ReturnedNode,'RunReturn') = '0' THEN BEGIN
            CSManagement.SendError(StrSubstNo(Text009,CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name"));
            exit;
          //END;
        //  CSCommunication.DecreaseStack(DOMxmlin,PreviousCode);
        //  CSUIHeader2.GET(PreviousCode);
        //  CSUIHeader2.SaveXMLin(DOMxmlin);
        //  CODEUNIT.RUN(CSUIHeader2."Handling Codeunit",CSUIHeader2);
        end else begin
          //-NPR5.52 [365967]
          CSSetup.Get;
          if CSSetup."Post with Job Queue" then begin
            ItemJournalBatch.Get(CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name");
            TestRecRef.GetTable(ItemJournalBatch);
            Clear(CSPostingBuffer);
            CSPostingBuffer.SetRange("Table No.",TestRecRef.Number);
            CSPostingBuffer.SetRange("Record Id",TestRecRef.RecordId);
            CSPostingBuffer.SetRange(Executed,false);
            if CSPostingBuffer.FindSet then begin
              CSManagement.SendError(StrSubstNo(Text031,CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name"));
              exit;
        //      CSCommunication.DecreaseStack(DOMxmlin,PreviousCode);
        //      CSUIHeader2.GET(PreviousCode);
        //      CSUIHeader2.SaveXMLin(DOMxmlin);
        //      CODEUNIT.RUN(CSUIHeader2."Handling Codeunit",CSUIHeader2);
            end else begin
              RecRef.GetTable(CSStockTakes);
              CSCommunication.SetRecRef(RecRef);
              ActiveInputField := 1;
              SendForm(ActiveInputField,CSStockTakes);
            end;
          end else begin
            RecRef.GetTable(CSStockTakes);
            CSCommunication.SetRecRef(RecRef);
            ActiveInputField := 1;
            SendForm(ActiveInputField,CSStockTakes);
          end;
        end;
    end;

    local procedure SendForm(InputField: Integer;CSStockTakes: Record "CS Stock-Takes")
    var
        Records: DotNet npNetXmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        if AddSummarize(Records,CSStockTakes) then
          DOMxmlin.DocumentElement.AppendChild(Records);

        CSManagement.SendXMLReply(DOMxmlin);
    end;

    local procedure Register(CSStockTakes: Record "CS Stock-Takes")
    var
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        CSSetup: Record "CS Setup";
        CSPostingBuffer: Record "CS Posting Buffer";
        PostingRecRef: RecordRef;
        CSPostEnqueue: Codeunit "CS Post - Enqueue";
        ItemJournalBatch: Record "Item Journal Batch";
        PostedCSStockTakes: Record "CS Stock-Takes";
    begin
        Remark := '';
        CSStockTakes.TestField(Closed,0DT);
        CSStockTakes.TestField("Journal Posted",false);

        ItemJournalBatch.Get(CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name");

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
          ItemJnlTemplate.TestField("Force Posting Report",false);

          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
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
        CSSetup: Record "CS Setup";
        ItemJournalLine: Record "Item Journal Line";
    begin
        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
        ItemJournalLine.DeleteAll;
    end;

    local procedure AddSummarize(var Records: DotNet npNetXmlElement;CSStockTakes: Record "CS Stock-Takes") NotEmptyResult: Boolean
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

        CSItemJournalLines.SetRange(Journal_Template_Name,CSStockTakes."Journal Template Name");
        CSItemJournalLines.SetRange(Journal_Batch_Name,CSStockTakes."Journal Batch Name");
        CSItemJournalLines.Open;
        while CSItemJournalLines.Read do
        begin

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
            AddAttribute(Line,'Descrip','No.');
            AddAttribute(Line,'Indicator',Indicator);
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            AddAttribute(Line,'CollapsItems','FALSE');
            Line.InnerText := CSItemJournalLines.Item_No;
            Record.AppendChild(Line);

            //2
            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Quantity');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            //Line.InnerText := FORMAT(CSItemJournalLines.Qty_Phys_Inventory);
            Line.InnerText := StrSubstNo(Text030,CSItemJournalLines.Qty_Calculated,CSItemJournalLines.Qty_Phys_Inventory,CSItemJournalLines.Quantity);
            Record.AppendChild(Line);

            //3
            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Variant');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := CSItemJournalLines.Variant_Code;
            Record.AppendChild(Line);

            //4
            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','UoM');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := CSItemJournalLines.Unit_of_Measure_Code;
            Record.AppendChild(Line);

            //5
            Item.Get(CSItemJournalLines.Item_No);
            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','ItemDesc');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := Item.Description;
            Record.AppendChild(Line);

            //6
            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := '';
            Record.AppendChild(Line);
          end else begin
            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','Description');
            AddAttribute(Line,'Indicator',Indicator);
            Line.InnerText := StrSubstNo(Text015,CSItemJournalLines.Qty_Phys_Inventory);
            Record.AppendChild(Line);

            Line := DOMxmlin.CreateElement('Line');
            AddAttribute(Line,'Descrip','No.');
            AddAttribute(Line,'Type',Format(LineType::TEXT));
            Line.InnerText := CSItemJournalLines.Item_No;
            Record.AppendChild(Line);

            if (CSItemJournalLines.Variant_Code <> '') then begin
              Line := DOMxmlin.CreateElement('Line');
              AddAttribute(Line,'Descrip','Variant');
              AddAttribute(Line,'Type',Format(LineType::TEXT));
              Line.InnerText := CSItemJournalLines.Variant_Code;
              Record.AppendChild(Line);
            end;

          end;

          Records.AppendChild(Record);
        end;

        CSItemJournalLines.Close;

        exit(NotEmptyResult);
    end;

    local procedure AddAttribute(var NewChild: DotNet npNetXmlNode;AttribName: Text[250];AttribValue: Text[250])
    begin
        if XMLDOMMgt.AddAttribute(NewChild,AttribName,AttribValue) > 0 then
          Error(Text002,AttribName);
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

