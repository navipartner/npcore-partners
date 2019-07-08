codeunit 6151394 "CS UI Refill Handling"
{
    // NPR5.50/CLVA/20190114 CASE 247747 Object created - NP Capture Service

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
          ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSMgt: Codeunit "CS Management";
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
        CSSessionId: Text;
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text006: Label 'No input Node found.';
        Text008: Label 'Input value Length Error';
        Text013: Label 'Input value is not valid';

    local procedure ProcessInput()
    var
        FuncGroup: Record "CS UI Function Group";
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
        CSTempData: Record "CS Temp Data";
        CSFieldDefaults: Record "CS Field Defaults";
        CommaString: DotNet npNetString;
        Values: DotNet npNetArray;
        Separator: DotNet npNetString;
        Value: Text;
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text006);

        Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
        if RecRef.Get(RecId) then begin
          RecRef.SetTable(CSTempData);
          RecRef.SetRecFilter;
          CSCommunication.SetRecRef(RecRef);
        end else begin
          CSCommunication.RunPreviousUI(DOMxmlin);
          exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code,TextValue);
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

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc,FuncGroup.KeyDef::Register]) then
          SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        CSTempData: Record "CS Temp Data";
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
        Records: DotNet npNetXmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);

        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CreateDataLine(var CSTempData: Record "CS Temp Data")
    var
        NewCSTempData: Record "CS Temp Data";
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

        Location.SetFilter(Code,LocationFilter);
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
        CSTempData: Record "CS Temp Data";
    begin
        CSTempData.SetRange(Id,CSSessionId);
        CSTempData.DeleteAll(true);
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

