codeunit 6151383 "NPR CS UI Put Act. List"
{
    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
    begin
        MiniformMgmt.Initialize(
          MiniformHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, CSCommunication, CSUserId,
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
        CSCommunication: Codeunit "NPR CS Communication";
        CSMgt: Codeunit "NPR CS Management";
        DOMxmlin: XmlDocument;
        RootNode: XmlNode;
        ReturnedNode: XmlNode;
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
        Text000: Label 'Function not Found.';
        Text006: Label 'No input Node found.';
        Text009: Label 'No Documents found.';
        CSSessionId: Text;
        Text010: Label 'There are no locations with mandatory bin for warehouse employee %1';
        Text011: Label 'Barcode length is exciting document no. max length';
        Text012: Label 'Documents not found in filter\\ %1.';

    local procedure ProcessSelection()
    var
        WhseActivityHeader: Record "Warehouse Activity Header";
        FuncGroup: Record "NPR CS UI Function Group";
        RecId: RecordID;
        TableNo: Integer;
        Barcode: Text;
        TmpWhseActivityHeader: Record "Warehouse Activity Header";
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        Location: Record Location;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);

        Barcode := CSCommunication.GetNodeAttribute(ReturnedNode, 'Barcode');
        if Barcode <> '' then begin
            if StrLen(Barcode) > MaxStrLen(TmpWhseActivityHeader."No.") then
                Error(Text010);
            TmpWhseActivityHeader.SetRange(Type, TmpWhseActivityHeader.Type::Pick);
            TmpWhseActivityHeader.SetRange("No.", Barcode);
            if CSCommunication.SetDocumentFilter(CSUserId) then
                TmpWhseActivityHeader.SetRange("Assigned User ID", WhseEmpId);
            if MiniformHeader."Warehouse Type" = MiniformHeader."Warehouse Type"::"Advanced (Bins)" then begin

                if LocationFilter <> '' then begin
                    LocationFilter := '';

                    CSUserRec.Get(CSUserId);

                    WhseEmployee.SetCurrentKey(Default);
                    WhseEmployee.SetRange("User ID", CSUserRec.Name);
                    if WhseEmployee.FindFirst then begin
                        repeat
                            if (Location.Get(WhseEmployee."Location Code")) then begin
                                if Location."Bin Mandatory" then
                                    LocationFilter := LocationFilter + WhseEmployee."Location Code" + '|';
                            end;
                        until WhseEmployee.Next = 0;
                    end;

                    if LocationFilter <> '' then
                        LocationFilter := CopyStr(LocationFilter, 1, (StrLen(LocationFilter) - 1))
                    else
                        Error(Text010, WhseEmployee."User ID");

                    TmpWhseActivityHeader.SetFilter("Location Code", LocationFilter);

                end else
                    TmpWhseActivityHeader.SetFilter("Location Code", LocationFilter);
            end else
                TmpWhseActivityHeader.SetFilter("Location Code", LocationFilter);
            if not TmpWhseActivityHeader.FindFirst then
                Error(Text011, TmpWhseActivityHeader.GetFilters);
            RecId := TmpWhseActivityHeader.RecordId;
            CSCommunication.SetNodeAttribute(ReturnedNode, 'RecordID', Format(RecId));
        end else
            Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(WhseActivityHeader);
            WhseActivityHeader.SetCurrentKey(Type, "No.");
            WhseActivityHeader.SetRange(Type, WhseActivityHeader.Type);
            if CSCommunication.SetDocumentFilter(CSUserId) then
                WhseActivityHeader.SetRange("Assigned User ID", WhseEmpId);
            WhseActivityHeader.SetFilter("Location Code", LocationFilter);
            RecRef.GetTable(WhseActivityHeader);
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
        WhseActivityHeader: Record "Warehouse Activity Header";
        CSUserRec: Record "NPR CS User";
        WhseEmployee: Record "Warehouse Employee";
        Location: Record Location;
        TempWhseActivityHeader: Record "Warehouse Activity Header" temporary;
        TestRecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        CSSetup: Record "NPR CS Setup";
    begin
        SelectLatestVersion;

        with WhseActivityHeader do begin
            Reset;
            SetRange(Type, Type::"Put-away");
            if WhseEmpId <> '' then begin
                if CSCommunication.SetDocumentFilter(CSUserId) then
                    SetRange("Assigned User ID", WhseEmpId);

                if MiniformHeader."Warehouse Type" = MiniformHeader."Warehouse Type"::"Advanced (Bins)" then begin

                    if LocationFilter <> '' then begin
                        LocationFilter := '';

                        CSUserRec.Get(CSUserId);

                        WhseEmployee.SetCurrentKey(Default);
                        WhseEmployee.SetRange("User ID", CSUserRec.Name);
                        if WhseEmployee.FindFirst then begin
                            repeat
                                if (Location.Get(WhseEmployee."Location Code")) then begin
                                    if Location."Bin Mandatory" then
                                        LocationFilter := LocationFilter + WhseEmployee."Location Code" + '|';
                                end;
                            until WhseEmployee.Next = 0;
                        end;

                        if LocationFilter <> '' then
                            LocationFilter := CopyStr(LocationFilter, 1, (StrLen(LocationFilter) - 1))
                        else
                            Error(Text010, WhseEmployee."User ID");

                        SetFilter("Location Code", LocationFilter);

                    end else
                        SetFilter("Location Code", LocationFilter);
                end else
                    SetFilter("Location Code", LocationFilter);
            end;
            if not FindFirst then begin
                if CSCommunication.GetNodeAttribute(ReturnedNode, 'RunReturn') = '0' then begin
                    CSMgt.SendError(Text009);
                    exit;
                end;
                CSCommunication.DecreaseStack(DOMxmlin, PreviousCode);
                MiniformHeader2.Get(PreviousCode);
                MiniformHeader2.SaveXMLin(DOMxmlin);
                CODEUNIT.Run(MiniformHeader2."Handling Codeunit", MiniformHeader2);
            end else begin
                CSSetup.Get;
                if CSSetup."Post with Job Queue" then begin
                    TempWhseActivityHeader.Reset;
                    TempWhseActivityHeader.DeleteAll;
                    if WhseActivityHeader.FindFirst then begin
                        repeat
                            TestRecRef.GetTable(WhseActivityHeader);
                            Clear(CSPostingBuffer);
                            CSPostingBuffer.SetRange("Table No.", TestRecRef.Number);
                            CSPostingBuffer.SetRange("Record Id", TestRecRef.RecordId);
                            if not CSPostingBuffer.FindSet then begin
                                TempWhseActivityHeader := WhseActivityHeader;
                                TempWhseActivityHeader.Insert;
                            end;
                        until WhseActivityHeader.Next = 0;
                    end;
                    Clear(TempWhseActivityHeader);
                    if TempWhseActivityHeader.FindSet then begin
                        RecRef.GetTable(TempWhseActivityHeader);
                        CSCommunication.SetRecRef(RecRef);
                        ActiveInputField := 1;
                        SendForm(ActiveInputField);
                    end else begin
                        if CSCommunication.GetNodeAttribute(ReturnedNode, 'RunReturn') = '0' then begin
                            CSMgt.SendError(Text009);
                            exit;
                        end;
                        CSCommunication.DecreaseStack(DOMxmlin, PreviousCode);
                        MiniformHeader2.Get(PreviousCode);
                        MiniformHeader2.SaveXMLin(DOMxmlin);
                        CODEUNIT.Run(MiniformHeader2."Handling Codeunit", MiniformHeader2);
                    end;
                end else begin
                    RecRef.GetTable(WhseActivityHeader);
                    CSCommunication.SetRecRef(RecRef);
                    ActiveInputField := 1;
                    SendForm(ActiveInputField);
                end;
            end;
        end;
    end;

    local procedure SendForm(InputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSMgt.SendXMLReply(DOMxmlin);
    end;
}
