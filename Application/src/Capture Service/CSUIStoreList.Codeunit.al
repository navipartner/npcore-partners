codeunit 6151354 "NPR CS UI Store List"
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
        Text006: Label 'No input Node found.';
        Text009: Label 'No Documents found.';
        CSSessionId: Text;
        Text010: Label 'There are no locations for warehouse employee %1';
        Text011: Label 'Barcode length is exceeding Location Code max length';
        Text012: Label 'Documents not found in filter\\ %1.';

    local procedure ProcessSelection()
    var
        RecId: RecordID;
        FuncGroup: Record "NPR CS UI Function Group";
        TableNo: Integer;
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        POSStore: Record "NPR POS Store";
        Barcode: Text;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        if RecRef.Get(RecId) then begin
            RecRef.SetTable(POSStore);
            RecRef.GetTable(POSStore);
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
            FuncGroup.KeyDef::First:
                CSCommunication.FindRecRef(RecRef, 0, CSUIHeader."No. of Records in List");
            FuncGroup.KeyDef::LnDn:
                if not CSCommunication.FindRecRef(RecRef, 1, CSUIHeader."No. of Records in List") then
                    Remark := Text009;
            FuncGroup.KeyDef::LnUp:
                CSCommunication.FindRecRef(RecRef, 2, CSUIHeader."No. of Records in List");
            FuncGroup.KeyDef::Last:
                CSCommunication.FindRecRef(RecRef, 3, CSUIHeader."No. of Records in List");
            FuncGroup.KeyDef::PgDn:
                if not CSCommunication.FindRecRef(RecRef, 4, CSUIHeader."No. of Records in List") then
                    Remark := Text009;
            FuncGroup.KeyDef::PgUp:
                CSCommunication.FindRecRef(RecRef, 5, CSUIHeader."No. of Records in List");
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

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Input]) then
            SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        POSStore: Record "NPR POS Store";
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
    begin
        with POSStore do begin
            Reset;
            if WhseEmpId <> '' then begin
                if LocationFilter = '' then
                    Error(Text010, WhseEmployee."User ID");

                SetFilter("Location Code", LocationFilter);
            end;
            if not FindFirst then begin
                if CSCommunication.GetNodeAttribute(ReturnedNode, 'RunReturn') = '0' then begin
                    CSManagement.SendError(Text009);
                    exit;
                end;
                CSCommunication.DecreaseStack(DOMxmlin, PreviousCode);
                CSUIHeader2.Get(PreviousCode);
                CSUIHeader2.SaveXMLin(DOMxmlin);
                CODEUNIT.Run(CSUIHeader2."Handling Codeunit", CSUIHeader2);
            end else begin
                RecRef.GetTable(POSStore);
                CSCommunication.SetRecRef(RecRef);
                ActiveInputField := 1;
                SendForm(ActiveInputField);
            end;
        end;
    end;

    local procedure SendForm(InputField: Integer)
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSManagement.SendXMLReply(DOMxmlin);
    end;

}

