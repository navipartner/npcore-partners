codeunit 6151479 "NPR Move Entries"
{
    Access = Public;

    var
        EntriesInOpenFiscalYearErr: Label 'You cannot delete %1 %2 because it has POS entries in a fiscal year that has not been closed yet.', Comment = '%1 - entity (item/customer) table caption; %2 - entity number';
        ParkedPOSSaleTxt: Label 'parked (saved) POS sale';
        UnfinishedPOSSaleTxt: Label 'unfinished POS sale';
        UnfinishedWaiterPadTxt: Label 'unfinished waiter pad';
        UnpostedPOSEntryTxt: Label 'unposted POS entry';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MoveEntries, 'OnBeforeMoveItemEntries', '', false, false)]
    local procedure ItemCheckOpenEntries(Item: Record Item)
    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSSaleLine: Record "NPR POS Sale Line";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
        POSEntrywithSalesLines: Query "NPR POS Entry with Sales Lines";
        UnpostedPOSItemEntries: Query "NPR Unposted POS Item Entries";
        WaiterPadswithLines: Query "NPR Waiter Pads with Lines";
        OpenPeriodStartingDate: Date;
        EntriesFound: Boolean;
        UsedInTransErr: Label 'You cannot delete Item %1 because there is at least one %2 that includes this item.', Comment = '%1 - item number, %2 - transction/document type';
    begin
        POSSavedSaleLine.SetRange("Line Type", POSSavedSaleLine."Line Type"::Item);
        POSSavedSaleLine.SetRange("No.", Item."No.");
        if not POSSavedSaleLine.IsEmpty() then
            Error(UsedInTransErr, Item."No.", ParkedPOSSaleTxt);

        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetRange("No.", Item."No.");
        if not POSSaleLine.IsEmpty() then
            Error(UsedInTransErr, Item."No.", UnfinishedPOSSaleTxt);

        ItemWorksheetLine.SetRange("Existing Item No.", Item."No.");
        if not ItemWorksheetLine.IsEmpty() then
            Error(UsedInTransErr, Item."No.", ItemWorksheetLine.TableCaption());

        WaiterPadswithLines.SetRange(Closed, false);
        WaiterPadswithLines.SetRange(Type, Enum::"NPR POS Sale Line Type"::Item);
        WaiterPadswithLines.SetRange(No, Item."No.");
        WaiterPadswithLines.Open();
        if WaiterPadswithLines.Read() then
            Error(UsedInTransErr, Item."No.", UnfinishedWaiterPadTxt);

        UnpostedPosItemEntries.SetRange(Item_No, Item."No.");
        UnpostedPosItemEntries.Open();
        if UnpostedPosItemEntries.Read() then
            Error(UsedInTransErr, Item."No.", UnpostedPOSEntryTxt);

        OpenPeriodStartingDate := EarliestOpenAccountingPeriodStartingDate();

        if OpenPeriodStartingDate <> 0D then begin
            POSEntrywithSalesLines.SetFilter(Posting_Date, '>=%1', OpenPeriodStartingDate);
            POSEntrywithSalesLines.SetRange(Type, POSEntrywithSalesLines.Type::Item);
            POSEntrywithSalesLines.SetRange(No, Item."No.");
            POSEntrywithSalesLines.Open();
            EntriesFound := POSEntrywithSalesLines.Read();
        end else begin
            POSEntrySaleLine.SetRange(Type, POSEntrySaleLine.Type::Item);
            POSEntrySaleLine.SetRange("No.", Item."No.");
            EntriesFound := not POSEntrySaleLine.IsEmpty();
        end;
        if EntriesFound then
            Error(EntriesInOpenFiscalYearErr, Item.TableCaption(), Item."No.");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
    [EventSubscriber(ObjectType::Codeunit, Codeunit::MoveEntries, 'OnAfterMoveItemEntries', '', false, false)]
    local procedure UpdateItemNoInLedgerEntries(Item: Record Item; var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        ArchSaleLinePOS: Record "NPR Archive Sale Line POS";
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSSaleLine: Record "NPR POS Sale Line";
        RegistItemWorkshLine: Record "NPR Regist. Item Worksh Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        NewItemNo: Code[20];
    begin
        if ItemLedgerEntry.FindFirst() then
            NewItemNo := ItemLedgerEntry."Item No.";

        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetRange("No.", Item."No.");
        if not POSSaleLine.IsEmpty() then
            POSSaleLine.ModifyAll("No.", NewItemNo);

        ExternalPOSSaleLine.SetRange("Line Type", ExternalPOSSaleLine."Line Type"::Item);
        ExternalPOSSaleLine.SetRange("No.", Item."No.");
        if not ExternalPOSSaleLine.IsEmpty() then
            ExternalPOSSaleLine.ModifyAll("No.", NewItemNo);

        ArchSaleLinePOS.SetRange("Line Type", ArchSaleLinePOS."Line Type"::Item);
        ArchSaleLinePOS.SetRange("No.", Item."No.");
        if not ArchSaleLinePOS.IsEmpty() then
            ArchSaleLinePOS.ModifyAll("No.", NewItemNo);

        POSEntrySaleLine.SetRange(Type, POSEntrySaleLine.Type::Item);
        POSEntrySaleLine.SetRange("No.", Item."No.");
        if not POSEntrySaleLine.IsEmpty() then
            POSEntrySaleLine.ModifyAll("No.", NewItemNo);

        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        WaiterPadLine.SetRange("No.", Item."No.");
        if not WaiterPadLine.IsEmpty() then
            WaiterPadLine.ModifyAll("No.", NewItemNo);

        KitchenRequest.SetRange("Line Type", KitchenRequest."Line Type"::Item);
        KitchenRequest.SetRange("No.", Item."No.");
        if not KitchenRequest.IsEmpty() then
            KitchenRequest.ModifyAll("No.", NewItemNo);

        RegistItemWorkshLine.SetRange("Existing Item No.", Item."No.");
        if not RegistItemWorkshLine.IsEmpty() then
            RegistItemWorkshLine.ModifyAll("Existing Item No.", NewItemNo);
        RegistItemWorkshLine.SetRange("Existing Item No.");
        RegistItemWorkshLine.SetRange("Item No.", Item."No.");
        if not RegistItemWorkshLine.IsEmpty() then
            RegistItemWorkshLine.ModifyAll("Item No.", NewItemNo);
    end;

#else

    [EventSubscriber(ObjectType::Codeunit, Codeunit::MoveEntries, OnMoveItemEntriesOnAfterModifyItemLedgerEntries, '', false, false)]
    local procedure UpdateItemNoInLedgerEntries(Item: Record Item; NewItemNo: Code[20])
    var
        ArchSaleLinePOS: Record "NPR Archive Sale Line POS";
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSSaleLine: Record "NPR POS Sale Line";
        RegisterItemWorksheetLine: Record "NPR Regist. Item Worksh Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin

        if (Item."No." = '') or (NewItemNo = '') or (Item."No." = NewItemNo) then
            exit;

        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetRange("No.", Item."No.");
        if not POSSaleLine.IsEmpty() then
            POSSaleLine.ModifyAll("No.", NewItemNo);

        ExternalPOSSaleLine.SetRange("Line Type", ExternalPOSSaleLine."Line Type"::Item);
        ExternalPOSSaleLine.SetRange("No.", Item."No.");
        if not ExternalPOSSaleLine.IsEmpty() then
            ExternalPOSSaleLine.ModifyAll("No.", NewItemNo);

        ArchSaleLinePOS.SetRange("Line Type", ArchSaleLinePOS."Line Type"::Item);
        ArchSaleLinePOS.SetRange("No.", Item."No.");
        if not ArchSaleLinePOS.IsEmpty() then
            ArchSaleLinePOS.ModifyAll("No.", NewItemNo);

        POSEntrySaleLine.SetRange(Type, POSEntrySaleLine.Type::Item);
        POSEntrySaleLine.SetRange("No.", Item."No.");
        if not POSEntrySaleLine.IsEmpty() then
            POSEntrySaleLine.ModifyAll("No.", NewItemNo);

        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        WaiterPadLine.SetRange("No.", Item."No.");
        if not WaiterPadLine.IsEmpty() then
            WaiterPadLine.ModifyAll("No.", NewItemNo);

        KitchenRequest.SetRange("Line Type", KitchenRequest."Line Type"::Item);
        KitchenRequest.SetRange("No.", Item."No.");
        if not KitchenRequest.IsEmpty() then
            KitchenRequest.ModifyAll("No.", NewItemNo);

        RegisterItemWorksheetLine.SetRange("Existing Item No.", Item."No.");
        if not RegisterItemWorksheetLine.IsEmpty() then
            RegisterItemWorksheetLine.ModifyAll("Existing Item No.", NewItemNo);

        RegisterItemWorksheetLine.SetRange("Existing Item No.");
        RegisterItemWorksheetLine.SetRange("Item No.", Item."No.");
        if not RegisterItemWorksheetLine.IsEmpty() then
            RegisterItemWorksheetLine.ModifyAll("Item No.", NewItemNo);
    end;
#endif



    [EventSubscriber(ObjectType::Codeunit, Codeunit::MoveEntries, 'OnBeforeMoveCustEntries', '', false, false)]
    local procedure CustCheckOpenEntries(Customer: Record Customer)
    var
        Coupon: Record "NPR NpDc Coupon";
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSSavedSale: Record "NPR POS Saved Sale Entry";
        RetailJournalLine: Record "NPR Retail Journal Line";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Voucher: Record "NPR NpRv Voucher";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        OpenPeriodStartingDate: Date;
        AllowEntriesInClosedPeriods: Boolean;
        EntriesFound: Boolean;
        OpenTicketResReqTxt: Label 'open ticket reservation request';
        UsedInTransErr: Label 'You cannot delete Customer %1 because there is at least one %2 for this customer.', Comment = '%1 - customer number, %2 - transction/document type';
    begin
        OnCustCheckOpenEntries(Customer, AllowEntriesInClosedPeriods);

        POSSavedSale.SetRange("Customer No.", Customer."No.");
        if not POSSavedSale.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", ParkedPOSSaleTxt);

        POSSale.SetRange("Customer No.", Customer."No.");
        if not POSSale.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", UnfinishedPOSSaleTxt);

        Coupon.SetRange("Customer No.", Customer."No.");
        if not Coupon.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", Coupon.TableCaption());

        Voucher.SetRange("Customer No.", Customer."No.");
        if not Voucher.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", Voucher.TableCaption());

        RetailJournalLine.SetRange("Customer No.", Customer."No.");
        if not RetailJournalLine.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", RetailJournalLine.TableCaption());

        WaiterPad.SetRange("Customer No.", Customer."No.");
        WaiterPad.SetRange(Closed, false);
        if not WaiterPad.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", UnfinishedWaiterPadTxt);

        TicketReservationReq.SetRange("Customer No.", Customer."No.");
        if not TicketReservationReq.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", OpenTicketResReqTxt);

        OpenPeriodStartingDate := EarliestOpenAccountingPeriodStartingDate();

        Ticket.SetRange("Customer No.", Customer."No.");
        if AllowEntriesInClosedPeriods and (OpenPeriodStartingDate <> 0D) then
            Ticket.SetFilter("Valid To Date", '>=%1', OpenPeriodStartingDate);
        if not Ticket.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", Ticket.TableCaption());

        TicketAccessEntry.SetRange("Customer No.", Customer."No.");
        if AllowEntriesInClosedPeriods and (OpenPeriodStartingDate <> 0D) then
            TicketAccessEntry.SetFilter("Access Date", '>=%1', OpenPeriodStartingDate);
        if not TicketAccessEntry.IsEmpty() then
            Error(UsedInTransErr, Customer."No.", TicketAccessEntry.TableCaption());

        POSEntry.SetRange("Customer No.", Customer."No.");
        if not AllowEntriesInClosedPeriods then
            if not POSEntry.IsEmpty() then
                Error(UsedInTransErr, Customer."No.", POSEntry.TableCaption());

        POSEntry.SetFilter("Post Item Entry Status", '%1|%2', POSEntry."Post Item Entry Status"::Unposted, POSEntry."Post Item Entry Status"::"Error while Posting");
        EntriesFound := not POSEntry.IsEmpty();
        POSEntry.SetRange("Post Item Entry Status");
        if not EntriesFound then begin
            POSEntry.SetFilter("Post Entry Status", '%1|%2', POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
            EntriesFound := not POSEntry.IsEmpty();
            POSEntry.SetRange("Post Entry Status");
        end;
        if EntriesFound then
            Error(UsedInTransErr, Customer."No.", UnpostedPOSEntryTxt);

        if OpenPeriodStartingDate <> 0D then
            POSEntry.SetFilter("Posting Date", '>=%1', OpenPeriodStartingDate);
        if not POSEntry.IsEmpty() then
            Error(EntriesInOpenFiscalYearErr, Customer.TableCaption(), Customer."No.");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
    [EventSubscriber(ObjectType::Codeunit, Codeunit::MoveEntries, 'OnAfterMoveCustEntries', '', false, false)]
    local procedure UpdateCustNoInLedgerEntries(Customer: Record Customer; var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        ArchCoupon: Record "NPR NpDc Arch. Coupon";
        ArchSalePOS: Record "NPR Archive Sale POS";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ExternalPOSSale: Record "NPR External POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        NewCustNo: Code[20];
    begin
        if CustLedgerEntry.FindFirst() then
            NewCustNo := CustLedgerEntry."Customer No.";

        ExternalPOSSale.SetRange("Customer No.", Customer."No.");
        if not ExternalPOSSale.IsEmpty() then
            ExternalPOSSale.ModifyAll("Customer No.", NewCustNo);

        ArchSalePOS.SetRange("Customer No.", Customer."No.");
        if not ArchSalePOS.IsEmpty() then
            ArchSalePOS.ModifyAll("Customer No.", NewCustNo);

        ArchCoupon.SetRange("Customer No.", Customer."No.");
        if not ArchCoupon.IsEmpty() then
            ArchCoupon.ModifyAll("Customer No.", NewCustNo);

        ArchVoucher.SetRange("Customer No.", Customer."No.");
        if not ArchVoucher.IsEmpty() then
            ArchVoucher.ModifyAll("Customer No.", NewCustNo);

        Ticket.SetRange("Customer No.", Customer."No.");
        if not Ticket.IsEmpty() then
            Ticket.ModifyAll("Customer No.", NewCustNo);

        TicketAccessEntry.SetRange("Customer No.", Customer."No.");
        if not TicketAccessEntry.IsEmpty() then
            TicketAccessEntry.ModifyAll("Customer No.", NewCustNo);

        WaiterPad.SetRange("Customer No.", Customer."No.");
        if not WaiterPad.IsEmpty() then
            WaiterPad.ModifyAll("Customer No.", NewCustNo);

        POSEntry.SetRange("Customer No.", Customer."No.");
        if not POSEntry.IsEmpty() then
            POSEntry.ModifyAll("Customer No.", NewCustNo);

        POSEntrySaleLine.SetRange("Customer No.", Customer."No.");
        if not POSEntrySaleLine.IsEmpty() then
            POSEntrySaleLine.ModifyAll("Customer No.", NewCustNo);
    end;
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::MoveEntries, OnMoveCustEntriesOnAfterModifyCustLedgEntries, '', false, false)]
    local procedure UpdateCustNoInLedgerEntries(Customer: Record Customer; NewCustNo: Code[20])
    var
        ArchCoupon: Record "NPR NpDc Arch. Coupon";
        ArchSalePOS: Record "NPR Archive Sale POS";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ExternalPOSSale: Record "NPR External POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        if (Customer."No." = '') or (NewCustNo = '') or (Customer."No." = NewCustNo) then
            exit;

        ExternalPOSSale.SetRange("Customer No.", Customer."No.");
        if not ExternalPOSSale.IsEmpty() then
            ExternalPOSSale.ModifyAll("Customer No.", NewCustNo);

        ArchSalePOS.SetRange("Customer No.", Customer."No.");
        if not ArchSalePOS.IsEmpty() then
            ArchSalePOS.ModifyAll("Customer No.", NewCustNo);

        ArchCoupon.SetRange("Customer No.", Customer."No.");
        if not ArchCoupon.IsEmpty() then
            ArchCoupon.ModifyAll("Customer No.", NewCustNo);

        ArchVoucher.SetRange("Customer No.", Customer."No.");
        if not ArchVoucher.IsEmpty() then
            ArchVoucher.ModifyAll("Customer No.", NewCustNo);

        Ticket.SetRange("Customer No.", Customer."No.");
        if not Ticket.IsEmpty() then
            Ticket.ModifyAll("Customer No.", NewCustNo);

        TicketAccessEntry.SetRange("Customer No.", Customer."No.");
        if not TicketAccessEntry.IsEmpty() then
            TicketAccessEntry.ModifyAll("Customer No.", NewCustNo);

        WaiterPad.SetRange("Customer No.", Customer."No.");
        if not WaiterPad.IsEmpty() then
            WaiterPad.ModifyAll("Customer No.", NewCustNo);

        POSEntry.SetRange("Customer No.", Customer."No.");
        if not POSEntry.IsEmpty() then
            POSEntry.ModifyAll("Customer No.", NewCustNo);

        POSEntrySaleLine.SetRange("Customer No.", Customer."No.");
        if not POSEntrySaleLine.IsEmpty() then
            POSEntrySaleLine.ModifyAll("Customer No.", NewCustNo);
    end;
#endif

    local procedure EarliestOpenAccountingPeriodStartingDate(): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.IsEmpty() then
            exit(0D);

        AccountingPeriod.SetRange(Closed, false);
        AccountingPeriod.FindFirst();
        exit(AccountingPeriod."Starting Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCustCheckOpenEntries(Customer: Record Customer; var AllowEntriesInClosedPeriods: Boolean)
    begin
    end;
}