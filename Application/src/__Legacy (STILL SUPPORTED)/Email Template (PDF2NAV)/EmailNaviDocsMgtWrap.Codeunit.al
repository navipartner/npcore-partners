codeunit 6014466 "NPR E-mail NaviDocs Mgt.Wrap."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    procedure GetCustomReportLayoutVariant(CustomReportSelection: Record "Custom Report Selection"; var ResultReportLayoutCode: Code[20])
    begin
        ResultReportLayoutCode := CustomReportSelection."Custom Report Layout Code";
    end;

    procedure HasCustomReportLayout(CustomReportSelection: Record "Custom Report Selection"): Boolean
    begin
        exit(CustomReportSelection."Custom Report Layout Code" <> '');
    end;
}

