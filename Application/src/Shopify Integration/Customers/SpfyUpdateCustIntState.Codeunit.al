#if not BC17
codeunit 6248552 "NPR Spfy Update Cust.Int.State"
{
    Access = Internal;
    TableNo = Customer;

    var
        _ShopifyStore: Record "NPR Spfy Store";
        _DisableDataLog: Boolean;
        _CreateAtShopify: Boolean;
        _Initialized: Boolean;

    trigger OnRun()
    var
        SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
        NotInitializedErr: Label 'Codeunit 6248552 wasn’t initialized correctly. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        if not _Initialized then
            Error(NotInitializedErr);
        SpfySendCustomers.MarkCustomerAlreadyOnShopify(Rec, _ShopifyStore, _DisableDataLog, _CreateAtShopify, false);
    end;

    internal procedure SetProcessingOptions(var ShopifyStoreIn: Record "NPR Spfy Store"; DisableDataLog: Boolean; CreateAtShopify: Boolean)
    begin
        _Initialized := true;
        _ShopifyStore.Copy(ShopifyStoreIn);
        _DisableDataLog := DisableDataLog;
        _CreateAtShopify := CreateAtShopify;
    end;
}
#endif