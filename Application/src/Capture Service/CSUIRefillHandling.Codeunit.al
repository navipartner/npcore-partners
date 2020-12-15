codeunit 6151394 "NPR CS UI Refill Handling"
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
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSMgt: Codeunit "NPR CS Management";
        RecRef: RecordRef;
        DOMxmlin: XmlDocument;
        ReturnedNode: XmlNode;
        RootNode: XmlNode;
        CSUserId: Text[250];
        Remark: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        ActiveInputField: Integer;
        CSSessionId: Text;
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text006: Label 'No input Node found.';
        Text008: Label 'Input value Length Error';
        Text013: Label 'Input value is not valid';

    local procedure ProcessInput()
    var
        FuncGroup: Record "NPR CS UI Function Group";
        RecId: RecordID;
        TextValue: Text[250];
        TableNo: Integer;
        FldNo: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        FuncFieldId: Integer;
        FuncName: Code[10];
        FuncValue: Text;
        CSTempData: Record "NPR CS Temp Data";
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CommaString: DotNet NPRNetString;
        Values: DotNet NPRNetArray;
        Separator: DotNet NPRNetString;
        Value: Text;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSTempData);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue);
        ActiveInputField := 1;

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    DeleteEmptyDataLines();
                    CSCommunication.RunPreviousUI(DOMxmlin);
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Register]) then
            SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        CSTempData: Record "NPR CS Temp Data";
        RecId: RecordID;
        TableNo: Integer;
    begin
        DeleteEmptyDataLines();
        CreateDataLine(CSTempData);

        RecId := CSTempData.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: DotNet NPRNetXmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CreateDataLine(var CSTempData: Record "NPR CS Temp Data")
    var
        NewCSTempData: Record "NPR CS Temp Data";
        LineNo: Integer;
        RecRef: RecordRef;
        Location: Record Location;
    begin
        Clear(NewCSTempData);
        NewCSTempData.SetRange(Id, CSSessionId);
        if NewCSTempData.FindLast then
            LineNo := NewCSTempData."Line No." + 1
        else
            LineNo := 1;

        Location.SetFilter(Code, LocationFilter);
        Location.FindFirst();

        CSTempData.Init;
        CSTempData.Id := CSSessionId;
        CSTempData."Line No." := LineNo;
        CSTempData."Created By" := UserId;
        CSTempData.Created := CurrentDateTime;
        CSTempData."Decription 1" := Location.Code;
        CSTempData."Decription 2" := Location.Name;
        CSTempData."Decription 3" := Location."Name 2";

        RecRef.GetTable(CSTempData);

        CSTempData."Table No." := RecRef.Number;

        CSTempData."Record Id" := CSTempData.RecordId;
        CSTempData.Insert(true);
    end;

    local procedure DeleteEmptyDataLines()
    var
        CSTempData: Record "NPR CS Temp Data";
    begin
        CSTempData.SetRange(Id, CSSessionId);
        CSTempData.DeleteAll(true);
    end;
}
