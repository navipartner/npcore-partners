#if not BC17
page 6184556 "NPR Spfy Stores Subpage"
{
    Extensible = false;
    Caption = 'Shopify Stores';
    PageType = ListPart;
    SourceTable = "NPR Spfy Store";
    DelayedInsert = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies an internal unique id of the Shopify store.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether the integration with this Shopify store is enabled.';
                    ApplicationArea = NPRShopify;

                    trigger OnValidate()
                    var
                        ShopifyStore: Record "NPR Spfy Store";
                        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
                    begin
                        CurrPage.SaveRecord();
                        ShopifyStore.Get(Rec."Code");
                        ShopifyStore.SetRecFilter();
                        SpfyScheduleSend.SetupTaskProcessingJobQueues(ShopifyStore);
                    end;
                }
                field("Shopify Url"; Rec."Shopify Url")
                {
                    ToolTip = 'Specifies the Url to Shopify webshop.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field("Shopify Access Token"; Rec."Shopify Access Token")
                {
                    ToolTip = 'Specifies the Shopify access token, i.e. the password from Shopify private app setup.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the BC Currency code of the Shopify Store';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field("Get Orders Starting From"; Rec."Get Orders Starting From")
                {
                    ToolTip = 'Specifies the starting date-time Shopify orders are to be downloaded from the store on first run. After that system will download only new or updated orders since last time the process was run.';
                    ApplicationArea = NPRShopify;
                    Importance = Additional;
                }
                field("Last Orders Imported At"; Rec."Last Orders Imported At")
                {
                    ToolTip = 'Specifies the date-time Shopify orders last imported at. Next time system will import only orders created or updated after that moment.';
                    ApplicationArea = NPRShopify;
                    Importance = Additional;
                }
            }
        }
    }
}
#endif