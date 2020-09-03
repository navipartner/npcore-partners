// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6150660 "NPR NPRE Waiter Pad POS Mgt."
{
    // NPR5.34/ANEN/20170712 CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO/20180412 CASE 309869 Filter parameters in SeatingLookup
    // NPR5.42/MMV /20180524 CASE 315838 Properly delete sale lines.
    // NPR5.45/MHA /20180827 CASE 318369 Added functions FindSeating(),GetSeatingCode(),SelectWaiterPad() and cleaned up code syntax
    // NPR5.50/TJ  /20190528 CASE 346384 New parameter for showing only active waiterpad on seatings
    // NPR5.53/ALPO/20191029 CASE 373792 Splitting the bill: include selected comment lines as well
    //                                   Automatically remove comment lines from waiterpad, if those are the only lines remaining on the waiterpad
    // NPR5.53/ALPO/20191122 CASE 376538 POS Info - Waiter Pad integration: save sale pos info and restore it, when waiter pad lines are moved back to a sale
    //                                   + Removed old version comment lines
    // NPR5.53/ALPO/20191122 CASE 378585 A new publisher to override existing print category assignment procedure
    // NPR5.53/ALPO/20191211 CASE 380609 NPRE: New guest arrival procedure. Use preselected Waiterpad No. and Seating Code as well as Number of Guests
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.53/ALPO/20200108 CASE 380918 Post Seating Code and Number of Guests to POS Entries (for further sales analysis breakedown)
    // NPR5.54/ALPO/20200331 CASE 398454 Preserve price VAT parameters and use it when copying waiter pad lines to a POS sale
    // NPR5.54/ALPO/20200414 CASE 400139 Item Add-On lines were not copied to waiter pads
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    //                                   - Removed functions UpdateNoOfGuests(), UpdateSaleHdrNoOfGuests()
    //                                   - Functions AddNewWaiterPadForSeating(), CleanupWaiterPad(), CloseWaiterPad(), AssignWPadLinePrintCategories(),
    //                                       AddWPadLinePrintCategory(), ClearWPadLinePrintCategories(), OnBeforeAssignWPadLinePrintCategories() moved to CU6150663
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    // NPR5.55/ALPO/20200706 CASE 412863 Reset 'UseLinePriceVATParams' in POSSaleLine codeunit after waiter pad line has been moved to POS sale
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link (filter seatings by restaurant)


    trigger OnRun()
    begin
    end;

    var
        ERRNoPadForSeating: Label 'No active waiter pad exists for seating %1.';
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadUI: Page "NPR NPRE Waiter Pad";
        TXTQtyToMove: Label 'Enter quantity to move to sales ticket from line %1 with total quantity %2.';
        CFRM_Move_seating: Label 'Do you want to move waiter pad %1 %2 from seating %3 to %4?';
        ERRMergeToSelf: Label 'Waiter pad can not be merged into itself, choose another waiter pad.';
        TXTMerged: Label 'Waiter pad lines merged into waiter pad %1 - %2.';
        CFRM_Merge: Label 'Do you want to move lines from waiter pad %1 %2 into waiter pad %3 %4.';
        WPInAnotherSale: Label 'Waiter pad %1 (seating %2) is being processed in another sale at the moment. If you continue, you will get only lines, which were not copied to the other sale.\Are you sure you want to continue?';
        CannotParkWPSale: Label 'Waiter pad related transaction cannot be parked. Please finish your work with the sale by moving it to the waiter pad instead.';
        SplitCancelled: Label 'The split process has been aborted.';

    procedure SplitBill(WaiterPad: Record "NPR NPRE Waiter Pad"; POSSession: Codeunit "NPR POS Session"; NumberOfGuests: Integer; CopyToSale: Boolean)
    var
        NewWaiterPad: Record "NPR NPRE Waiter Pad";
        TMPWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary;
        ChoosenWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DeleteWPLine: Boolean;
    begin
        if not UIShowWaiterPadSplitBilForm(WaiterPad, TMPWaiterPadLine) then
            Error(SplitCancelled);

        TMPWaiterPadLine.SetRange(Marked, true);
        TMPWaiterPadLine.FilterGroup(-1);  //NPR5.53 [373792]
        TMPWaiterPadLine.SetFilter("Marked Qty", '<>%1', 0);
        //-NPR5.53 [373792]
        TMPWaiterPadLine.SetRange(Type, TMPWaiterPadLine.Type::Comment);
        TMPWaiterPadLine.FilterGroup(0);
        //+NPR5.53 [373792]
        if TMPWaiterPadLine.IsEmpty then
            exit;

        //-NPR5.55 [399170]
        WaiterPad.CalcFields("Current Seating FF");
        WaiterPadMgt.DuplicateWaiterPadHdr(WaiterPad, NewWaiterPad);
        WaiterPadMgt.MoveNumberOfGuests(WaiterPad, NewWaiterPad, NumberOfGuests);
        //+NPR5.55 [399170]

        TMPWaiterPadLine.FindFirst;
        repeat
            ChoosenWaiterPadLine.Get(TMPWaiterPadLine."Waiter Pad No.", TMPWaiterPadLine."Line No.");
            SplitWaiterPadLine(WaiterPad, ChoosenWaiterPadLine, TMPWaiterPadLine."Marked Qty", NewWaiterPad);
        //-NPR5.55 [399170]-revoked
        /*
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        DeleteWPLine := TMPWaiterPadLine.Quantity = TMPWaiterPadLine."Marked Qty";
        //MoveSaleLineFromWaiterPadToPOS(SaleLinePOS, ChoosenWaiterPadLine, DeleteWPLine, POSSaleLine);  //NPR5.53 [380918]-revoked
        MoveSaleLineFromWaiterPadToPOS(SaleLinePOS,WaiterPad,ChoosenWaiterPadLine,DeleteWPLine,POSSaleLine);  //NPR5.53 [380918]

        POSSaleLine.SetQuantity(TMPWaiterPadLine."Marked Qty");

        IF TMPWaiterPadLine.Quantity <> TMPWaiterPadLine."Marked Qty" THEN BEGIN
          ChoosenWaiterPadLine.Quantity := ChoosenWaiterPadLine.Quantity - TMPWaiterPadLine."Marked Qty";
          ChoosenWaiterPadLine.MODIFY;
        END;
        */
        //+NPR5.55 [399170]-revoked
        until (0 = TMPWaiterPadLine.Next);

        //-NPR5.55 [399170]-revoked
        /*
        UpdateNoOfGuests(WaiterPad,SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",1);  //NPR5.53 [380918]
        CopySaleHdrPOSInfo(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",WaiterPad."No.",FALSE);  //NPR5.53 [376538]
        
        CloseWaiterPad(WaiterPad);
        */
        //+NPR5.55 [399170]-revoked
        //-NPR5.55 [399170]
        WaiterPadMgt.CloseWaiterPad(WaiterPad, false);

        if CopyToSale then begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.DeleteAll;

            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            ClearSaleHdrNPREPresetFields(SalePOS, false);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);
            GetSaleFromWaiterPadToPOS(NewWaiterPad, POSSession);
        end;
        //-NPR5.55 [399170]

    end;

    procedure SplitWaiterPadLine(var FromWaiterPad: Record "NPR NPRE Waiter Pad"; var FromWaiterPadLine: Record "NPR NPRE Waiter Pad Line"; MoveQty: Decimal; ToWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        NewWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestPrint: Codeunit "NPR NPRE Restaurant Print";
        FullLineTransfer: Boolean;
    begin
        //-NPR5.55 [399170]
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
        KitchenOrderMgt.SplitWaiterPadLineKitchenReqSourceLinks(FromWaiterPadLine, NewWaiterPadLine, FullLineTransfer);

        FromWaiterPadLine.CalcFields("Sent to Kitchen");
        FromWaiterPadLine.Validate(Quantity, FromWaiterPadLine.Quantity - NewWaiterPadLine.Quantity);
        FromWaiterPadLine.Validate("Billed Quantity", FromWaiterPadLine."Billed Quantity" - NewWaiterPadLine."Billed Quantity");
        if not FromWaiterPadLine."Sent to Kitchen" and (FromWaiterPadLine.Quantity = 0) and (FromWaiterPadLine."Billed Quantity" = 0) then
            FromWaiterPadLine.Delete(true)
        else begin
            FromWaiterPadLine."Amount Incl. VAT" := 0;
            FromWaiterPadLine."Amount Excl. VAT" := 0;
            FromWaiterPadLine."Discount Amount" := 0;
            FromWaiterPadLine.Modify;
        end;
        //+NPR5.55 [399170]
    end;

    procedure MoveSaleFromPOSToWaiterPad(var SalePOS: Record "NPR Sale POS"; WaiterPad: Record "NPR NPRE Waiter Pad"; CleanupSale: Boolean)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        TouchedWaiterPadLineTmp: Record "NPR NPRE Waiter Pad Line" temporary;
        NPHHospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        //IF NOT SaleLinePOS.FINDSET(TRUE) THEN  //NPR5.55 [399170]-revoked
        if not SaleLinePOS.FindSet(CleanupSale) then  //NPR5.55 [399170]
            exit;

        TouchedWaiterPadLineTmp.DeleteAll;  //NPR5.55 [399170]

        CopySaleHdrPOSInfo(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", WaiterPad."No.", true);  //NPR5.53 [376538]
        repeat
            //MoveSaleLineFromPOSToWaiterPad(SaleLinePOS, WaiterPad);  //NPR5.53 [380609]-revoked
            //MoveSaleLineFromPOSToWaiterPad(SaleLinePOS,WaiterPad,WaiterPadLine);  //NPR5.53 [380609]  //NPR5.55 [399170]-revoked
            //-NPR5.55 [399170]
            MoveSaleLineFromPOSToWaiterPad(SalePOS, SaleLinePOS, WaiterPad, WaiterPadLine);
            TouchedWaiterPadLineTmp := WaiterPadLine;
            TouchedWaiterPadLineTmp.Insert;
        //+NPR5.55 [399170]
        //SaleLinePOS.DELETE(TRUE);  //NPR5.54 [400139]-revoked
        until SaleLinePOS.Next = 0;

        //-NPR5.55 [399170]
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("Sale Retail ID", SalePOS."Retail ID");
        WaiterPadLine.SetAutoCalcFields("Kitchen Order Sent", "Serving Requested");
        if WaiterPadLine.FindSet then
            repeat
                TouchedWaiterPadLineTmp := WaiterPadLine;
                if not TouchedWaiterPadLineTmp.Find then begin
                    if (WaiterPadLine."Kitchen Order Sent" or WaiterPadLine."Serving Requested") and
                       (WaiterPadLine.Type = WaiterPadLine.Type::Item)
                    then begin
                        if WaiterPadLine.Quantity <> 0 then begin
                            WaiterPadLine.Validate(Quantity, 0);
                            WaiterPadLine.Modify;
                            WaiterPadLine.Mark := true;
                        end;
                    end else
                        WaiterPadLine.Delete(true);
                end;
            until WaiterPadLine.Next = 0;

        if CleanupSale then begin
            //+NPR5.55 [399170]
            SaleLinePOS.DeleteAll(true);  //NPR5.54 [400139]
                                          //-NPR5.55 [399170]
            ClearSaleHdrNPREPresetFields(SalePOS, false);
        end;
        WaiterPadLine.SetRange("Sale Retail ID");
        //+NPR5.55 [399170]

        //-NPR5.53 [380609]
        WaiterPadLine.MarkedOnly(true);
        //-NPR5.55 [399170]
        if not WaiterPadLine.IsEmpty then
            NPHHospitalityPrint.SetWaiterPadPreReceiptPrinted(WaiterPad, false, true);
        //+NPR5.55 [399170]
        OnAfterMoveSaleFromPosToWaiterPad(WaiterPad, WaiterPadLine);
        //+NPR5.53 [380609]

        Commit;  //NPR5.55 [399170]
        NPHHospitalityPrint.LinesAddedToWaiterPad(WaiterPad);
    end;

    procedure MoveSaleLineFromPOSToWaiterPad(SalePOS: Record "NPR Sale POS"; SaleLinePOS: Record "NPR Sale Line POS"; WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        WaiterPadLine2: Record "NPR NPRE Waiter Pad Line";
        NewLine: Boolean;
    begin
        //-NPR5.55 [399170]
        WaiterPadLine2.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine2.SetRange("Sale Line Retail ID", SaleLinePOS."Retail ID");
        with WaiterPadLine do begin
            NewLine := not WaiterPadLine2.FindFirst or IsNullGuid(SaleLinePOS."Retail ID");
            if not NewLine then begin
                WaiterPadLine := WaiterPadLine2;
                TestField(Type, SaleLinePOS.Type);
                TestField("Sale Type", SaleLinePOS."Sale Type");
                TestField("No.", SaleLinePOS."No.");
                TestField("Variant Code", SaleLinePOS."Variant Code");
                TestField("Unit of Measure Code", SaleLinePOS."Unit of Measure Code");
                TestField("Qty. per Unit of Measure", SaleLinePOS."Qty. per Unit of Measure");
            end else begin
                WaiterPadLine2.Init;

                Init;
                "Waiter Pad No." := WaiterPad."No.";
                "Register No." := SaleLinePOS."Register No.";
                "Start Date" := Today;
                "Start Time" := Time;

                "Sale Type" := SaleLinePOS."Sale Type";
                Type := SaleLinePOS.Type;
                "No." := SaleLinePOS."No.";
                "Variant Code" := SaleLinePOS."Variant Code";
                Description := SaleLinePOS.Description;
                "Description 2" := SaleLinePOS."Description 2";
                "Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
                "Qty. per Unit of Measure" := SaleLinePOS."Qty. per Unit of Measure";

                "Sale Retail ID" := SalePOS."Retail ID";
                "Sale Line Retail ID" := SaleLinePOS."Retail ID";
                Insert(true);

                WaiterPadMgt.AssignWPadLinePrintCategories(WaiterPadLine, true);
            end;

            Quantity := SaleLinePOS.Quantity;
            "Quantity (Base)" := SaleLinePOS."Quantity (Base)";
            "Unit Price" := SaleLinePOS."Unit Price";
            "Discount Type" := SaleLinePOS."Discount Type";
            "Discount Code" := SaleLinePOS."Discount Code";
            "Allow Line Discount" := SaleLinePOS."Allow Line Discount";
            "Discount %" := SaleLinePOS."Discount %";
            "Discount Amount" := SaleLinePOS."Discount Amount";
            "Allow Invoice Discount" := SaleLinePOS."Allow Invoice Discount";
            "Invoice Discount Amount" := SaleLinePOS."Invoice Discount Amount";
            "Amount Excl. VAT" := SaleLinePOS.Amount;
            "Amount Incl. VAT" := SaleLinePOS."Amount Including VAT";
            "Price Includes VAT" := SaleLinePOS."Price Includes VAT";
            "VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
            "VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
            "Order No. from Web" := SaleLinePOS."Order No. from Web";
            "Order Line No. from Web" := SaleLinePOS."Order Line No. from Web";
            Modify;

            Mark := NewLine or ("Quantity (Base)" <> WaiterPadLine2."Quantity (Base)");

            CopyPOSInfo(SaleLinePOS, "Waiter Pad No.", "Line No.", true);
        end;
        //+NPR5.55 [399170]
        //-NPR5.55 [399170]-revoked
        /*
        WaiterPadLine.INIT;
        WaiterPadLine."Waiter Pad No." := WaiterPad."No.";
        WaiterPadLine."Register No." := SaleLinePOS."Register No.";
        WaiterPadLine."Start Date" := TODAY;
        WaiterPadLine."Start Time" :=  TIME;
        
        WaiterPadLine.Type                        := SaleLinePOS.Type;
        WaiterPadLine."Sale Type"                 := SaleLinePOS."Sale Type";
        WaiterPadLine.Description                 := SaleLinePOS.Description;
        WaiterPadLine."No."                       := SaleLinePOS."No.";
        WaiterPadLine."Description 2"             := SaleLinePOS."Description 2";
        WaiterPadLine."Variant Code"              := SaleLinePOS."Variant Code";
        WaiterPadLine."Order No. from Web"        := SaleLinePOS."Order No. from Web";
        WaiterPadLine."Order Line No. from Web"   := SaleLinePOS."Order Line No. from Web";
        WaiterPadLine."Unit of Measure Code"      := SaleLinePOS."Unit of Measure Code";
        WaiterPadLine.Quantity                    := SaleLinePOS.Quantity;
        WaiterPadLine."Unit Price"                := SaleLinePOS."Unit Price";
        WaiterPadLine."Discount Type"             := SaleLinePOS."Discount Type";
        WaiterPadLine."Discount Code"             := SaleLinePOS."Discount Code";
        WaiterPadLine."Allow Line Discount"       := SaleLinePOS."Allow Line Discount";
        WaiterPadLine."Discount %"                := SaleLinePOS."Discount %";
        WaiterPadLine."Discount Amount"           := SaleLinePOS."Discount Amount";
        WaiterPadLine."Allow Invoice Discount"    := SaleLinePOS."Allow Invoice Discount";
        WaiterPadLine."Invoice Discount Amount"   := SaleLinePOS."Invoice Discount Amount";
        WaiterPadLine."Amount Excl. VAT"          := SaleLinePOS.Amount;
        WaiterPadLine."Amount Incl. VAT"          := SaleLinePOS."Amount Including VAT";
        //-NPR5.54 [398454]
        WaiterPadLine."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
        WaiterPadLine."VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
        WaiterPadLine."VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
        //+NPR5.54 [398454]
        WaiterPadLine.INSERT(TRUE);
        WaiterPadLine.MARK(TRUE);  //NPR5.53 [380609]
        
        CopyPOSInfo(SaleLinePOS,WaiterPadLine."Waiter Pad No.",WaiterPadLine."Line No.",TRUE);  //NPR5.53 [376538]
        
        AssignWPadLinePrintCategories(WaiterPadLine,TRUE);  //NPR5.53 [360258]
        */
        //+NPR5.55 [399170]-revoked
        //-NPR5.53 [360258]-revoked
        /*
        //-NPR5.53 [378585]
        WPadLine_OnBeforeAssignPrintCategory(WaiterPadLine,Handled);
        IF NOT Handled THEN
        //+NPR5.53 [378585]
          IF WaiterPadLine.Type = WaiterPadLine.Type::Item THEN BEGIN
            IF Item.GET(WaiterPadLine."No.") THEN BEGIN
              IF Item."Print Tags" <> '' THEN BEGIN
                NPHPrintCategory.RESET;
                NPHPrintCategory.SETFILTER("Print Tag", '=%1', Item."Print Tags");
                IF NPHPrintCategory.FINDFIRST THEN BEGIN
                  WaiterPadLine."Print Category" := NPHPrintCategory.Code;
                  WaiterPadLine.MODIFY;
                END;
              END;
            END;
          END;
        */
        //+NPR5.53 [360258]-revoked

    end;

    procedure GetSaleFromWaiterPadToPOS(WaiterPad: Record "NPR NPRE Waiter Pad"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        //-NPR5.55 [399170]-revoked
        /*
        WaiterPadLine.RESET;
        WaiterPadLine.SETRANGE("Waiter Pad No.", WaiterPad."No.");
        IF WaiterPadLine.ISEMPTY THEN BEGIN
          CloseWaiterPad(WaiterPad);
          EXIT;
        END;
        */
        //+NPR5.55 [399170]-revoked

        //-NPR5.55 [399170]
        WaiterPad.CalcFields("Current Seating FF");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("NPRE Pre-Set Waiter Pad No.", '');

        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Sale Retail ID", '<>%1&<>%2', GetNullGuid(), SalePOS."Retail ID");
        if not WaiterPadLine.IsEmpty then
            if not Confirm(WPInAnotherSale, false, WaiterPad."No.", WaiterPad."Current Seating FF") then
                Error('');

        SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        SalePOS."NPRE Pre-Set Seating Code" := WaiterPad."Current Seating FF";
        SalePOS."NPRE Number of Guests" := WaiterPad."Number of Guests";
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        POSSession.GetSaleLine(POSSaleLine);

        WaiterPadLine.SetRange("Sale Retail ID", GetNullGuid());
        if WaiterPadLine.FindSet(true) then
            //+NPR5.55 [399170]
            //WaiterPadLine.FINDSET(TRUE, FALSE);  //NPR5.55 [399170]-revoked
            repeat
                POSSaleLine.GetNewSaleLine(SaleLinePOS);
                //MoveSaleLineFromWaiterPadToPOS(SaleLinePOS, WaiterPadLine, TRUE, POSSaleLine);  //NPR5.53 [380918]-revoked
                //MoveSaleLineFromWaiterPadToPOS(SaleLinePOS,WaiterPad,WaiterPadLine,TRUE,POSSaleLine);  //NPR5.53 [380918]  //NPR5.55 [399170]-revoked
                GetSaleLineFromWaiterPadToPOS(SalePOS, SaleLinePOS, WaiterPad, WaiterPadLine, POSSaleLine);  //NPR5.55 [399170]
            until (0 = WaiterPadLine.Next);

        //-NPR5.55 [399170]-revoked
        //UpdateNoOfGuests(WaiterPad,SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",WaiterPad."Number of Guests" - WaiterPad."Billed Number of Guests");  //NPR5.53 [380918]
        //+NPR5.55 [399170]-revoked
        CopySaleHdrPOSInfo(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", WaiterPad."No.", false);  //NPR5.53 [376538]

        //CloseWaiterPad(WaiterPad);  //NPR5.55 [399170]-revoked

    end;

    local procedure GetSaleLineFromWaiterPadToPOS(SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS"; WaiterPad: Record "NPR NPRE Waiter Pad"; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; var POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
        SaleLinePOS.Silent := true;

        SaleLinePOS.Type := WaiterPadLine.Type;
        SaleLinePOS."Sale Type" := WaiterPadLine."Sale Type";
        if SaleLinePOS.Type <> SaleLinePOS.Type::Comment then
            SaleLinePOS."No." := WaiterPadLine."No.";
        SaleLinePOS."Variant Code" := WaiterPadLine."Variant Code";

        SaleLinePOS.Description := WaiterPadLine.Description;
        SaleLinePOS."Description 2" := WaiterPadLine."Description 2";
        SaleLinePOS."Order No. from Web" := WaiterPadLine."Order No. from Web";
        SaleLinePOS."Order Line No. from Web" := WaiterPadLine."Order Line No. from Web";
        if SaleLinePOS.Type = SaleLinePOS.Type::Item then
            SaleLinePOS.Validate("Unit of Measure Code");
        SaleLinePOS.Silent := false;

        //SaleLinePOS.VALIDATE(Quantity, WaiterPadLine.Quantity);  //NPR5.55 [399170]-revoked
        SaleLinePOS.Validate(Quantity, WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity");  //NPR5.55 [399170]
        SaleLinePOS."Unit Price" := WaiterPadLine."Unit Price";
        //-NPR5.54 [398454]
        SaleLinePOS."Price Includes VAT" := WaiterPadLine."Price Includes VAT";
        SaleLinePOS."VAT Bus. Posting Group" := WaiterPadLine."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := WaiterPadLine."VAT Prod. Posting Group";
        //+NPR5.54 [398454]

        SaleLinePOS."Discount Type" := WaiterPadLine."Discount Type";
        SaleLinePOS."Discount Code" := WaiterPadLine."Discount Code";

        SaleLinePOS."Allow Line Discount" := WaiterPadLine."Allow Line Discount";
        SaleLinePOS."Allow Invoice Discount" := WaiterPadLine."Allow Invoice Discount";

        SaleLinePOS."Discount %" := WaiterPadLine."Discount %";
        SaleLinePOS."Invoice Discount Amount" := WaiterPadLine."Invoice Discount Amount";

        //-NPR5.53 [380918]
        if SaleLinePOS.Type <> SaleLinePOS.Type::Comment then begin
            WaiterPad.CalcFields("Current Seating FF");
            SaleLinePOS."NPRE Seating Code" := WaiterPad."Current Seating FF";
        end;
        //+NPR5.53 [380918]

        POSSaleLine.SetUseLinePriceVATParams(true);  //NPR5.54 [398454]
        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.SetUseLinePriceVATParams(false);  //NPR5.55 [412863]
        CopyPOSInfo(SaleLinePOS, WaiterPadLine."Waiter Pad No.", WaiterPadLine."Line No.", false);  //NPR5.53 [376538]

        //-NPR5.55 [399170]
        WaiterPadLine."Sale Retail ID" := SalePOS."Retail ID";
        WaiterPadLine."Sale Line Retail ID" := SaleLinePOS."Retail ID";
        WaiterPadLine.Modify;
        //+NPR5.55 [399170]
        //-NPR5.55 [399170]-revoked
        /*
        IF DeleteWaiterPadLine THEN
          //WaiterPadLine.DELETE;  //NPR5.53 [360258]-revoked
          WaiterPadLine.DELETE(TRUE);  //NPR5.53 [360258]
        */
        //+NPR5.55 [399170]-revoked

    end;

    local procedure WaiterPadExistsForSeating(SeatingCode: Code[20]; OpenOnly: Boolean; ExcludeWaiterPadNo: Code[20]) Exists: Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
    begin
        Seating.Get(SeatingCode);

        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        //-NPR5.55 [399170]
        if OpenOnly then
            SeatingWaiterPadLink.SetRange(Closed, false);
        if ExcludeWaiterPadNo <> '' then
            SeatingWaiterPadLink.SetFilter("Waiter Pad No.", '<>%1', ExcludeWaiterPadNo);
        //+NPR5.55 [399170]

        exit(not SeatingWaiterPadLink.IsEmpty);
    end;

    local procedure GetWaiterPadForSeating(SeatingCode: Code[20]; OpenOnly: Boolean; ExcludeWaiterPadNo: Code[20]; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
    begin
        Seating.Get(SeatingCode);

        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        //-NPR5.55 [399170]
        if OpenOnly then
            SeatingWaiterPadLink.SetRange(Closed, false);
        if ExcludeWaiterPadNo <> '' then
            SeatingWaiterPadLink.SetFilter("Waiter Pad No.", '<>%1', ExcludeWaiterPadNo);
        //+NPR5.55 [399170]

        if SeatingWaiterPadLink.IsEmpty then
            WaiterPadMgt.AddNewWaiterPadForSeating(Seating.Code, WaiterPad, SeatingWaiterPadLink);

        if SeatingWaiterPadLink.Count > 1 then begin
            SeatingWaiterPadLink.FindSet;
            WaiterPad.Reset;
            repeat
                WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.");
                WaiterPad.Mark(true);
            until SeatingWaiterPadLink.Next = 0;
            WaiterPad.MarkedOnly(true);
        end else begin
            SeatingWaiterPadLink.FindFirst;
            WaiterPad.Reset;
            WaiterPad.SetRange("No.", SeatingWaiterPadLink."Waiter Pad No.");
            WaiterPad.FindFirst;
        end;
    end;

    local procedure UILookUpWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad") LookUpOK: Boolean
    var
        WaiterPadList: Page "NPR NPRE Waiter Pad List";
    begin
        WaiterPadList.SetTableView(WaiterPad);
        WaiterPadList.LookupMode := true;
        if WaiterPadList.RunModal = ACTION::LookupOK then begin
            WaiterPadList.GetRecord(WaiterPad);
            WaiterPad.SetRange("No.", WaiterPad."No.");
            WaiterPad.FindFirst;
            LookUpOK := true;
        end else begin
            LookUpOK := false;
        end;

        exit(LookUpOK);
    end;

    local procedure UIShowWaiterPadSplitBilForm(WaiterPad: Record "NPR NPRE Waiter Pad"; var TMPWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary) OK: Boolean
    var
        POSWaiterPadLines: Page "NPR NPRE Tmp POSWaiterPadLines";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");

        TMPWaiterPadLine.Reset;
        TMPWaiterPadLine.DeleteAll;

        //WaiterPadLine.FINDFIRST;  //NPR5.55 [399170]-revoked
        if WaiterPadLine.FindSet then  //NPR5.55 [399170]
            repeat
                if WaiterPadLine.Quantity > WaiterPadLine."Billed Quantity" then begin  //NPR5.55 [399170]
                    TMPWaiterPadLine.TransferFields(WaiterPadLine);
                    TMPWaiterPadLine.Marked := false;
                    TMPWaiterPadLine."Marked Qty" := 0;
                    TMPWaiterPadLine.Insert;
                end;  //NPR5.55 [399170]
            until (0 = WaiterPadLine.Next);

        Clear(POSWaiterPadLines);

        POSWaiterPadLines.fnSetLines(TMPWaiterPadLine);
        POSWaiterPadLines.SetTableView(TMPWaiterPadLine);

        POSWaiterPadLines.Editable(false);

        if POSWaiterPadLines.RunModal = ACTION::OK then begin
            //POSWaiterPadLines.fnGetLines(TMPWaiterPadLine);  //NPR5.55 [399170]-revoked
            exit(true);
        end else begin
            exit(false);
        end;
    end;

    procedure UIShowWaiterPad(WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPadUI.SetRecord(WaiterPad);
        WaiterPadUI.RunModal;
    end;

    procedure GetQtyUI(OrgQty: Decimal; Description: Text; var ioChosenQty: Decimal) OK: Boolean
    var
    // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
    //Marshaller: Codeunit "POS Event Marshaller";
    begin
        //Used by page [Tmp POS Waiter Pad Lines] to chose a qty from a total qty
        //Shall show numpad
        ioChosenQty := OrgQty;

        // TODO: CTRLUPGRADE - Must be refactored to not use Marshaller
        Error('CTRLUPGRADE');
        /*
        if not Marshaller.NumPad((StrSubstNo(TXTQtyToMove, Description, OrgQty)), ioChosenQty, false, false) then
            exit(false);
        */

        exit(true);
    end;

    procedure MoveWaiterPadToNewSeatingUI(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        //Called from Waiter pad page -  with UI used to change seating on waiter pad
        Seating.Get(SeatingManagement.UILookUpSeating('', ''));

        WaiterPad.CalcFields("Current Seating FF");

        if not Confirm(StrSubstNo(CFRM_Move_seating, WaiterPad."No.", WaiterPad.Description, WaiterPad."Current Seating Description", Seating.Description), true) then
            exit;
        WaiterPadManagement.ChangeSeating(WaiterPad."No.", WaiterPad."Current Seating FF", Seating.Code);
    end;

    procedure MergeWaiterPadUI(var WaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        MergeToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        //Called from Waiter pad card - with UI to chose a waiter pad and merge current waiter pad into it
        //-NPR5.55 [399170]-revoked
        /*
        ChosenSeatingCode := SeatingManagement.UILookUpSeating('','');
        IF ChosenSeatingCode = '' THEN
          EXIT;
        Seating.GET(ChosenSeatingCode);
        
        IF NOT WaiterPadExistsForSeating(Seating.Code) THEN
          ERROR(ERRNoPadForSeating, Seating.Description);
        
        GetWaiterPadForSeating(Seating.Code, MergeToWaiterPad);
        
        IF MergeToWaiterPad.COUNT = 0 THEN
          EXIT;
        
        IF MergeToWaiterPad.COUNT > 1 THEN BEGIN
          IF NOT UILookUpWaiterPad(MergeToWaiterPad) THEN
            EXIT;
        END;
        
        IF WaiterPad."No." = MergeToWaiterPad."No." THEN
          ERROR(ERRMergeToSelf);
        
        IF NOT CONFIRM(STRSUBSTNO(CFRM_Merge, WaiterPad."No.", WaiterPad.Description, MergeToWaiterPad."No.", MergeToWaiterPad.Description), TRUE) THEN
          EXIT;
        */
        //+NPR5.55 [399170]-revoked
        if SelectWaiterPadToMergeTo(WaiterPad, MergeToWaiterPad) then  //NPR5.55 [399170]
            if WaiterPadManagement.MergeWaiterPad(WaiterPad, MergeToWaiterPad) then begin
                WaiterPad.Get(MergeToWaiterPad."No.");
                //IF CONFIRM(STRSUBSTNO(TXTMerged, MergeToWaiterPad."No.", MergeToWaiterPad.Description), TRUE) THEN;  //NPR5.55 [399170]-revoked
                Message(TXTMerged, MergeToWaiterPad."No.", MergeToWaiterPad.Description);  //NPR5.55 [399170]
                exit(true);
            end;
        exit(false);  //NPR5.55 [399170]

    end;

    procedure SelectWaiterPadToMergeTo(WaiterPad: Record "NPR NPRE Waiter Pad"; var MergeToWaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        Seating: Record "NPR NPRE Seating";
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        ChosenSeatingCode: Code[10];
    begin
        //-NPR5.55 [399170] (Moved from MergeWaiterPadUI())
        ChosenSeatingCode := SeatingManagement.UILookUpSeating('', '');
        if ChosenSeatingCode = '' then
            exit(false);
        Seating.Get(ChosenSeatingCode);

        if not WaiterPadExistsForSeating(Seating.Code, true, WaiterPad."No.") then
            Error(ERRNoPadForSeating, Seating.Description);

        GetWaiterPadForSeating(Seating.Code, true, WaiterPad."No.", MergeToWaiterPad);

        if MergeToWaiterPad.Count = 0 then
            exit(false);
        if MergeToWaiterPad.Count > 1 then begin
            if not UILookUpWaiterPad(MergeToWaiterPad) then
                exit(false);
        end;
        if WaiterPad."No." = MergeToWaiterPad."No." then
            Error(ERRMergeToSelf);

        if not Confirm(CFRM_Merge, true, WaiterPad."No.", WaiterPad.Description, MergeToWaiterPad."No.", MergeToWaiterPad.Description) then
            exit(false);

        exit(true);
        //+NPR5.55 [399170]
    end;

    procedure FindSeating(JSON: Codeunit "NPR POS JSON Management"; var NPRESeating: Record "NPR NPRE Seating")
    var
        RestaurantCode: Code[20];
        SeatingCode: Code[10];
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        LocationFilter: Text;
        SeatingFilter: Text;
    begin
        //SeatingCode := GetSeatingCode(JSON);  //NPR5.55 [414938]-revoked
        //-NPR5.55 [414938]
        RestaurantCode := CopyStr(JSON.GetString('restaurantCode', false), 1, MaxStrLen(RestaurantCode));
        SeatingCode := GetSeatingCode(JSON, RestaurantCode);
        //+NPR5.55 [414938]
        NPRESeating.Get(SeatingCode);

        if not JSON.SetScope('parameters', false) then
            exit;

        SeatingFilter := JSON.GetString('SeatingFilter', false);
        LocationFilter := JSON.GetString('LocationFilter', false);
        //-NPR5.55 [414938]
        if LocationFilter = '' then
            LocationFilter := SeatingManagement.RestaurantSeatingLocationFilter(RestaurantCode);
        //+NPR5.55 [414938]
        if (SeatingFilter <> '') or (LocationFilter <> '') then begin
            NPRESeating.SetRecFilter;
            NPRESeating.FilterGroup(2);
            NPRESeating.SetFilter(Code, SeatingFilter);
            NPRESeating.SetFilter("Seating Location", LocationFilter);
            NPRESeating.FindFirst;
        end;
    end;

    local procedure GetSeatingCode(JSON: Codeunit "NPR POS JSON Management"; RestaurantCode: Code[20]) SeatingCode: Code[10]
    var
        SeatingManagement: Codeunit "NPR NPRE Seating Mgt.";
        SeatingFilter: Text;
        LocationFilter: Text;
        NPRESeating: Record "NPR NPRE Seating";
    begin
        SeatingCode := CopyStr(UpperCase(JSON.GetString('seatingCode', false)), 1, MaxStrLen(SeatingCode));
        if SeatingCode <> '' then
            exit(SeatingCode);

        JSON.SetScope('/', true);
        JSON.SetScope('parameters', true);
        if JSON.GetInteger('InputType', true) <> 2 then
            exit('');

        if JSON.GetBoolean('ShowOnlyActiveWaiPad', false) then begin
            NPRESeating.SetAutoCalcFields("Current Waiter Pad FF");
            NPRESeating.SetFilter("Current Waiter Pad FF", '<>%1', '');
            SeatingManagement.SetAddSeatingFilters(NPRESeating);
        end;
        SeatingFilter := JSON.GetString('SeatingFilter', true);
        LocationFilter := JSON.GetString('LocationFilter', true);
        //-NPR5.55 [414938]
        if LocationFilter = '' then
            LocationFilter := SeatingManagement.RestaurantSeatingLocationFilter(RestaurantCode);
        //+NPR5.55 [414938]
        SeatingCode := SeatingManagement.UILookUpSeating(SeatingFilter, LocationFilter);
        exit(SeatingCode);
    end;

    procedure SelectWaiterPad(NPRESeating: Record "NPR NPRE Seating"; var NPREWaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        TempNPREWaiterPad: Record "NPR NPRE Waiter Pad" temporary;
    begin
        NPRESeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        NPRESeatingWaiterPadLink.SetRange(Closed, false);  //NPR5.55 [399170]
        if NPRESeatingWaiterPadLink.IsEmpty then
            Error(ERRNoPadForSeating, NPRESeating.Code);

        NPRESeatingWaiterPadLink.FindSet;
        repeat
            //IF NPREWaiterPad.GET(NPRESeatingWaiterPadLink."Waiter Pad No.") THEN BEGIN  //NPR5.55 [399170]-revoked
            if NPREWaiterPad.Get(NPRESeatingWaiterPadLink."Waiter Pad No.") and not NPREWaiterPad.Closed then begin  //NPR5.55 [399170]
                TempNPREWaiterPad.Init;
                TempNPREWaiterPad := NPREWaiterPad;
                TempNPREWaiterPad.Insert;
            end;
        until NPRESeatingWaiterPadLink.Next = 0;

        TempNPREWaiterPad.FindLast;
        NPREWaiterPad."No." := TempNPREWaiterPad."No.";

        TempNPREWaiterPad.FindFirst;
        if NPREWaiterPad."No." <> TempNPREWaiterPad."No." then begin
            if PAGE.RunModal(0, TempNPREWaiterPad) <> ACTION::LookupOK then begin
                Clear(NPREWaiterPad);
                exit(false);
            end;
        end;

        NPREWaiterPad.Get(TempNPREWaiterPad."No.");
        exit(true);
    end;

    local procedure CopyPOSInfo(SaleLinePOS: Record "NPR Sale Line POS"; WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; ToWaiterPad: Boolean)
    var
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        //-NPR5.53 [376538]
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        if ToWaiterPad then begin
            if POSInfoTransaction.FindSet then
                repeat
                    POSInfoWaiterPadLink.Init;
                    POSInfoWaiterPadLink."Waiter Pad No." := WaiterPadNo;
                    POSInfoWaiterPadLink."Waiter Pad Line No." := WaiterPadLineNo;
                    POSInfoWaiterPadLink."POS Info Code" := POSInfoTransaction."POS Info Code";
                    if not POSInfoWaiterPadLink.Find then
                        POSInfoWaiterPadLink.Insert;
                    POSInfoWaiterPadLink."POS Info" := POSInfoTransaction."POS Info";
                    POSInfoWaiterPadLink.Modify;
                until POSInfoTransaction.Next = 0;

        end else begin
            POSInfoTransaction.DeleteAll;

            POSInfoWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);
            POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
            if POSInfoWaiterPadLink.FindSet then
                repeat
                    POSInfoTransaction.SetRange("POS Info Code", POSInfoWaiterPadLink."POS Info Code");
                    if POSInfoTransaction.FindFirst then begin
                        POSInfoTransaction."POS Info" := POSInfoWaiterPadLink."POS Info";
                        POSInfoTransaction.Modify;
                    end else begin
                        POSInfoTransaction.Init;
                        POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
                        POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                        POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
                        POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
                        POSInfoTransaction."Receipt Type" := SaleLinePOS.Type;
                        POSInfoTransaction."Entry No." := 0;
                        POSInfoTransaction."POS Info Code" := POSInfoWaiterPadLink."POS Info Code";
                        POSInfoTransaction."POS Info" := POSInfoWaiterPadLink."POS Info";
                        POSInfoTransaction.Insert(true);
                    end;
                until POSInfoWaiterPadLink.Next = 0;
        end;
        //+NPR5.53 [376538]
    end;

    local procedure CopySaleHdrPOSInfo(RegisterNo: Code[10]; SalesTicketNo: Code[20]; WaiterPadNo: Code[20]; ToWaiterPad: Boolean)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        //-NPR5.53 [376538]
        SaleLinePOS."Register No." := RegisterNo;
        SaleLinePOS."Sales Ticket No." := SalesTicketNo;
        SaleLinePOS."Line No." := 0;
        CopyPOSInfo(SaleLinePOS, WaiterPadNo, 0, ToWaiterPad);
        //+NPR5.53 [376538]
    end;

    procedure CopyPOSInfoWPad2WPad(FromWaiterPad: Record "NPR NPRE Waiter Pad"; FromWaiterPadLineNo: Integer; ToWaiterPad: Record "NPR NPRE Waiter Pad"; ToWaiterPadLineNo: Integer)
    var
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
        POSInfoWaiterPadLink2: Record "NPR POS Info NPRE Waiter Pad";
    begin
        //-NPR5.55 [399170]
        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", FromWaiterPad."No.");
        POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", FromWaiterPadLineNo);
        if POSInfoWaiterPadLink.FindSet then
            repeat
                POSInfoWaiterPadLink2 := POSInfoWaiterPadLink;
                if not POSInfoWaiterPadLink2.Find then
                    POSInfoWaiterPadLink2.Insert;
                POSInfoWaiterPadLink2."POS Info" := POSInfoWaiterPadLink."POS Info";
                POSInfoWaiterPadLink2.Modify;
            until POSInfoWaiterPadLink.Next = 0;
        //+NPR5.55 [399170]
    end;

    procedure ClearSaleHdrNPREPresetFields(var SalePOS: Record "NPR Sale POS"; ModifyRec: Boolean)
    begin
        //-NPR5.53 [380609]
        SalePOS."NPRE Number of Guests" := 0;
        SalePOS."NPRE Pre-Set Seating Code" := '';
        SalePOS."NPRE Pre-Set Waiter Pad No." := '';
        if ModifyRec then
            SalePOS.Modify;
        //+NPR5.53 [380609]

        ClearWPLineSaleHdrLinks(SalePOS);  //NPR5.55 [399170]
    end;

    procedure GetNullGuid(): Guid
    var
        NullGuid: Guid;
    begin
        //-NPR5.55 [399170]
        Clear(NullGuid);
        exit(NullGuid);
        //+NPR5.55 [399170]
    end;

    local procedure ClearWPLineSaleHdrLinks(SalePOS: Record "NPR Sale POS")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        //-NPR5.55 [399170]
        if IsNullGuid(SalePOS."Retail ID") then
            exit;
        WaiterPadLine.SetRange("Sale Retail ID", SalePOS."Retail ID");
        WaiterPadLine.ModifyAll("Sale Retail ID", GetNullGuid());
        //+NPR5.55 [399170]
    end;

    local procedure ClearWPLineSaleLineLinks(SaleLinePOS: Record "NPR Sale Line POS")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        //-NPR5.55 [399170]
        if IsNullGuid(SaleLinePOS."Retail ID") then
            exit;
        WaiterPadLine.SetRange("Sale Line Retail ID", SaleLinePOS."Retail ID");
        WaiterPadLine.ModifyAll("Sale Line Retail ID", GetNullGuid());
        //+NPR5.55 [399170]
    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnAfterDeleteEvent', '', true, false)]
    local procedure ClearWPadLinksOnSaleHdrDelete(var Rec: Record "NPR Sale POS"; RunTrigger: Boolean)
    begin
        //-NPR5.55 [399170]
        if not Rec.IsTemporary then
            ClearWPLineSaleHdrLinks(Rec);
        //+NPR5.55 [399170]
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, false)]
    local procedure ClearWPadLinksOnSaleLineDelete(var Rec: Record "NPR Sale Line POS"; RunTrigger: Boolean)
    begin
        //-NPR5.55 [399170]
        if not Rec.IsTemporary then
            ClearWPLineSaleLineLinks(Rec);
        //+NPR5.55 [399170]
    end;

    [EventSubscriber(ObjectType::Table, 6150661, 'OnAfterDeleteEvent', '', true, false)]
    local procedure DeleteWPadPOSInfoLink(var Rec: Record "NPR NPRE Waiter Pad Line"; RunTrigger: Boolean)
    var
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
    begin
        //-NPR5.53 [376538]
        with Rec do begin
            POSInfoWaiterPadLink.SetRange("Waiter Pad No.", "Waiter Pad No.");
            POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", "Line No.");
            if not POSInfoWaiterPadLink.IsEmpty then
                POSInfoWaiterPadLink.DeleteAll;
        end;
        //+NPR5.53 [376538]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSSalesLine', '', true, false)]
    local procedure UpdateBilledQtyOnPOSSalePost(SalePOS: Record "NPR Sale POS"; SaleLinePOS: Record "NPR Sale Line POS"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Sales Line")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        //-NPR5.55 [399170]
        if IsNullGuid(POSSalesLine."Retail ID") then
            exit;
        WaiterPadLine.SetRange("Sale Line Retail ID", POSSalesLine."Retail ID");
        if WaiterPadLine.FindFirst then begin
            if POSSalesLine."Quantity (Base)" <> 0 then begin
                if WaiterPadLine."Qty. per Unit of Measure" = POSSalesLine."Qty. per Unit of Measure" then
                    WaiterPadLine.Validate("Billed Quantity", WaiterPadLine."Billed Quantity" + POSSalesLine.Quantity)
                else
                    WaiterPadLine.Validate("Billed Qty. (Base)", WaiterPadLine."Billed Qty. (Base)" + POSSalesLine."Quantity (Base)");
                WaiterPadLine.Modify;
            end;

            if WaiterPad.Get(WaiterPadLine."Waiter Pad No.") then
                WaiterPadMgt.CloseWaiterPad(WaiterPad, false);
        end;
        //+NPR5.55 [399170]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151004, 'OnBeforeSaveAsQuote', '', true, false)]
    local procedure OnBeforeSaveAsPOSQuote(var SalePOS: Record "NPR Sale POS")
    begin
        //-NPR5.55 [399170]
        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then
            Error(CannotParkWPSale);
        //+NPR5.55 [399170]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151005, 'OnBeforeLoadFromPOSQuote', '', true, false)]
    local procedure OnBeforeLoadPOSQuote(var SalePOS: Record "NPR Sale POS"; var POSQuoteEntry: Record "NPR POS Quote Entry"; var XmlDoc: DotNet "NPRNetXmlDocument")
    begin
        //-NPR5.55 [399170]
        ClearSaleHdrNPREPresetFields(SalePOS, true);
        //+NPR5.55 [399170]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnAfterMoveSaleFromPosToWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        //NPR5.53 [380609]
    end;
}

