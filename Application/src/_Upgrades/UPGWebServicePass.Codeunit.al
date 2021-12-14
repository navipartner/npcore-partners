codeunit 6014655 "NPR UPG Web Service Pass"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Remote Endp. Pass. Upgrade', 'Upgrade');

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'RemoteEndpoints')) then begin
            UpgradeRemoteEndpointsPassword();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'RemoteEndpoints'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'RetailInventorySets')) then begin
            UpgradeRetailInventorySetsPassword();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'RetailInventorySets'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'POSHCEndpointSetup')) then begin
            UpgradePOSHCEndpointSetupPassword();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'POSHCEndpointSetup'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpXmlTemplate')) then begin
            UpgradeNpXmlTemplatePassword();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpXmlTemplate'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpCsStore')) then begin
            UpgradeNpCsStorePassword();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpCsStore'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpRvPartner')) then begin
            UpgradeNpRvPartnerPassword();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpRvPartner'));
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpRvGlobalVoucher')) then begin
            UpgradeNpRvGlobalVoucherSetup();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Web Service Pass", 'NpRvGlobalVoucher'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeRemoteEndpointsPassword()
    var
        RemoteEndpointSetup: Record "NPR MM NPR Remote Endp. Setup";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if RemoteEndpointSetup.FindSet(true) then
            repeat
                if RemoteEndpointSetup."User Password" <> '' then begin
                    WebServiceAuthHelper.SetApiPassword(RemoteEndpointSetup."User Password", RemoteEndpointSetup."User Password Key");
                    RemoteEndpointSetup."User Password" := '';
                    RemoteEndpointSetup.Modify();
                end;
            until RemoteEndpointSetup.Next() = 0;
    end;

    local procedure UpgradeRetailInventorySetsPassword()
    var
        RetailInvSetEntry: Record "NPR RIS Retail Inv. Set Entry";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if RetailInvSetEntry.FindSet(true) then
            repeat
                if RetailInvSetEntry."API Password" <> '' then begin
                    WebServiceAuthHelper.SetApiPassword(RetailInvSetEntry."API Password", RetailInvSetEntry."API Password Key");
                    RetailInvSetEntry."API Password" := '';
                    RetailInvSetEntry.Modify();
                end;
            until RetailInvSetEntry.Next() = 0;
    end;

    local procedure UpgradePOSHCEndpointSetupPassword()
    var
        POSHCEndpointSetup: Record "NPR POS HC Endpoint Setup";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if POSHCEndpointSetup.FindSet(true) then
            repeat
                if POSHCEndpointSetup."User Password" <> '' then begin
                    WebServiceAuthHelper.SetApiPassword(POSHCEndpointSetup."User Password", POSHCEndpointSetup."API Password Key");
                    POSHCEndpointSetup."User Password" := '';
                    POSHCEndpointSetup.Modify();
                end;
            until POSHCEndpointSetup.Next() = 0;
    end;

    local procedure UpgradeNpXmlTemplatePassword()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        MagentoSetup: Record "NPR Magento Setup";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        WindowsAuthDeprecatedErr: Label 'Cannot upgrade %1 - %2. Error: Windows Credentials are deprecated. Please select API Username Type ''Automatic'' and add Basic Authentication Username and Password or ''Custom'' and add a value into field ''API Authorization''.';
    begin
        If MagentoSetup.Get() AND MagentoSetup."Magento Enabled" then begin
            IF MagentoSetup."API Authorization" <> '' then
                MagentoSetup.AuthType := MagentoSetup.AuthType::Custom
            else
                MagentoSetup.AuthType := MagentoSetup.AuthType::Basic;
            MagentoSetup.Modify();
        end;

        NpXmlTemplate.SetRange("API Transfer", true);
        if NpXmlTemplate.FindSet(true) then
            repeat
                IF NpXmlTemplate."API Authorization" <> '' then begin
                    NpXmlTemplate.AuthType := NpXmlTemplate.AuthType::Custom;
                    NpXmlTemplate.Modify();
                end else begin
                    IF NpXmlTemplate."API Password" = '' then
                        Error(WindowsAuthDeprecatedErr, NpXmlTemplate.TableCaption, NpXmlTemplate.Code)
                    else begin
                        IF NpXmlTemplate."API Username Type" <> NpXmlTemplate."API Username Type"::Automatic then
                            Error(WindowsAuthDeprecatedErr, NpXmlTemplate.TableCaption, NpXmlTemplate.Code);
                        NpXmlTemplate.AuthType := NpXmlTemplate.AuthType::Basic;
                        WebServiceAuthHelper.SetApiPassword(NpXmlTemplate."API Password", NpXmlTemplate."API Password Key");
                        NpXmlTemplate."API Password" := '';
                        NpXmlTemplate.Modify();
                    end;
                end;
            until NpXmlTemplate.Next() = 0;
    end;

    local procedure UpgradeNpCsStorePassword()
    var
        NpCsStore: Record "NPR NpCs Store";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if NpCsStore.FindSet(true) then
            repeat
                if NpCsStore."Service Password" <> '' then begin
                    WebServiceAuthHelper.SetApiPassword(NpCsStore."Service Password", NpCsStore."API Password Key");
                    NpCsStore."Service Password" := '';
                    NpCsStore.Modify();
                end;
            until NpCsStore.Next() = 0;
    end;

    local procedure UpgradeNpRvPartnerPassword()
    var
        NpRvPartner: Record "NPR NpRv Partner";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if NpRvPartner.FindSet(true) then
            repeat
                if NpRvPartner."Service Password" <> '' then begin
                    WebServiceAuthHelper.SetApiPassword(NpRvPartner."Service Password", NpRvPartner."API Password Key");
                    NpRvPartner."Service Password" := '';
                    NpRvPartner.Modify();
                end;
            until NpRvPartner.Next() = 0;
    end;

    local procedure UpgradeNpRvGlobalVoucherSetup()
    var
        GlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if GlobalVoucherSetup.FindSet(true) then
            repeat
                if GlobalVoucherSetup."Service Password" <> '' then begin
                    WebServiceAuthHelper.SetApiPassword(GlobalVoucherSetup."Service Password", GlobalVoucherSetup."API Password Key");
                    GlobalVoucherSetup."Service Password" := '';
                    GlobalVoucherSetup.Modify();
                end;
            until GlobalVoucherSetup.Next() = 0;
    end;
}