#if not BC17
codeunit 6184810 "NPR Spfy Integration Mgt."
{
    Access = Internal;
    SingleInstance = true;
    Permissions = tabledata "NPR Spfy Integration Setup" = rim;

    var
        _ShopifySetup: Record "NPR Spfy Integration Setup";
        _ShopifyStore: Record "NPR Spfy Store";

    procedure CheckIsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStoreCode: Code[20])
    var
        IntegrationDisabledErr: Label 'NaviPartner BC-Shopify integration is disabled. Please open the "Shopify Integration Setup" page and enable the integration.';
        IntegrationDisabledAllStoresErr: Label 'NaviPartner BC-Shopify integration must be enabled for at least one Shopify store. Please open the "Shopify Store" page and enable the integration.';
        IntegrationDisabledStoreErr: Label 'NaviPartner BC-Shopify integration is disabled for the "%1" Shopify store. Please open the "Shopify Store" page and enable the integration.', Comment = '%1 - Shopify store code';
        IntegrationAreaDisabledAllStoresErr: Label 'The "%1" area/option of NaviPartner BC-Shopify integration must be enabled for at least one Shopify store.', Comment = '%1 - integration area name';
        IntegrationAreaDisabledStoreErr: Label 'The "%1" area/option of NaviPartner BC-Shopify integration for the "%2" Shopify store is disabled.', Comment = '%1 - integration area name, %2 - Shopify store code';
    begin
        _ShopifySetup.GetRecordOnce(false);
        if not _ShopifySetup."Enable Integration" then
            Error(IntegrationDisabledErr);

        if ShopifyStoreCode = '' then begin
            if IsEnabledForAnyStore(IntegrationArea) then
                exit;
            if IntegrationArea = IntegrationArea::" " then
                Error(IntegrationDisabledAllStoresErr)
            else
                Error(IntegrationAreaDisabledAllStoresErr, Format(IntegrationArea));
        end;

        if IsEnabled(IntegrationArea, ShopifyStoreCode) then
            exit;
        if IntegrationArea = IntegrationArea::" " then
            Error(IntegrationDisabledStoreErr, ShopifyStoreCode)
        else
            Error(IntegrationAreaDisabledStoreErr, Format(IntegrationArea), ShopifyStoreCode);
    end;

    procedure IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStoreCode: Code[20]): Boolean
    begin
        GetStore(ShopifyStoreCode);
        exit(IsEnabled(IntegrationArea, _ShopifyStore));
    end;

    procedure IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"; ShopifyStore: Record "NPR Spfy Store"): Boolean
    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        AreaIsEnabled: Boolean;
        Handled: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeCheckIfStoreIntegrationAreaIsEnabled(IntegrationArea, ShopifyStore.Code, AreaIsEnabled, Handled);
        if Handled then
            exit(AreaIsEnabled);

        _ShopifySetup.GetRecordOnce(false);
        if not _ShopifySetup."Enable Integration" or ((ShopifyStore.Code = '') and (IntegrationArea = IntegrationArea::" ")) then
            exit(_ShopifySetup."Enable Integration");

        if not ShopifyStore.Enabled or (IntegrationArea = IntegrationArea::" ") then
            exit(ShopifyStore.Enabled);
        case IntegrationArea of
            IntegrationArea::Items:
                exit(ShopifyStore."Item List Integration");
            IntegrationArea::"Inventory Levels":
                exit(ShopifyStore."Send Inventory Updates");
            IntegrationArea::"Item Prices":
                exit(not ShopifyStore."Do Not Sync. Sales Prices");
            IntegrationArea::"Item Categories":
                exit(ShopifyStore."Item Category as Metafield");
            IntegrationArea::"Sales Orders":
                exit(ShopifyStore."Sales Order Integration");
            IntegrationArea::"Order Fulfillments":
                exit(ShopifyStore."Send Order Fulfillments");
            IntegrationArea::"Payment Capture Requests":
                exit(ShopifyStore."Send Payment Capture Requests");
            IntegrationArea::"Close Order Requests":
                exit(ShopifyStore."Send Close Order Requets");
            IntegrationArea::"Retail Vouchers":
                exit(ShopifyStore."Retail Voucher Integration");
            IntegrationArea::"Loyalty Points":
                exit(ShopifyStore."Loyalty Points as Metafield");
            else begin
                AreaIsEnabled := false;
                SpfyIntegrationEvents.OnCheckIfStoreIntegrationAreaIsEnabled(IntegrationArea, ShopifyStore.Code, AreaIsEnabled, Handled);
                if Handled then
                    exit(AreaIsEnabled);
            end;
        end;
    end;

    procedure IsEnabledForAnyStore(IntegrationArea: Enum "NPR Spfy Integration Area"): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if _ShopifySetup.IsEmpty() then
            exit(false);
        _ShopifySetup.GetRecordOnce(false);
        if not _ShopifySetup."Enable Integration" then
            exit(false);

