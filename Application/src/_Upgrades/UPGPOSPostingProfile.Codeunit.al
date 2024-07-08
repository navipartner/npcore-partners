codeunit 6184561 "NPR UPG POS Posting Profile"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Posting Profile', 'MoveAsyncPostingSetup');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Posting Profile", 'MoveAsyncPostingSetup')) then begin
            MoveAsyncPostingSetup();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Posting Profile", 'MoveAsyncPostingSetup'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure MoveAsyncPostingSetup()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSalesDocumentSetup: Record "NPR POS Sales Document Setup";
    begin
        if not POSSalesDocumentSetup.Get() then begin
            POSSalesDocumentSetup.Init();
            POSSalesDocumentSetup.Insert();
        end;
        if POSSalesDocumentSetup."Post with Job Queue" then
            exit;

        POSPostingProfile.SetRange("Post POS Sale Doc. With JQ", true);
        if POSPostingProfile.IsEmpty() then
            exit;

        POSSalesDocumentSetup."Post with Job Queue" := true;
        POSSalesDocumentSetup.Modify();
    end;
}
