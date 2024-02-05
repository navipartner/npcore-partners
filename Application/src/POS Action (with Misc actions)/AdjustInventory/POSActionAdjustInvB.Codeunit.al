codeunit 6059836 "NPR POS Action: Adjust Inv. B"
{
    Access = Internal;

    procedure PerformAdjustInventory(POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; Quantity: Decimal; UnitOfMeasureCode: Code[10]; ReturnReasonCode: Code[10]; CustomDescription: text[100])
    var
        TempItemJnlLine: Record "Item Journal Line" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Text005: Label 'Adjust Quantity %1 performed';

    begin
        POSSale.GetCurrentSale(SalePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not ConfirmAdjustInventory(SaleLinePOS, UnitOfMeasureCode, Quantity) then
            exit;

        CreateItemJnlLine(SalePOS, SaleLinePOS, Quantity, UnitOfMeasureCode, ReturnReasonCode, TempItemJnlLine, CustomDescription);
        PostItemJnlLine(TempItemJnlLine);

        Message(Text005, Quantity);
    end;

    local procedure ConfirmAdjustInventory(SaleLinePOS: Record "NPR POS Sale Line"; UnitOfMeasureCode: Code[10]; Quantity: Decimal) PerformAdjustInventory: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Text002: Label 'Inventory Adjustment:\- Item: %1 %2 %3\- Current Inventory: %4\- Adjust Unit of Measure: %5\- Adjust Quantity: %6\- New Inventory: %7\\Perform Inventory Adjustment?';
    begin
        if SaleLinePOS."Variant Code" <> '' then
            ItemVariant.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code");

        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter", SaleLinePOS."Variant Code");
        Item.SetFilter("Location Filter", SaleLinePOS."Location Code");
        Item.CalcFields(Inventory);

        PerformAdjustInventory := Confirm(Text002, true, Item."No.", Item.Description, ItemVariant.Description, Item.Inventory, UnitOfMeasureCode, Quantity, Item.Inventory + Quantity);
        exit(PerformAdjustInventory);
    end;

    local procedure CreateItemJnlLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; Quantity: Decimal; UnitOfMeasureCode: Code[10]; ReturnReasonCode: Code[10]; var TempItemJnlLine: Record "Item Journal Line" temporary; CustomDescription: Text[100])
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TempItemJnlLine.Init();
        TempItemJnlLine.Validate("Item No.", SaleLinePOS."No.");
        TempItemJnlLine.Validate("Posting Date", Today);

        POSUnit.Get(SalePOS."Register No.");
        POSUnit.TestField("POS Audit Profile");
        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile.TestField("Sales Ticket No. Series");
        TempItemJnlLine."Document No." := NoSeriesMgt.GetNextNo(POSAuditProfile."Sales Ticket No. Series", Today(), true);

        TempItemJnlLine."NPR Register Number" := SaleLinePOS."Register No.";

        TempItemJnlLine."NPR Document Time" := Time;
        if SaleLinePOS."Variant Code" <> '' then
            TempItemJnlLine.Validate("Variant Code", SaleLinePOS."Variant Code");
        TempItemJnlLine.Validate("Entry Type", TempItemJnlLine."Entry Type"::"Positive Adjmt.");
        if Quantity < 0 then
            TempItemJnlLine.Validate("Entry Type", TempItemJnlLine."Entry Type"::"Negative Adjmt.");
        TempItemJnlLine.Validate("Unit of Measure Code", UnitOfMeasureCode);
        TempItemJnlLine.Validate(Quantity, Abs(Quantity));
        if ReturnReasonCode <> '' then
            TempItemJnlLine.Validate("Return Reason Code", ReturnReasonCode);
        TempItemJnlLine.Validate("Location Code", SaleLinePOS."Location Code");
        TempItemJnlLine.Validate("Shortcut Dimension 1 Code", SaleLinePOS."Shortcut Dimension 1 Code");
        TempItemJnlLine.Validate("Shortcut Dimension 2 Code", SaleLinePOS."Shortcut Dimension 2 Code");
        TempItemJnlLine.Validate("Salespers./Purch. Code", SalePOS."Salesperson Code");
        if CustomDescription <> '' then
            TempItemJnlLine.Description := CopyStr(CustomDescription, 1, MaxStrLen(TempItemJnlLine.Description));
        TempItemJnlLine.Insert();
    end;

    local procedure PostItemJnlLine(var TempItemJnlLine: Record "Item Journal Line" temporary)
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlPostLine.Run(TempItemJnlLine);
    end;
}