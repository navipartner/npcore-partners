#if not BC17
page 6185044 "NPR Spfy Sales Channels"
{
    Extensible = false;
    Caption = 'Shopify Sales Channels';
    PageType = List;
    SourceTable = "NPR Spfy Sales Channel";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store the sales channel is created in.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the unique identifier of the sales channel, as assigned by Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the sales channel.';
                    ApplicationArea = NPRShopify;
                }
                field("Use for publication"; Rec."Use for publication")
                {
                    ToolTip = 'Specifies if the sales channel is used when creating new products in Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field(Default; Rec.Default)
                {
                    ToolTip = 'Specifies whether this is the default sales channel. It is used when creating new products in Shopify if no other channel is selected.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetSalesChannels)
            {
                Caption = 'Get Sales Channels';
                ToolTip = 'Retrieves sales channels from Shopify.';
                ApplicationArea = NPRShopify;
                Image = RefreshLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SpfySalesChannelMgt: Codeunit "NPR Spfy Sales Channel Mgt.";
                begin
                    SpfySalesChannelMgt.RetrieveSalesChannelsFromShopify(CopyStr(Rec.GetFilter("Shopify Store Code"), 1, 20), true);
                end;
            }
        }
    }
}
#endif