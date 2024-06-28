page 6184655 "NPR Adyen Webhook Event Codes"
{
    Extensible = false;
    UsageCategory = None;
    Caption = 'Adyen Webhook Event Codes';
    PageType = List;
    SourceTable = "NPR Adyen Webhook Event Code";
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Event Code';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        if AdyenManagement.RefreshWebhookEventCodes() then
            CurrPage.Update(false);
    end;
}
