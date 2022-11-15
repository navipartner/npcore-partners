codeunit 6059960 "NPR POS Action: Item Variant B"
{
    Access = Internal;
    procedure ShowItemVariants(POSSetup: Codeunit "NPR POS Setup")
    var
        ItemVariants: Page "NPR Item Variants";
        POSStore: Record "NPR POS Store";
    begin
        POSSetup.GetPOSStore(POSStore);
        ItemVariants.SetLocationCodeFilter(POSStore."Location Code");
        ItemVariants.LookupMode(true);
        ItemVariants.Run();
    end;
}