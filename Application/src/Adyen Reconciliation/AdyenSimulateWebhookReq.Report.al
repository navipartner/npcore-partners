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
                    field(Live; _Live)
                    {
                        Caption = 'Live';
                        ToolTip = 'Specifies if the Report should be downloaded from the Live environment.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Report Name"; _ReportName)
                    {
                        Caption = 'Report Name';
                        ToolTip = 'Specifies the downloadable Report''s Name.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Merchant Account"; _MerchantAccount)
                    {
                        Caption = 'Merchant Account';
                        ToolTip = 'Specifies the downloadable Report''s Merchant Account.';
                        ApplicationArea = NPRRetail;
                        Lookup = true;
                        TableRelation = "NPR Adyen Merchant Account".Name;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        CurrReport.Break();
    end;

    procedure RequestReportName(): Text[200]
    begin
        if CurrReport.RunRequestPage() = '' then
            exit('');

        exit(CopyStr(CopyStr(_ReportName, 1, 100) + '|' + _MerchantAccount + '|' + Format(_Live), 1, 200));
    end;

    var
        _ReportName: Text;
        _MerchantAccount: Text[80];
        _Live: Boolean;
}
