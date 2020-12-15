codeunit 6151374 "NPR CS UI Management"
{
    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'The Node does not exist.';

    procedure ReceiveXML(xmlin: XmlDocument)
    var
        CSUIHeader: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSManagement: Codeunit "NPR CS Management";
        DOMxmlin: XmlDocument;
        RootNode: XmlNode;
        RootElement: XmlElement;
        ReturnedNode: XmlNode;
        TextValue: Text[250];
    begin
        DOMxmlin := xmlin;
        DOMxmlin.GetRoot(RootElement);

        if RootElement.SelectSingleNode('Header', ReturnedNode) then begin
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

    procedure Initialize(var CSUIHeader: Record "NPR CS UI Header"; var Rec: Record "NPR CS UI Header";
        var DOMxmlin: XmlDocument; var ReturnedNode: XmlNode; var RootNode: XmlNode;
        var CSCommunication: Codeunit "NPR CS Communication";
        var CSUserId: Text[250]; var CurrentCode: Text[250]; var StackCode: Text[250];
        var WhseEmpId: Text[250]; var LocationFilter: Text[250]; var CSSessionId: Text[250])
    var
        RootElement: XmlElement;
        AttributeCollection: XmlAttributeCollection;
        Attribute: XmlAttribute;
    begin
        CSUIHeader := Rec;
        CSUIHeader.LoadXMLin(DOMxmlin);

        DOMxmlin.GetRoot(RootElement);
        RootNode := RootElement.AsXmlNode();

        RootNode.SelectSingleNode('Header', ReturnedNode);

        CurrentCode := CSCommunication.GetNodeAttribute(ReturnedNode, 'UseCaseCode');
        StackCode := CSCommunication.GetNodeAttribute(ReturnedNode, 'StackCode');
        CSUserId := CSCommunication.GetNodeAttribute(ReturnedNode, 'LoginID');
        CSSessionId := CSCommunication.GetNodeAttribute(ReturnedNode, 'ID');

        CSCommunication.GetWhseEmployee(CSUserId, WhseEmpId, LocationFilter);
    end;
}

