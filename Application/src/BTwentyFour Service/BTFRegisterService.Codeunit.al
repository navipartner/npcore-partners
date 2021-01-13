codeunit 6014640 "NPR BTF Register Service"
{
    var
        ServiceCodeLbl: Label 'B24 V1', Locked = true;
        ServiceNameLbl: Label 'BTwentyFour Omni Channel V1.0';
        ServiceURLLbl: Label 'https://api-connect.btwentyfour.com', Locked = true;
        AboutAPIURLLbl: Label 'https://api-developer.btwentyfour.com/apis', Locked = true;
        GetTokenEndPointIDLbl: Label 'GetToken', Locked = true;
        AuthorizePathLbl: Label '/authorizations/token', Locked = true;
        GetTokenDescriptionLbl: Label 'Get authorization token to use as Authorization header for all subsequent calls';
        GetInvoicesEndPointIDLbl: Label 'GetInvoices', Locked = true;
        GetInvoicesDescriptionIDLbl: Label 'List Invoices';
        GetOrdersEndPointIDLbl: Label 'GetOrders', Locked = true;
        GetOrdersDescriptionIDLbl: Label 'List Orders';
        MessagesPathLbl: Label '/messages', Locked = true;

    #region Register Service with EndPoints
    [EventSubscriber(ObjectType::Table, Database::"NPR BTF Service Setup", 'OnRegisterService', '', true, true)]
    local procedure OnRegisterService(sender: Record "NPR BTF Service Setup")
    begin
        RegisterServiceWithEndPoints(sender);
    end;

    local procedure RegisterServiceWithEndPoints(sender: Record "NPR BTF Service Setup")
    var
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
    begin
        sender.RegisterService(
                    GetServiceCode(), ServiceURLLbl, ServiceNameLbl, AboutAPIURLLbl,
                    'fe27956dfdc846d7874ff753a9dd0493', "NPR BTF Environment"::Sandbox, 'f7c015e631394d8ca9970351', '', true,
                    '853878c0abd34e6f8aec6d91df03ec');



        RegisterServiceEndPointAuthorization(ServiceEndPoint);
        sender."Authroization EndPoint ID" := ServiceEndPoint."EndPoint ID";
        sender.Modify();

        RegisterServiceEndPointMessages(ServiceEndPoint);

        OnAfterRegisterService(sender);
    end;

    local procedure GetServiceCode(): Text
    begin
        exit(ServiceCodeLbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterService(sender: Record "NPR BTF Service Setup")
    begin
    end;
    #endregion

    #region Register EndPoints
    [EventSubscriber(ObjectType::Table, Database::"NPR BTF Service EndPoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure OnRegisterServiceEndPoint(sender: Record "NPR BTF Service EndPoint")
    begin
        RegisterServiceEndPointAuthorization(sender);
        RegisterServiceEndPointMessages(sender);

        OnAfterRegisterServiceEndPoint(sender);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterServiceEndPoint(sender: Record "NPR BTF Service EndPoint")
    begin
    end;
    #endregion

    #region Register Authorization EndPoint
    local procedure RegisterServiceEndPointAuthorization(var sender: Record "NPR BTF Service EndPoint")
    var
        ServiceSetup: Record "NPR BTF Service Setup";
    begin
        ServiceSetup.SetRange(Code, GetServiceCode());
        if ServiceSetup.IsEmpty() then
            exit;
        sender.RegisterServiceEndPoint(
                    GetServiceCode(), GetTokenEndPointIDLbl, AuthorizePathLbl, "NPR BTF Service Method"::POST,
                    GetTokenDescriptionLbl, true, 0, "NPR BTF EndPoint Method"::"Get Token",
                    "NPR BTF Content Type"::"application/json", "NPR BTF Content Type"::"application/xml",
                    '');
    end;
    #endregion

    #region Register Messages EndPoints
    local procedure RegisterServiceEndPointMessages(sender: Record "NPR BTF Service EndPoint")
    var
        ServiceSetup: Record "NPR BTF Service Setup";
    begin
        ServiceSetup.SetRange(Code, GetServiceCode());
        if ServiceSetup.IsEmpty() then
            exit;

        sender.RegisterServiceEndPoint(
                    GetServiceCode(), GetOrdersEndPointIDLbl, MessagesPathLbl, "NPR BTF Service Method"::GET,
                    GetOrdersDescriptionIDLbl, true, 100, "NPR BTF EndPoint Method"::"Get Orders",
                    "NPR BTF Content Type"::"application/json", "NPR BTF Content Type"::"application/xml",
                    'BF0DBE87-5369-405F-AA67-4D2640B4678C');

        sender.RegisterServiceEndPoint(
                    GetServiceCode(), GetInvoicesEndPointIDLbl, MessagesPathLbl, "NPR BTF Service Method"::GET,
                    GetInvoicesDescriptionIDLbl, true, 200, "NPR BTF EndPoint Method"::"Get Invoices",
                    "NPR BTF Content Type"::"application/json", "NPR BTF Content Type"::"application/xml",
                    'BF0DBE87-5369-405F-AA67-4D2640B4678C');


        OnAfterRegisterServiceEndPoint(sender);
    end;
    #endregion

}