#if not (BC18 or BC19 or BC20 or BC21)
        ShopifyStore.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        if ShopifyStore.Find('-') then
            repeat
                if IsEnabled(IntegrationArea, ShopifyStore) then
                    exit(true);
            until ShopifyStore.Next() = 0;
    end;

    procedure ShopifyApiVersion(): Text
    begin
        _ShopifySetup.GetRecordOnce(false);
        _ShopifySetup.TestField("Shopify Api Version");
        exit(_ShopifySetup."Shopify Api Version");
    end;

    procedure IsSendSalesPrices(ShopifyStoreCode: Code[20]): Boolean
    begin
        GetStore(ShopifyStoreCode);
        exit(IsSendSalesPrices(_ShopifyStore));
    end;

    procedure IsSendSalesPrices(ShopifyStoreIn: Record "NPR Spfy Store"): Boolean
    begin
        exit(not ShopifyStoreIn."Do Not Sync. Sales Prices");
    end;

    procedure OrderLineSalesPriceType(ShopifyStoreCode: Code[20]): Enum "NPR Spfy Order Line Price Type"
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Sales Price on Order Lines");
    end;

    procedure IsSendShopifyNameAndDescription(ShopifyStoreCode: Code[20]): Boolean
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Set Shopify Name/Descr. in BC");
    end;

    procedure DefaultNewProductStatus(ShopifyStoreCode: Code[20]): Enum "NPR Spfy Product Status"
    begin
        GetStore(ShopifyStoreCode);
        if not (_ShopifyStore."New Product Status" in [_ShopifyStore."New Product Status"::DRAFT, _ShopifyStore."New Product Status"::ACTIVE]) then
            exit(_ShopifyStore."New Product Status"::DRAFT);
        exit(_ShopifyStore."New Product Status");
    end;

    procedure DefaultECStoreCode(ShopifyStoreCode: Code[20]): Code[20]
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Default Ec Store Code");
    end;

    procedure IsAllowedFinancialStatus(FinancialStatus: Text; ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyAllowedFinStatus: Record "NPR Spfy Allowed Fin. Status";
        OrderFinancialStatus: Enum "NPR Spfy Order FinancialStatus";
    begin
        case FinancialStatus of
            'pending':
                OrderFinancialStatus := OrderFinancialStatus::Pending;
            'authorized':
                OrderFinancialStatus := OrderFinancialStatus::Authorized;
            'paid':
                OrderFinancialStatus := OrderFinancialStatus::Paid;
            else
                exit(false);
        end;
        exit(SpfyAllowedFinStatus.Get(ShopifyStoreCode, OrderFinancialStatus));
    end;

    procedure SelectAllowedFinancialStatuses(ShopifyStoreCode: Code[20])
    var
        SpfyAllowedFinStatus: Record "NPR Spfy Allowed Fin. Status";
        TempSpfyAllowedFinStatus: Record "NPR Spfy Allowed Fin. Status" temporary;
        SpfySelectFinStatuses: Page "NPR Spfy Select Fin. Statuses";
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"NPR Spfy Order FinancialStatus".Ordinals() do begin
            TempSpfyAllowedFinStatus.Init();
            TempSpfyAllowedFinStatus."Shopify Store Code" := ShopifyStoreCode;
            TempSpfyAllowedFinStatus."Order Financial Status" := Enum::"NPR Spfy Order FinancialStatus".FromInteger(Ordinal);
            TempSpfyAllowedFinStatus.Insert();
        end;
        SpfyAllowedFinStatus.SetRange("Shopify Store Code", ShopifyStoreCode);
        if SpfyAllowedFinStatus.FindSet() then
            repeat
                if TempSpfyAllowedFinStatus.Get(ShopifyStoreCode, SpfyAllowedFinStatus."Order Financial Status") then
                    TempSpfyAllowedFinStatus.Mark(true);
            until SpfyAllowedFinStatus.Next() = 0;

        Clear(SpfySelectFinStatuses);
        SpfySelectFinStatuses.SetDataset(TempSpfyAllowedFinStatus);
        SpfySelectFinStatuses.LookupMode(true);
        if SpfySelectFinStatuses.RunModal() <> Action::LookupOK then
            exit;
        SpfySelectFinStatuses.GetDataset(TempSpfyAllowedFinStatus);

        if not SpfyAllowedFinStatus.IsEmpty() then
            SpfyAllowedFinStatus.DeleteAll();
        TempSpfyAllowedFinStatus.MarkedOnly(true);
        if TempSpfyAllowedFinStatus.FindSet() then
            repeat
                SpfyAllowedFinStatus := TempSpfyAllowedFinStatus;
                SpfyAllowedFinStatus.Insert();
            until TempSpfyAllowedFinStatus.Next() = 0;
    end;

    procedure GetAllowedFinancialStatusesAsCommaString(ShopifyStoreCode: Code[20]): Text
    var
        SpfyAllowedFinStatus: Record "NPR Spfy Allowed Fin. Status";
        AllowedFinancialStatuses: Text;
    begin
        SpfyAllowedFinStatus.SetRange("Shopify Store Code", ShopifyStoreCode);
        if SpfyAllowedFinStatus.FindSet() then
            repeat
                if AllowedFinancialStatuses <> '' then
                    AllowedFinancialStatuses += ', ';
                AllowedFinancialStatuses += Format(SpfyAllowedFinStatus."Order Financial Status");
            until SpfyAllowedFinStatus.Next() = 0;
        exit(AllowedFinancialStatuses);
    end;

    procedure CreatePmtLinesOnOrderImport(ShopifyStoreCode: Code[20]): Boolean
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Get Payment Lines from Shopify" = _ShopifyStore."Get Payment Lines from Shopify"::ON_ORDER_IMPORT);
    end;

    procedure IsSendNegativeInventory(ShopifyStoreCode: Code[20]): Boolean
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Send Negative Inventory");
    end;

    procedure IncludeTrasferOrders(ShopifyStoreCode: Code[20]): Option No,Outbound,All
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Include Transfer Orders");
    end;

    procedure IncludeTrasferOrdersAnyStore(): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.SetFilter("Include Transfer Orders", '<>%1', ShopifyStore."Include Transfer Orders"::No);
        exit(not ShopifyStore.IsEmpty());
    end;

    procedure DeleteAfterFinalPosting(ShopifyStoreCode: Code[20]): Boolean
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Delete After Final Post");
    end;

    procedure GetLanguageCode(ShopifyStoreCode: Code[20]): Code[10]
    begin
        GetStore(ShopifyStoreCode);
        exit(_ShopifyStore."Language Code");
    end;

    procedure DataProcessingHandlerID(AutoCreate: Boolean): Code[20]
    begin
        if not AutoCreate then
            if _ShopifySetup.IsEmpty() then
                exit('');

        _ShopifySetup.GetRecordOnce(false);
        if _ShopifySetup."Data Processing Handler ID" = '' then begin
            SelectLatestVersion();
            _ShopifySetup.GetRecordOnce(true);
            if _ShopifySetup."Data Processing Handler ID" = '' then begin
                _ShopifySetup.SetDataProcessingHandlerIDToDefaultValue();
                _ShopifySetup.Modify();
            end;
        end;
        exit(_ShopifySetup."Data Processing Handler ID");
    end;

    procedure SetRereadSetup()
    begin
        Clear(_ShopifySetup);
        Clear(_ShopifyStore);
        SelectLatestVersion();
    end;

    local procedure GetStore(ShopifyStoreCode: Code[20])
    begin
        if ShopifyStoreCode = _ShopifyStore.Code then
            exit;
        if ShopifyStoreCode = '' then
            Clear(_ShopifyStore)
        else
            _ShopifyStore.Get(ShopifyStoreCode);
    end;

    procedure TestShopifyStoreConnection(ShopifyStoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
        xShopifyStore: Record "NPR Spfy Store";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        Window: Dialog;
        ShopifyStoreID: Text[30];
        QueryingShopifyLbl: Label 'Querying Shopify...';
    begin
        Window.Open(QueryingShopifyLbl);
        ClearLastError();
        if not SpfyCommunicationHandler.GetShopifyStoreConfiguration(ShopifyStoreCode, ShopifyResponse) then
            Error(GetLastErrorText());
        Window.Close();

        ShopifyStore.Get(ShopifyStoreCode);
        xShopifyStore := ShopifyStore;
        ClearLastError();
        if not UpdateShopifyStoreWithDataFromShopify(ShopifyStore, ShopifyStoreID, ShopifyResponse, true) then
            Error(GetLastErrorText());
        if Format(ShopifyStore) <> Format(xShopifyStore) then
            ShopifyStore.Modify();
        SpfyAssignedIDMgt.AssignShopifyID(ShopifyStore.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyStoreID, true);
    end;

    [TryFunction]
    procedure UpdateShopifyStoreWithDataFromShopify(var ShopifyStore: Record "NPR Spfy Store"; var ShopifyStoreID: Text[30]; ShopifyResponse: JsonToken; WithDialog: Boolean)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        ShopifyPlan: JsonToken;
        RetrievedFieldValue: Text;
        SuccessLbl: Label 'Connection to Shopify store %1 has been successfully established. Do you want to update the store card with the data received from Shopify?', Comment = '%1 - Shopify store code';
    begin
        ShopifyResponse.SelectToken('data.shop', ShopifyResponse);
        if WithDialog and GuiAllowed() then
            if Confirm(SuccessLbl, true, ShopifyStore.Code) then begin
                RetrievedFieldValue := JsonHelper.GetJText(ShopifyResponse, 'name', false);
                if RetrievedFieldValue <> '' then
                    ShopifyStore.Description := CopyStr(RetrievedFieldValue, 1, MaxStrLen(ShopifyStore.Description));
                RetrievedFieldValue := JsonHelper.GetJText(ShopifyResponse, 'currencyCode', false);
                if RetrievedFieldValue <> '' then
                    ShopifyStore."Currency Code" := CopyStr(RetrievedFieldValue, 1, MaxStrLen(ShopifyStore."Currency Code"));
            end;

        if ShopifyResponse.AsObject().Get('plan', ShopifyPlan) then begin
            RetrievedFieldValue := JsonHelper.GetJText(ShopifyPlan, 'displayName', false);
            if RetrievedFieldValue <> '' then
                ShopifyStore."Plan Display Name" := CopyStr(RetrievedFieldValue, 1, MaxStrLen(ShopifyStore."Plan Display Name"));
            ShopifyStore."Shopify Plus Subscription" := JsonHelper.GetJBoolean(ShopifyPlan, 'shopifyPlus', false);
        end;

        RetrievedFieldValue := JsonHelper.GetJText(ShopifyResponse, 'id', false);
        if RetrievedFieldValue <> '' then
            ShopifyStoreID := CopyStr(CopyStr(RetrievedFieldValue, RetrievedFieldValue.LastIndexOf('/') + 1, StrLen(RetrievedFieldValue)), 1, MaxStrLen(ShopifyStoreID));
    end;

    procedure SetResponse(var NcTask: Record "NPR Nc Task"; ResponseTxt: Text)
    begin
        SetResponse(NcTask, CurrentDateTime(), 0DT, ResponseTxt);
    end;

    procedure SetResponse(var NcTask: Record "NPR Nc Task"; ProcessingStartedAt: DateTime; ProcessingCompletedAt: DateTime; ResponseTxt: Text)
    var
        OutStr: OutStream;
    begin
        NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(ResponseTxt);
        if ProcessingStartedAt <> 0DT then
            NcTask."Last Processing Started at" := ProcessingStartedAt;
        if ProcessingCompletedAt <> 0DT then
            NcTask."Last Processing Completed at" := ProcessingCompletedAt;
    end;

    internal procedure RemoveUntil(Input: Text; UntilChr: Char) Output: Text
    var
        Position: Integer;
    begin
        Position := Input.LastIndexOf(UntilChr);
        if Position <= 0 then
            exit(Input);

        Output := DelStr(Input, 1, Position);
        exit(Output);
    end;

    procedure LowerFirstLetter(TextStringIn: Text): Text
    begin
        if TextStringIn = '' then
            exit;
        exit(LowerCase(CopyStr(TextStringIn, 1, 1)) + CopyStr(TextStringIn, 2));
    end;

    procedure UnsupportedIntegrationTable(NcTask: Record "NPR Nc Task"; CallerFunction: Text)
    var
        UnsupportedErr: Label '%1: unsupported integration table %2 %3';
    begin
        NcTask.CalcFields("Table Name");
        Error(UnsupportedErr, CallerFunction, NcTask."Table No.", NcTask."Table Name");
    end;

    procedure LongRunningProcessConfirmQst(): Text
    var
        ConfirmQst: Label 'The process might take significant amount of time to complete. Are you sure you want to continue?';
    begin
        exit(ConfirmQst);
    end;

    procedure FunctionCallOnNonTempVarErr(ObjectAndProcedureName: Text)
    var
        NotTempErr: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.', Comment = '%1 - object and procedure names';
    begin
        Error(NotTempErr, ObjectAndProcedureName);
    end;

    #region Azure AD application
    internal procedure RegisterWebhookHandlingAzureEntraApp()
    var
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        ClientId: Guid;
        PermissionSets: List of [Code[20]];
        ErrorTxt: Text;
        ClientIdLbl: Label '{cc658235-645e-4fd3-a254-2f777077579a}', Locked = true;
    begin
        //Register NaviPartner Shopify Entra application and try to grant permissions
        Evaluate(ClientId, ClientIdLbl);
        PermissionSets.Add('NPR Spfy Webhook');
        AADApplicationMgt.RegisterAzureADApplication(ClientId, 'Shopify Webhooks', PermissionSets);
        if not AADApplicationMgt.TryGrantConsentToApp(ClientId, 'common', ErrorTxt) then
            Error(ErrorTxt);
    end;
    #endregion

#if not BC18
    #region clear configuration on company/environment copy
#if BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
#else
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", OnAfterCreatedNewCompanyByCopyCompany, '', false, false)]
#endif
    local procedure SpfyOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    begin
        DisableIntegration(NewCompanyName);
        DeleteWebhookSubscriptions(NewCompanyName);
    end;

#if BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
#endif
    local procedure SpfyOnClearCompanyConfiguration(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
        DisableIntegration(CompanyName);
        DeleteWebhookSubscriptions(CompanyName);
    end;

    local procedure DisableIntegration(NewCompanyName: Text)
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if (NewCompanyName <> '') and (NewCompanyName <> CompanyName()) then begin
            ShopifyStore.ChangeCompany(NewCompanyName);
            ShopifySetup.ChangeCompany(NewCompanyName)
        end;
        if ShopifySetup.Get() and ShopifySetup."Enable Integration" then begin
            ShopifySetup."Enable Integration" := false;
            ShopifySetup.Modify();
        end;
        if ShopifyStore.FindSet(true) then
            repeat
                ShopifyStore.Enabled := false;
                ShopifyStore.Modify();
            until ShopifyStore.Next() = 0;
    end;

    local procedure DeleteWebhookSubscriptions(NewCompanyName: Text)
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        if (NewCompanyName <> '') and (NewCompanyName <> CompanyName()) then
            SpfyWebhookSubscription.ChangeCompany(NewCompanyName);
        SpfyWebhookSubscription.DeleteAll();
    end;
    #endregion
#endif
}
#endif