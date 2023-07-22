codeunit 6151377 "NPR POS Action:Block DiscountB"
{
    Access = Internal;
    procedure VerifyPassword(POSSetup: Codeunit "NPR POS Setup"; Password: Text)
    var
        POSUnit: Record "NPR POS Unit";
        SecurityProfile: Codeunit "NPR POS Security Profile";
    begin
        POSSetup.GetPOSUnit(POSUnit);
        if not SecurityProfile.IsUnblockDiscountPasswordValidIfProfileExist(POSUnit."POS Security Profile", Password) then
            Error('');
    end;

    procedure ToggleBlockState(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Custom Disc Blocked" := not SaleLinePOS."Custom Disc Blocked";
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        if (not SaleLinePOS."Custom Disc Blocked") then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";

        SaleLinePOS.Modify();
    end;

    procedure ShowPassPrompt(Setup: Codeunit "NPR POS Setup"; var ShowPasswordPrompt: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        SecurityProfile: Codeunit "NPR POS Security Profile";
    begin
        Setup.GetPOSUnit(POSUnit);
        ShowPasswordPrompt := SecurityProfile.IsUnblockDiscountPasswordSetIfProfileExist(POSUnit."POS Security Profile")
    end;
}