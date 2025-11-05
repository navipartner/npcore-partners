#if not BC17
report 6014530 "NPR Spfy Initial Voucher Sync"
{
    Extensible = false;
    Caption = 'Initial Retail Voucher Sync. to Shopify';
    UsageCategory = None;
    ProcessingOnly = true;
    Description = 'This batch job will do initial retail voucher migration from BC to Shopify. It will go through retail vouchers in BC and create those marked as synchronizable with your selected Shopify Store as gift cards at the store. System will also update gift cards balances at Shopify, if needed.';

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
        dataitem(VoucherType; "NPR NpRv Voucher Type")
        {
            RequestFilterFields = Code;
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(Voucher; "NPR NpRv Voucher")
        {
            RequestFilterFields = "No.";
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }

    trigger OnPreReport()
    var
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
    begin
        SpfyRetailVoucherMgt.InitialSync(ShopifyStore, VoucherType, Voucher, true);
    end;
}
#endif