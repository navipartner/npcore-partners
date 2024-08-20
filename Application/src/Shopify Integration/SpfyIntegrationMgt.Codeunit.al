#if not BC17
codeunit 6184810 "NPR Spfy Integration Mgt."
{
    Access = Internal;
    SingleInstance = true;
    Permissions = tabledata "NPR Spfy Integration Setup" = rim;

    var
        _ShopifySetup: Record "NPR Spfy Integration Setup";

    procedure CheckIsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area")
    var
        IntegrationDisabledErr: Label 'NaviPartner BC-Shopify integration is disabled. Please open the "Shopify Integration Setup" page and enable the integration.';
        IntegrationAreaDisabledErr: Label 'The "%1" area/option of NaviPartner BC-Shopify integration is disabled.', Comment = '%1 - integration area name';
    begin
        if IsEnabled(IntegrationArea) then
            exit;
        if IntegrationArea = IntegrationArea::" " then
            Error(IntegrationDisabledErr)
        else
            Error(IntegrationAreaDisabledErr)
    end;

    procedure IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"): Boolean
    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        AreaIsEnabled: Boolean;
        Handled: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeCheckIfIntegrationAreaIsEnabled(IntegrationArea, AreaIsEnabled, Handled);
        if Handled then
            exit(AreaIsEnabled);

        _ShopifySetup.GetRecordOnce(false);
        if not _ShopifySetup."Enable Integration" then
            exit(false);
        case IntegrationArea of
            IntegrationArea::" ":
                exit(_ShopifySetup."Enable Integration");
            IntegrationArea::Items:
                exit(_ShopifySetup."Item List Integration");
            IntegrationArea::"Inventory Levels":
                exit(_ShopifySetup."Send Inventory Updates");
            IntegrationArea::"Sales Orders":
                exit(_ShopifySetup."Sales Order Integration");
            IntegrationArea::"Order Fulfillments":
                exit(_ShopifySetup."Send Order Fulfillments");
            IntegrationArea::"Payment Capture Requests":
                exit(_ShopifySetup."Send Payment Capture Requests");
            IntegrationArea::"Close Order Requests":
                exit(_ShopifySetup."Send Close Order Requets");
            IntegrationArea::"Retail Vouchers":
                exit(_ShopifySetup."Retail Voucher Integration");
            else begin
                AreaIsEnabled := false;
                SpfyIntegrationEvents.OnCheckIfIntegrationAreaIsEnabled(IntegrationArea, AreaIsEnabled, Handled);
                if Handled then
                    exit(AreaIsEnabled);
            end;
        end;
    end;

    procedure ShopifyStoreIsEnabled(ShopifyStoreCode: Code[20]): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        exit(ShopifyStore.Get(ShopifyStoreCode) and ShopifyStore.Enabled);
    end;

    procedure ShopifyApiVersion(): Text
    begin
        _ShopifySetup.GetRecordOnce(false);
        _ShopifySetup.TestField("Shopify Api Version");
        exit(_ShopifySetup."Shopify Api Version");
    end;

    procedure IsSendSalesPrices(): Boolean
    begin
        _ShopifySetup.GetRecordOnce(false);
        exit(not _ShopifySetup."Do Not Sync. Sales Prices");
    end;

    procedure IsSendShopifyNameAndDescription(): Boolean
    begin
        _ShopifySetup.GetRecordOnce(false);
        exit(_ShopifySetup."Set Shopify Name/Descr. in BC");
    end;

    procedure IsAllowedFinancialStatus(FinancialStatus: Text): Boolean
    begin
        _ShopifySetup.GetRecordOnce(false);
        case FinancialStatus of
            'authorized':
                exit(_ShopifySetup."Allowed Payment Statuses" in
                    [_ShopifySetup."Allowed Payment Statuses"::Authorized, _ShopifySetup."Allowed Payment Statuses"::Both]);
            'paid':
                exit(_ShopifySetup."Allowed Payment Statuses" in
                    [_ShopifySetup."Allowed Payment Statuses"::Paid, _ShopifySetup."Allowed Payment Statuses"::Both]);
        end;
        exit(false);
    end;

    procedure ProcessCancelledOrders(): Boolean
    begin
        _ShopifySetup.GetRecordOnce(false);
        exit(_ShopifySetup."Delete on Cancellation");
    end;

    procedure ProcessFinishedOrders(): Boolean
    begin
        _ShopifySetup.GetRecordOnce(false);
        exit(_ShopifySetup."Post on Completion");
    end;

    procedure CreatePmtLinesOnOrderImport(): Boolean
    begin
        _ShopifySetup.GetRecordOnce(false);
        exit(_ShopifySetup."Get Payment Lines From Shopify" = _ShopifySetup."Get Payment Lines From Shopify"::ON_ORDER_IMPORT);
    end;

    procedure IsSendNegativeInventory(): Boolean
    begin
        _ShopifySetup.GetRecordOnce(false);
        exit(_ShopifySetup."Send Negative Inventory");
    end;

    procedure IncludeTrasferOrders(): Option No,Outbound,All
    begin
        _ShopifySetup.GetRecordOnce(false);
        exit(_ShopifySetup."Include Transfer Orders");
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
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure SpfyOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    begin
        DisableIntegration(NewCompanyName);
        DeleteWebhookSubscriptions(NewCompanyName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
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