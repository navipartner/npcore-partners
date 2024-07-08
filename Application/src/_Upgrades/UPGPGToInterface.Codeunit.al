codeunit 6151474 "NPR UPG PG To Interface"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG PG To Interface', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG PG To Interface")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG PG To Interface"));

        LogMessageStopwatch.LogFinish();
    end;

    procedure Upgrade()
    begin
        MoveRecordsToCustomTables();
    end;

    local procedure MoveRecordsToCustomTables()
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        IntegrationType: Enum "NPR PG Integrations";
        FoundIntegrationType: Boolean;
    begin
        if not PaymentGateway.FindSet(true) then
            exit;

        repeat
            FoundIntegrationType := true;
            if (not GetIntegrationTypeFromID(PaymentGateway."Capture Codeunit Id", IntegrationType)) then
                if (not GetIntegrationTypeFromID(PaymentGateway."Refund Codeunit Id", IntegrationType)) then
                    if (not GetIntegrationTypeFromID(PaymentGateway."Cancel Codeunit Id", IntegrationType)) then
                        FoundIntegrationType := false;

            if (FoundIntegrationType) then begin
                case IntegrationType of
                    IntegrationType::Adyen:
                        begin
                            MovePGAdyen(PaymentGateway);
                            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::Adyen;
                            PaymentGateway.Description := 'Integration for Adyen';
                        end;
                    IntegrationType::Bambora:
                        begin
                            MovePGBambora(PaymentGateway);
                            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::Bambora;
                            PaymentGateway.Description := StrSubstNo('Integration for Bambora merchant %1', PaymentGateway."Merchant ID");
                        end;
                    IntegrationType::Dibs:
                        begin
                            MovePGDibs(PaymentGateway);
                            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::Dibs;
                            PaymentGateway.Description := StrSubstNo('Integration for Dibs merchant %1', PaymentGateway."Merchant ID");
                        end;
                    IntegrationType::Netaxept:
                        begin
                            MovePGNetaxept(PaymentGateway);
                            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::Netaxept;
                            PaymentGateway.Description := 'Integration for Netaxept';
                        end;
                    IntegrationType::EasyNets:
                        begin
                            MovePGNetsEasy(PaymentGateway);
                            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::EasyNets;
                            PaymentGateway.Description := 'Integration for EasyNets';
                        end;
                    IntegrationType::Quickpay:
                        begin
                            MovePGQuickPay(PaymentGateway);
                            PaymentGateway."Integration Type" := PaymentGateway."Integration Type"::Quickpay;
                            PaymentGateway.Description := 'Integration for QuickPay';
                        end;
                end;

                PaymentGateway."Enable Capture" := (PaymentGateway."Capture Codeunit Id" <> 0);
                PaymentGateway."Enable Refund" := (PaymentGateway."Refund Codeunit Id" <> 0);
                PaymentGateway."Enable Cancel" := (PaymentGateway."Cancel Codeunit Id" <> 0);

                PaymentGateway."Capture Codeunit Id" := 0;
                PaymentGateway."Refund Codeunit Id" := 0;
                PaymentGateway."Cancel Codeunit Id" := 0;

                PaymentGateway.Modify();
            end;
        until PaymentGateway.Next() = 0;
    end;

    local procedure GetIntegrationTypeFromID(CodeunitID: Integer; var IntegrationType: Enum "NPR PG Integrations"): Boolean
    begin
        case CodeunitID of
            Codeunit::"NPR Magento Pmt. Adyen Mgt.":
                IntegrationType := IntegrationType::Adyen;
            Codeunit::"NPR Magento Pmt. Bambora Mgt.", 6014405, 6014623: // All ids have been used for Bambora
                IntegrationType := IntegrationType::Bambora;
            Codeunit::"NPR Magento Pmt. Dibs Mgt.":
                IntegrationType := IntegrationType::Dibs;
            Codeunit::"NPR Magento Pmt. Netaxept Mgt.":
                IntegrationType := IntegrationType::Netaxept;
            Codeunit::"NPR Magento Pmt. EasyNets Mgt":
                IntegrationType := IntegrationType::EasyNets;
            Codeunit::"NPR Magento Pmt. Quickpay Mgt.":
                IntegrationType := IntegrationType::Quickpay;
            else
                exit(false);
        end;

        exit(true);
    end;
