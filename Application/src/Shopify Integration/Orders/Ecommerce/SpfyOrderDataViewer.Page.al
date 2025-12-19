#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248217 "NPR Spfy Order Data Viewer"
{
    Extensible = false;
    Caption = 'Shopify Order Data';
    PageType = CardPart;
    SourceTable = "NPR Spfy Event Log Entry";
    UsageCategory = None;
    Editable = false;
    DataCaptionExpression = Format(Rec."Document Type") + ' ' + Rec."Shopify Id";
    layout
    {
        area(content)
        {
#if not BC23
            usercontrol(ShopifyResponseViewer; "WebPageViewer")
#else
            usercontrol(ShopifyResponseViewer; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#endif
            {
                ApplicationArea = NPRShopify, NPRShopifyEcommerce;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    _IsReady := true;
                    FillAddIn();
                end;
            }
        }
    }

    local procedure FillAddIn()
    begin
        CurrPage.ShopifyResponseViewer.SetContent(StrSubstNo('<textarea readonly Id="NPRShopifyOrderDataTextArea" style="width:100%;height:100%;resize: none;">%1</textarea>', _FactBoxData));
    end;

    trigger OnAfterGetRecord()
    begin
        _FactBoxData := SpfyAPIOrderLogMgt.GetOrderData(Rec);
        if _IsReady then
            FillAddIn();
    end;

    var
        SpfyAPIOrderLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        _IsReady: Boolean;
        _FactBoxData: Text;
}
#ENDIF