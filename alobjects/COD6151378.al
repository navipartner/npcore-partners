codeunit 6151378 "CS UI Item Detail"
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
        Text004: Label 'Invalid %1.';
        Text006: Label 'No input Node found.';
        Text007: Label 'Record not found.';
        Text008: Label 'End of Document.';
        Text012: Label 'RecordKey is empty';
        CSSessionId: Text;

    local procedure ProcessInput()
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        FuncGroup: Record "Miniform Function Group";
        RecId: RecordID;
        TextValue: Text[250];
        TableNo: Integer;
        FldNo: Integer;
        Lookup: Integer;
    begin
        CSCommunication.RunPreviousUI(DOMxmlin);
    end;

    local procedure PrepareData()
    var
        Item: Record Item;
        RecId: RecordID;
        TableNo: Integer;
    begin
        XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode);

        if CSCommunication.GetNodeAttribute(ReturnedNode,'LookupKey') = '' then
          Error(Text012);

        Evaluate(TableNo,'27');
        RecRef.Open(TableNo);
        Evaluate(RecId,'Item: ' + CSCommunication.GetNodeAttribute(ReturnedNode,'LookupKey'));
        if RecRef.Get(RecId) then begin
          CSCommunication.SetRecRef(RecRef);
          ActiveInputField := 1;
          SendForm(ActiveInputField);
        end else
          Error(Text007);
    end;

    local procedure SendForm(InputField: Integer)
    begin
        // Prepare Miniform
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSManagement.SendXMLReply(DOMxmlin);
    end;
}

