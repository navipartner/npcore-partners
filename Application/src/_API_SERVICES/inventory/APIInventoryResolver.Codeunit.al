#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248291 "NPR API Inventory Resolver" implements "NPR API Module Resolver"
{
    Access = Internal;

    procedure Resolve(var Request: Codeunit "NPR API Request"): Interface "NPR API Request Handler"
    var
        APIInventory: Codeunit "NPR API Inventory";
    begin
        exit(APIInventory);
    end;

    procedure GetRequiredPermissionSet(): Text
    begin
        exit('NPR API Inventory');
    end;
}
#endif