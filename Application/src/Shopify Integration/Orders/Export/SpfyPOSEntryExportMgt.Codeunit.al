#if not (BC17 or BC18 or BC19 or BC20)
codeunit 6248585 "NPR Spfy POS Entry Export Mgt."
{
    Access = Internal;
    TableNo = "NPR POS Entry";

    var
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;

    trigger OnRun()
    begin
        ProcessOutstandingPOSEntries(Rec, TempSpfyExportPointerBuffer);
    end;

    internal procedure ProcessOutstandingPOSEntries(var POSEntry: Record "NPR POS Entry"; var SpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer")
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        IncludeReturns: Boolean;
    begin
        if SpfyExportPointerBuffer.IsEmpty() then
            exit;
        IncludeReturns := ReturnsAreSupported();

        SpfyStoreCustomerLink.SetCurrentKey("Sync. to this Store");
        SpfyStoreCustomerLink.SetRange("Sync. to this Store", true);
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetFilter("Shopify Store Code", SpfyExportPointerBuffer.GetSpfyStoreFilter());

        if POSEntry.FindSet() then
            repeat
                SpfyStoreCustomerLink.SetRange("No.", POSEntry."Customer No.");
                ProcessPOSEntry(POSEntry, SpfyStoreCustomerLink, SpfyExportPointerBuffer, IncludeReturns);
            until POSEntry.Next() = 0;
    end;

    internal procedure ProcessPOSEntry(POSEntry: Record "NPR POS Entry"; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; var SpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer") TaskCreated: Boolean
    begin
        exit(ProcessPOSEntry(POSEntry, SpfyStoreCustomerLink, SpfyExportPointerBuffer, ReturnsAreSupported()));
    end;

    // The scheduler passes every POS entry of the row-version window through here, so the line queries come last.
    internal procedure ProcessPOSEntry(POSEntry: Record "NPR POS Entry"; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; var SpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer"; IncludeReturns: Boolean) TaskCreated: Boolean
    var
        TempSpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link" temporary;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        HasSaleLines: Boolean;
    begin
        if not HeaderIsEligibleForSync(POSEntry) then
            exit;
        if not SpfyStoreCustomerLink.FindSet() then
            exit;
        if not LinesAreEligibleForSync(POSEntry, IncludeReturns, HasSaleLines) then
            exit;

        repeat
            if SpfyExportPointerBuffer.Get(SpfyStoreCustomerLink."Shopify Store Code") then begin
                if ((SpfyExportPointerBuffer."Cut-Off Date" = 0D) or (POSEntry."Entry Date" >= SpfyExportPointerBuffer."Cut-Off Date")) and
                   (POSEntry.SystemRowVersion > SpfyExportPointerBuffer."Cut-Off POS Entry Row Version")
                then begin
                    TempSpfyStorePOSEntryLink."POS Entry No." := POSEntry."Entry No.";
                    TempSpfyStorePOSEntryLink."Shopify Store Code" := SpfyStoreCustomerLink."Shopify Store Code";
                    if SpfyAssignedIDMgt.GetAssignedShopifyID(TempSpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") = '' then  //not yet sent to Shopify
                        if not ReturnOnlyEntryAlreadyQueued(POSEntry, HasSaleLines, SpfyStoreCustomerLink."Shopify Store Code") then
                            TaskCreated := SchedulePOSEntrySync(POSEntry, SpfyStoreCustomerLink."Shopify Store Code") or TaskCreated;
                end;

                if POSEntry.SystemRowVersion > SpfyExportPointerBuffer."New Last POS Entry Row Version" then begin
                    SpfyExportPointerBuffer."New Last POS Entry Row Version" := POSEntry.SystemRowVersion;
                    SpfyExportPointerBuffer.Modify();
                end;
            end;
        until SpfyStoreCustomerLink.Next() = 0;
    end;

    // A return-only entry never gets a Shopify order of its own, so its task, in any state and while the task is kept, is what marks it as handled; Send Again or Requeue reruns it.
    local procedure ReturnOnlyEntryAlreadyQueued(POSEntry: Record "NPR POS Entry"; HasSaleLines: Boolean; ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if HasSaleLines then
            exit(false);
        SpfyTask.SetRange("Table No.", Database::"NPR POS Entry");
        SpfyTask.SetRange("Store Code", ShopifyStoreCode);
        SpfyTask.SetRange("Record Value", Format(POSEntry."Entry No."));
        exit(not SpfyTask.IsEmpty());
    end;

    local procedure SchedulePOSEntrySync(POSEntry: Record "NPR POS Entry"; ShopifyStoreCode: Code[20]) TaskCreated: Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        clear(NcTask);
        NcTask.Type := NcTask.Type::Insert;

        RecRef.GetTable(POSEntry);
        TaskCreated := SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, Format(POSEntry."Entry No."), NcTask.Type, NcTask);
        if TaskCreated then
            Commit();
    end;

    internal procedure IsEligibleForSync(POSEntry: Record "NPR POS Entry"): Boolean
    begin
        exit(IsEligibleForSync(POSEntry, false));
    end;

    internal procedure IsEligibleForSync(POSEntry: Record "NPR POS Entry"; IncludeReturns: Boolean): Boolean
    var
        HasSaleLines: Boolean;
    begin
        if not HeaderIsEligibleForSync(POSEntry) then
            exit(false);
        exit(LinesAreEligibleForSync(POSEntry, IncludeReturns, HasSaleLines));
    end;

    local procedure HeaderIsEligibleForSync(POSEntry: Record "NPR POS Entry"): Boolean
    begin
        if POSEntry."System Entry" or (POSEntry."Customer No." = '') then
            exit(false);
        exit(POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale"]);
    end;

    // HasSaleLines tells whether the entry gets a Shopify order of its own; without returns every eligible entry does.
    local procedure LinesAreEligibleForSync(POSEntry: Record "NPR POS Entry"; IncludeReturns: Boolean; var HasSaleLines: Boolean): Boolean
    var
        ReturnResolver: Codeunit "NPR Spfy POS Return Resolver";
    begin
        if not IncludeReturns then begin
            HasSaleLines := true;
            exit(POSEntry."Amount Excl. Tax" > 0);  // the rule the frozen Nc Task sender was built against
        end;
        HasSaleLines := ReturnResolver.HasSaleLines(POSEntry);
        if HasSaleLines then
            exit(true);
        exit(ReturnResolver.HasReturnLines(POSEntry));
    end;

    // Returns ride on the Task List queue only; the frozen Nc Task sender never receives them.
    internal procedure ReturnsAreSupported(): Boolean
    var
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
    begin
        exit(SpfyTaskListFeature.IsFeatureEnabled());
    end;

    /// <summary>
    /// The Shopify line item title. Shopify rejects an order whose line item has a blank title, so a line without a
    /// description falls back to the item variant, then the item, and last to the line type and number.
    /// </summary>
    internal procedure GetLineItemTitle(POSEntrySalesLine: Record "NPR POS Entry Sales Line") Title: Text
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        Title := JoinDescriptions(POSEntrySalesLine.Description, POSEntrySalesLine."Description 2");
        if Title <> '' then
            exit;
        if POSEntrySalesLine.Type = POSEntrySalesLine.Type::Item then begin
            if POSEntrySalesLine."Variant Code" <> '' then
                if ItemVariant.Get(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code") then
                    Title := JoinDescriptions(ItemVariant.Description, ItemVariant."Description 2");
            if Title = '' then
                if Item.Get(POSEntrySalesLine."No.") then
                    Title := JoinDescriptions(Item.Description, Item."Description 2");
        end;
        if Title = '' then
            Title := JoinDescriptions(Format(POSEntrySalesLine.Type), POSEntrySalesLine."No.");
    end;

    /// <summary>
    /// The Shopify line items a POS entry sales line is sent as. Shopify has no line discount input and takes whole-number quantities,
    /// so the unit price is the line amount after discount divided by the quantity, on the VAT basis given by TaxesIncluded.
    /// When that does not divide evenly at the amount rounding precision, the units are split into two line items one rounding step
    /// apart, so the line items still add up to the line amount exactly. The line's tax is shared out in proportion to the units.
    /// </summary>
    internal procedure GetLineItemSplit(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; TaxesIncluded: Boolean; var Quantities: List of [Integer]; var UnitPrices: List of [Decimal]; var TaxAmounts: List of [Decimal])
    var
        GLSetup: Record "General Ledger Setup";
        LineAmount: Decimal;
        TaxAmount: Decimal;
        UnitPrice: Decimal;
        TaxAmountAtUnitPrice: Decimal;
        RoundingPrecision: Decimal;
        Units: Integer;
        UnitsAtHigherPrice: Integer;
    begin
        Clear(Quantities);
        Clear(UnitPrices);
        Clear(TaxAmounts);

        TaxAmount := POSEntrySalesLine."Amount Incl. VAT" - POSEntrySalesLine."Amount Excl. VAT";
        if TaxesIncluded then
            LineAmount := POSEntrySalesLine."Amount Incl. VAT"
        else
            LineAmount := POSEntrySalesLine."Amount Excl. VAT";
        Units := Round(POSEntrySalesLine.Quantity, 1, '>');
        if Units <= 1 then begin
            Quantities.Add(1);
            UnitPrices.Add(LineAmount);
            TaxAmounts.Add(TaxAmount);
            exit;
        end;

        if GLSetup.Get() then
            RoundingPrecision := GLSetup."Amount Rounding Precision";
        if RoundingPrecision <= 0 then
            RoundingPrecision := 0.01;
        UnitPrice := Round(LineAmount / Units, RoundingPrecision, '<');
        // Round '<' rounds toward zero, so for a negative amount the remainder is negative too.
        UnitsAtHigherPrice := Round(Abs(LineAmount - UnitPrice * Units) / RoundingPrecision, 1);
        if UnitsAtHigherPrice >= Units then
            UnitsAtHigherPrice := Units - 1;
        if UnitsAtHigherPrice <= 0 then begin
            Quantities.Add(Units);
            UnitPrices.Add(UnitPrice);
            TaxAmounts.Add(TaxAmount);
            exit;
        end;

        TaxAmountAtUnitPrice := Round(TaxAmount * (Units - UnitsAtHigherPrice) / Units, RoundingPrecision);
        Quantities.Add(Units - UnitsAtHigherPrice);
        UnitPrices.Add(UnitPrice);
        TaxAmounts.Add(TaxAmountAtUnitPrice);
        Quantities.Add(UnitsAtHigherPrice);
        UnitPrices.Add((LineAmount - UnitPrice * (Units - UnitsAtHigherPrice)) / UnitsAtHigherPrice);
        TaxAmounts.Add(TaxAmount - TaxAmountAtUnitPrice);
    end;

    local procedure JoinDescriptions(Description: Text; Description2: Text): Text
    begin
        if Description2 = '' then
            exit(Description);
        if Description = '' then
            exit(Description2);
        exit(Description + ' ' + Description2);
    end;

    internal procedure SetExportPointerBuffer(var SpfyExportPointerBufferIn: Record "NPR Spfy Export Pointer Buffer")
    begin
        TempSpfyExportPointerBuffer.Copy(SpfyExportPointerBufferIn, true);
    end;

    internal procedure GetExportPointerBuffer(var SpfyExportPointerBufferOut: Record "NPR Spfy Export Pointer Buffer")
    begin
        SpfyExportPointerBufferOut.Copy(TempSpfyExportPointerBuffer, true);
    end;
}
#endif