codeunit 6014431 "NPR Event Report Layout Upg."
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeReportLayouts();
    end;

    local procedure UpgradeReportLayouts()
    var
        EventWordLayout: Record "NPR Event Word Layout";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), '"NPR Event Report Layout Upg."', 'Upgrade');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Event Report Layout Upg.")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if EventWordLayout.FindSet() then
            repeat
                CopyToReportLayout(EventWordLayout);
            until EventWordLayout.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Event Report Layout Upg."));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure CopyToReportLayout(EventWordLayout: Record "NPR Event Word Layout")
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        if not EventWordLayout.Layout.HasValue() then
            exit;
        CreateReportLayout(CustomReportLayout, EventWordLayout);
        CreateEventReportLayout(CustomReportLayout, EventWordLayout);
    end;

    local procedure CreateReportLayout(var CustomReportLayout: Record "Custom Report Layout"; EventWordLayout: Record "NPR Event Word Layout")
    begin
        EventWordLayout.CalcFields(Layout, "XML Part");
        CustomReportLayout.Init();
        CustomReportLayout."Report ID" := EventWordLayout."Report ID";
        CustomReportLayout.Code := CustomReportLayout.GetDefaultCode(CustomReportLayout."Report ID");
        CustomReportLayout.Insert(true);
        CustomReportLayout.Description := EventWordLayout.Description;
        CustomReportLayout.Type := CustomReportLayout.Type::Word;
        CustomReportLayout."File Extension" := 'DOCX';
        CustomReportLayout.Layout := EventWordLayout.Layout;
        CustomReportLayout."Custom XML Part" := EventWordLayout."XML Part";
        CustomReportLayout.Modify(true);
    end;

    local procedure CreateEventReportLayout(CustomReportLayout: Record "Custom Report Layout"; EventWordLayout: Record "NPR Event Word Layout")
    var
        EventReportLayout: Record "NPR Event Report Layout";
        Job: Record Job;
    begin
        EventWordLayout.CalcFields("Request Page Parameters");
        EventReportLayout.Init();
        EventWordLayout.GetJobFromRecID(Job);
        EventReportLayout."Event No." := Job."No.";
        EventReportLayout.Insert(true);
        EventReportLayout.Validate(Usage, EventWordLayout.Usage);
        EventReportLayout.Validate("Report ID", EventWordLayout."Report ID");
        EventReportLayout.Validate("Layout Code", CustomReportLayout.Code);
        EventReportLayout."Request Page Parameters" := EventWordLayout."Request Page Parameters";
        EventReportLayout."Use Req. Page Parameters" := EventWordLayout."Use Req. Page Parameters";
        EventReportLayout.Modify(true);
    end;
}
