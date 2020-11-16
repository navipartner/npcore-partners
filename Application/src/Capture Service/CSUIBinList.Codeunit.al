codeunit 6151360 "NPR CS UI Bin List"
{
    // NPR5.51/CLVA  /20190813  CASE 362173 Object created - NP Capture Service

    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
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
        MiniformHeader: Record "NPR CS UI Header";
        MiniformHeader2: Record "NPR CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "NPR CS Communication";
        CSManagement: Codeunit "NPR CS Management";
        ReturnedNode: DotNet NPRNetXmlNode;
        DOMxmlin: DotNet "NPRNetXmlDocument";
        RootNode: DotNet NPRNetXmlNode;
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
        Text011: Label 'Barcode length is exceeding Bin Code max length';
        Text012: Label 'Documents not found in filter\\ %1.';
        Text013: Label 'Bin Code %1 doesn''t exist on Location Code %2';

    local procedure ProcessSelection()
    var
        RecId: RecordID;
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        FuncGroup: Record "NPR CS UI Function Group";
        TableNo: Integer;
        TmpWhseShipmentHeader: Record "Warehouse Shipment Header";
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        Bin: Record Bin;
        Barcode: Text;
        LocationCode: Code[10];
        xBin: Record Bin;
    begin
        if XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        Barcode := CSCommunication.GetNodeAttribute(ReturnedNode, 'Barcode');

        if RecRef.Get(RecId) then begin
            RecRef.SetTable(Bin);
            RecRef.GetTable(Bin);
            LocationCode := Bin."Location Code";
            if Barcode <> '' then begin
                if StrLen(Barcode) > MaxStrLen(Bin.Code) then
                    Error(Text011);
                if not xBin.Get(LocationCode, Barcode) then
                    Error(Text013, Barcode, LocationCode);
                RecId := xBin.RecordId;
                RecRef.Get(RecId);
                RecRef.SetTable(xBin);
                RecRef.GetTable(xBin);
                CSCommunication.SetNodeAttribute(ReturnedNode, 'RecordID', Format(RecId));
                CSCommunication.AddAttribute(ReturnedNode, 'Barcode', Barcode);
            end;
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
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        Bin: Record Bin;
        RecId: RecordID;
        TableNo: Integer;
        CSPhysInventoryHandling: Record "NPR CS Phys. Inv. Handl.";
    begin
        XMLDOMMgt.FindNode(RootNode, 'Header/Input', ReturnedNode);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));

        if TableNo = 6151396 then begin
            if RecRef.Get(RecId) then begin
                RecRef.SetTable(CSPhysInventoryHandling);
                RecRef.GetTable(CSPhysInventoryHandling);
                Location.Get(CSPhysInventoryHandling."Location Code");
                RecRef.Close;
                RecId := Location.RecordId;
                TableNo := RecId.TableNo;
                RecRef.Open(TableNo);
            end else begin
                CSCommunication.RunPreviousUI(DOMxmlin);
                exit;
            end;
        end;

        RecRef.Get(RecId);
        RecRef.SetTable(Location);

        Bin.SetRange("Location Code", Location.Code);
        if not Bin.FindFirst then begin
            if CSCommunication.GetNodeAttribute(ReturnedNode, 'RunReturn') = '0' then begin
                CSManagement.SendError(Text009);
                exit;
            end;
            CSCommunication.DecreaseStack(DOMxmlin, PreviousCode);
            MiniformHeader2.Get(PreviousCode);
            MiniformHeader2.SaveXMLin(DOMxmlin);
            CODEUNIT.Run(MiniformHeader2."Handling Codeunit", MiniformHeader2);
        end else begin
            RecRef.GetTable(Bin);
            CSCommunication.SetRecRef(RecRef);
            ActiveInputField := 1;
            SendForm(ActiveInputField);
        end;
    end;

    local procedure SendForm(InputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSManagement.SendXMLReply(DOMxmlin);
    end;
}

