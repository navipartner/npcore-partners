codeunit 6248651 "NPR BINMatching Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeEFTBinGroupPaymentLinks();
    end;

    local procedure UpgradeEFTBinGroupPaymentLinks()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        EFTGroupPaymLink: Record "NPR EFT BIN Group Paym. Link";
        EFTGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR BINMatching Upgrade", 'UpgradeBINGroupPaymentLink')) then
            exit;

        if EFTGroupPaymLink.FindSet() then
            repeat
                if not EFTGroupPaymentLink.Get(EFTGroupPaymLink."Group Code", EFTGroupPaymLink."Location Code", '') then begin
                    EFTGroupPaymentLink.Init();
                    EFTGroupPaymentLink."Group Code" := EFTGroupPaymLink."Group Code";
                    EFTGroupPaymentLink."Location Code" := EFTGroupPaymLink."Location Code";
                    EFTGroupPaymentLink."Payment Type POS" := EFTGroupPaymLink."Payment Type POS";
                    EFTGroupPaymentLink."From Payment Type POS" := '';
                    EFTGroupPaymentLink.Insert();
                end;
            until EFTGroupPaymLink.Next() = 0;

        EFTGroupPaymLink.DeleteAll();
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR BINMatching Upgrade", 'UpgradeBINGroupPaymentLink'));
    end;
}