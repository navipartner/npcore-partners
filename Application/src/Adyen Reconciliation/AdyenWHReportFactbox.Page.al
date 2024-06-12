page 6184666 "NPR Adyen WH Report Factbox"
{
    Extensible = false;

    Caption = 'Adyen Webhook Report Data';
    PageType = CardPart;
    SourceTable = "NPR AF Rec. Webhook Request";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
            usercontrol(ReportDataUC; "WebPageViewer")
#else
            usercontrol(ReportDataUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#endif
            {
                ApplicationArea = NPRRetail;
                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    _IsReady := true;
                    FillAddIn();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _ReportFactBoxData := Rec.GetReportData();
        if _IsReady then
            FillAddIn();
    end;

    local procedure FillAddIn()
    begin
        CurrPage.ReportDataUC.SetContent(StrSubstNo('<textarea readonly Id="NPRAdyenWebhookRequestDataTextArea" style="width:100%;height:100%;resize: none;">%1</textarea>', _ReportFactBoxData));
    end;

    var
        _IsReady: Boolean;
        _ReportFactBoxData: Text;
}
