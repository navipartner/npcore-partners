codeunit 6150660 "NPR NPRE Waiter Pad POS Mgt."
{
    Access = Internal;

    var
        ERRNoPadForSeating: Label 'No active waiter pad exists for seating %1.';
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadUI: Page "NPR NPRE Waiter Pad";
        CFRM_Move_seating: Label 'Do you want to move waiter pad %1 %2 from seating %3 to %4?';
        ERRMergeToSelf: Label 'Waiter pad can not be merged into itself, choose another waiter pad.';
        TXTMerged: Label 'Waiter pad lines merged into waiter pad %1 - %2.';
        CFRM_Merge: Label 'Do you want to move lines from waiter pad %1 %2 into waiter pad %3 %4.';
        WPInAnotherSale: Label 'Waiter pad %1 (seating %2) is being processed in another sale at the moment. If you continue, you will get only lines, which were not copied to the other sale.\Are you sure you want to continue?';
        CannotParkWPSale: Label 'Waiter pad related transaction cannot be parked. Please finish your work with the sale by moving it to the waiter pad instead.';

    procedure SplitWaiterPadLine(var FromWaiterPad: Record "NPR NPRE Waiter Pad"; var FromWaiterPadLine: Record "NPR NPRE Waiter Pad Line"; MoveQty: Decimal; ToWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        NewWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestPrint: Codeunit "NPR NPRE Restaurant Print";
        FullLineTransfer: Boolean;
    begin
        if MoveQty > FromWaiterPadLine.Quantity then
            MoveQty := FromWaiterPadLine.Quantity;
        if MoveQty <= 0 then
            exit;

        FullLineTransfer := MoveQty = FromWaiterPadLine.Quantity;

        NewWaiterPadLine := FromWaiterPadLine;
        NewWaiterPadLine."Waiter Pad No." := ToWaiterPad."No.";
        NewWaiterPadLine."Line No." := 0;
        if not FullLineTransfer then begin
            NewWaiterPadLine.Validate(Quantity, MoveQty);

            NewWaiterPadLine."Billed Quantity" := FromWaiterPadLine."Billed Quantity" - FromWaiterPadLine.Quantity + MoveQty;
            if NewWaiterPadLine."Billed Quantity" < 0 then
                NewWaiterPadLine."Billed Quantity" := 0;
            if NewWaiterPadLine."Billed Quantity" > NewWaiterPadLine.Quantity then
                NewWaiterPadLine."Billed Quantity" := NewWaiterPadLine.Quantity;
            NewWaiterPadLine.Validate("Billed Quantity");

            NewWaiterPadLine."Amount Incl. VAT" := 0;
            NewWaiterPadLine."Amount Excl. VAT" := 0;
            NewWaiterPadLine."Discount Amount" := 0;
        end;
        NewWaiterPadLine.Insert(true);

        WaiterPadMgt.CopyAssignedPrintCategories(FromWaiterPadLine.RecordId, NewWaiterPadLine.RecordId);
        WaiterPadMgt.CopyAssignedFlowStatuses(FromWaiterPadLine.RecordId, NewWaiterPadLine.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        CopyPOSInfoWPad2WPad(FromWaiterPad, FromWaiterPadLine."Line No.", ToWaiterPad, NewWaiterPadLine."Line No.");

        RestPrint.SplitWaiterPadLinePrintLogEntries(FromWaiterPadLine, NewWaiterPadLine, FullLineTransfer);
        KitchenOrderMgt.SplitWaiterPadLineKitchenReqSourceLinks(FromWaiterPadLine, ToWaiterPad, NewWaiterPadLine, FullLineTransfer);

        FromWaiterPadLine.CalcFields("Sent to Kitchen");
        FromWaiterPadLine.Validate(Quantity, FromWaiterPadLine.Quantity - NewWaiterPadLine.Quantity);
        FromWaiterPadLine.Validate("Billed Quantity", FromWaiterPadLine."Billed Quantity" - NewWaiterPadLine."Billed Quantity");
        if not FromWaiterPadLine."Sent to Kitchen" and (FromWaiterPadLine.Quantity = 0) and (FromWaiterPadLine."Billed Quantity" = 0) then
            FromWaiterPadLine.Delete(true)
        else begin
            FromWaiterPadLine."Amount Incl. VAT" := 0;
            FromWaiterPadLine."Amount Excl. VAT" := 0;
            FromWaiterPadLine."Discount Amount" := 0;
            FromWaiterPadLine.Modify();
        end;
    end;

    procedure MoveSaleFromPOSToWaiterPad(var SalePOS: Record "NPR POS Sale"; WaiterPad: Record "NPR NPRE Waiter Pad"; CleanupSale: Boolean) SaleCleanupSuccessful: Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        TempTouchedWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary;
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinesExist: Boolean;
    begin
        FilterSupportedSaleLines(SalePOS, SaleLinePOS);
        SaleLinesExist := not SaleLinePOS.IsEmpty();

        if SaleLinesExist then begin
            TempTouchedWaiterPadLine.DeleteAll();
            UpdateWPHdrFromSaleHdr(SalePOS, WaiterPad);
            SaleLinePOS.FindSet(CleanupSale);
            CopySaleHdrPOSInfo(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", WaiterPad."No.", true);
            repeat
                MoveSaleLineFromPOSToWaiterPad(SalePOS, SaleLinePOS, WaiterPad, WaiterPadLine);
                TempTouchedWaiterPadLine := WaiterPadLine;
                TempTouchedWaiterPadLine.Insert();
            until SaleLinePOS.Next() = 0;

            WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
            WaiterPadLine.SetRange("Sale Retail ID", SalePOS.SystemId);
            WaiterPadLine.SetAutoCalcFields("Kitchen Order Sent", "Serving Requested");
            if WaiterPadLine.FindSet() then
                repeat
                    TempTouchedWaiterPadLine := WaiterPadLine;
                    if not TempTouchedWaiterPadLine.Find() then
                        CleanupWaiterPadLine(WaiterPadLine, true);
                until WaiterPadLine.Next() = 0;
        end;

        if CleanupSale then
            if not UnsupportedSaleLinesExist(SalePOS) then begin
                if SaleLinesExist then begin
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.DeleteAll();
                end;
                ClearSaleHdrNPREPresetFields(SalePOS, true);
                RemoveSaleHdrPOSInfo(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                SaleCleanupSuccessful := true;
            end;
        if not SaleLinesExist then
            exit;

        WaiterPadLine.SetRange("Sale Retail ID");
        WaiterPadLine.MarkedOnly(true);
        if not WaiterPadLine.IsEmpty() then
            RestaurantPrint.SetWaiterPadPreReceiptPrinted(WaiterPad, false, true);
        OnAfterMoveSaleFromPosToWaiterPad(WaiterPad, WaiterPadLine);

        Commit();
        RestaurantPrint.LinesAddedToWaiterPad(WaiterPad);
    end;

    procedure CleanupWaiterPadOnSaleCancel(SalePOS: Record "NPR POS Sale"; WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        PrintTemplate: Record "NPR NPRE Print Templ.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("Sale Retail ID", SalePOS.SystemId);
        if WaiterPadLine.IsEmpty() then
            exit;
        WaiterPadLine.SetAutoCalcFields("Kitchen Order Sent", "Serving Requested");
        WaiterPadLine.FindSet(true);
        repeat
            CleanupWaiterPadLine(WaiterPadLine, false);
        until WaiterPadLine.Next() = 0;
        Commit();
        RestaurantPrint.PrintWaiterPadLinesToKitchen(WaiterPad, WaiterPadLine, PrintTemplate."Print Type"::"Kitchen Order", '', false, false);  //Includes commit
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Cancelled Sale");
    end;

    local procedure CleanupWaiterPadLine(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; MarkTouched: Boolean)
    begin
        if (WaiterPadLine."Kitchen Order Sent" or WaiterPadLine."Serving Requested" or (WaiterPadLine."Billed Quantity" <> 0)) and
           (WaiterPadLine."Line Type" = WaiterPadLine."Line Type"::Item)
        then begin
            if WaiterPadLine.Quantity > WaiterPadLine."Billed Quantity" then begin
                WaiterPadLine.Validate(Quantity, WaiterPadLine."Billed Quantity");
                WaiterPadLine.Modify();
                if MarkTouched then
                    WaiterPadLine.Mark := true;
            end;
        end else
            WaiterPadLine.Delete(true);
    end;

    procedure FilterSupportedSaleLines(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line Type", '%1|%2', SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::Comment);
    end;

    procedure UnsupportedSaleLinesExist(SalePOS: Record "NPR POS Sale"): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line Type", '<>%1&<>%2', SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::Comment);
        exit(not SaleLinePOS.IsEmpty());
    end;

    procedure UnableToCleanupSaleMsgText(ConfirmRemoval: Boolean): Text
    var
        Result: TextBuilder;
        ConfirmRemovalTxt: Label 'Those will be lost forever. Are you sure you want to continue?';
        ManualRemovalTxt: Label 'No lines have been removed from the POS sale to respect the warning. You will need to manually remove all unsupported lines and/or void payments from the sale first, or finish the sale.';
        MsgTxt1: Label 'All supported POS sale lines (lines of type "item" and "comment") have been successfully saved to selected waiter pad and processed according to restaurant module configuration.';
        MsgTxt2: Label 'However, other types of lines, like customer deposit, retail voucher or payment, cannot be saved to waiter pads.';
    begin
        Result.AppendLine(MsgTxt1);
        Result.AppendLine(MsgTxt2);
        if ConfirmRemoval then
            Result.AppendLine(ConfirmRemovalTxt)
        else
            Result.AppendLine(ManualRemovalTxt);
        exit(Result.ToText());
    end;

    local procedure UpdateWPHdrFromSaleHdr(SalePOS: Record "NPR POS Sale"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPad."Customer No." := SalePOS."Customer No.";
        WaiterPad.Modify();
    end;

    procedure MoveSaleLineFromPOSToWaiterPad(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        WaiterPadLine2: Record "NPR NPRE Waiter Pad Line";
        NewLine: Boolean;
    begin
        WaiterPadLine2.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine2.SetRange("Sale Line Retail ID", SaleLinePOS.SystemID);
        NewLine := not WaiterPadLine2.FindFirst() or IsNullGuid(SaleLinePOS.SystemID);
        if not NewLine then begin
            WaiterPadLine := WaiterPadLine2;
            WaiterPadLine.TestField(WaiterPadLine."Line Type", SaleLinePOS."Line Type");
            WaiterPadLine.TestField(WaiterPadLine."No.", SaleLinePOS."No.");
            WaiterPadLine.TestField(WaiterPadLine."Variant Code", SaleLinePOS."Variant Code");
            WaiterPadLine.TestField(WaiterPadLine."Unit of Measure Code", SaleLinePOS."Unit of Measure Code");
            WaiterPadLine.TestField(WaiterPadLine."Qty. per Unit of Measure", SaleLinePOS."Qty. per Unit of Measure");
        end else begin
            WaiterPadLine2.Init();

            WaiterPadLine.Init();
            WaiterPadLine."Waiter Pad No." := WaiterPad."No.";
            WaiterPadLine."Register No." := SaleLinePOS."Register No.";
            WaiterPadLine."Line Type" := SaleLinePOS."Line Type";
            WaiterPadLine."No." := SaleLinePOS."No.";
            WaiterPadLine."Variant Code" := SaleLinePOS."Variant Code";
            WaiterPadLine.Description := SaleLinePOS.Description;
            WaiterPadLine."Description 2" := SaleLinePOS."Description 2";
            WaiterPadLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
            WaiterPadLine."Qty. per Unit of Measure" := SaleLinePOS."Qty. per Unit of Measure";
            WaiterPadLine."Sale Retail ID" := SalePOS.SystemId;
            WaiterPadLine."Sale Line Retail ID" := SaleLinePOS.SystemId;
            WaiterPadLine.Insert(true);

            WaiterPadMgt.AssignWPadLinePrintCategories(WaiterPadLine, true);
        end;

        WaiterPadLine.Quantity := SaleLinePOS.Quantity;
        WaiterPadLine."Quantity (Base)" := SaleLinePOS."Quantity (Base)";
        WaiterPadLine."Unit Price" := SaleLinePOS."Unit Price";
        WaiterPadLine."Discount Type" := SaleLinePOS."Discount Type";
        WaiterPadLine."Discount Code" := SaleLinePOS."Discount Code";
        WaiterPadLine."Allow Line Discount" := SaleLinePOS."Allow Line Discount";
        WaiterPadLine."Discount %" := SaleLinePOS."Discount %";
        WaiterPadLine."Discount Amount" := SaleLinePOS."Discount Amount";
        WaiterPadLine."Amount Excl. VAT" := SaleLinePOS.Amount;
        WaiterPadLine."Amount Incl. VAT" := SaleLinePOS."Amount Including VAT";
        WaiterPadLine."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
        WaiterPadLine."VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
        WaiterPadLine."VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
        WaiterPadLine."Order No. from Web" := SaleLinePOS."Order No. from Web";
        WaiterPadLine."Order Line No. from Web" := SaleLinePOS."Order Line No. from Web";
        WaiterPadLine.Modify();

        WaiterPadLine.Mark := NewLine or (WaiterPadLine."Quantity (Base)" <> WaiterPadLine2."Quantity (Base)");

        CopyPOSInfo(SaleLinePOS, WaiterPadLine."Waiter Pad No.", WaiterPadLine."Line No.", true);
    end;

    procedure GetSaleFromWaiterPadToPOS(WaiterPad: Record "NPR NPRE Waiter Pad"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        WaiterPad.CalcFields("Current Seating FF");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("NPRE Pre-Set Waiter Pad No.", '');

        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Sale Retail ID", '<>%1&<>%2', GetNullGuid(), SalePOS.SystemId);
        if not WaiterPadLine.IsEmpty then
            if not Confirm(WPInAnotherSale, false, WaiterPad."No.", WaiterPad."Current Seating FF") then
                Error('');

        SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        SalePOS."NPRE Pre-Set Seating Code" := WaiterPad."Current Seating FF";
        SalePOS."NPRE Number of Guests" := WaiterPad."Number of Guests";
        SalePOS.Validate("Customer No.", WaiterPad."Customer No.");
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        POSSession.GetSaleLine(POSSaleLine);

        WaiterPadLine.SetRange("Sale Retail ID", GetNullGuid());
        if WaiterPadLine.FindSet(true) then
            repeat
                POSSaleLine.GetNewSaleLine(SaleLinePOS);
                GetSaleLineFromWaiterPadToPOS(SalePOS, SaleLinePOS, WaiterPad, WaiterPadLine, POSSaleLine);
            until (0 = WaiterPadLine.Next());

        CopySaleHdrPOSInfo(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", WaiterPad."No.", false);
    end;

    local procedure GetSaleLineFromWaiterPadToPOS(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; WaiterPad: Record "NPR NPRE Waiter Pad"; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; var POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
        SaleLinePOS.SetSkipUpdateDependantQuantity(true);

        SaleLinePOS."Line Type" := WaiterPadLine."Line Type";
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Comment then
            SaleLinePOS."No." := WaiterPadLine."No.";
        SaleLinePOS."Variant Code" := WaiterPadLine."Variant Code";

        SaleLinePOS.Description := WaiterPadLine.Description;
        SaleLinePOS."Description 2" := WaiterPadLine."Description 2";
        SaleLinePOS."Order No. from Web" := WaiterPadLine."Order No. from Web";
        SaleLinePOS."Order Line No. from Web" := WaiterPadLine."Order Line No. from Web";
        if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item then
            SaleLinePOS.Validate("Unit of Measure Code");

        SaleLinePOS.SetSkipUpdateDependantQuantity(false);

        SaleLinePOS.Validate(Quantity, WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity");
        SaleLinePOS."Unit Price" := WaiterPadLine."Unit Price";
        SaleLinePOS."Price Includes VAT" := WaiterPadLine."Price Includes VAT";
        SaleLinePOS."VAT Bus. Posting Group" := WaiterPadLine."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := WaiterPadLine."VAT Prod. Posting Group";

        SaleLinePOS."Discount Type" := WaiterPadLine."Discount Type";
        SaleLinePOS."Discount Code" := WaiterPadLine."Discount Code";

        SaleLinePOS."Allow Line Discount" := WaiterPadLine."Allow Line Discount";

        SaleLinePOS."Discount %" := WaiterPadLine."Discount %";

        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Comment then begin
            WaiterPad.CalcFields("Current Seating FF");
            SaleLinePOS."NPRE Seating Code" := WaiterPad."Current Seating FF";
        end;

        POSSaleLine.SetUseLinePriceVATParams(true);
        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.SetUseLinePriceVATParams(false);
        CopyPOSInfo(SaleLinePOS, WaiterPadLine."Waiter Pad No.", WaiterPadLine."Line No.", false);

        WaiterPadLine."Sale Retail ID" := SalePOS.SystemId;
        WaiterPadLine."Sale Line Retail ID" := SaleLinePOS.SystemId;
        WaiterPadLine.Modify();
    end;

    local procedure WaiterPadExistsForSeating(SeatingCode: Code[20]; OpenOnly: Boolean; ExcludeWaiterPadNo: Code[20]): Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
    begin
        Seating.Get(SeatingCode);

        SeatingWaiterPadLink.Reset();
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        if OpenOnly then begin
            SeatingWaiterPadLink.SetCurrentKey(Closed);
            SeatingWaiterPadLink.SetRange(Closed, false);
        end;
        if ExcludeWaiterPadNo <> '' then
            SeatingWaiterPadLink.SetFilter("Waiter Pad No.", '<>%1', ExcludeWaiterPadNo);

        exit(not SeatingWaiterPadLink.IsEmpty());
    end;

    local procedure GetWaiterPadForSeating(SeatingCode: Code[20]; OpenOnly: Boolean; ExcludeWaiterPadNo: Code[20]; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
    begin
        Seating.Get(SeatingCode);

        SeatingWaiterPadLink.Reset();
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        if OpenOnly then begin
            SeatingWaiterPadLink.SetCurrentKey(Closed);
            SeatingWaiterPadLink.SetRange(Closed, false);
        end;
        if ExcludeWaiterPadNo <> '' then
            SeatingWaiterPadLink.SetFilter("Waiter Pad No.", '<>%1', ExcludeWaiterPadNo);

        if SeatingWaiterPadLink.IsEmpty then
            WaiterPadMgt.AddNewWaiterPadForSeating(Seating.Code, WaiterPad, SeatingWaiterPadLink);

        if SeatingWaiterPadLink.Count() > 1 then begin
            SeatingWaiterPadLink.FindSet();
            WaiterPad.Reset();
            repeat
                WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.");
                WaiterPad.Mark(true);
            until SeatingWaiterPadLink.Next() = 0;
            WaiterPad.MarkedOnly(true);
        end else begin
            SeatingWaiterPadLink.FindFirst();
            WaiterPad.Reset();
            WaiterPad.SetRange("No.", SeatingWaiterPadLink."Waiter Pad No.");
            WaiterPad.FindFirst();
        end;
    end;

    local procedure UILookUpWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad") LookUpOK: Boolean
    var
        WaiterPadList: Page "NPR NPRE Waiter Pad List";
    begin
        WaiterPadList.SetTableView(WaiterPad);
        WaiterPadList.LookupMode := true;
        if WaiterPadList.RunModal() = ACTION::LookupOK then begin
            WaiterPadList.GetRecord(WaiterPad);
            WaiterPad.SetRange("No.", WaiterPad."No.");
            WaiterPad.FindFirst();
            LookUpOK := true;
        end else begin
            LookUpOK := false;
        end;

        exit(LookUpOK);
    end;

    procedure UIShowWaiterPad(WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPadUI.SetRecord(WaiterPad);
        WaiterPadUI.RunModal();
    end;

    procedure MoveWaiterPadToNewSeatingUI(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        CurrentSeating: Record "NPR NPRE Seating";
        NewSeating: Record "NPR NPRE Seating";
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        NewSeating.Get(SeatingManagement.UILookUpSeating('', ''));

        WaiterPad.CalcFields("Current Seating FF");
        WaiterPad.GetCurrentSeating(CurrentSeating);

        if not Confirm(StrSubstNo(CFRM_Move_seating, WaiterPad."No.", WaiterPad.Description, CurrentSeating.Description, NewSeating.Description), true) then
            exit;
        WaiterPadManagement.ChangeSeating(WaiterPad, WaiterPad."Current Seating FF", NewSeating.Code);
    end;

    procedure MergeWaiterPadUI(var WaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        MergeToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        if SelectWaiterPadToMergeTo(WaiterPad, MergeToWaiterPad) then
            if WaiterPadManagement.MergeWaiterPad(WaiterPad, MergeToWaiterPad) then begin
                WaiterPad.Get(MergeToWaiterPad."No.");
                Message(TXTMerged, MergeToWaiterPad."No.", MergeToWaiterPad.Description);
                exit(true);
            end;
        exit(false);

    end;

    procedure SelectWaiterPadToMergeTo(WaiterPad: Record "NPR NPRE Waiter Pad"; var MergeToWaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        Seating: Record "NPR NPRE Seating";
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        ChosenSeatingCode: Code[20];
    begin
        ChosenSeatingCode := SeatingManagement.UILookUpSeating('', '');
        if ChosenSeatingCode = '' then
            exit(false);
        Seating.Get(ChosenSeatingCode);

        if not WaiterPadExistsForSeating(Seating.Code, true, WaiterPad."No.") then
            Error(ERRNoPadForSeating, Seating.Description);

        GetWaiterPadForSeating(Seating.Code, true, WaiterPad."No.", MergeToWaiterPad);

        if MergeToWaiterPad.Count() = 0 then
            exit(false);
        if MergeToWaiterPad.Count() > 1 then begin
            if not UILookUpWaiterPad(MergeToWaiterPad) then
                exit(false);
        end;
        if WaiterPad."No." = MergeToWaiterPad."No." then
            Error(ERRMergeToSelf);

        if not Confirm(CFRM_Merge, true, WaiterPad."No.", WaiterPad.Description, MergeToWaiterPad."No.", MergeToWaiterPad.Description) then
            exit(false);

        exit(true);
    end;

    procedure FindSeating(JSON: Codeunit "NPR POS JSON Helper"; var NPRESeating: Record "NPR NPRE Seating")
    var
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        RestaurantCode: Code[20];
        SeatingCode: Code[20];
        OutText: text;
        LocationFilter: Text;
        SeatingFilter: Text;
    begin
        if JSON.GetString('restaurantCode', OutText) then
            RestaurantCode := CopyStr(OutText, 1, MaxStrLen(RestaurantCode));
        SeatingCode := GetSeatingCode(JSON, RestaurantCode);
        NPRESeating.Get(SeatingCode);

        SeatingFilter := JSON.GetStringParameter('SeatingFilter');
        LocationFilter := JSON.GetStringParameter('LocationFilter');
        if LocationFilter = '' then
            LocationFilter := SeatingManagement.RestaurantSeatingLocationFilter(RestaurantCode);
        if (SeatingFilter <> '') or (LocationFilter <> '') then begin
            NPRESeating.SetRecFilter();
            NPRESeating.FilterGroup(2);
            NPRESeating.SetFilter(Code, SeatingFilter);
            NPRESeating.SetFilter("Seating Location", LocationFilter);
            NPRESeating.FindFirst();
        end;
    end;

    local procedure GetSeatingCode(JSON: Codeunit "NPR POS JSON Helper"; RestaurantCode: Code[20]) SeatingCode: Code[20]
    var
        NPRESeating: Record "NPR NPRE Seating";
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        ShowOnlyActiveWaiPad: Boolean;
        OutText: text;
        SeatingFilter: Text;
        LocationFilter: Text;
    begin
        if JSON.GetString('seatingCode', OutText) then
            SeatingCode := CopyStr(OutText, 1, MaxStrLen(SeatingCode));
        if SeatingCode <> '' then
            exit(SeatingCode);

        if JSON.GetIntegerParameter('InputType') <> 2 then
            exit('');

        if JSON.GetBoolean('ShowOnlyActiveWaiPad', ShowOnlyActiveWaiPad) and ShowOnlyActiveWaiPad then begin
            NPRESeating.SetAutoCalcFields("Current Waiter Pad FF");
            NPRESeating.SetFilter("Current Waiter Pad FF", '<>%1', '');
            SeatingManagement.SetAddSeatingFilters(NPRESeating);
        end;
        SeatingFilter := JSON.GetStringParameter('SeatingFilter');
        LocationFilter := JSON.GetStringParameter('LocationFilter');
        if LocationFilter = '' then
            LocationFilter := SeatingManagement.RestaurantSeatingLocationFilter(RestaurantCode);
        SeatingCode := SeatingManagement.UILookUpSeating(SeatingFilter, LocationFilter);
        exit(SeatingCode);
    end;

    procedure SelectWaiterPad(NPRESeating: Record "NPR NPRE Seating"; var NPREWaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        TempNPREWaiterPad: Record "NPR NPRE Waiter Pad" temporary;
    begin
        NPRESeatingWaiterPadLink.SetCurrentKey(Closed);
        NPRESeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        NPRESeatingWaiterPadLink.SetRange(Closed, false);
        if NPRESeatingWaiterPadLink.IsEmpty then
            Error(ERRNoPadForSeating, NPRESeating.Code);

        NPRESeatingWaiterPadLink.FindSet();
        repeat
            if NPREWaiterPad.Get(NPRESeatingWaiterPadLink."Waiter Pad No.") and not NPREWaiterPad.Closed then begin
                TempNPREWaiterPad.Init();
                TempNPREWaiterPad := NPREWaiterPad;
                TempNPREWaiterPad.Insert();
            end;
        until NPRESeatingWaiterPadLink.Next() = 0;

        TempNPREWaiterPad.FindLast();
        NPREWaiterPad."No." := TempNPREWaiterPad."No.";

        TempNPREWaiterPad.FindFirst();
        if NPREWaiterPad."No." <> TempNPREWaiterPad."No." then begin
            if PAGE.RunModal(0, TempNPREWaiterPad) <> ACTION::LookupOK then begin
                Clear(NPREWaiterPad);
                exit(false);
            end;
        end;

        NPREWaiterPad.Get(TempNPREWaiterPad."No.");
        exit(true);
    end;

    local procedure CopyPOSInfo(SaleLinePOS: Record "NPR POS Sale Line"; WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; ToWaiterPad: Boolean)
    var
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", "Sales Line No.");
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        if ToWaiterPad then begin
            if POSInfoTransaction.FindSet() then
                repeat
                    POSInfoWaiterPadLink.Init();
                    POSInfoWaiterPadLink."Waiter Pad No." := WaiterPadNo;
                    POSInfoWaiterPadLink."Waiter Pad Line No." := WaiterPadLineNo;
                    POSInfoWaiterPadLink."POS Info Code" := POSInfoTransaction."POS Info Code";
                    if not POSInfoWaiterPadLink.Find() then
                        POSInfoWaiterPadLink.Insert();
                    POSInfoWaiterPadLink."POS Info" := POSInfoTransaction."POS Info";
                    POSInfoWaiterPadLink.Modify();
                until POSInfoTransaction.Next() = 0;

        end else begin
            if not POSInfoTransaction.IsEmpty then
                POSInfoTransaction.DeleteAll();

            POSInfoWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);
            POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
            if POSInfoWaiterPadLink.FindSet() then
                repeat
                    POSInfoTransaction.SetRange("POS Info Code", POSInfoWaiterPadLink."POS Info Code");
                    if POSInfoTransaction.FindFirst() then begin
                        POSInfoTransaction."POS Info" := POSInfoWaiterPadLink."POS Info";
                        POSInfoTransaction.Modify();
                    end else begin
                        POSInfoTransaction.Init();
                        POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
                        POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                        POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
                        POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
                        POSInfoTransaction."Line Type" := SaleLinePOS."Line Type";
                        POSInfoTransaction."Entry No." := 0;
                        POSInfoTransaction.Validate("POS Info Code", POSInfoWaiterPadLink."POS Info Code");
                        POSInfoTransaction."POS Info" := POSInfoWaiterPadLink."POS Info";
                        POSInfoTransaction.Insert(true);
                    end;
                until POSInfoWaiterPadLink.Next() = 0;
        end;
    end;

    local procedure CopySaleHdrPOSInfo(RegisterNo: Code[10]; SalesTicketNo: Code[20]; WaiterPadNo: Code[20]; ToWaiterPad: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS."Register No." := RegisterNo;
        SaleLinePOS."Sales Ticket No." := SalesTicketNo;
        SaleLinePOS."Line No." := 0;
        CopyPOSInfo(SaleLinePOS, WaiterPadNo, 0, ToWaiterPad);
    end;

    local procedure RemoveSaleHdrPOSInfo(RegisterNo: Code[10]; SalesTicketNo: Code[20])
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetRange("Sales Line No.", 0);
        if not POSInfoTransaction.IsEmpty() then
            POSInfoTransaction.DeleteAll();
    end;

    procedure CopyPOSInfoWPad2WPad(FromWaiterPad: Record "NPR NPRE Waiter Pad"; FromWaiterPadLineNo: Integer; ToWaiterPad: Record "NPR NPRE Waiter Pad"; ToWaiterPadLineNo: Integer)
    var
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
        POSInfoWaiterPadLink2: Record "NPR POS Info NPRE Waiter Pad";
    begin
        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", FromWaiterPad."No.");
        POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", FromWaiterPadLineNo);
        if POSInfoWaiterPadLink.FindSet() then
            repeat
                POSInfoWaiterPadLink2 := POSInfoWaiterPadLink;
                if not POSInfoWaiterPadLink2.Find() then
                    POSInfoWaiterPadLink2.Insert();
                POSInfoWaiterPadLink2."POS Info" := POSInfoWaiterPadLink."POS Info";
                POSInfoWaiterPadLink2.Modify();
            until POSInfoWaiterPadLink.Next() = 0;
    end;

    procedure ClearSaleHdrNPREPresetFields(var SalePOS: Record "NPR POS Sale"; ModifyRec: Boolean)
    begin
        SalePOS."NPRE Number of Guests" := 0;
        SalePOS."NPRE Pre-Set Seating Code" := '';
        SalePOS."NPRE Pre-Set Waiter Pad No." := '';

        if SalePOS."Customer No." <> '' then
            SalePOS.Validate("Customer No.", '');
        if ModifyRec then
            SalePOS.Modify();

        ClearWPLineSaleHdrLinks(SalePOS);
    end;

    procedure GetNullGuid(): Guid
    var
        NullGuid: Guid;
    begin
        Clear(NullGuid);
        exit(NullGuid);
    end;

    local procedure ClearWPLineSaleHdrLinks(SalePOS: Record "NPR POS Sale")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        if IsNullGuid(SalePOS.SystemId) then
            exit;
        WaiterPadLine.SetCurrentKey("Sale Retail ID");
        WaiterPadLine.SetRange("Sale Retail ID", SalePOS.SystemId);
        if not WaiterPadLine.IsEmpty() then
            WaiterPadLine.ModifyAll("Sale Retail ID", GetNullGuid());
    end;

    local procedure ClearWPLineSaleLineLinks(SaleLinePOS: Record "NPR POS Sale Line")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        if IsNullGuid(SaleLinePOS.SystemId) then
            exit;
        WaiterPadLine.SetCurrentKey("Sale Line Retail ID");
        WaiterPadLine.SetRange("Sale Line Retail ID", SaleLinePOS.SystemId);
        if not WaiterPadLine.IsEmpty() then
            WaiterPadLine.ModifyAll("Sale Line Retail ID", GetNullGuid());
    end;

    procedure RunWaiterPadAction(WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Open Waiter Pad"; SendAllLines: Boolean; ServingStepToRequest: Code[10]; WaiterPad: Record "NPR NPRE Waiter Pad"; var ResultMessageText: Text)
    var
        WaiterPad2: Record "NPR NPRE Waiter Pad";
    begin
        Clear(WaiterPad2);
        RunWaiterPadAction(WPadAction, SendAllLines, ServingStepToRequest, WaiterPad, WaiterPad2, ResultMessageText);
    end;

    procedure RunWaiterPadAction(WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Open Waiter Pad"; SendAllLines: Boolean; ServingStepToRequest: Code[10]; WaiterPad: Record "NPR NPRE Waiter Pad"; var MergeToWaiterPad: Record "NPR NPRE Waiter Pad"; var ResultMessageText: Text)
    var
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        case WPadAction of
            WPadAction::"Print Pre-Receipt":
                begin
                    RestaurantPrint.PrintWaiterPadPreReceiptPressed(WaiterPad);
                end;

            WPadAction::"Send Kitchen Order":
                begin
                    RestaurantPrint.PrintWaiterPadPreOrderToKitchenPressed(WaiterPad, SendAllLines);
                end;

            WPadAction::"Request Next Serving":
                begin
                    ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, true, '');
                end;

            WPadAction::"Request Specific Serving":
                begin
                    if ServingStepToRequest = '' then
                        if not LookupServingStep(ServingStepToRequest) then
                            Error('');
                    ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, ServingStepToRequest);
                end;

            WPadAction::"Merge Waiter Pad":
                begin
                    if MergeToWaiterPad."No." = '' then
                        if not SelectWaiterPadToMergeTo(WaiterPad, MergeToWaiterPad) then
                            Error('');
                    WaiterPadMgt.MergeWaiterPad(WaiterPad, MergeToWaiterPad);
                end;

            WPadAction::"Open Waiter Pad":
                begin
                    Page.Run(Page::"NPR NPRE Waiter Pad", WaiterPad);
                end;
        end;
    end;

    procedure LookupServingStep(var SelectedServingStep: Code[10]): Boolean
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        FlowStatus.FilterGroup(2);
        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.FilterGroup(0);
        if SelectedServingStep <> '' then begin
            FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
            FlowStatus.Code := SelectedServingStep;
            if FlowStatus.Find('=><') then;
        end;
        if Page.RunModal(0, FlowStatus) = Action::LookupOK then begin
            SelectedServingStep := FlowStatus.Code;
            exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ClearWPadLinksOnSaleHdrDelete(var Rec: Record "NPR POS Sale"; RunTrigger: Boolean)
    begin
        if not Rec.IsTemporary then
            ClearWPLineSaleHdrLinks(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ClearWPadLinksOnSaleLineDelete(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    begin
        if not Rec.IsTemporary then
            ClearWPLineSaleLineLinks(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Waiter Pad Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure DeleteWPadPOSInfoLink(var Rec: Record "NPR NPRE Waiter Pad Line"; RunTrigger: Boolean)
    var
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
    begin
        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", Rec."Waiter Pad No.");
        POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", Rec."Line No.");
        if not POSInfoWaiterPadLink.IsEmpty then
            POSInfoWaiterPadLink.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, false)]
    local procedure UpdateBilledQtyOnPOSSalePost(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        if IsNullGuid(POSSalesLine.SystemId) then
            exit;
        WaiterPadLine.SetCurrentKey("Sale Line Retail ID");
        WaiterPadLine.SetRange("Sale Line Retail ID", POSSalesLine.SystemId);
        if WaiterPadLine.FindFirst() then begin
            if POSSalesLine."Quantity (Base)" <> 0 then begin
                if WaiterPadLine."Qty. per Unit of Measure" = POSSalesLine."Qty. per Unit of Measure" then
                    WaiterPadLine.Validate("Billed Quantity", WaiterPadLine."Billed Quantity" + POSSalesLine.Quantity)
                else
                    WaiterPadLine.Validate("Billed Qty. (Base)", WaiterPadLine."Billed Qty. (Base)" + POSSalesLine."Quantity (Base)");
                WaiterPadLine.Modify();
            end;

            if WaiterPad.Get(WaiterPadLine."Waiter Pad No.") then
                WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: SavePOSSvSl B", 'OnBeforeSaveAsQuote', '', true, false)]
    local procedure OnBeforeSaveAsPOSQuote(var SalePOS: Record "NPR POS Sale")
    begin
        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then
            Error(CannotParkWPSale);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: LoadPOSSvSl B", 'OnBeforeLoadFromPOSQuote', '', true, false)]
    local procedure OnBeforeLoadPOSQuote(var SalePOS: Record "NPR POS Sale"; var POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var XmlDoc: XmlDocument)
    begin
        ClearSaleHdrNPREPresetFields(SalePOS, true);
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnAfterMoveSaleFromPosToWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
    end;
}
