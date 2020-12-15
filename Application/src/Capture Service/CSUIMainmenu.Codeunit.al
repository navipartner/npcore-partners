codeunit 6151377 "NPR CS UI Mainmenu"
{
    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgt: Codeunit "NPR CS UI Management";
    begin
        MiniformMgt.Initialize(
          MiniformHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            SendForm(1)
        else
            Process;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "NPR CS UI Header";
        MiniformHeader2: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSManagement: Codeunit "NPR CS Management";
        ReturnedNode: XmlNode;
        RootNode: XmlNode;
        DOMxmlin: XmlDocument;
        TextValue: Text[250];
        CSUserId: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        Text005: Label 'No input Node found.';
        CSSessionId: Text;
        Remark: Text[250];

    local procedure Process()
    var
        FuncGroup: Record "NPR CS UI Function Group";
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text005);

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code, TextValue);

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    CSCommunication.RunPreviousUI(DOMxmlin);
                    exit;
                end;
        end;

        CSCommunication.GetCallUI(MiniformHeader.Code, MiniformHeader2, TextValue);
        CSCommunication.IncreaseStack(DOMxmlin, MiniformHeader.Code);
        MiniformHeader2.SaveXMLin(DOMxmlin);
        CODEUNIT.Run(MiniformHeader2."Handling Codeunit", MiniformHeader2);
    end;

    local procedure SendForm(ActiveInputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader, StackCode, DOMxmlin, ActiveInputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSManagement.SendXMLReply(DOMxmlin);
    end;
}

