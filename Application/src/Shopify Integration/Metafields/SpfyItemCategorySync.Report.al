#if not BC17
report 6014566 "NPR Spfy Item Category Sync"
{
    Extensible = false;
    Caption = 'Item Category Sync. to Shopify';
    UsageCategory = None;
    ProcessingOnly = true;
    Description = 'This batch job will perform the initial migration of item categories from BC to Shopify. It will go through the item categories in BC and create any that do not already exist in your selected Shopify store.';

    dataset
    {
        dataitem(ShopifyStore; "NPR Spfy Store")
        {
            RequestFilterFields = Code;
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(ItemCategory; "Item Category")
        {
            RequestFilterFields = Code;
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ResyncExistingOption; ResyncExisting)
                    {
                        Caption = 'Resync Existing Categories';
                        ToolTip = 'Specifies if you want to resync existing item categories.';
                        ApplicationArea = NPRShopify;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        ConfirmSyncQst: Label 'This batch job will perform synchronization of item categories from BC to Shopify. It will go through the item categories in BC and create any that do not already exist in your selected Shopify store(s).\Are you sure you want to continue?';
    begin
        if not Confirm(ConfirmSyncQst, true) then
            exit;
        SpfyMetafieldMgt.SyncItemCategories(ItemCategory, ShopifyStore, ResyncExisting, false);
    end;

    var
        ResyncExisting: Boolean;
}
#endif