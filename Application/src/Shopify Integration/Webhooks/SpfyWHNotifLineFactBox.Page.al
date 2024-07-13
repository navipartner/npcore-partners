#if not BC17
page 6184708 "NPR Spfy WH Notif.Line FactBox"
{
    Extensible = false;
    Caption = 'Shopify Webhook Notification Payload';
    PageType = CardPart;
    SourceTable = "NPR Spfy Webhook Notification";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
#if BC18 or BC19 or BC20 or BC21 or BC22 or BC23
            usercontrol(NotificationPayloadDataUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#else
            usercontrol(NotificationPayloadDataUC; WebPageViewer)
#endif
            {
                ApplicationArea = NPRShopify;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    IsReady := true;
                    FillAddIn();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NotificationPayload := Rec.GetPayload();
        if IsReady then
            FillAddIn();
    end;

    local procedure FillAddIn()
    begin
        CurrPage.NotificationPayloadDataUC.SetContent(StrSubstNo('<textarea readonly Id="NPRHLWebhookRequestDataTextArea" style="width:100%;height:100%;resize: none;">%1</textarea>', NotificationPayload));
    end;

    var
        NotificationPayload: Text;
        IsReady: Boolean;
}
#endif