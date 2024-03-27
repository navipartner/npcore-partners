codeunit 6151032 "NPR POS Tracking Utils"
{
    Access = Internal;


    local procedure SerialNumberCanBeUsedByItem(ItemNo: Code[20]; var VariantCode: Code[10]; SerialNumber: Code[50]; var UserInformationErrorWarning: Text; SerialSelectionFromList: Boolean) CanBeUsed: Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        WrongSerialOnILELbl: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received.', Comment = '%1 = Serial Number, %2 = Item No., %3 = Item Description';
        WrongSerialOnSLPLbl: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6.', Comment = '%1 = Serial Number, %2 = Item No., %3 = Item Description, %4 = Sale, %5 = sales Ticket No, %6 = Register No.';
        ActiveLbl: Label 'active';
        WrongSerial_InstrLbl: Label ' \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\';
    begin
        Item.SetLoadFields(Description, "Item Tracking Code");
        if not Item.Get(ItemNo) then
            exit;

        if Item."Item Tracking Code" = '' then
            exit;

        ItemTrackingCode.SetLoadFields("SN Specific Tracking");
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;

        CanBeUsed := not ItemTrackingCode."SN Specific Tracking";
        if CanBeUsed then
            exit;

        UserInformationErrorWarning := '';


        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Lot No.", "Serial No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Serial No.", SerialNumber);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetFilter("Variant Code", VariantCode);

        ItemLedgerEntry.SetLoadFields("Variant Code");
        CanBeUsed := ItemLedgerEntry.FindSet(false);
        if not CanBeUsed then begin

            UserInformationErrorWarning := StrSubstNo(WrongSerialOnILELbl, SerialNumber, Item."No.", Item.Description);

            if SerialSelectionFromList then
                UserInformationErrorWarning += WrongSerial_InstrLbl;

            exit;
        end;

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Serial No.");
        SaleLinePOS.SetLoadFields("Line Type", "No.", "Serial No.", "Variant Code");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("No.", ItemNo);
        SaleLinePOS.SetRange("Serial No.", SerialNumber);
        repeat
            SaleLinePOS.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
            CanBeUsed := SaleLinePOS.IsEmpty();
            if CanBeUsed then
                VariantCode := ItemLedgerEntry."Variant Code";
        until (ItemLedgerEntry.Next() = 0) or CanBeUsed;

        if CanBeUsed then
            exit;

        SaleLinePOS.FindFirst();
        SalePOS.SetLoadFields("Register No.", "Sales Ticket No.");
        SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");

        UserInformationErrorWarning := StrSubstNo(WrongSerialOnSLPLbl, SerialNumber, Item."No.", Item.Description, ActiveLbl, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.");

        if SerialSelectionFromList then
            UserInformationErrorWarning += WrongSerial_InstrLbl;

    end;

    local procedure SelectSerialNoFromList(ItemNo: Code[20]; var VariantCode: Code[10]; LocationCode: Code[10]; var SerialNo: Text[50])
    var
        RequiresSerialNo: Boolean;
        RequiresSpecificSerialNo: Boolean;
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        ItemRequiresSerialNumber(ItemNo, RequiresSerialNo, RequiresSpecificSerialNo);
        if not RequiresSerialNo then
            exit;

        SaleLinePOS.Init();
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := ItemNo;
        SaleLinePOS."Variant Code" := VariantCode;
        SaleLinePOS."Location Code" := LocationCode;
        SaleLinePOS.Quantity := 1;
        if not SaleLinePOS.SerialNoLookup2() then
            exit;

        SerialNo := SaleLinePOS."Serial No.";
        VariantCode := SaleLinePOS."Variant Code";
    end;

    #region ValidateSerialNo
    internal procedure ValidateSerialNo(ItemNo: Code[20]; var VariantCode: Code[10]; var SerialNumberInput: Text[50]; SerialSelectionFromList: Boolean; POSStore: Record "NPR POS Store")
    var
        AskForSerialNoContinuously: Boolean;
        RequiresSerialNo: Boolean;
        RequiresSpecificSerialNo: Boolean;
        UserInformationErrorWarning: Text;
    begin
        ItemRequiresSerialNumber(ItemNo, RequiresSerialNo, RequiresSpecificSerialNo);
        if not RequiresSerialNo then
            exit;

        if SerialSelectionFromList and RequiresSpecificSerialNo then
            SerialNumberInput := '';

        AskForSerialNoContinuously := true;
        while (not SerialNumberCanBeUsedByItem(ItemNo, VariantCode, SerialNumberInput, UserInformationErrorWarning, SerialSelectionFromList)) and AskForSerialNoContinuously do begin

            AskForSerialNoContinuously := SerialSelectionFromList;
            if SerialSelectionFromList then begin

                if SerialNumberInput <> '' then
                    Message(UserInformationErrorWarning);

                SerialNumberInput := '';

                SelectSerialNoFromList(ItemNo, VariantCode, POSStore."Location Code", SerialNumberInput);

                if SerialNumberInput = '' then
                    Error('');

            end else
                if (SerialNumberInput <> '') and (UserInformationErrorWarning <> '') then
                    Error(UserInformationErrorWarning);

        end;
    end;
    #endregion ValidateSerialNo

    procedure LotCanBeUsedByItem(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; var UserInformationErrorWarning: Text) CanBeUsed: Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        WrongLotNoOnILELbl: Label 'Lot No. %1 for item %2 - %3 can not be used since it can not be found as received.', Comment = '%1 = Lot No., %2 = Item No., %3 = Item Description';
        WrongLotNoOnSLPLbl: Label 'Lot No. %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6.', Comment = '%1 = Lot No., %2 = Item No., %3 = Item Description, %4 = Sale, %5 = sales Ticket No, %6 = Register No.';
        ActiveLbl: Label 'active';
    begin
        Item.SetLoadFields(Description, "Item Tracking Code");
        if not Item.Get(ItemNo) then
            exit;

        if Item."Item Tracking Code" = '' then
            exit;

        ItemTrackingCode.SetLoadFields("Lot Specific Tracking");
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;

        CanBeUsed := not ItemTrackingCode."Lot Specific Tracking";
        if CanBeUsed then
            exit;

        UserInformationErrorWarning := '';


        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Lot No.", "Serial No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Lot No.", LotNo);
        ItemLedgerEntry.SetFilter("Variant Code", VariantCode);
        ItemLedgerEntry.SetLoadFields("Variant Code", "Remaining Quantity");

        CanBeUsed := ItemLedgerEntry.FindSet(false);
        if not CanBeUsed then begin
            UserInformationErrorWarning := StrSubstNo(WrongLotNoOnILELbl, LotNo, Item."No.", Item.Description);
            exit;
        end;

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Lot No.");
        SaleLinePOS.SetLoadFields("Line Type", "No.", "Lot No.", "Variant Code", Quantity);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("No.", ItemNo);
        SaleLinePOS.SetRange("Lot No.", LotNo);
        repeat
            SaleLinePOS.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
            CanBeUsed := SaleLinePOS.IsEmpty();
            if not CanBeUsed then begin
                SaleLinePOS.FindSet(false);
                ItemLedgerEntry.CalcSums("Remaining Quantity");
                SaleLinePOS.CalcSums(Quantity);
                CanBeUsed := ItemLedgerEntry."Remaining Quantity" > SaleLinePOS.Quantity;
            end;
        until (ItemLedgerEntry.Next() = 0) or CanBeUsed;

        if CanBeUsed then
            exit;

        SaleLinePOS.FindFirst();
        SalePOS.SetLoadFields("Register No.", "Sales Ticket No.");
        SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");

        UserInformationErrorWarning := StrSubstNo(WrongLotNoOnSLPLbl, LotNo, Item."No.", Item.Description, ActiveLbl, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.");

    end;

    procedure ItemRequiresLotNoSerialNo(var Item: Record Item; var UseSpecificSerialNoTracking: Boolean; var UseSpecificLotNoTracking: Boolean; var RequiresSerialNo: Boolean; var RequiresLotNo: Boolean)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if Item."Item Tracking Code" = '' then
            exit;

        ItemTrackingCode.SetLoadFields("Lot Specific Tracking", "SN Specific Tracking", "SN Sales Outbound Tracking", "Lot Specific Tracking", "Lot Sales Outbound Tracking");
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;

        UseSpecificSerialNoTracking := ItemTrackingCode."SN Specific Tracking";

        RequiresSerialNo := ItemTrackingCode."SN Sales Outbound Tracking";

        UseSpecificLotNoTracking := ItemTrackingCode."Lot Specific Tracking";

        RequiresLotNo := ItemTrackingCode."Lot Sales Outbound Tracking";
    end;

    #region ValidateLotNo
    internal procedure ValidateLotNo(ItemNo: Code[20]; VariantCode: Code[10]; LotInput: Text[50]; POSStore: Record "NPR POS Store")
    var
        RequiresLotNo: Boolean;
        RequiresSpecificLotNo: Boolean;
        UserInformationErrorWarning: Text;
    begin
        ItemRequiresLotNo(ItemNo, RequiresLotNo, RequiresSpecificLotNo);
        if not RequiresLotNo then
            exit;

        RequiresSpecificLotNo := true;
        if (not LotCanBeUsedByItem(ItemNo, VariantCode, LotInput, UserInformationErrorWarning)) then
            if (LotInput <> '') and (UserInformationErrorWarning <> '') then
                Error(UserInformationErrorWarning);

    end;
    #endregion ValidateLotNo

    internal procedure ItemRequiresSerialNumber(var Item: Record Item; var UseSpecificTracking: Boolean) RequiresSerialNo: Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin

        if Item."Item Tracking Code" = '' then
            exit;

        ItemTrackingCode.SetLoadFields("Lot Specific Tracking", "SN Specific Tracking", "SN Sales Outbound Tracking");
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;

        UseSpecificTracking := ItemTrackingCode."SN Specific Tracking";

        RequiresSerialNo := ItemTrackingCode."SN Sales Outbound Tracking";
    end;

    internal procedure ItemRequiresSerialNumber(ItemNo: Code[20]; var RequiresSerialNo: Boolean; var UseSpecificSerialNo: Boolean)
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("No.", "Item Tracking Code");
        if not Item.Get(ItemNo) then
            exit;

        RequiresSerialNo := ItemRequiresSerialNumber(Item, UseSpecificSerialNo);
    end;

    internal procedure ItemRequiresLotNo(var Item: Record Item; var UseSpecificTracking: Boolean) RequiresLotNo: Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin

        if Item."Item Tracking Code" = '' then
            exit;

        ItemTrackingCode.SetLoadFields("Lot Specific Tracking", "Lot Sales Outbound Tracking");
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;

        UseSpecificTracking := ItemTrackingCode."Lot Specific Tracking";

        RequiresLotNo := ItemTrackingCode."Lot Sales Outbound Tracking";
    end;

    internal procedure ItemRequiresLotNo(ItemNo: Code[20]; var RequiresLotNo: Boolean; var UseSpecificLotNo: Boolean)
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("No.", "Item Tracking Code");
        if not Item.Get(ItemNo) then
            exit;

        RequiresLotNo := ItemRequiresLotNo(Item, UseSpecificLotNo);
    end;

}