#if not BC17
codeunit 6248491 "NPR Spfy Assigned ID Temp"
{
    Access = Internal;
    SingleInstance = true;

    var
        TempShopifyAssignedID: Record "NPR Spfy Assigned ID" temporary;

    procedure SetTempRecordSet(var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        TempShopifyAssignedID.Copy(ShopifyAssignedID, true);
    end;

    procedure GetTempRecordSet(var ShopifyAssignedID: Record "NPR Spfy Assigned ID")
    begin
        ShopifyAssignedID.Copy(TempShopifyAssignedID, true);
    end;
}
#endif