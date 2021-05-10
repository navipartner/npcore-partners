codeunit 6014652 "NPR BTF GetPriCat" implements "NPR BTF IEndPoint", "NPR Nc Import List IUpdate"
{
    var
        EndPointKeyNotSetLbl: Label 'Endpoint-Key is not set for endpoint %1 (%2 -> %3)', Comment = '%1=Service EndPoint ID;%2=ServiceSetup.TableCaption();%3=ServiceEndPoint.TableCaption()';
        AuthMethodIDNotSetLbl: Label 'Authorization Method ID is not set in %1 or it''s not found in related table %2', Comment = '%1=Service Setup Table Caption;%2=Service EndPoint Table Caption';
        RequestNotSentLbl: Label 'Failed to send request to %1', Comment = '%1=Request URI';
        DefaultFileNameLbl: Label 'GetPriCat_%1', Comment = '%1=Current Date and Time';
        ErrorLogInfoLbl: Label 'Error encountered. Check out error log for more details.';
        PriCatNotDeliveredLbl: Label 'Price Catalogue %1 has been imported successfully. However, due to offline import, this Price Catalogue is still available in a B24 queue under the messageId %2 and has to be set as a delivered.', Comment = '%1=Price Catlogue No.;%2=Message ID';
        PriCatNotFoundInContentLbl: Label 'Price Catalogue or it''s lines not found in the content';
        PriCatRemovedLbl: Label 'Price Catalogue %1 has been created under the same number with the same action.', Comment = '%1=Price Catalogue Name';
        MessageIdNotFoundLbl: Label 'Message Id not found in "%1" under the %2.', Comment = '%1="NPR Item Worksheet".TableCaption();%2="NPR Item Worksheet".FieldName(Name)';
        ItemWrksAlreadyCreatedLbl: Label 'Item Worksheet that you are trying to import has been already created.';
        ItemWrksAlreadyRegisteredLbl: Label 'Item Worksheet that you are trying to import has been already registered.';
        ItemWrksCreatedInLiveEnvLbl: Label 'Since this is live environment, this Item Worksheet has to be removed from B24 queue by sending message id of this document to B24 portal. Message ID could be found under the %1 or under the property messageId in the original content downloaded from B24.', Comment = '%1="NPR Item Worksheet".FieldName(Name)';
        DefaultWrksTemplateNameLbl: Label 'Integration';
        OpenCardLbl: Label 'Open';

    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.SendWebRequests(ImportType, TaskLine.RecordID(), '');
    end;

    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        EndPointIDFilter: Text;
    begin
        ServiceAPI.GetJobQueueParameters(JobQueueEntry, ImportType, EndPointIDFilter);
        ServiceAPI.SendWebRequests(ImportType, JobQueueEntry.RecordId(), EndPointIDFilter);
    end;

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.ShowEndPoint(ImportType.Code);
    end;

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.ShowErrorLogEntries('', ImportType.Code);
    end;

    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; Request: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
    var
        ServiceEndPointForAuth: Record "NPR BTF Service EndPoint";
    begin
        if not CheckServiceSetup(ServiceSetup, ServiceEndPointForAuth, ServiceEndPoint, Response) then
            exit;
        if not CheckServiceEndPoint(ServiceSetup, ServiceEndPoint, Response) then
            exit;
        GetPriCat(ServiceSetup, ServiceEndPoint, ServiceEndPointForAuth, Request, Response, StatusCode);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    local procedure GetPriCat(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; ServiceEndPointForAuth: Record "NPR BTF Service EndPoint"; DummyRequest: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        EndPoint: Interface "NPR BTF IEndPoint";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        OutStr: OutStream;
        ResponseText: Text;
        URI: Text;
        ParameterValue: Text;
        OrdinalValue: Integer;
        Index: Integer;
    begin
        EndPoint := ServiceEndPointForAuth."EndPoint Method";
        EndPoint.SendRequest(ServiceSetup, ServiceEndPointForAuth, DummyRequest, Response, StatusCode);
        if not ServiceAPI.IsTokenAvailable(ServiceEndPointForAuth, Response) then
            exit;

        ClearLastError();
        RequestMessage.Method := Format(ServiceEndPoint."Service Method Name");
        URI := StrSubstNo(ServiceSetup."Service URL" + ServiceEndPoint.Path + '?classid=%1', "NPR BTF Messages Class"::pricat.AsInteger());
        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365');
        Headers.Add('Authorization', StrSubstNo('bearer %1', ServiceAPI.GetTokenFromResponse(ServiceEndPointForAuth, Response)));
        Headers.Add('Subscription-Key', ServiceSetup."Subscription-Key");
        Headers.Add('Username', ServiceSetup.Username);

        OrdinalValue := ServiceSetup.Environment.AsInteger();
        Index := ServiceSetup.Environment.Ordinals.IndexOf(OrdinalValue);
        ParameterValue := ServiceSetup.Environment.Names.Get(Index);

        Headers.Add('Environment', ParameterValue);

        OrdinalValue := ServiceEndPoint.Accept.AsInteger();
        Index := ServiceEndPoint.Accept.Ordinals.IndexOf(OrdinalValue);
        ParameterValue := ServiceEndPoint.Accept.Names.Get(Index);

        Headers.Add('Accept', ParameterValue);
        Headers.Add('Endpoint-Key', ServiceEndPoint."EndPoint-Key");
        if ServiceSetup.Portal <> '' then
            Headers.Add('Portal', ServiceSetup.Portal);

        Client.Timeout(5000);
        if not Client.Send(RequestMessage, ResponseMessage) then begin
            FormatResponse := ServiceEndPoint.Accept;
            StatusCode := 400;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(RequestNotSentLbl, RequestMessage.GetRequestUri()), Response);
            exit;
        end;

        StatusCode := ResponseMessage.HttpStatusCode();
        Content := ResponseMessage.Content();
        Content.ReadAs(ResponseText);
        Clear(Response);
        Response.CreateOutStream(OutStr);
        OutStr.WriteText(ResponseText);
    end;

    local procedure CheckServiceSetup(ServiceSetup: Record "NPR BTF Service Setup"; var ServiceEndPointAuth: Record "NPR BTF Service EndPoint"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob"): Boolean
    var
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        if (ServiceSetup."Authroization EndPoint ID" = '') or (not ServiceEndPointAuth.Get(ServiceSetup.Code, ServiceSetup."Authroization EndPoint ID")) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(AuthMethodIDNotSetLbl, ServiceSetup.TableCaption(), ServiceEndPointAuth.TableCaption()), Response);
            exit;
        end;
        exit(true);
    end;

    local procedure CheckServiceEndPoint(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob"): Boolean
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        if not ServiceAPI.CheckServiceEndPoint(ServiceEndPoint) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', GetLastErrorText(), Response);
        end;
        if ServiceEndPoint."EndPoint-Key" = '' then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(EndPointKeyNotSetLbl, ServiceEndPoint."EndPoint ID", ServiceSetup.TableCaption(), ServiceEndPoint.TableCaption()), Response);
            exit;
        end;
        exit(true);
    end;

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"): Boolean
    var
        NextServiceEndPoint: Record "NPR BTF Service EndPoint";
        ServiceSetup: Record "NPR BTF Service Setup";
        TempItemWrks: Record "NPR Item Worksheet" temporary;
        TempItemWrksLine: Record "NPR Item Worksheet Line" temporary;
        ItemWrks: Record "NPR Item Worksheet";
        RegisteredItemWrks: Record "NPR Registered Item Works.";
        Request: Codeunit "Temp Blob";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        OutStr: OutStream;
        StatusCode: Integer;
        MessageId: Text;
    begin
        FormatResponse := ServiceEndPoint.Accept;
        FormatResponse.GetPriceCat(Content, TempItemWrks, TempItemWrksLine);
        if (not TempItemWrks.Find()) or TempItemWrksLine.IsEmpty() then begin
            FormatResponse.FormatInternalError('internal_business_central_error', PriCatNotFoundInContentLbl, Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), ItemWrks.RecordId());
            exit;
        end;

        if ItemWrksRegistered(RegisteredItemWrks, TempItemWrks) then
            exit;

        if not ItemWrksCreated(ItemWrks, TempItemWrks) then begin
            CreateItemWrksTemplateIfNotFound(TempItemWrks."Item Template Name");
            CreateItemWorksheet(ItemWrks, TempItemWrks);
            CreateItemWorksheetLines(ItemWrks, TempItemWrks, TempItemWrksLine);
            if not ItemWrksLineCreated(ItemWrks) then begin
                FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(PriCatRemovedLbl, ItemWrks.Description), Response);
                ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), ItemWrks.RecordId());
                ItemWrks.Delete(true);
                exit;
            end;
        end;

        MessageId := ItemWrks.Name;

        if MessageId = '' then begin
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(MessageIdNotFoundLbl, ItemWrks.TableCaption(), ItemWrks.FieldName(Name)), Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), ItemWrks.RecordId());
            ItemWrks.Delete(true);
            exit;
        end;

        NextServiceEndPoint."Service Code" := ServiceEndPoint."Service Code";
        NextServiceEndPoint."EndPoint ID" := ServiceEndPoint."Next EndPoint ID";
        NextServiceEndPoint.Find();
        NextServiceEndPoint.TestField(Enabled);

        ServiceSetup.Code := NextServiceEndPoint."Service Code";
        ServiceSetup.Find();
        ServiceSetup.TestField(Enabled);

        Request.CreateOutStream(OutStr);
        OutStr.WriteText(MessageId);

        ServiceAPI.SendWebRequest(ServiceSetup, NextServiceEndPoint, Request, Response, StatusCode);
        FormatResponse := NextServiceEndPoint.Accept;
        if FormatResponse.FoundErrorInResponse(Response, StatusCode) then begin
            ServiceAPI.LogEndPointError(ServiceSetup, NextServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), ItemWrks.RecordId());
            ItemWrks.Delete(true);
            exit;
        end;
        exit(true);
    end;

    procedure ProcessImportedContentOffline(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        TempItemWrks: Record "NPR Item Worksheet" temporary;
        TempItemWrksLine: Record "NPR Item Worksheet Line" temporary;
        ItemWrks: Record "NPR Item Worksheet";
        RegisteredItemWrks: Record "NPR Registered Item Works.";
        ServiceSetup: Record "NPR BTF Service Setup";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        ServiceSetup.Code := ServiceEndPoint."Service Code";
        ServiceSetup.Find();
        ServiceSetup.TestField(Enabled);

        FormatResponse := ServiceEndPoint.Accept;
        FormatResponse.GetPriceCat(Content, TempItemWrks, TempItemWrksLine);

        if (not TempItemWrks.Find()) or TempItemWrksLine.IsEmpty() then begin
            FormatResponse.FormatInternalError('internal_business_central_error', PriCatNotFoundInContentLbl, Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), TempItemWrks.RecordId());
            Message(ErrorLogInfoLbl);
            exit;
        end;

        if ItemWrksCreated(ItemWrks, TempItemWrks) then begin
            if ServiceSetup.Environment = ServiceSetup.Environment::production then begin
                FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(PriCatNotDeliveredLbl, TempItemWrks.Description, TempItemWrks.Name), Response);
                ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), ItemWrks.RecordId());
                ItemWrks.SetRecFilter();
                Page.RunModal(0, ItemWrks);
                SendItemWrksNotification(GetItemWrksCreatedInLiveEnvNotificationId(), ItemWrksAlreadyCreatedLbl + ' ' + ItemWrksCreatedInLiveEnvLbl, ItemWrks."Item Template Name", ItemWrks.Name, 'OpenWorksheet');
            end else begin
                ItemWrks.SetRecFilter();
                Page.RunModal(0, ItemWrks);
                SendItemWrksNotification(GetItemWrksAlreadyCreatedNotificationId(), ItemWrksAlreadyCreatedLbl, ItemWrks."Item Template Name", ItemWrks.Name, 'OpenWorksheet');
            end;
            exit;
        end else begin
            if ItemWrksRegistered(RegisteredItemWrks, TempItemWrks) then begin
                RegisteredItemWrks.SetRecFilter();
                Page.RunModal(0, RegisteredItemWrks);
                SendItemWrksNotification(GetItemWrksAlreadyPostedNotificationId(), ItemWrksAlreadyRegisteredLbl, '', RegisteredItemWrks."Worksheet Name", 'OpenRegisteredWorksheet');
                exit;
            end;
        end;

        CreateItemWrksTemplateIfNotFound(TempItemWrks."Item Template Name");
        CreateItemWorksheet(ItemWrks, TempItemWrks);
        CreateItemWorksheetLines(ItemWrks, TempItemWrks, TempItemWrksLine);

        ItemWrks.SetRecFilter();
        Page.Run(0, ItemWrks);
    end;


    local procedure CreateItemWrksTemplateIfNotFound(TemplateName: Text)
    var
        ItemWorkshTemplate: Record "NPR Item Worksh. Template";
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ItemWorkshTemplate.Name := TemplateName;
        if ItemWorkshTemplate.Name = '' then
            ItemWorkshTemplate.Name := ServiceAPI.GetIntegrationPrefix();
        if ItemWorkshTemplate.Find() then
            exit;
        ItemWorkshTemplate.Init();
        ItemWorkshTemplate.Description := CopyStr(ServiceAPI.GetIntegrationPrefix() + ' ' + DefaultWrksTemplateNameLbl, 1, MaxStrLen(ItemWorkshTemplate.Description));
        ItemWorkshTemplate."Create Internal Barcodes" := ItemWorkshTemplate."Create Internal Barcodes"::"As Cross Reference";
        ItemWorkshTemplate."Create Vendor  Barcodes" := ItemWorkshTemplate."Create Vendor  Barcodes"::"As Cross Reference";
        ItemWorkshTemplate.Insert(true);
    end;

    local procedure CreateItemWorksheet(var ItemWrks: Record "NPR Item Worksheet"; TempItemWrks: Record "NPR Item Worksheet")
    var
        ItemWrksLine: Record "NPR Item Worksheet Line";
    begin
        ItemWrks.TransferFields(TempItemWrks);
        ItemWrks.Validate("Vendor No.");
        ItemWrks.Validate("Currency Code");
        ItemWrks.Insert(true);
    end;

    local procedure CreateItemWorksheetLines(var ItemWrks: Record "NPR Item Worksheet"; TempItemWrks: Record "NPR Item Worksheet"; var TempItemWrksLine: Record "NPR Item Worksheet Line")
    var
        ItemWrksLine: Record "NPR Item Worksheet Line";
        ItemWkshCheckLine: Codeunit "NPR Item Wsht.-Check Line";
    begin
        if TempItemWrksLine.FindSet() then
            repeat
                if not ItemWrksLineCreatedWithSameAction(ItemWrksLine, TempItemWrksLine) then begin
                    Clear(ItemWrksLine);
                    ItemWrksLine.TransferFields(TempItemWrksLine);
                    ItemWrksLine.Validate(Action);
                    ItemWrksLine.Validate("Item No.");
                    ItemWrksLine.Validate("Base Unit of Measure");
                    ItemWrksLine.Insert(true);
                    ItemWkshCheckLine.RunCheck(ItemWrksLine, false, false);
                end;
            until TempItemWrksLine.next() = 0;
    end;

    local procedure ItemWrksCreated(var ItemWrks: Record "NPR Item Worksheet"; TempItemWrks: Record "NPR Item Worksheet"): Boolean
    begin
        ItemWrks."Item Template Name" := TempItemWrks."Item Template Name";
        ItemWrks.Name := TempItemWrks.Name;
        exit(ItemWrks.Find());
    end;

    local procedure ItemWrksLineCreatedWithSameAction(var ItemWrksLine: Record "NPR Item Worksheet Line"; var TempItemWrksLine: Record "NPR Item Worksheet Line"): Boolean
    begin
        Clear(ItemWrksLine);
        ItemWrksLine.SetRange("Worksheet Template Name", TempItemWrksLine."Worksheet Template Name");
        ItemWrksLine.SetRange("Worksheet Name", TempItemWrksLine."Worksheet Name");
        ItemWrksLine.SetRange("Item No.", TempItemWrksLine."Item No.");
        ItemWrksLine.SetRange(Action, TempItemWrksLine.Action);
        exit(not ItemWrksLine.IsEmpty());
    end;

    local procedure ItemWrksLineCreated(ItemWrks: Record "NPR Item Worksheet"): Boolean
    var
        ItemWrksLine: Record "NPR Item Worksheet Line";
    begin
        ItemWrksLine.SetRange("Worksheet Template Name", ItemWrks."Item Template Name");
        ItemWrksLine.SetRange("Worksheet Name", ItemWrks.Name);
        exit(not ItemWrksLine.IsEmpty());
    end;

    local procedure ItemWrksRegistered(var RegisteredItemWorksheet: Record "NPR Registered Item Works."; ItemWorksheet: Record "NPR Item Worksheet"): Boolean
    begin
        RegisteredItemWorksheet."Worksheet Name" := ItemWorksheet.Name;
        exit(RegisteredItemWorksheet.FindFirst());
    end;

    procedure OpenWorksheet(ItemWkrsNotification: Notification)
    var
        ItemWrks: Record "NPR Item Worksheet";
    begin
        ItemWrks."Item Template Name" := ItemWkrsNotification.GetData('WrksTemplate');
        ItemWrks.Name := ItemWkrsNotification.GetData('WrksName');
        ItemWrks.SetRecFilter();
        Page.Run(0, ItemWrks);
    end;

    procedure OpenRegisteredWorksheet(ItemWkrsNotification: Notification)
    var
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
    begin
        RegisteredItemWorksheet."Worksheet Name" := ItemWkrsNotification.GetData('WrksName');
        RegisteredItemWorksheet.SetRecFilter();
        Page.Run(0, RegisteredItemWorksheet);
    end;

    local procedure SendItemWrksNotification(ItemWkrsNotificationId: Guid; Msg: Text; WkrsTemplate: Text; WkrsName: Text; ActionName: Text)
    var
        ItemWkrsNotification: Notification;
    begin
        ItemWkrsNotification.Id := ItemWkrsNotificationId;
        ItemWkrsNotification.Recall();
        ItemWkrsNotification.Message(Msg);
        ItemWkrsNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
        ItemWkrsNotification.SetData('WrksTemplate', WkrsTemplate);
        ItemWkrsNotification.SetData('WrksName', WkrsName);
        ItemWkrsNotification.AddAction(OpenCardLbl, Codeunit::"NPR BTF GetPriCat", ActionName);
        ItemWkrsNotification.Send();
    end;

    local procedure GetItemWrksAlreadyCreatedNotificationId(): Guid
    begin
        exit('4bd34c29-4f15-4505-b69c-026e6a1d7594');
    end;

    local procedure GetItemWrksAlreadyPostedNotificationId(): Guid
    begin
        exit('5fc3dfd2-e681-438d-b7fb-6aab325da47b');
    end;

    local procedure GetItemWrksCreatedInLiveEnvNotificationId(): Guid
    begin
        exit('4203777e-b874-4b0e-b85d-b5e79d0c7784');
    end;

    procedure GetImportListUpdateHandler(): Enum "NPR Nc IL Update Handler"
    begin
        exit("NPR Nc IL Update Handler"::B24GetPriCat);
    end;
}