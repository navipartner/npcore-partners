codeunit 6150639 "NPR UPG Pay By Link Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdatePayByLinkSetup();
    end;

    local procedure UpdatePayByLinkSetup()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Pay By Link Setup', 'UpdatePayByLinkSetup');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdatePayByLinkSetup')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        TransferPayByLinkSetup();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdatePayByLinkSetup'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure TransferPayByLinkSetup()
    var
        PaybyLinkSetup: Record "NPR Pay by Link Setup";
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if not PaybyLinkSetup.Get() then
            exit;
        if AdyenSetup.Get() then begin
            PopulateAdyenSetup(AdyenSetup, PaybyLinkSetup);
            AdyenSetup.Modify();
        end else begin
            AdyenSetup.Init();
            PopulateAdyenSetup(AdyenSetup, PaybyLinkSetup);
            AdyenSetup.Insert();
        end;
    end;

    local procedure PopulateAdyenSetup(var AdyenSetup: Record "NPR Adyen Setup"; PaybyLinkSetup: Record "NPR Pay by Link Setup")
    begin
        AdyenSetup."Pay By Link Gateaway Code" := PaybyLinkSetup."Payment Gateaway Code";
        AdyenSetup."Pay By Link E-Mail Template" := PaybyLinkSetup."E-Mail Template";
        AdyenSetup."Pay By Link Account Type" := PaybyLinkSetup."Account Type";
        AdyenSetup."Pay By Link Account No." := PaybyLinkSetup."Account No.";
        AdyenSetup."PayByLink Enable Auto Posting" := PaybyLinkSetup."Enable Automatic Posting";
        AdyenSetup."Pay By Link Exp. Duration" := PaybyLinkSetup."Pay by Link Exp. Duration";
        AdyenSetup."Pay By Link SMS Template" := PaybyLinkSetup."SMS Template";
        AdyenSetup."PayByLink Posting Retry Count" := PaybyLinkSetup."Posting Retry Count";
        AdyenSetup."Enable Pay by Link" := PaybyLinkSetup."Enable Pay by Link";
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Pay By Link Setup");
    end;
}