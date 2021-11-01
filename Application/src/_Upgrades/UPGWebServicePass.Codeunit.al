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
                    RetailInvSetEntry.Modify();
                end;
            until RetailInvSetEntry.Next() = 0;
    end;
}