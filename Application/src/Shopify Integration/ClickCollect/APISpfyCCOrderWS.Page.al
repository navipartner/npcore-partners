#if not BC17
page 6184559 "NPR API Spfy C&C Order WS"
{
    PageType = API;
    APIVersion = 'v2.0';
    APIPublisher = 'navipartner';
    APIGroup = 'shopify';
    Caption = 'Shopify ClickCollect Orders';
    EntityCaption = 'Shopify ClickCollect Order';
    EntitySetCaption = 'Shopify ClickCollect Orders';
    ChangeTrackingAllowed = false;
    DelayedInsert = true;
    EntityName = 'clickCollectOrder';
    EntitySetName = 'clickCollectOrders';
    SourceTable = "NPR Spfy C&C Order";
    ODataKeyFields = SystemId;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(shopifyStoreCode; Rec."Shopify Store Code")
                {
                    Caption = 'ShopifyStoreCode', Locked = true;
                }
                field(collectinStoreShopifyID; Rec."Collect in Store Shopify ID")
                {
                    Caption = 'CollectinStoreShopifyID', Locked = true;
                }
                field(customerName; Rec."Customer Name")
                {
                    Caption = 'CustomerName', Locked = true;
                }
                field(customerEmail; Rec."Customer E-Mail")
                {
                    Caption = 'CustomerEmail', Locked = true;
                }
                field(customerPhone; Rec."Customer Phone No.")
                {
                    Caption = 'CustomerPhone', Locked = true;
                }
                field(orderLines; OrderLines)
                {
                    Caption = 'OrderLines', Locked = true;

                    trigger OnValidate()
                    begin
                        Rec.SetOrderLines(OrderLines);
                    end;
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'BC System Id', Locked = true;
                    Editable = false;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'BC Created at', Locked = true;
                    Editable = false;
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'BC Row Version', Locked = true;
                }
#ENDIF
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OrderLines := Rec.GetOrderLines();
    end;

    var
        OrderLines: Text;
}
#endif