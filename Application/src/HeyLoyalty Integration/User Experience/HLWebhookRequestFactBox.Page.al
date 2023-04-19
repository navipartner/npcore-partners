page 6150802 "NPR HL Webhook Request FactBox"
{
    Extensible = false;
    Caption = 'HL Webhook Request Data';
    PageType = CardPart;
    SourceTable = "NPR HL Webhook Request";
    UsageCategory = None;
    Editable = false;
#IF NOT BC17
    AboutText = 'Specifies webhook request details received from HeyLoyalty.';
#ENDIF

    layout
    {
        area(content)
        {
            usercontrol(HLRequestDataUC; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
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