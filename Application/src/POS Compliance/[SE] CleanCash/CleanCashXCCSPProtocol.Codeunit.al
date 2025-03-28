﻿codeunit 6014477 "NPR CleanCash XCCSP Protocol" implements "NPR CleanCash XCCSP Interface"
{
    Access = Internal;
    // XML CleanCash Signature Protocol (XCCSP)

    // URL: http://online.cleancash.se:8081/xccsp
    // UserId: retail
    // Password: cloud
    // (use Windows authentication)

    // For testing:
    // OrgNo = 12345676890
    // PosId = retailint #note: lowercase

    // This method creates the CleanCash request based on the POS Entry
    procedure StoreReceipt(PosEntry: Record "NPR POS Entry")
    var
        RequestType: Enum "NPR CleanCash Request Type";
        RequestEntryNo: Integer;
        ResponseEntryNo: Integer;
        XccspInterface: Interface "NPR CleanCash XCCSP Interface";
    begin

        // Negatives and postives need to be on separate transactions
        XccspInterface := RequestType::RegisterSalesReceipt;
        if (XccspInterface.CreateRequest(PosEntry, RequestType::RegisterSalesReceipt, RequestEntryNo)) then
            HandleRequest(RequestEntryNo, ResponseEntryNo, true);

        XccspInterface := RequestType::RegisterReturnReceipt;
        if (XccspInterface.CreateRequest(PosEntry, RequestType::RegisterReturnReceipt, RequestEntryNo)) then
            HandleRequest(RequestEntryNo, ResponseEntryNo, true);
    end;

    // This method, products the request XML, sends the request and stores the response XML
    procedure HandleRequest(RequestEntryNo: Integer; ResponseEntryNo: Integer; Verbose: Boolean) Success: Boolean
    var
        CleanCashSetup: Record "NPR CleanCash Setup";
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        CleanCashResponse: Record "NPR CleanCash Trans. Response";
        MessageHandler: Interface "NPR CleanCash XCCSP Interface";
        CleanCashMsg: Label '[CleanCash] %1', Locked = true;
        RequestXmlDoc: XmlDocument;
        ResponseXmlDoc: XmlDocument;
    begin

        if (not CleanCashTransaction.Get(RequestEntryNo)) then
            exit(false);

        if (CleanCashTransaction."Request Send Status" = CleanCashTransaction."Request Send Status"::COMPLETE) then
            exit(false);

        CleanCashSetup.Get(CleanCashTransaction."POS Unit No.");

        CleanCashTransaction."Request Datetime" := CurrentDateTime();
        CleanCashTransaction."Request Send Status" := CleanCashTransaction."Request Send Status"::COMPLETE;

        MessageHandler := CleanCashTransaction."Request Type";

        if (not MessageHandler.GetRequestXml(CleanCashTransaction, RequestXmlDoc)) then
            exit(false);

        if (not TrySendRequest(CleanCashSetup."Connection String", RequestXmlDoc, ResponseXmlDoc)) then begin
            // Networking issue or similar - no response from service.
            CleanCashTransaction."Request Send Status" := CleanCashTransaction."Request Send Status"::FAILED;
            CleanCashResponse.SetFilter("Request Entry No.", '=%1', RequestEntryNo);
            if (not CleanCashResponse.FindLast()) then
                CleanCashResponse."Request Entry No." := RequestEntryNo;
            CleanCashResponse."Response No." += 1;
            CleanCashResponse.Init();
            CleanCashResponse."Response Datetime" := CurrentDateTime;
            CleanCashResponse."Fault Code" := CleanCashResponse."Fault Code"::CleanCashComError;
            CleanCashResponse."Fault Short Description" := 'NP LOCAL';
            CleanCashResponse."Fault Description" := CopyStr(GetLastErrorText(), 1, MaxStrLen(CleanCashResponse."Fault Description"));
            CleanCashResponse.Insert();
        end;

        if (CleanCashTransaction."Request Send Status" = CleanCashTransaction."Request Send Status"::COMPLETE) then
            MessageHandler.SerializeResponse(CleanCashTransaction, ResponseXmlDoc, ResponseEntryNo);

        CleanCashTransaction.Modify();

        if (CleanCashSetup."Show Error Message") and (Verbose) and (CleanCashTransaction."Request Send Status" <> CleanCashTransaction."Request Send Status"::COMPLETE) then
            Message(CleanCashMsg, CleanCashResponse."Fault Description");

        exit(true);
    end;

    // The try function attemps to send the request to clean cash server
    [NonDebuggable]
    [TryFunction]
    local procedure TrySendRequest(Url: Text; XmlIn: XmlDocument; var XmlOut: XmlDocument)
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ConnectionErr: Label 'CleanCash server connection error. (reason: %1)';
        InvalidConnectStringErr: Label 'The URL is expected to contain user and password such as "http://<username>:<password>@online.cleancash.se:8081/xccsp", but url is: %1';
        InvalidXmlErr: Label 'CleanCash server did not respond with a valid XML document: (response was %1)';
        RequestMethodTok: Label 'POST', Locked = true;
        UnexpectedResponseCodeErr: Label 'CleanCash service did not return with a HTTP 200 return code (return code was: %1)';
        Password: Text;
        RequestText: Text;
        ResponseText: Text;
        Username: Text;
    begin
        XmlIn.WriteTo(RequestText);
        Content.WriteFrom(RequestText);
        Content.GetHeaders(Headers);

        if (not ExtractUserNamePasswordFromUrl(Url, Username, Password)) then
            Error(InvalidConnectStringErr, Url);

        Request.Method := RequestMethodTok;
        Request.SetRequestUri(Url);
        Request.Content(Content);
        Request.GetHeaders(Headers);

        Headers.Add('Authorization', 'Basic ' + GetBasicAuthInfo(Username, Password));

        if (Client.Send(Request, Response)) then begin

            if (Response.HttpStatusCode() = 200) then begin
                Response.Content.ReadAs(ResponseText);
                if (not XmlDocument.ReadFrom(ResponseText, XmlOut)) or (ResponseText.Contains('<type>Fault</type>')) then
                    Error(InvalidXmlErr, ResponseText);
            end else
                Error(UnexpectedResponseCodeErr, Response.HttpStatusCode);
        end else
            Error(ConnectionErr, GetLastErrorText());
    end;

    [NonDebuggable]
    local procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        SubMsg: Label '%1:%2', Locked = true;
    begin
        exit(Base64Convert.ToBase64(StrSubstNo(SubMsg, Username, Password)))
    end;

    local procedure ExtractUserNamePasswordFromUrl(var Url: Text; var Username: Text; var Password: Text): Boolean
    var
        TmpText: Text;
    begin
        // expected format is http://<username>:<password>@online.cleancash.se:8081/xccsp

        if (not Url.Contains('@')) then
            exit(false);

        TmpText := Url.Substring(1, Url.IndexOf('@') - 1);
        if (TmpText.Contains('://')) then
            TmpText := TmpText.Substring(TmpText.IndexOf('://') + 3);

        if (not TmpText.Contains(':') or TmpText.StartsWith(':') or TmpText.EndsWith(':')) then
            exit(false);

        Username := TmpText.Substring(1, TmpText.IndexOf(':') - 1);
        Password := TmpText.Substring(TmpText.IndexOf(':') + 1);

        TmpText := '';
        if (Url.Contains('://')) then
            TmpText := Url.Substring(1, Url.IndexOf('://') + 2);

        TmpText += Url.Substring(Url.IndexOf('@') + 1);
        Url := TmpText;

        exit((StrLen(Url) > 0) and (StrLen(Username) > 0) and (StrLen(Password) > 0));
    end;

    procedure GetNamespace(): Text
    var
        Ns: Label 'http://www.retailinnovation.se/xccsp', Locked = true;
    begin
        exit(Ns);
    end;

    // Provides value to the dropdown selection box on POS Audit Profile Card when activating CleanCash
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'SE_CleanCash-XCCSP', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    // Default or unknown request type implementation returns false;

#pragma warning disable AA0150
    procedure CreateRequest(PosUnitNo: Code[10]; var EntryNo: Integer): Boolean
#pragma warning restore
    begin
        exit(false);
    end;

    // Default or unknown request type implementation returns false;
#pragma warning disable AA0150
    procedure CreateRequest(PosEntry: Record "NPR POS Entry"; RequestType: Enum "NPR CleanCash Request Type"; var EntryNo: Integer): Boolean
#pragma warning restore
    begin
        exit(false);
    end;

    // Default or unknown request type implementation returns false;
    procedure GetRequestXml(CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; var XmlDoc: XmlDocument) Success: Boolean
    var
    begin
        exit(false);
    end;

    // Default or unknown request type implementation returns false;
#pragma warning disable AA0150
    procedure SerializeResponse(var CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; XmlDoc: XmlDocument; var ResponseEntryNo: Integer) Success: Boolean
#pragma warning restore
    var
    begin
        exit(false);
    end;

    // Default or unknown request type implementation (no print)
    procedure AddToPrintBuffer(var LinePrintMgt: Codeunit "NPR RP Line Print Mgt."; var CleanCashTransaction: Record "NPR CleanCash Trans. Request")
    begin
    end;

    // Get the fault information returned by cleancash server
    procedure SerializeFaultInfo(Element: XmlElement; NamespaceManager: XmlNamespaceManager; var CleanCashResponse: Record "NPR CleanCash Trans. Response")
    var
        EnumAsText: Text;
        DataElement: XmlElement;
        Node: XmlNode;
    begin
        if (Element.SelectSingleNode('cc:data', NamespaceManager, Node)) then begin
            DataElement := Node.AsXmlElement();
            GetElementInnerText(NamespaceManager, DataElement, 'cc:FaultInfo/cc:Code', EnumAsText, MaxStrLen(EnumAsText));
            Evaluate(CleanCashResponse."Fault Code", EnumAsText);
#pragma warning disable AA0139
            GetElementInnerText(NamespaceManager, DataElement, 'cc:FaultInfo/cc:ShortMessage', CleanCashResponse."Fault Short Description", MaxStrLen(CleanCashResponse."Fault Short Description"));
            GetElementInnerText(NamespaceManager, DataElement, 'cc:FaultInfo/cc:Message', CleanCashResponse."Fault Description", MaxStrLen(CleanCashResponse."Fault Description"));
#pragma warning restore
        end;
    end;

    // Helper function when creating the XML request
    procedure AddElement(Name: Text; Value: Text; XmlNs: Text): XmlElement
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(Name, XmlNs);
        Element.Add(Value);
        exit(Element);
    end;

    // Helper function when decoding the XML response
    procedure GetElementInnerText(NamespaceManager: XmlNamespaceManager; Element: XmlElement; XPath: Text; var InnerText: Text; MaxLen: Integer): Boolean
    var
        Node: XmlNode;
    begin
        if (not Element.SelectSingleNode(XPath, NamespaceManager, Node)) then
            exit(false);

        InnerText := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxLen);
        exit(true);
    end;
}
