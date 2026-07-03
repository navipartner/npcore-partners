codeunit 6151178 "NPR NPRE Kitchen Print Mgt"
{
    Access = Public;

    procedure GetPrintHeader(WaiterPadNo: Code[20]; IncludeReceiptLogo: Boolean; var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        Clear(RestaurantPrintHeader);

        RestaurantPrintHeader.Init();
        RestaurantPrintHeader."Waiter Pad No." := WaiterPadNo;
        RestaurantPrintHeader."Print Date Time" := CurrentDateTime();

        if not WaiterPad.Get(WaiterPadNo) then
            exit;

        RestaurantPrintHeader."Number of Guests" := WaiterPad."Number of Guests";
        RestaurantPrintHeader."Customer No." := WaiterPad."Customer No.";
        RestaurantPrintHeader."Customer Phone No." := WaiterPad."Customer Phone No.";
        RestaurantPrintHeader."Waiter Pad Description" := CopyStr(WaiterPad.Description, 1, MaxStrLen(RestaurantPrintHeader."Waiter Pad Description"));
        SetWaiterInfo(WaiterPad, RestaurantPrintHeader);
        SetCustomerInfo(WaiterPad, RestaurantPrintHeader);
        SetSeatingInfo(WaiterPadNo, RestaurantPrintHeader);
        SetTotals(WaiterPadNo, RestaurantPrintHeader);
        if IncludeReceiptLogo then
            SetReceiptLogo(RestaurantPrintHeader);
    end;

    procedure GetRelatedPOSEntries(WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer"; var POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
    begin
        POSEntry.Reset();
        POSEntryWaiterPadLink.SetCurrentKey("Waiter Pad No.", "Waiter Pad Line No.");
        POSEntryWaiterPadLink.SetRange("Waiter Pad No.", WPadLineOutBuffer."Waiter Pad No.");
        POSEntryWaiterPadLink.SetRange("Waiter Pad Line No.", WPadLineOutBuffer."Waiter Pad Line No.");
        POSEntryWaiterPadLink.SetLoadFields("POS Entry No.");
        if not POSEntryWaiterPadLink.FindSet() then
            exit(false);

        repeat
            POSEntry."Entry No." := POSEntryWaiterPadLink."POS Entry No.";
            POSEntry.Mark(true);
        until POSEntryWaiterPadLink.Next() = 0;

        POSEntry.MarkedOnly(true);
        exit(true);
    end;

    procedure GetPrintLines(WaiterPadNo: Code[20]; var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary)
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        EntryNo: Integer;
    begin
        WPadLineOutBuffer.Reset();
        WPadLineOutBuffer.DeleteAll();

        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        if not WaiterPadLine.FindSet() then
            exit;
        repeat
            EntryNo += 1;
            WPadLineOutBuffer.Init();
            WPadLineOutBuffer."Entry No." := EntryNo;
            WPadLineOutBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
            WPadLineOutBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
            FillLineData(WaiterPadLine, '', '', WPadLineOutBuffer);
            WPadLineOutBuffer.Insert();
        until WaiterPadLine.Next() = 0;
    end;

    procedure GetPrintLines(var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary)
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        PrintCategoryCode: Code[20];
        ServingStep: Code[10];
        EntryNo: Integer;
    begin
        if not WPadLineOutBuffer.FindSet() then
            exit;

        PrintCategoryCode := WPadLineOutBuffer."Print Category Code";
        ServingStep := WPadLineOutBuffer."Serving Step";

        repeat
            if WaiterPadLine.Get(WPadLineOutBuffer."Waiter Pad No.", WPadLineOutBuffer."Waiter Pad Line No.") then begin
                WaiterPadLine.Mark(true);
                AddComments(WaiterPadLine);
            end;
        until WPadLineOutBuffer.Next() = 0;

        WaiterPadLine.MarkedOnly(true);

        WPadLineOutBuffer.Reset();
        WPadLineOutBuffer.DeleteAll();

        if not WaiterPadLine.FindSet() then
            exit;
        repeat
            EntryNo += 1;
            WPadLineOutBuffer.Init();
            WPadLineOutBuffer."Entry No." := EntryNo;
            WPadLineOutBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
            WPadLineOutBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
            WPadLineOutBuffer."Print Category Code" := PrintCategoryCode;
            WPadLineOutBuffer."Serving Step" := ServingStep;
            FillLineData(WaiterPadLine, PrintCategoryCode, ServingStep, WPadLineOutBuffer);
            WPadLineOutBuffer.Insert();
        until WaiterPadLine.Next() = 0;
    end;

    internal procedure AddComments(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        WaiterPadLine2: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine2.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
        WaiterPadLine2 := WaiterPadLine;
        while (WaiterPadLine2.Next() <> 0) and (WaiterPadLine2."Line Type" = WaiterPadLine2."Line Type"::Comment) do begin
            WaiterPadLine := WaiterPadLine2;
            WaiterPadLine.Mark := true;
        end;
    end;

    local procedure FillLineData(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintCategoryCode: Code[20]; ServingStep: Code[10]; var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary)
    begin
        if WaiterPadLine."Line Type" = WaiterPadLine."Line Type"::Comment then
            WPadLineOutBuffer."Line Type" := WPadLineOutBuffer."Line Type"::Comment
        else
            WPadLineOutBuffer."Line Type" := WPadLineOutBuffer."Line Type"::Item;
        WPadLineOutBuffer."No." := WaiterPadLine."No.";
        WPadLineOutBuffer.Description := WaiterPadLine.Description;
        WPadLineOutBuffer.Quantity := WaiterPadLine.Quantity;
        WPadLineOutBuffer."Variant Code" := WaiterPadLine."Variant Code";
        WPadLineOutBuffer."Unit of Measure Code" := WaiterPadLine."Unit of Measure Code";
        WPadLineOutBuffer."Attached to Line No." := WaiterPadLine."Attached to Line No.";
        WPadLineOutBuffer.Indentation := WaiterPadLine.Indentation;
        WPadLineOutBuffer."Print Category Code" := PrintCategoryCode;
        WPadLineOutBuffer."Serving Step" := ServingStep;
        WPadLineOutBuffer."Amount Excl. VAT" := WaiterPadLine."Amount Excl. VAT";
        WPadLineOutBuffer."Amount Incl. VAT" := WaiterPadLine."Amount Incl. VAT";
    end;

    local procedure SetWaiterInfo(WaiterPad: Record "NPR NPRE Waiter Pad"; var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        RestaurantPrintHeader."Waiter Code" := WaiterPad."Assigned Waiter Code";
        if SalespersonPurchaser.Get(WaiterPad."Assigned Waiter Code") then
            RestaurantPrintHeader."Waiter Name" := CopyStr(SalespersonPurchaser.Name, 1, MaxStrLen(RestaurantPrintHeader."Waiter Name"));
    end;

    local procedure SetCustomerInfo(WaiterPad: Record "NPR NPRE Waiter Pad"; var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        Customer: Record Customer;
    begin
        if Customer.Get(WaiterPad."Customer No.") then
            RestaurantPrintHeader."Customer Name" := CopyStr(Customer.Name, 1, MaxStrLen(RestaurantPrintHeader."Customer Name"));
    end;

    local procedure SetSeatingInfo(WaiterPadNo: Code[20]; var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SeatWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);
        SeatWaiterPadLink.SetRange(Primary, true);
        if not SeatWaiterPadLink.FindFirst() then begin
            SeatWaiterPadLink.SetRange(Primary);
            if not SeatWaiterPadLink.FindFirst() then
                exit;
        end;

        if not Seating.Get(SeatWaiterPadLink."Seating Code") then
            exit;

        RestaurantPrintHeader."Seating Code" := Seating.Code;
        RestaurantPrintHeader."Seating No." := CopyStr(Seating."Seating No.", 1, MaxStrLen(RestaurantPrintHeader."Seating No."));
        RestaurantPrintHeader."Seating Location" := Seating."Seating Location";
        RestaurantPrintHeader."Seating Description" := CopyStr(Seating.Description, 1, MaxStrLen(RestaurantPrintHeader."Seating Description"));

        if SeatingLocation.Get(Seating."Seating Location") then begin
            RestaurantPrintHeader."Restaurant Code" := SeatingLocation."Restaurant Code";
            SetStoreInfo(SeatingLocation."POS Store", RestaurantPrintHeader);
        end;
    end;

    local procedure SetStoreInfo(POSStoreCode: Code[10]; var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        POSStore: Record "NPR POS Store";
    begin
        if not POSStore.Get(POSStoreCode) then
            exit;
        RestaurantPrintHeader."Store Address" := POSStore.Address;
        RestaurantPrintHeader."Store Post Code" := POSStore."Post Code";
        RestaurantPrintHeader."Store City" := POSStore.City;
        RestaurantPrintHeader."Store Phone No." := POSStore."Phone No.";
        RestaurantPrintHeader."Store VAT Registration No." := POSStore."VAT Registration No.";
    end;

    local procedure SetTotals(WaiterPadNo: Code[20]; var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.CalcSums("Amount Excl. VAT", "Amount Incl. VAT");
        RestaurantPrintHeader."Total Amount Excl. VAT" := WaiterPadLine."Amount Excl. VAT";
        RestaurantPrintHeader."Total Amount Incl. VAT" := WaiterPadLine."Amount Incl. VAT";
    end;

    local procedure SetReceiptLogo(var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        RetailLogo: Record "NPR Retail Logo";
        POSUnit: Record "NPR POS Unit";
    begin
        RetailLogo.SetRange("Register No.", POSUnit.GetCurrentPOSUnit());
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        RestaurantPrintHeader."Has Receipt Logo" := not RetailLogo.IsEmpty();
    end;
}
