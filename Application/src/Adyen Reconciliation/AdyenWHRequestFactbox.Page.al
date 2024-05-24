page 6184533 "NPR Adyen WH Request Factbox"
{
    Extensible = false;

    Caption = 'Adyen Webhook Request Data';
    PageType = CardPart;
    SourceTable = "NPR AF Rec. Webhook Request";
    UsageCategory = Documents;
    ApplicationArea = NPRRetail;
    Editable = false;

    layout
    {
        area(content)
        {
            usercontrol(AdyenRequestDataUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
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
