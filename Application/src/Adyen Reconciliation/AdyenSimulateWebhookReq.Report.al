report 6014536 "NPR Adyen Simulate Webhook Req"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    Caption = 'Adyen Simulate Webhook Request';
    ProcessingOnly = true;
    UsageCategory = None;

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(DownloadReport)
                {
                    Caption = 'Download a Report';
                    field("Report Name"; _ReportName)
                    {
                        Caption = 'Report Name';
                        ToolTip = 'Specifies the downloadable Report''s Name.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        CurrReport.Break();
    end;

    procedure RequestReportName(): Text[100]
    begin
        if CurrReport.RunRequestPage() = '' then
            exit('');

        exit(CopyStr(_ReportName, 1, 100));
    end;

    var
        _ReportName: Text;
}