#pragma warning disable AA0139
    local procedure MovePGAdyen(PaymentGateway: Record "NPR Magento Payment Gateway")
    var
        PGAdyen: Record "NPR PG Adyen Setup";
        Offset: Integer;
    begin
        if (PGAdyen.Get(PaymentGateway.Code)) then
            exit;

        PGAdyen.Init();
        PGAdyen.Code := PaymentGateway.Code;

        if (PaymentGateway."Api Url".Contains('pal-test')) then begin
            PGAdyen.Environment := PGAdyen.Environment::Test;
            PGAdyen."API URL Prefix" := '';
        end else begin
            PGAdyen.Environment := PGAdyen.Environment::Production;
            Offset := PaymentGateway."Api Url".IndexOf('://') + 3;
            PGAdyen."API URL Prefix" :=
                CopyStr(PaymentGateway."Api Url",
                        Offset,
                        PaymentGateway."Api Url".IndexOf('-pal') - Offset
                    );
        end;

        PGAdyen."API Username" := PaymentGateway."Api Username";
        if (SecretExists(PaymentGateway."Api Password Key")) then
            PGAdyen.SetAPIPassword(GetSecret(PaymentGateway."Api Password Key"));
        PGAdyen."Merchant Name" := PaymentGateway."Merchant Name";

        PGAdyen.Insert();
    end;
#pragma warning restore AA0139

    local procedure MovePGBambora(PaymentGateway: Record "NPR Magento Payment Gateway")
    var
        PGBambora: Record "NPR PG Bambora Setup";
    begin
        if (PGBambora.Get(PaymentGateway.Code)) then
            exit;

        PGBambora.Init();
        PGBambora.Code := PaymentGateway.Code;
        PGBambora."Access Token" := PaymentGateway."Api Username";
        if (SecretExists(PaymentGateway."Api Password Key")) then
            PGBambora.SetSecretToken(GetSecret(PaymentGateway."Api Password Key"));
        PGBambora."Merchant ID" := PaymentGateway."Merchant ID";

        PGBambora.Insert();
    end;

    local procedure MovePGDibs(PaymentGateway: Record "NPR Magento Payment Gateway")
    var
        DibsSetup: Record "NPR PG Dibs Setup";
    begin
        if (DibsSetup.Get(PaymentGateway.Code)) then
            exit;

        DibsSetup.Init();
        DibsSetup.Code := PaymentGateway.Code;
        DibsSetup."Api Url" := PaymentGateway."Api Url";
        DibsSetup."Api Username" := PaymentGateway."Api Username";
        if (SecretExists(PaymentGateway."Api Password Key")) then
            DibsSetup.SetApiPassword(GetSecret(PaymentGateway."Api Password Key"));
        DibsSetup."Merchant ID" := PaymentGateway."Merchant ID";

        DibsSetup.Insert();
    end;

    local procedure MovePGNetaxept(PaymentGateway: Record "NPR Magento Payment Gateway")
    var
        PGNetaxept: Record "NPR PG Netaxept Setup";
    begin
        if (PGNetaxept.Get(PaymentGateway.Code)) then
            exit;

        PGNetaxept.Init();
        PGNetaxept.Code := PaymentGateway.Code;
        if (PaymentGateway."Api Url".Contains('test')) then
            PGNetaxept.Environment := PGNetaxept.Environment::Test
        else
            PGNetaxept.Environment := PGNetaxept.Environment::Production;

        if (SecretExists(PaymentGateway."Api Password Key")) then
            PGNetaxept.SetApiAccessToken(GetSecret(PaymentGateway."Api Password Key"));
        PGNetaxept."Merchant ID" := PaymentGateway."Merchant ID";

        PGNetaxept.Insert();
    end;

    local procedure MovePGNetsEasy(PaymentGateway: Record "NPR Magento Payment Gateway")
    var
        PGNetsEasy: Record "NPR PG Nets Easy Setup";
    begin
        if (PGNetsEasy.Get(PaymentGateway.Code)) then
            exit;

        PGNetsEasy.Init();
        PGNetsEasy.Code := PaymentGateway.Code;

        if (PaymentGateway."Api Url".Contains('test')) then
            PGNetsEasy.Environment := PGNetsEasy.Environment::Test
        else
            PGNetsEasy.Environment := PGNetsEasy.Environment::Production;

        if (PaymentGateway.Token <> '') then
            PGNetsEasy.SetAuthorizationToken(PaymentGateway.Token);

        PGNetsEasy.Insert();
    end;

    local procedure MovePGQuickPay(PaymentGateway: Record "NPR Magento Payment Gateway")
    var
        QuickPaySetup: Record "NPR PG Quickpay Setup";
    begin
        if (QuickPaySetup.Get(PaymentGateway.Code)) then
            exit;

        QuickPaySetup.Init();
        QuickPaySetup.Code := PaymentGateway.Code;
        if (SecretExists(PaymentGateway."Api Password Key")) then
            QuickPaySetup.SetApiPassword(GetSecret(PaymentGateway."Api Password Key"));
        QuickPaySetup.Insert();
    end;

    local procedure SecretExists(KeyGuid: Guid): Boolean
    begin
        if (not IsolatedStorage.Contains(KeyGuid, DataScope::Company)) then
            exit(false);

        exit(GetSecret(KeyGuid) <> '');
    end;

    local procedure GetSecret(KeyGuid: Guid) Secret: Text
    begin
        if (IsNullGuid(KeyGuid)) then
            exit('');

        IsolatedStorage.Get(KeyGuid, DataScope::Company, Secret);
    end;
}
