report 6014502 "NPR NpCs Data Source EF Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
#IF NOT BC17
    Extensible = false;
#ENDIF
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'Collect DS Exten.Field Location Setup';
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnPreReport()
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
    begin
        DataSourceExtFieldSetup.FilterGroup(2);
        DataSourceExtFieldSetup.SetRange("Extension Module", DataSourceExtFieldSetup."Extension Module"::ClickCollect);
        DataSourceExtFieldSetup.FilterGroup(0);
        Page.Run(Page::"NPR POS DS Exten. Field Setup", DataSourceExtFieldSetup);
    end;
}