codeunit 6014640 "NPR BTF Register Service"
{
    var
        ServiceCodeLbl: Label 'V1', Locked = true;
        ServiceNameLbl: Label 'BTwentyFour Omni Channel V1.0';
        ServiceURLLbl: Label 'https://api-connect.btwentyfour.com', Locked = true;
        AboutAPIURLLbl: Label 'https://api-developer.btwentyfour.com/apis', Locked = true;
        GetTokenEndPointIDLbl: Label 'GetToken', Locked = true;
        AuthorizePathLbl: Label '/authorizations/token', Locked = true;
        GetTokenDescriptionLbl: Label 'Get authorization token to use as Authorization header for all subsequent calls';
        GetInvoicesEndPointIDLbl: Label 'GetInvoice', Locked = true;
        GetInvoicesDescriptionIDLbl: Label 'Get Invoice';
        GetInvoicesPathLbl: Label '/messages/queue/next', Locked = true;
        ProcessMessageEndPointIDLbl: Label 'ProcessMessage', Locked = true;
        ProcessMessageDescriptionIDLbl: Label 'Set message status, e.g to mark message as delivered (status 40) after processing';
        ProcessMessagePathLbl: Label '/messages/%1/status/%2', Locked = true, Comment = '%1={message_id};%2={status_id}';
        GetOrderRespEndPointIDLbl: Label 'GetOrderResp', Locked = true;
        GetOrderRespDescriptionIDLbl: Label 'Get Order Response';
        GetOrderRespPathLbl: Label '/messages/queue/next', Locked = true;
        GetPriCatEndPointIDLbl: Label 'GetPriCat', Locked = true;
        GetPriCatDescriptionIDLbl: Label 'Get Price Catalogue';
        GetPriCatPathLbl: Label '/messages/queue/next', Locked = true;

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

    local procedure GetServiceCode(): Code[20]
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        exit(ServiceAPI.GetIntegrationPrefix() + ' ' + ServiceCodeLbl);
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
                    '', '');
    end;
    #endregion

    #region Register Messages EndPoints
    local procedure RegisterServiceEndPointMessages(sender: Record "NPR BTF Service EndPoint")
    var
        ServiceSetup: Record "NPR BTF Service Setup";
        ImportType: Record "NPR Nc Import Type";
        ServiceAPI: Codeunit "NPR BTF Service API";
        ProcessMessageEndPointId: Text;
    begin
        ServiceSetup.SetRange(Code, GetServiceCode());
        if ServiceSetup.IsEmpty() then
            exit;

        sender.RegisterServiceEndPoint(
                    GetServiceCode(), ProcessMessageEndPointIDLbl, ProcessMessagePathLbl, "NPR BTF Service Method"::PUT,
                    ProcessMessageDescriptionIDLbl, true, 0, "NPR BTF EndPoint Method"::"Process Message",
                    "NPR BTF Content Type"::"application/json", "NPR BTF Content Type"::"application/xml",
                    'BF0DBE87-5369-405F-AA67-4D2640B4678C', '');
        ProcessMessageEndPointId := sender."EndPoint ID";

        sender.RegisterServiceEndPoint(
                    GetServiceCode(), GetInvoicesEndPointIDLbl, GetInvoicesPathLbl, "NPR BTF Service Method"::GET,
                    GetInvoicesDescriptionIDLbl, true, 200, "NPR BTF EndPoint Method"::"Get Invoices",
                    "NPR BTF Content Type"::"application/json", "NPR BTF Content Type"::"application/xml",
                    'BF0DBE87-5369-405F-AA67-4D2640B4678C', ProcessMessageEndPointId);

        ServiceAPI.RegisterNcImportType(CopyStr(sender."EndPoint ID", 1, MaxStrlen(ImportType.Code)), sender.Description, "NPR Nc IL Update Handler"::B24GetInvoice);
        ServiceAPI.ScheduleJobQueueEntry(sender);
        OnAfterRegisterServiceEndPoint(sender);

        sender.RegisterServiceEndPoint(
                    GetServiceCode(), GetOrderRespEndPointIDLbl, GetOrderRespPathLbl, "NPR BTF Service Method"::GET,
                    GetOrderRespDescriptionIDLbl, true, 200, "NPR BTF EndPoint Method"::"Get Order Response",
                    "NPR BTF Content Type"::"application/json", "NPR BTF Content Type"::"application/xml",
                    'BF0DBE87-5369-405F-AA67-4D2640B4678C', ProcessMessageEndPointId);

        ServiceAPI.RegisterNcImportType(CopyStr(sender."EndPoint ID", 1, MaxStrlen(ImportType.Code)), sender.Description, "NPR Nc IL Update Handler"::B24GetOrderResp);
        ServiceAPI.ScheduleJobQueueEntry(sender);
        OnAfterRegisterServiceEndPoint(sender);

        sender.RegisterServiceEndPoint(
                    GetServiceCode(), GetPriCatEndPointIDLbl, GetPriCatPathLbl, "NPR BTF Service Method"::GET,
                    GetPriCatDescriptionIDLbl, true, 100, "NPR BTF EndPoint Method"::"Get Price Catalogue",
                    "NPR BTF Content Type"::"application/json", "NPR BTF Content Type"::"application/xml",
                    'BF0DBE87-5369-405F-AA67-4D2640B4678C', ProcessMessageEndPointId);

        ServiceAPI.RegisterNcImportType(CopyStr(sender."EndPoint ID", 1, MaxStrlen(ImportType.Code)), sender.Description, "NPR Nc IL Update Handler"::B24GetPriCat);
        ServiceAPI.ScheduleJobQueueEntry(sender);
        OnAfterRegisterServiceEndPoint(sender);
    end;
    #endregion

}