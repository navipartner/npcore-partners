codeunit 6151032 "NPR POS Tracking Utils"
{
    Access = Internal;


    local procedure SerialNumberCanBeUsedByItem(ItemNo: Code[20];
                                                var VariantCode: Code[10];
                                                SerialNumber: Code[50];
                                                var UserInformationErrorWarning: Text;
                                                SerialSelectionFromList: Boolean) CanBeUsed: Boolean
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
        if not Item.Get(ItemNo) then
            exit;

        if Item."Item Tracking Code" = '' then
            exit;

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
        ItemLedgerEntry.SetRange("Lot No.", '');
        ItemLedgerEntry.SetFilter("Variant Code", VariantCode);

        ItemLedgerEntry.SetLoadFields("Variant Code");
        CanBeUsed := ItemLedgerEntry.FindSet(false);
        if not CanBeUsed then begin

            UserInformationErrorWarning := StrSubstNo(WrongSerialOnILELbl,
                                                      SerialNumber,
                                                      Item."No.",
                                                      Item.Description);

            if SerialSelectionFromList then
                UserInformationErrorWarning += WrongSerial_InstrLbl;

            exit;
        end;

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Serial No.");
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
        SalePOS.Get(SaleLinePOS."Register No.",
                    SaleLinePOS."Sales Ticket No.");

        UserInformationErrorWarning := StrSubstNo(WrongSerialOnSLPLbl,
                                                  SerialNumber,
                                                  Item."No.",
                                                  Item.Description,
                                                  ActiveLbl,
                                                  SaleLinePOS."Sales Ticket No.",
                                                  SaleLinePOS."Register No.");

        if SerialSelectionFromList then
            UserInformationErrorWarning += WrongSerial_InstrLbl;

    end;

    local procedure SelectSerialNoFromList(ItemNo: Code[20];
                                           var VariantCode: Code[10];
                                           LocationCode: Code[10];
                                           var SerialNo: Text[50])
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        UseSpecificTracking: Boolean;
    begin
        if not Item.Get(ItemNo) then
            Clear(Item);

        if not ItemRequiresSerialNumber(Item, UseSpecificTracking) then
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
    internal procedure ValidateSerialNo(ItemNo: Code[20];
                                        var VariantCode: Code[10];
                                        var SerialNumberInput: Text[50];
                                        SerialSelectionFromList: Boolean;
                                        Setup: Codeunit "NPR POS Setup")
    var
        Item: Record Item;
        POSStore: Record "NPR POS Store";
        AskForSerialNoContinuously: Boolean;
        UseSpecTracking: Boolean;
        UserInformationErrorWarning: Text;
    begin
        Item.Get(ItemNo);

        if not ItemRequiresSerialNumber(Item,
                                        UseSpecTracking)
        then
            exit;

        if SerialSelectionFromList and
           UseSpecTracking
        then
            SerialNumberInput := '';

        AskForSerialNoContinuously := true;
        while (not SerialNumberCanBeUsedByItem(ItemNo,
                                               VariantCode,
                                               SerialNumberInput,
                                               UserInformationErrorWarning,
                                               SerialSelectionFromList)) and
            AskForSerialNoContinuously
        do begin


            AskForSerialNoContinuously := SerialSelectionFromList;
            if SerialSelectionFromList then begin

                if SerialNumberInput <> '' then
                    Message(UserInformationErrorWarning);

                SerialNumberInput := '';

                Setup.GetPOSStore(POSStore);

                SelectSerialNoFromList(ItemNo,
                                       VariantCode,
                                       POSStore."Location Code",
                                        SerialNumberInput);

                if SerialNumberInput = '' then
                    Error('');

            end else
                if (SerialNumberInput <> '') and
                   (UserInformationErrorWarning <> '')
                then
                    Error(UserInformationErrorWarning);

        end;
    end;
    #endregion ValidateSerialNo

    internal procedure ItemRequiresSerialNumber(Item: Record Item;
                                                var UseSpecificTracking: Boolean) RequiresSerialNo: Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin

        if Item."Item Tracking Code" = '' then
            exit;

        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;

        ItemTrackingCode.TestField("Lot Specific Tracking", false);

        UseSpecificTracking := ItemTrackingCode."SN Specific Tracking";

        RequiresSerialNo := ItemTrackingCode."SN Sales Outbound Tracking";
    end;
}