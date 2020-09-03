codeunit 6014466 "NPR E-mail NaviDocs Mgt.Wrap."
{
    // NPR5.38/THRO/20171108 CASE 295065 Object created Wrappers for E-mail and NaviDocs.
    //                                   Custom Report Layout Primary Key field have diff name and type in NAV2016 and NAV2017


    trigger OnRun()
    begin
    end;

    procedure GetCustomReportLayoutVariant(CustomReportSelection: Record "Custom Report Selection"; var ResultReportLayoutCode: Variant)
    begin
        ResultReportLayoutCode := CustomReportSelection."Custom Report Layout Code";
    end;

    procedure HasCustomReportLayout(CustomReportSelection: Record "Custom Report Selection"): Boolean
    begin
        exit(CustomReportSelection."Custom Report Layout Code" <> '');
    end;
}

