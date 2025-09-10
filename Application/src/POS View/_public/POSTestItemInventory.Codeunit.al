codeunit 6248494 "NPR POS Test Item Inventory"
{
    TableNo = "NPR POS Sale";
    trigger OnRun()
    begin
        if not CheckSetup(Rec) then
            exit;

        TestItemInventory(Rec);
    end;

    local procedure FindNotInStockLines(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var ErrorMessage: Record "Error Message")
    begin
        if not TempSaleLinePOS.FindSet() then
            exit;

        repeat
            TempSaleLinePOS."MR Anvendt antal" := CalcInventory(TempSaleLinePOS);
            if TempSaleLinePOS."MR Anvendt antal" < TempSaleLinePOS."Quantity (Base)" then
                LogErrorMessage(TempSaleLinePOS, ErrorMessage);
        until TempSaleLinePOS.Next() = 0;
    end;

    local procedure CalcInventory(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Decimal
    var
        Item: Record Item;
    begin
        if not Item.Get(TempSaleLinePOS."No.") then
            exit(0);

        if TempSaleLinePOS."Bin Code" <> '' then
            exit(CheckBinContent(TempSaleLinePOS));

        Item.SetRange("Variant Filter", TempSaleLinePOS."Variant Code");
        Item.SetRange("Location Filter", TempSaleLinePOS."Location Code");
        if SpecificItemTrackingExist(Item) then begin
            if TempSaleLinePOS."Serial No." <> '' then
                Item.SetRange("Serial No. Filter", TempSaleLinePOS."Serial No.");
            if TempSaleLinePOS."Lot No." <> '' then
                Item.SetRange("Lot No. Filter", TempSaleLinePOS."Lot No.");
        end;
        Item.CalcFields(Inventory);
        exit(Item.Inventory);
    end;

    local procedure SetupSalesItems(var SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not TempSaleLinePOS.IsTemporary then
            exit(false);

        Clear(TempSaleLinePOS);
        TempSaleLinePOS.DeleteAll();

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        if SaleLinePOS.IsEmpty then
            exit(false);

        SaleLinePOS.FindSet();
        repeat
            SetupSalesItem(SaleLinePOS, TempSaleLinePOS);
        until SaleLinePOS.Next() = 0;
        TempSaleLinePOS.Reset();

        exit(TempSaleLinePOS.FindFirst());
    end;

    local procedure SetupSalesItem(SaleLinePOS: Record "NPR POS Sale Line"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        Item: Record Item;
    begin
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit;
        if not Item.Get(SaleLinePOS."No.") then
            exit;
        if Item.IsNonInventoriableType() then
            exit;
        if Item."NPR Group sale" then
            exit;
        if not Item.PreventNegativeInventory() then
            exit;

        TempSaleLinePOS.SetRange("No.", SaleLinePOS."No.");
        TempSaleLinePOS.SetRange("Variant Code", SaleLinePOS."Variant Code");
        TempSaleLinePOS.SetRange("Location Code", SaleLinePOS."Location Code");
        TempSaleLinePOS.SetRange("Serial No.", SaleLinePOS."Serial No.");
        TempSaleLinePOS.SetRange("Bin Code", SaleLinePOS."Bin Code");
        if TempSaleLinePOS.FindFirst() then begin
            TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
            TempSaleLinePOS."Quantity (Base)" += SaleLinePOS."Quantity (Base)";
            TempSaleLinePOS.Modify();
        end else begin
            TempSaleLinePOS.Init();
            TempSaleLinePOS := SaleLinePOS;
            TempSaleLinePOS.Insert();
        end;
    end;

    local procedure SpecificItemTrackingExist(Item: Record Item): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if Item."Item Tracking Code" = '' then
            exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);
        if ItemTrackingCode."SN Specific Tracking" then
            exit(true);
        if ItemTrackingCode."Lot Specific Tracking" then
            exit(true);
        exit(false);
    end;

    local procedure CheckBinContent(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Decimal
    var
        BinContent: Record "Bin Content";
    begin
        if not BinContent.Get(TempSaleLinePOS."Location Code", TempSaleLinePOS."Bin Code", TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code", TempSaleLinePOS."Unit of Measure Code") then
            exit;
        BinContent.SetRange("Serial No. Filter", TempSaleLinePOS."Serial No.");
        BinContent.CalcFields(Quantity);
        exit(BinContent.Quantity);
    end;

    local procedure LogErrorMessage(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var ErrorMessage: Record "Error Message")
    var
        Msg: Text;
        AvailableInventoryDescLbl: Label 'The available inventory for item %1 - %2 is lower than the entered quantity at this location.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description';
        AvailableInventoryDesc2Lbl: Label 'The available inventory for item %1 - %2 %3 is lower than the entered quantity at this location.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description,%3=SaleLinePOS."Description 2"';
        AvailableInventoryBinDescLbl: Label 'The available inventory for item %1 - %2 is lower than the entered quantity in this Bin.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description';
        AvailableInventoryBinDesc2Lbl: Label 'The available inventory for item %1 - %2 %3 is lower than the entered quantity in this Bin.', Comment = '%1=SaleLinePOS."No.",%2=SaleLinePOS.Description,%3=SaleLinePOS."Description 2"';
    begin
        Clear(Msg);
        if TempSaleLinePOS."Bin Code" = '' then begin
            if TempSaleLinePOS."Description 2" <> '' then
                Msg := StrSubstNo(AvailableInventoryDesc2Lbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description, TempSaleLinePOS."Description 2")
            else
                Msg := StrSubstNo(AvailableInventoryDescLbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description);
        end else begin
            if TempSaleLinePOS."Description 2" <> '' then
                Msg := StrSubstNo(AvailableInventoryBinDesc2Lbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description, TempSaleLinePOS."Description 2")
            else
                Msg := StrSubstNo(AvailableInventoryBinDescLbl, TempSaleLinePOS."No.", TempSaleLinePOS.Description);
        end;

        ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, Msg);
    end;

    local procedure TestItemInventory(var Rec: Record "NPR POS Sale")
    var
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempErrorMessage: Record "Error Message" temporary;
    begin
        if not SetupSalesItems(Rec, TempSaleLinePOS) then
            exit;
        FindNotInStockLines(TempSaleLinePOS, TempErrorMessage);

        if TempErrorMessage.HasErrors(false) then
            TempErrorMessage.ShowErrorMessages(true);
    end;

    local procedure CheckSetup(var Rec: Record "NPR POS Sale"): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetLoadFields("POS Audit Profile");
        POSUnit.Get(Rec."Register No.");
        POSUnit.TestField("POS Audit Profile");

        POSAuditProfile.SetLoadFields("Test Item Inventory");
        POSAuditProfile.Get(POSUnit."POS Audit Profile");

        exit(POSAuditProfile."Test Item Inventory");
    end;
}