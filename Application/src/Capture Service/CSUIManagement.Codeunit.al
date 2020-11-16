codeunit 6151374 "NPR CS UI Management"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'The Node does not exist.';

    procedure ReceiveXML(xmlin: DotNet "NPRNetXmlDocument")
    var
        CSUIHeader: Record "NPR CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "NPR CS Communication";
        CSManagement: Codeunit "NPR CS Management";
        DOMxmlin: DotNet "NPRNetXmlDocument";
        RootNode: DotNet NPRNetXmlNode;
        ReturnedNode: DotNet NPRNetXmlNode;
        TextValue: Text[250];
    begin
        DOMxmlin := xmlin;
        RootNode := DOMxmlin.DocumentElement;
        if XMLDOMMgt.FindNode(RootNode, 'Header', ReturnedNode) then begin
            TextValue := CSCommunication.GetNodeAttribute(ReturnedNode, 'UseCaseCode');
            if UpperCase(TextValue) = 'HELLO' then
                TextValue := CSCommunication.GetLoginFormCode;
            CSUIHeader.Get(TextValue);
            CSUIHeader.TestField("Handling Codeunit");
            CSUIHeader.SaveXMLin(DOMxmlin);
            if not CODEUNIT.Run(CSUIHeader."Handling Codeunit", CSUIHeader) then
                CSManagement.SendError(GetLastErrorText);
        end else
            Error(Text001);
    end;

    procedure Initialize(var CSUIHeader: Record "NPR CS UI Header"; var Rec: Record "NPR CS UI Header"; var DOMxmlin: DotNet "NPRNetXmlDocument"; var ReturnedNode: DotNet NPRNetXmlNode; var RootNode: DotNet NPRNetXmlNode; var XMLDOMMgt: Codeunit "XML DOM Management"; var CSCommunication: Codeunit "NPR CS Communication"; var CSUserId: Text[250]; var CurrentCode: Text[250]; var StackCode: Text[250]; var WhseEmpId: Text[250]; var LocationFilter: Text[250]; var CSSessionId: Text[250])
    begin
        DOMxmlin := DOMxmlin.XmlDocument;

        CSUIHeader := Rec;
        CSUIHeader.LoadXMLin(DOMxmlin);
        RootNode := DOMxmlin.DocumentElement;
        XMLDOMMgt.FindNode(RootNode, 'Header', ReturnedNode);
        CurrentCode := CSCommunication.GetNodeAttribute(ReturnedNode, 'UseCaseCode');
        StackCode := CSCommunication.GetNodeAttribute(ReturnedNode, 'StackCode');
        CSUserId := CSCommunication.GetNodeAttribute(ReturnedNode, 'LoginID');
        CSSessionId := CSCommunication.GetNodeAttribute(ReturnedNode, 'ID');
        CSCommunication.GetWhseEmployee(CSUserId, WhseEmpId, LocationFilter);
    end;
}

