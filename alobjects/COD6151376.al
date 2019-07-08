codeunit 6151376 "CS UI Logoff"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    TableNo = "CS UI Header";

    trigger OnRun()
    var
        MiniformMgt: Codeunit "CS UI Management";
    begin
        MiniformMgt.Initialize(
          MiniformHeader,Rec,DOMxmlin,ReturnedNode,
          RootNode,XMLDOMMgt,CSCommunication,CSUserId,
          CurrentCode,StackCode,WhseEmpId,LocationFilter,CSSessionId);

        if Code <> CurrentCode then
          SendForm(1)
        else
          Process;

        Clear(DOMxmlin);
    end;

    var
        MiniformHeader: Record "CS UI Header";
        MiniformHeader2: Record "CS UI Header";
        XMLDOMMgt: Codeunit "XML DOM Management";
        CSCommunication: Codeunit "CS Communication";
        CSManagement: Codeunit "CS Management";
        ReturnedNode: DotNet XmlNode;
        RootNode: DotNet XmlNode;
        DOMxmlin: DotNet XmlDocument;
        TextValue: Text[250];
        CSUserId: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        Text001: Label 'No input Node found.';
        CSSessionId: Text;

    local procedure Process()
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text001);

        CSCommunication.GetCallUI(MiniformHeader.Code,MiniformHeader2,TextValue);
        CSCommunication.IncreaseStack(DOMxmlin,MiniformHeader.Code);
        MiniformHeader2.SaveXMLin(DOMxmlin);
        CODEUNIT.Run(MiniformHeader2."Handling Codeunit",MiniformHeader2);
    end;

    local procedure SendForm(ActiveInputField: Integer)
    begin
        CSCommunication.EncodeUI(MiniformHeader,'',DOMxmlin,ActiveInputField,'',CSUserId);
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

