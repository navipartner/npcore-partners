#if not BC17
codeunit 6184828 "NPR Spfy Assigned ID Mgt."
{
    Access = Public;

    var
        _SpfyAssignedIDMgtImpl: Codeunit "NPR Spfy Assigned ID Mgt Impl.";

    procedure GetAssignedShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"): Text[30]
    begin
        exit(_SpfyAssignedIDMgtImpl.GetAssignedShopifyID(BCRecID, ShopifyIDType));
    end;

    procedure AssignShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"; NewShopifyID: Text[30]; WithCheck: Boolean)
    begin
        _SpfyAssignedIDMgtImpl.AssignShopifyID(BCRecID, ShopifyIDType, NewShopifyID, WithCheck);
    end;

    procedure RemoveAssignedShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type")
    begin
        _SpfyAssignedIDMgtImpl.RemoveAssignedShopifyID(BCRecID, ShopifyIDType);
    end;

    procedure CopyAssignedShopifyID(FromBCRecID: RecordId; ToBCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type")
    begin
        _SpfyAssignedIDMgtImpl.CopyAssignedShopifyID(FromBCRecID, ToBCRecID, ShopifyIDType);
    end;

    procedure FilterWhereUsed(ShopifyIDType: Enum "NPR Spfy ID Type"; ShopifyID: Text[30]; ForUpdate: Boolean; var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        _SpfyAssignedIDMgtImpl.FilterWhereUsed(ShopifyIDType, ShopifyID, ForUpdate, ShopifyAssignedID);
    end;

    procedure FilterWhereUsedInTable(TableNo: Integer; ShopifyIDType: Enum "NPR Spfy ID Type"; ShopifyID: Text[30]; var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        _SpfyAssignedIDMgtImpl.FilterWhereUsedInTable(TableNo, ShopifyIDType, ShopifyID, ShopifyAssignedID);
    end;
}
#endif