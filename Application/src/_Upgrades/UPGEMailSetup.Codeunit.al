codeunit 6014470 "NPR UPG E-Mail Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG E-Mail Setup', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG E-Mail Setup")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG E-Mail Setup"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeEmailSetup();
    end;

    local procedure UpgradeEmailSetup()
    var
        EmailSetup: Record "NPR E-mail Setup";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        NaviDocsSetup: Record "NPR NaviDocs Setup";
        DoModify: Boolean;
    begin
        //EmailTemplate
        if not EmailSetup.Get() then
            exit;

        if EmailSetup."From Name" = '' then
            EmailSetup."From Name" := 'Navipartner Demo';

        if EmailSetup."From E-mail Address" = '' then
            EmailSetup."From E-mail Address" := 'notification@navipartner.dk';

        if EmailTemplateHeader.FindSet() then
            repeat
                DoModify := false;
                if EmailTemplateHeader."From E-mail Name" = '' then begin
                    EmailTemplateHeader."From E-mail Name" := EmailSetup."From Name";
                    DoModify := true;
                end;
                if EmailTemplateHeader."From E-mail Address" = '' then begin
                    EmailTemplateHeader."From E-mail Address" := EmailSetup."From E-mail Address";
                    DoModify := true;
                end;
                if DoModify then
                    EmailTemplateHeader.Modify();
            until EmailTemplateHeader.Next() = 0;

        //NaviDocs
        if not NaviDocsSetup.Get() then
            exit;
        NaviDocsSetup."From E-mail Name" := EmailSetup."From Name";
        NaviDocsSetup."From E-mail Address" := EmailSetup."From E-mail Address";
        NaviDocsSetup.Modify();
    end;

}