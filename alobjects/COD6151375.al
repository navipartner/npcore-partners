codeunit 6151375 "CS UI Logon"
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

        if CSCommunication.GetNodeAttribute(ReturnedNode,'RunReturn') = '0' then begin
          if Code <> CurrentCode then
            PrepareData
          else
            ProcessInput;
        end else
          PrepareData;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "CS UI Header";
        MiniformHeader2: Record "CS UI Header";
        CSUser: Record "CS User";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSManagement: Codeunit "CS Management";
        RecRef: RecordRef;
        DOMxmlin: DotNet XmlDocument;
        ReturnedNode: DotNet XmlNode;
        RootNode: DotNet XmlNode;
        CSUserId: Text[250];
        Remark: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        ActiveInputField: Integer;
        Text001: Label 'Invalid User ID.';
        Text002: Label 'Invalid Password.';
        Text003: Label 'No input Node found.';
        Text004: Label 'Record not found.';
        DebugTxt: Text;
        CSSessionId: Text;

    local procedure ProcessInput()
    var
        FuncGroup: Record "CS UI Function Group";
        RecId: RecordID;
        TableNo: Integer;
        FldNo: Integer;
        TextValue: Text[250];
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text003);

        if Evaluate(TableNo,CSCommunication.GetNodeAttribute(ReturnedNode,'TableNo')) then begin
          RecRef.Open(TableNo);
          Evaluate(RecId,CSCommunication.GetNodeAttribute(ReturnedNode,'RecordID'));
          if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSUser);
            CSCommunication.SetRecRef(RecRef);
          end else
            Error(Text004);
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code,TextValue);

        case FuncGroup.KeyDef of
          FuncGroup.KeyDef::Esc:
            PrepareData;
          FuncGroup.KeyDef::Input:
            begin
              Evaluate(FldNo,CSCommunication.GetNodeAttribute(ReturnedNode,'FieldID'));
              case FldNo of
                CSUser.FieldNo(Name):
                  if not GetUser(UpperCase(TextValue)) then
                    exit;
                CSUser.FieldNo(Password):
                  if not CheckPassword(TextValue) then
                    exit;
                else begin
                  CSCommunication.FieldSetvalue(RecRef,FldNo,TextValue);
                  RecRef.SetTable(CSUser);
                end;
              end;

              ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode,FldNo);
              if CSCommunication.LastEntryField(CurrentCode,FldNo) then begin
                CSCommunication.GetNextUI(MiniformHeader,MiniformHeader2);
                MiniformHeader2.SaveXMLin(DOMxmlin);
                CODEUNIT.Run(MiniformHeader2."Handling Codeunit",MiniformHeader2);
              end else
                ActiveInputField += 1;

              RecRef.GetTable(CSUser);
              CSCommunication.SetRecRef(RecRef);
            end;
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc]) and
           not CSCommunication.LastEntryField(CurrentCode,FldNo)
        then
          SendForm(ActiveInputField);
    end;

    local procedure GetUser(TextValue: Text[250]) ReturnValue: Boolean
    var
        WhseEmployee: Record "Warehouse Employee";
        NewCSUser: Record "CS User";
    begin
        if CSUser.Get(TextValue) then begin
          CSUserId := CSUser.Name;
          CSUser.Password := '';
          if not CSCommunication.GetWhseEmployee(CSUserId,WhseEmpId,LocationFilter) then begin
            CSManagement.SendError(Text001);
            ReturnValue := false;
            exit;
          end;
        end else begin
          WhseEmployee.SetCurrentKey(Default);
          WhseEmployee.SetRange("User ID",TextValue);
          if WhseEmployee.FindFirst then begin
            NewCSUser.Name := TextValue;
            NewCSUser.Insert;
            CSUserId := NewCSUser.Name;
            NewCSUser.Password := '';
            if not CSCommunication.GetWhseEmployee(CSUserId,WhseEmpId,LocationFilter) then begin
              CSManagement.SendError(Text001);
              ReturnValue := false;
              exit;
            end;
          end else begin
            CSManagement.SendError(Text001);
            ReturnValue := false;
            exit;
          end;
        end;
        ReturnValue := true;
    end;

    local procedure CheckPassword(TextValue: Text[250]) ReturnValue: Boolean
    begin
        CSUser.Get(CSUserId);

        if (CSUser.Password = '') and (TextValue <> '') then begin
          CSUser.Password := CSUser.CalculatePassword(CopyStr(TextValue,1,30));
          CSUser.Modify;
        end;

        if CSUser.Password <> CSUser.CalculatePassword(CopyStr(TextValue,1,30)) then begin
          CSManagement.SendError(Text002);
          ReturnValue := false;
          exit;
        end;
        ReturnValue := true;
    end;

    local procedure PrepareData()
    begin
        ActiveInputField := 1;
        SendForm(ActiveInputField);
    end;

    local procedure SendForm(InputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,InputField,Remark,CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        DebugTxt := DOMxmlin.OuterXml;
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

