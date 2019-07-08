codeunit 6151389 "CS UI Transfer List"
{
    // NPR5.43/CLVA/20180518 CASE 315503 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.50/CLVA  /20190514  CASE 352719 Added support for selection by barcode

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
          ProcessSelection;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "CS UI Header";
        MiniformHeader2: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSMgt: Codeunit "CS Management";
        DOMxmlin: DotNet npNetXmlDocument;
        RootNode: DotNet npNetXmlNode;
        ReturnedNode: DotNet npNetXmlNode;
        RecRef: RecordRef;
        TextValue: Text[250];
        CSUserId: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        PreviousCode: Text[250];
        StackCode: Text[250];
        Remark: Text[250];
        ActiveInputField: Integer;
        CSSessionId: Text;
        Text000: Label 'Function not Found.';
        Text006: Label 'No input Node found.';
        Text009: Label 'No Documents found.';
        Text010: Label 'Barcode length is exciting document no. max length';
        Text011: Label 'Documents not found in filter\\ %1.';

    local procedure ProcessSelection()
    var
        TransferHeader: Record "Transfer Header";
        FuncGroup: Record "CS UI Function Group";
        RecId: RecordID;
        TableNo: Integer;
        Barcode: Text;
        TmpTransferHeader: Record "Transfer Header";
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        //-NPR5.50 [352719]
        Barcode := CSCommunication.GetNodeAttribute(ReturnedNode,'Barcode');
        if Barcode <> '' then begin
          if StrLen(Barcode) > MaxStrLen(TmpTransferHeader."No.") then
            Error(Text010);
          TmpTransferHeader.SetRange("No.",Barcode);
          TmpTransferHeader.SetFilter("Transfer-from Code",LocationFilter);
          if not TmpTransferHeader.FindFirst then
            Error(Text011,TmpTransferHeader.GetFilters);
          RecId := TmpTransferHeader.RecordId;
          CSCommunication.SetNodeAttribute(ReturnedNode,'RecordID',Format(RecId));
        end else
        //+NPR5.50 [352719]
          Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(TransferHeader);
          RecRef.GetTable(TransferHeader);
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
          FuncGroup.KeyDef::First:
            CSCommunication.FindRecRef(RecRef,0,MiniformHeader."No. of Records in List");
          FuncGroup.KeyDef::LnDn:
            if not CSCommunication.FindRecRef(RecRef,1,MiniformHeader."No. of Records in List") then
              Remark := Text009;
          FuncGroup.KeyDef::LnUp:
            CSCommunication.FindRecRef(RecRef,2,MiniformHeader."No. of Records in List");
          FuncGroup.KeyDef::Last:
            CSCommunication.FindRecRef(RecRef,3,MiniformHeader."No. of Records in List");
          FuncGroup.KeyDef::PgDn:
            if not CSCommunication.FindRecRef(RecRef,4,MiniformHeader."No. of Records in List") then
              Remark := Text009;
          FuncGroup.KeyDef::PgUp:
            CSCommunication.FindRecRef(RecRef,5,MiniformHeader."No. of Records in List");
          FuncGroup.KeyDef::Input:
            begin
              CSCommunication.IncreaseStack(DOMxmlin,MiniformHeader.Code);
              CSCommunication.GetNextUI(MiniformHeader,MiniformHeader2);
              MiniformHeader2.SaveXMLin(DOMxmlin);
              CODEUNIT.Run(MiniformHeader2."Handling Codeunit",MiniformHeader2);
            end;
          else
            Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Input]) then
          SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        TransferHeader: Record "Transfer Header";
        CSSetup: Record "CS Setup";
    begin
        CSSetup.Get;

        with TransferHeader do begin
          Reset;
          SetFilter("Transfer-from Code",LocationFilter);
          if not FindFirst then begin
            if CSCommunication.GetNodeAttribute(ReturnedNode,'RunReturn') = '0' then begin
              CSMgt.SendError(Text009);
              exit;
            end;
            CSCommunication.DecreaseStack(DOMxmlin,PreviousCode);
            MiniformHeader2.Get(PreviousCode);
            MiniformHeader2.SaveXMLin(DOMxmlin);
            CODEUNIT.Run(MiniformHeader2."Handling Codeunit",MiniformHeader2);
          end else begin
            RecRef.GetTable(TransferHeader);
            CSCommunication.SetRecRef(RecRef);
            ActiveInputField := 1;
            SendForm(ActiveInputField);
          end;
        end;
    end;

    local procedure SendForm(InputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSMgt.SendXMLReply(DOMxmlin);
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

