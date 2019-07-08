codeunit 6151377 "CS UI Mainmenu"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180604 CASE 304872 Added ESC functionality to selection lists

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
        ReturnedNode: DotNet npNetXmlNode;
        RootNode: DotNet npNetXmlNode;
        DOMxmlin: DotNet npNetXmlDocument;
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
        FuncGroup: Record "CS UI Function Group";
    begin
        if XMLDOMMgt.FindNode(RootNode,'Header/Input',ReturnedNode) then
          TextValue := ReturnedNode.InnerText
        else
          Error(Text005);

        //-NPR5.43 [304872]
        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(MiniformHeader.Code,TextValue);

        case FuncGroup.KeyDef of
          FuncGroup.KeyDef::Esc: begin
              CSCommunication.RunPreviousUI(DOMxmlin);
              exit;
            end;
        end;
        //+NPR5.43 [304872]

        CSCommunication.GetCallUI(MiniformHeader.Code,MiniformHeader2,TextValue);
        CSCommunication.IncreaseStack(DOMxmlin,MiniformHeader.Code);
        MiniformHeader2.SaveXMLin(DOMxmlin);
        CODEUNIT.Run(MiniformHeader2."Handling Codeunit",MiniformHeader2);
    end;

    local procedure SendForm(ActiveInputField: Integer)
    begin
        //-NPR5.43 [304872]
        //CSCommunication.EncodeUI(MiniformHeader,'',DOMxmlin,ActiveInputField,'',CSUserId);
        CSCommunication.EncodeUI(MiniformHeader,StackCode,DOMxmlin,ActiveInputField,Remark,CSUserId);
        //+NPR5.43 [304872]
        CSCommunication.GetReturnXML(DOMxmlin);
        CSManagement.SendXMLReply(DOMxmlin);
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

