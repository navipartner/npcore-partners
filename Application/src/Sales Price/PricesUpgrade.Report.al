report 6014409 "NPR Prices Upgrade"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    ApplicationArea = NPRRetail;
    Caption = 'Prices Upgrade';
    UsageCategory = Administration;
    ProcessingOnly = true;
    dataset
    {

    }

    requestpage
    {
        Caption = 'Action';
        layout
        {
            area(Content)
            {
                field(fUpgradePrices; UpgradePrices)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Upgrade Prices and Discounts';
                    ToolTip = 'Specifies the value of the Upgrade Prices and Discounts field.';

                }
                field(fDeleteOldPrices; DeleteOldPrices)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Delete Old Prices and Discounts';
                    ToolTip = 'Specifies the value of the Delete Old Prices and Discounts field.';
                }
            }
        }
    }

    trigger OnPostReport()
    var
#pragma warning disable AL0432
        FeaturePriceCalculation: Codeunit "Feature - Price Calculation";
#pragma warning restore
        NewPricesUpgrade: Codeunit "NPR New Prices Upgrade";
        PreviewRecordsLbl: Label 'Old prices found. Do you want to review data before upgrade?';
        ConfirmUpgradeLbl: Label 'Upgrade can take some time depending on the record count. Do you want to continue?';
        UpgradeNotNeededLbl: Label 'Old prices not found. Upgrade not needed.';
        DeleteOldLbl: Label 'Do you want to delete records from old prices and discont tables? This process is irreversible.';
    begin
        if UpgradePrices then
            if FeaturePriceCalculation.IsDataUpdateRequired() then begin
                if Confirm(PreviewRecordsLbl) then
                    FeaturePriceCalculation.ReviewData();
                if Confirm(ConfirmUpgradeLbl) then begin
#if BC17
                    NewPricesUpgrade.FillPriceListNos();
#endif
                    NewPricesUpgrade.EnableFeature();
                end;
            end else
                Message(UpgradeNotNeededLbl);
        if DeleteOldPrices then
            if Confirm(DeleteOldLbl) then
                DeleteOldPricesAndDiscounts();
    end;


    var

        UpgradePrices: Boolean;
        DeleteOldPrices: Boolean;

    local procedure DeleteOldPricesAndDiscounts()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
#pragma warning disable AL0432
        PriceCalculationMgt.TestIsEnabled();
#pragma warning restore
        DeleteRecords();
    end;

#pragma warning disable AL0432
    local procedure DeleteRecords()
    var
        SalesPrice: Record "Sales Price";
        SalesLineDiscount: Record "Sales Line Discount";
        PurchasePrice: Record "Purchase Price";
        PurchaseLineDiscount: Record "Purchase Line Discount";
        JobItemPrice: Record "Job Item Price";
        JobGLAccountPrice: Record "Job G/L Account Price";
        JobResourcePrice: Record "Job Resource Price";
        ResourceCost: Record "Resource Cost";
        ResourcePrice: Record "Resource Price";
    begin
        SalesPrice.Reset();
        SalesPrice.DeleteAll();
        Commit();

        SalesLineDiscount.Reset();
        SalesLineDiscount.DeleteAll();
        Commit();

        PurchasePrice.Reset();
        PurchasePrice.DeleteAll();
        Commit();

        PurchaseLineDiscount.Reset();
        PurchaseLineDiscount.DeleteAll();
        Commit();

        JobItemPrice.Reset();
        JobItemPrice.DeleteAll();
        Commit();

        JobGLAccountPrice.Reset();
        JobGLAccountPrice.DeleteAll();
        Commit();

        JobResourcePrice.Reset();
        JobResourcePrice.DeleteAll();
        Commit();

        ResourceCost.Reset();
        ResourceCost.DeleteAll();
        Commit();

        ResourcePrice.Reset();
        ResourcePrice.DeleteAll();
        Commit();
    end;
#pragma warning restore
}
