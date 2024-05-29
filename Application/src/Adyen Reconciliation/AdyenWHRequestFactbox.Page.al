page 6184533 "NPR Adyen WH Request Factbox"
{
    Extensible = false;

    Caption = 'Adyen Webhook Request Data';
    PageType = CardPart;
    SourceTable = "NPR AF Rec. Webhook Request";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
            usercontrol(AdyenRequestDataUC; "WebPageViewer")
#else
            usercontrol(AdyenRequestDataUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
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
        _AdyenRequestData := Rec.GetAdyenRequestData();
        if _IsReady then
            FillAddIn();
    end;

    local procedure FillAddIn()
    begin
        CurrPage.AdyenRequestDataUC.SetContent(StrSubstNo('<textarea readonly Id="NPRAdyenWebhookRequestDataTextArea" style="width:100%;height:100%;resize: none;">%1</textarea>', _AdyenRequestData));
    end;

    var
        _IsReady: Boolean;
        _AdyenRequestData: Text;
}
