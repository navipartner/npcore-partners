#if not BC17
codeunit 6248341 "NPR Spfy Update Item Int.State"
{
    Access = Internal;
    TableNo = Item;

    var
        _ShopifyStore: Record "NPR Spfy Store";
        _DisableDataLog: Boolean;
        _CreateAtShopify: Boolean;
        _Initialized: Boolean;

    trigger OnRun()
    var
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        NotInitializedErr: Label 'Codeunit 6248341 wasn’t initialized correctly. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        if not _Initialized then
            Error(NotInitializedErr);
        SendItemAndInventory.MarkItemAlreadyOnShopify(Rec, _ShopifyStore, _DisableDataLog, _CreateAtShopify, false);
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