page 6150802 "NPR HL Webhook Request FactBox"
{
    Extensible = false;
    Caption = 'HL Webhook Request Data';
    PageType = CardPart;
    SourceTable = "NPR HL Webhook Request";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
            usercontrol(HLRequestDataUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#else
            usercontrol(HLRequestDataUC; WebPageViewer)
#endif
            {
                ApplicationArea = NPRHeyLoyalty;

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
        HLRequestData := Rec.GetHLRequestData();
        if IsReady then
            FillAddIn();
    end;

    local procedure FillAddIn()
    begin
        CurrPage.HLRequestDataUC.SetContent(StrSubstNo('<textarea readonly Id="NPRHLWebhookRequestDataTextArea" style="width:100%;height:100%;resize: none;">%1</textarea>', HLRequestData));
    end;

    var
        HLRequestData: Text;
        IsReady: Boolean;
}