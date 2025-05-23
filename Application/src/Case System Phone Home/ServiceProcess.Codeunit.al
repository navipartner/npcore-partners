﻿codeunit 6014483 "NPR Service Process"
{
    Access = Internal;

    TableNo = "NPR Retail List";

    trigger OnRun()
    var
        AmountUsed: Decimal;
    begin
        if StrLen(Rec.Value) > 0 then begin
            if Evaluate(AmountUsed, Rec.Value) then;
            AmountUsed := AmountUsed / 100;
            if not ProcessServiceAmount(CopyStr(Rec.Choice, 1, 20), AmountUsed) then
                Rec.Chosen := false;
        end else
            if not ProcessService(CopyStr(Rec.Choice, 1, 20)) then
                Rec.Chosen := false;
    end;

    var
        SMSSetup: Record "NPR SMS Setup";
        ServiceLibraryNamespaceUri: Label 'urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary', Locked = true;

    local procedure IsUserSubscribed(SubscriptionUserId: Text[50]; CustomerNo: Code[20]; ServiceId: Code[20]): Boolean
    var
        ServiceMethod: Text;
        BodyXmlText: Text;
        BodyXmlLbl: Label '<userID>%1</userID><customerNo>%2</customerNo><serviceId>%3</serviceId>', Locked = true;
    begin
        ServiceMethod := 'IsUserSubscribed';
        BodyXmlText := StrSubstNo(BodyXmlLbl, SubscriptionUserId, CustomerNo, ServiceId);
        exit(InvokeServiceLibrary(ServiceMethod, BodyXmlText));

    end;

    local procedure IsCustomerSubscribed(CustomerNo: Code[20]; ServiceId: Code[20]): Boolean
    var
        ServiceMethod: Text;
        BodyXmlText: Text;
        BodyXmlLbl: Label '<customerNo>%1</customerNo><serviceId>%2</serviceId>', Locked = true;
    begin
        ServiceMethod := 'IsCustomerSubscribed';
        BodyXmlText := StrSubstNo(BodyXmlLbl, CustomerNo, ServiceId);
        exit(InvokeServiceLibrary(ServiceMethod, BodyXmlText));
    end;

    local procedure CreateUserAccount(SubscriptionUserId: Text[50]; CustomerNo: Code[20]; ServiceId: Code[20]): Boolean
    var
        ServiceMethod: Text;
        BodyXmlText: Text;
        BodyXmlLbl: Label '<userId>%1</userId><customerNo>%2</customerNo><serviceId>%3</serviceId>', Locked = true;
    begin
        ServiceMethod := 'CreateUserAccount';
        BodyXmlText := StrSubstNo(BodyXmlLbl, SubscriptionUserId, CustomerNo, ServiceId);
        exit(InvokeServiceLibrary(ServiceMethod, BodyXmlText));
    end;

    local procedure CreateTransactionLogEntry(SubscriptionUserId: Text[50]; CustomerNo: Code[20]; ServiceId: Code[20]): Boolean
    var
        ServiceMethod: Text;
        BodyXmlText: Text;
        BodyXmlLbl: Label '<userId>%1</userId><customerNo>%2</customerNo><serviceId>%3</serviceId>', Locked = true;
    begin
        ServiceMethod := 'CreateTransactionLog';
        BodyXmlText := StrSubstNo(BodyXmlLbl, SubscriptionUserId, CustomerNo, ServiceId);
        exit(InvokeServiceLibrary(ServiceMethod, BodyXmlText));
    end;

    local procedure CreateTransactionLogEntryAmt(SubscriptionUserId: Text[50]; CustomerNo: Code[20]; Quantity: Decimal; Description: Text[50]; Amount: Decimal): Boolean
    var
        ServiceMethod: Text;
        BodyXmlText: Text;
        BodyXmlLbl: Label '<userId>%1</userId><customerNo>%2</customerNo><quantity>%3</quantity><description>%4</description><amount>%5</amount>', Locked = true;
    begin
        ServiceMethod := 'CreateTransacLogAmt';
        BodyXmlText := StrSubstNo(BodyXmlLbl, SubscriptionUserId, CustomerNo, Format(Quantity, 0, 9), Description, Format(Amount, 0, 9));
        exit(InvokeServiceLibrary(ServiceMethod, BodyXmlText));
    end;

    local procedure ProcessService(serviceid: Code[20]): Boolean
    var
        UserSubscribed: Boolean;
        CustomerSubscribed: Boolean;
        ServiceUsed: Boolean;
        CustomerNo: Code[20];
        SubscriptionUserId: Text[50];
    begin
        if SMSSetup.Get() then begin
            SubscriptionUserId := ''; //Unknown in webclient
            CustomerNo := SMSSetup."Customer No.";
            UserSubscribed := IsUserSubscribed(SubscriptionUserId, CustomerNo, serviceid);
            if not UserSubscribed then begin
                CustomerSubscribed := IsCustomerSubscribed(CustomerNo, serviceid);
                if CustomerSubscribed then begin
                    CreateUserAccount(SubscriptionUserId, CustomerNo, serviceid);
                    CreateTransactionLogEntry(CopyStr(UserId, 1, 50), CustomerNo, serviceid);
                    ServiceUsed := true;
                end;

            end else begin
                CreateTransactionLogEntry(SubscriptionUserId, CustomerNo, serviceid);
                ServiceUsed := true;
            end;
        end;
        exit(ServiceUsed);
    end;

    local procedure ProcessServiceAmount(ServiceId: Code[20]; AmountUsed: Decimal): Boolean
    var
        UserSubscribed: Boolean;
        CustomerSubscribed: Boolean;
        ServiceUsed: Boolean;
        CustomerNo: Code[20];
        SubscriptionUserId: Text[50];
        QtyUsed: Decimal;
        LogDescription: Text[50];
    begin
        if SMSSetup.Get() then begin
            SubscriptionUserId := ''; //Unknown in webclient
            CustomerNo := SMSSetup."Customer No.";
            UserSubscribed := IsUserSubscribed(SubscriptionUserId, CustomerNo, ServiceId);
            QtyUsed := -1;
            LogDescription := SubscriptionUserId;
            if not UserSubscribed then begin
                CustomerSubscribed := IsCustomerSubscribed(CustomerNo, ServiceId);
                if CustomerSubscribed then begin
                    CreateUserAccount(SubscriptionUserId, CustomerNo, ServiceId);
                    CreateTransactionLogEntryAmt(SubscriptionUserId, CustomerNo, QtyUsed, LogDescription, AmountUsed);
                    ServiceUsed := true;
                end;
            end else begin
                CreateTransactionLogEntryAmt(SubscriptionUserId, CustomerNo, QtyUsed, LogDescription, AmountUsed);
                ServiceUsed := true;
            end;
        end;
        exit(ServiceUsed);
    end;

    local procedure GetReturnValue(ResponseMessage: HttpResponseMessage; NamespaceUri: Text): Text
    var
        Document: XmlDocument;
        Element: XmlElement;
        Node: XmlNode;
        NamespaceMgr: XmlNamespaceManager;

        Response: Text;
    begin
        ResponseMessage.Content().ReadAs(Response);
        XmlDocument.ReadFrom(Response, Document);
        NamespaceMgr.NameTable(Document.NameTable());
        NamespaceMgr.AddNamespace('result', NamespaceUri);

        Document.GetRoot(Element);
        if Element.SelectSingleNode('//result:return_value', NamespaceMgr, Node) then
            exit(node.AsXmlElement().InnerText());
        exit('');
    end;

    [NonDebuggable]
    local procedure InvokeServiceLibrary(ServiceMethod: Text; BodyXmlText: Text): Boolean
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        SoapActionLbl: Label '%1:%2', Locked = true;
        UriLbl: Label '%1/servicelibrary', Locked = true;
    begin
        Content.WriteFrom(CreateXMLRequest(ServiceMethod, BodyXmlText));
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');
        Headers.Add('SOAPAction', StrSubstNo(SoapActionLbl, ServiceLibraryNamespaceUri, ServiceMethod));
        Headers.Add('Ocp-Apim-Subscription-Key', AzureKeyVaultMgt.GetAzureKeyVaultSecret('ServiceLibraryKey'));
        RequestMessage.Content(Content);
        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(StrSubstNo(UriLbl, AzureKeyVaultMgt.GetAzureKeyVaultSecret('ApiHostUri')));

        Client.Timeout(5000);
        if not Client.Send(RequestMessage, ResponseMessage) then
            exit(false);
        if not ResponseMessage.IsSuccessStatusCode then
            exit(false);

        exit(LowerCase(GetReturnValue(ResponseMessage, ServiceLibraryNamespaceUri)) = 'true');

    end;

    local procedure CreateXMLRequest(ServiceMethod: Text; BodyXMLText: Text): Text
    begin
        exit(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '<Body>' +
              '<' + ServiceMethod + ' xmlns="' + ServiceLibraryNamespaceUri + '">' +
                BodyXMLText +
              '</' + ServiceMethod + '>' +
            '</Body>' +
          '</Envelope>');

    end;


}
