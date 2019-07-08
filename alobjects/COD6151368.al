codeunit 6151368 "CS UI Shipments List"
{
    // NPR5.50/CLVA  /20190514  CASE 352719 Object created - NP Capture Service

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
        CSManagement: Codeunit "CS Management";
        ReturnedNode: DotNet XmlNode;
        DOMxmlin: DotNet XmlDocument;
        RootNode: DotNet XmlNode;
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
        Text010: Label 'There are no locations with mandatory bin for warehouse employee %1';
        Text011: Label 'Barcode length is exciting document no. max length';
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
        debugStr: Text;
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Barcode := CSCommunication.GetNodeAttribute(ReturnedNode,'Barcode');
        if Barcode <> '' then begin
          if StrLen(Barcode) > MaxStrLen(TmpWhseShipmentHeader."No.") then
            Error(Text011);
          TmpWhseShipmentHeader.SetRange("No.",Barcode);
          if CSCommunication.SetDocumentFilter(CSUserId) then
            TmpWhseShipmentHeader.SetRange("Assigned User ID",WhseEmpId);
            if MiniformHeader."Warehouse Type" = MiniformHeader."Warehouse Type"::"Advanced (Bins)" then begin

              if LocationFilter <> '' then begin
                LocationFilter := '';

                CSUserRec.Get(CSUserId);

                WhseEmployee.SetCurrentKey(Default);
                WhseEmployee.SetRange("User ID",CSUserRec.Name);
                if WhseEmployee.FindFirst then begin
                  repeat
                    if(Location.Get(WhseEmployee."Location Code")) then begin
                      if Location."Bin Mandatory" then
                        LocationFilter := LocationFilter + WhseEmployee."Location Code" + '|';
                    end;
                  until WhseEmployee.Next = 0;
                end;

                if LocationFilter <> '' then
                  LocationFilter := CopyStr(LocationFilter,1,(StrLen(LocationFilter) - 1))
                else
                  Error(Text010,WhseEmployee."User ID");

                TmpWhseShipmentHeader.SetFilter("Location Code",LocationFilter);

              end else
                TmpWhseShipmentHeader.SetFilter("Location Code",LocationFilter);
            end else
              TmpWhseShipmentHeader.SetFilter("Location Code",LocationFilter);
          if not TmpWhseShipmentHeader.FindFirst then
            Error(Text012,TmpWhseShipmentHeader.GetFilters);
          RecId := TmpWhseShipmentHeader.RecordId;
          CSCommunication.SetNodeAttribute(ReturnedNode,'RecordID',Format(RecId));
        end else
          Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(WhseShipmentHeader);
          if CSCommunication.SetDocumentFilter(CSUserId) then
            WhseShipmentHeader.SetRange("Assigned User ID",WhseEmpId);
          WhseShipmentHeader.SetFilter("Location Code",LocationFilter);
          RecRef.GetTable(WhseShipmentHeader);
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
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        CSUserRec: Record "CS User";
        WhseEmployee: Record "Warehouse Employee";
        Location: Record Location;
    begin
        with WhseShipmentHeader do begin
          Reset;
          if WhseEmpId <> '' then begin
            if CSCommunication.SetDocumentFilter(CSUserId) then
              SetRange("Assigned User ID",WhseEmpId);
            if MiniformHeader."Warehouse Type" = MiniformHeader."Warehouse Type"::"Advanced (Bins)" then begin

              if LocationFilter <> '' then begin
                LocationFilter := '';

                CSUserRec.Get(CSUserId);

                WhseEmployee.SetCurrentKey(Default);
                WhseEmployee.SetRange("User ID",CSUserRec.Name);
                if WhseEmployee.FindFirst then begin
                  repeat
                    if(Location.Get(WhseEmployee."Location Code")) then begin
                      if Location."Bin Mandatory" then
                        LocationFilter := LocationFilter + WhseEmployee."Location Code" + '|';
                    end;
                  until WhseEmployee.Next = 0;
                end;

                if LocationFilter <> '' then
                  LocationFilter := CopyStr(LocationFilter,1,(StrLen(LocationFilter) - 1))
                else
                  Error(Text010,WhseEmployee."User ID");

                SetFilter("Location Code",LocationFilter);

              end else
                SetFilter("Location Code",LocationFilter);
            end else
              SetFilter("Location Code",LocationFilter);
          end;
          if not FindFirst then begin
            if CSCommunication.GetNodeAttribute(ReturnedNode,'RunReturn') = '0' then begin
              CSManagement.SendError(Text009);
              exit;
            end;
            CSCommunication.DecreaseStack(DOMxmlin,PreviousCode);
            MiniformHeader2.Get(PreviousCode);
            MiniformHeader2.SaveXMLin(DOMxmlin);
            CODEUNIT.Run(MiniformHeader2."Handling Codeunit",MiniformHeader2);
          end else begin
            RecRef.GetTable(WhseShipmentHeader);
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
        CSManagement.SendXMLReply(DOMxmlin);
    end;

    trigger DOMxmlin::NodeInserting(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeInserted(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoving(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeRemoved(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanging(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;

    trigger DOMxmlin::NodeChanged(sender: Variant;e: DotNet XmlNodeChangedEventArgs)
    begin
    end;
}

