codeunit 6151365 "CS UI Location List"
{
    // NPR5.50/CLVA  /20190524  CASE 352719 Object created - NP Capture Service
    // NPR5.51/CLVA  /20190628  CASE 359093 Changed location filter
    // NPR5.51/LS  /20190709  CASE 361352 Changed text constant Text011
    // NPR5.51/CLVA  /20190813  CASE 362173 Added loop back functionality

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "CS UI Management";
    begin
        MiniformMgmt.Initialize(
          MiniformHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, XMLDOMMgt, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

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
        Text006: Label 'No input Node found.';
        Text009: Label 'No Documents found.';
        CSSessionId: Text;
        Text010: Label 'There are no locations for warehouse employee %1';
        Text011: Label 'Barcode length is exceeding Location Code max length';
        Text012: Label 'Documents not found in filter\\ %1.';

    local procedure ProcessSelection()
    var
        RecId: RecordID;
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        FuncGroup: Record "CS UI Function Group";
        TableNo: Integer;
        TmpWhseShipmentHeader: Record "Warehouse Shipment Header";
        CSUserRec: Record "CS User";
        WhseEmployee: Record "Warehouse Employee";
        Location: Record Location;
        Barcode: Text;
        Bin: Record Bin;
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        //-NPR5.51 [362173]
        if TableNo = 7354 then begin
          RecRef.Get(RecId);
          RecRef.SetTable(Bin);
          RecRef.GetTable(Bin);
          Location.Get(Bin."Location Code");
          RecRef.Close;
          RecId := Location.RecordId;
          TableNo := RecId.TableNo;
          RecRef.Open(TableNo);
        end;
        //-NPR5.51 [362173]

        if RecRef.Get(RecId) then begin
            RecRef.SetTable(Location);
            RecRef.GetTable(Location);
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
            FuncGroup.KeyDef::First:
                CSCommunication.FindRecRef(RecRef, 0, MiniformHeader."No. of Records in List");
            FuncGroup.KeyDef::LnDn:
                if not CSCommunication.FindRecRef(RecRef, 1, MiniformHeader."No. of Records in List") then
                    Remark := Text009;
            FuncGroup.KeyDef::LnUp:
                CSCommunication.FindRecRef(RecRef, 2, MiniformHeader."No. of Records in List");
            FuncGroup.KeyDef::Last:
                CSCommunication.FindRecRef(RecRef, 3, MiniformHeader."No. of Records in List");
            FuncGroup.KeyDef::PgDn:
                if not CSCommunication.FindRecRef(RecRef, 4, MiniformHeader."No. of Records in List") then
                    Remark := Text009;
            FuncGroup.KeyDef::PgUp:
                CSCommunication.FindRecRef(RecRef, 5, MiniformHeader."No. of Records in List");
            FuncGroup.KeyDef::Input:
                begin
                    CSCommunication.IncreaseStack(DOMxmlin, MiniformHeader.Code);
                    CSCommunication.GetNextUI(MiniformHeader, MiniformHeader2);
                    MiniformHeader2.SaveXMLin(DOMxmlin);
                    CODEUNIT.Run(MiniformHeader2."Handling Codeunit", MiniformHeader2);
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Input]) then
            SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        Location: Record Location;
        CSUserRec: Record "CS User";
        WhseEmployee: Record "Warehouse Employee";
        TmpLocation: Record Location;
    begin
        with Location do begin
            Reset;
            if WhseEmpId <> '' then begin

              //-NPR5.51 [359093]
              //IF LocationFilter <> '' THEN
              //  LocationFilter := COPYSTR(LocationFilter,1,(STRLEN(LocationFilter) - 1))
              //ELSE
              if LocationFilter = '' then
                Error(Text010,WhseEmployee."User ID");
              //+NPR5.51 [359093]

              SetFilter(Code,LocationFilter);

            end;
            if not FindFirst then begin
                if CSCommunication.GetNodeAttribute(ReturnedNode, 'RunReturn') = '0' then begin
                    CSManagement.SendError(Text009);
                    exit;
                end;
                CSCommunication.DecreaseStack(DOMxmlin, PreviousCode);
                MiniformHeader2.Get(PreviousCode);
                MiniformHeader2.SaveXMLin(DOMxmlin);
                CODEUNIT.Run(MiniformHeader2."Handling Codeunit", MiniformHeader2);
            end else begin
                RecRef.GetTable(Location);
                CSCommunication.SetRecRef(RecRef);
                ActiveInputField := 1;
                SendForm(ActiveInputField);
            end;
        end;
    end;

    local procedure SendForm(InputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSManagement.SendXMLReply(DOMxmlin);
    end;
}

