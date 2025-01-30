#if not BC17
page 6184937 "NPR Spfy App Request FactBox"
{
    Extensible = false;
    Caption = 'Shopify App Request Payload';
    PageType = CardPart;
    SourceTable = "NPR Spfy App Request";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
#if BC18 or BC19 or BC20 or BC21 or BC22 or BC23
            usercontrol(RequestPayloadDataUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#else
            usercontrol(RequestPayloadDataUC; WebPageViewer)
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
        RequestPayload := Rec.GetPayload();
        if IsReady then
            FillAddIn();
    end;

    local procedure FillAddIn()
    begin
        CurrPage.RequestPayloadDataUC.SetContent(StrSubstNo('<textarea readonly Id="NPRSpfyAppRequestDataTextArea" style="width:100%;height:100%;resize: none;">%1</textarea>', RequestPayload));
    end;

    var
        RequestPayload: Text;
        IsReady: Boolean;
}
#endif