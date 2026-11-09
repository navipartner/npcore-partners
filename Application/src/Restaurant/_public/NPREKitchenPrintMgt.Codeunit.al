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

    procedure GetPrintHeader(POSEntry: Record "NPR POS Entry"; IncludeReceiptLogo: Boolean; var RestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary)
    var
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        WaiterPadNo: Code[20];
    begin
        POSEntryWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryWaiterPadLink.SetLoadFields("Waiter Pad No.");
        if POSEntryWaiterPadLink.FindFirst() then
            WaiterPadNo := POSEntryWaiterPadLink."Waiter Pad No.";
        GetPrintHeader(WaiterPadNo, IncludeReceiptLogo, RestaurantPrintHeader);
    end;

    internal procedure GetKitchenOrderIds(POSEntryNo: Integer; var KitchenOrderIds: List of [BigInteger])
    var
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        VisitedWaiterPadLines: List of [Text];
        WaiterPadLineKey: Text;
    begin
        Clear(KitchenOrderIds);

        POSEntryWaiterPadLink.SetRange("POS Entry No.", POSEntryNo);
        POSEntryWaiterPadLink.SetLoadFields("Waiter Pad No.", "Waiter Pad Line No.");
        if not POSEntryWaiterPadLink.FindSet() then
            exit;

        repeat
            WaiterPadLineKey := StrSubstNo('%1:%2', POSEntryWaiterPadLink."Waiter Pad No.", POSEntryWaiterPadLink."Waiter Pad Line No.");
            if not VisitedWaiterPadLines.Contains(WaiterPadLineKey) then begin
                VisitedWaiterPadLines.Add(WaiterPadLineKey);
                AddKitchenOrderIdsOfWaiterPadLine(POSEntryWaiterPadLink."Waiter Pad No.", POSEntryWaiterPadLink."Waiter Pad Line No.", KitchenOrderIds);
            end;
        until POSEntryWaiterPadLink.Next() = 0;
    end;

    internal procedure GetKitchenOrderId(POSEntryNo: Integer; var KitchenOrderSystemId: Guid): BigInteger
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenOrderIds: List of [BigInteger];
        KitchenOrderId: BigInteger;
    begin
        Clear(KitchenOrderSystemId);

        GetKitchenOrderIds(POSEntryNo, KitchenOrderIds);
        if KitchenOrderIds.Count() = 0 then
            exit(0);

        KitchenOrderId := KitchenOrderIds.Get(1);
        if KitchenOrder.Get(KitchenOrderId) then
            KitchenOrderSystemId := KitchenOrder.SystemId;
        exit(KitchenOrderId);
    end;

    local procedure AddKitchenOrderIdsOfWaiterPadLine(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; var KitchenOrderIds: List of [BigInteger])
    var
        KitchenReqSrcLink: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        KitchenReqSrcLink.SetCurrentKey(
            "Source Document Type", "Source Document Subtype", "Source Document No.", "Source Document Line No.", "Serving Step", "Request No.");
        KitchenReqSrcLink.SetRange("Source Document Type", KitchenReqSrcLink."Source Document Type"::"Waiter Pad");
        KitchenReqSrcLink.SetRange("Source Document Subtype", 0);
        KitchenReqSrcLink.SetRange("Source Document No.", WaiterPadNo);
        KitchenReqSrcLink.SetRange("Source Document Line No.", WaiterPadLineNo);
        KitchenReqSrcLink.SetLoadFields("Request No.");
        if not KitchenReqSrcLink.FindSet() then
            exit;

        KitchenRequest.SetLoadFields("Order ID", "Line Status");
        repeat
            if KitchenRequest.Get(KitchenReqSrcLink."Request No.") then
                if (KitchenRequest."Order ID" <> 0) and
                   (KitchenRequest."Line Status" <> KitchenRequest."Line Status"::Cancelled) and
                   not KitchenOrderIds.Contains(KitchenRequest."Order ID")
                then
                    KitchenOrderIds.Add(KitchenRequest."Order ID");
        until KitchenReqSrcLink.Next() = 0;
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

    internal procedure MergeIdenticalLines(var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary)
    var
        FirstPlainLineEntryNos: Dictionary of [Text, Integer];
        PlainLineEntryNos: List of [Integer];
        EntryNo: Integer;
        FirstEntryNo: Integer;
        AddedQuantity: Decimal;
        AddedAmountExclVAT: Decimal;
        AddedAmountInclVAT: Decimal;
        LineKey: Text;
    begin
        //Only dishes with no add-on and no comment are bulked. A customised dish keeps its own line at its real quantity,
        //so the kitchen never has to read a combined add-on quantity off a bulked line (is "2 x cheese" two per burger or
        //two in total?). Repeated plain items - the main source of over-long tickets - still collapse to one line.
        CollectPlainMainLineEntryNos(WPadLineOutBuffer, PlainLineEntryNos);

        foreach EntryNo in PlainLineEntryNos do begin
            WPadLineOutBuffer.Get(EntryNo);
            LineKey := StrSubstNo('%1|%2|%3|%4', WPadLineOutBuffer."No.", WPadLineOutBuffer."Variant Code", WPadLineOutBuffer."Unit of Measure Code", WPadLineOutBuffer.Description);
            if FirstPlainLineEntryNos.Get(LineKey, FirstEntryNo) then begin
                AddedQuantity := WPadLineOutBuffer.Quantity;
                AddedAmountExclVAT := WPadLineOutBuffer."Amount Excl. VAT";
                AddedAmountInclVAT := WPadLineOutBuffer."Amount Incl. VAT";
                WPadLineOutBuffer.Delete();
                WPadLineOutBuffer.Get(FirstEntryNo);
                WPadLineOutBuffer.Quantity += AddedQuantity;
                WPadLineOutBuffer."Amount Excl. VAT" += AddedAmountExclVAT;
                WPadLineOutBuffer."Amount Incl. VAT" += AddedAmountInclVAT;
                WPadLineOutBuffer.Modify();
            end else
                FirstPlainLineEntryNos.Add(LineKey, EntryNo);
        end;
    end;

    internal procedure GetLatestKDSOrderIDsFromSendLog(var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary) KitchenOrderIDs: List of [BigInteger]
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        //Distinct from GetKitchenOrderIds(POSEntryNo): this reads the latest KDS order each dispatched line was sent as, from
        //the print log, for the kitchen ticket header. The POS-entry overload reads kitchen requests for the sales receipt.
        if not WPadLineOutBuffer.FindSet() then
            exit;

        WPadLinePrintLogEntry.SetRange("Output Type", WPadLinePrintLogEntry."Output Type"::KDS);
        WPadLinePrintLogEntry.SetFilter("Kitchen Order ID", '<>%1', 0);
        WPadLinePrintLogEntry.SetLoadFields("Kitchen Order ID");
        repeat
            WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WPadLineOutBuffer."Waiter Pad No.");
            WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", WPadLineOutBuffer."Waiter Pad Line No.");
            if WPadLinePrintLogEntry.FindLast() then
                if not KitchenOrderIDs.Contains(WPadLinePrintLogEntry."Kitchen Order ID") then
                    KitchenOrderIDs.Add(WPadLinePrintLogEntry."Kitchen Order ID");
        until WPadLineOutBuffer.Next() = 0;
    end;

    internal procedure GetKitchenStationDescriptions(var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary) KitchenStationDescriptions: List of [Text]
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenStation: Record "NPR NPRE Kitchen Station";
        ProcessedRequests: List of [BigInteger];
        KitchenStationDescription: Text;
    begin
        //Stations are read from the kitchen requests the dispatched lines created, not from the config-based resolver (which
        //does a bare Seating.Get that errors on the print path if the seating was deleted while the pad was still linked).
        //When the print job is split by serving step the lookup is narrowed to that step, so a starter ticket does not also
        //list a later course's station. A print-only restaurant creates no requests and gets no station line.
        if not WPadLineOutBuffer.FindSet() then
            exit;

        //Constant filters and the key are set once so the per-line read seeks on the full key. Source Document Subtype is
        //always 0 for a waiter pad (InitSource writes 0); without it SQL cannot seek past Source Document Type.
        KitchenReqSourceLink.SetCurrentKey("Source Document Type", "Source Document Subtype", "Source Document No.", "Source Document Line No.", "Serving Step", "Request No.");
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document Subtype", 0);
        KitchenReqSourceLink.SetLoadFields("Request No.");
        KitchenRequestStation.SetLoadFields("Production Restaurant Code", "Kitchen Station");
        KitchenStation.SetLoadFields(Description);
        repeat
            KitchenReqSourceLink.SetRange("Source Document No.", WPadLineOutBuffer."Waiter Pad No.");
            KitchenReqSourceLink.SetRange("Source Document Line No.", WPadLineOutBuffer."Waiter Pad Line No.");
            if WPadLineOutBuffer."Serving Step" <> '' then
                KitchenReqSourceLink.SetRange("Serving Step", WPadLineOutBuffer."Serving Step")
            else
                KitchenReqSourceLink.SetRange("Serving Step");
            if KitchenReqSourceLink.FindSet() then
                repeat
                    if not ProcessedRequests.Contains(KitchenReqSourceLink."Request No.") then begin
                        ProcessedRequests.Add(KitchenReqSourceLink."Request No.");
                        KitchenRequestStation.SetRange("Request No.", KitchenReqSourceLink."Request No.");
                        if KitchenRequestStation.FindSet() then
                            repeat
                                if KitchenStation.Get(KitchenRequestStation."Production Restaurant Code", KitchenRequestStation."Kitchen Station") then begin
                                    KitchenStationDescription := KitchenStation.Description;
                                    if KitchenStationDescription = '' then
                                        KitchenStationDescription := KitchenRequestStation."Kitchen Station";
                                    if not KitchenStationDescriptions.Contains(KitchenStationDescription) then
                                        KitchenStationDescriptions.Add(KitchenStationDescription);
                                end;
                            until KitchenRequestStation.Next() = 0;
                    end;
                until KitchenReqSourceLink.Next() = 0;
        until WPadLineOutBuffer.Next() = 0;
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

    local procedure CollectPlainMainLineEntryNos(var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary; var PlainLineEntryNos: List of [Integer])
    var
        MainLineNosWithAddOn: List of [Integer];
        CurrentMainEntryNo: Integer;
        CurrentMainWaiterPadLineNo: Integer;
        CurrentMainQuantity: Decimal;
        CurrentMainHasComment: Boolean;
    begin
        //First pass: which main lines carry an add-on, matched by "Attached to Line No." rather than by print order. Split-bill
        //moves all main lines to the top of the pad and appends the add-on lines at the end, so an add-on is not always printed
        //directly below its dish; relying on adjacency would misread such a pad and bulk a customised dish.
        WPadLineOutBuffer.Reset();
        if WPadLineOutBuffer.FindSet() then
            repeat
                if (WPadLineOutBuffer."Attached to Line No." <> 0) and not MainLineNosWithAddOn.Contains(WPadLineOutBuffer."Attached to Line No.") then
                    MainLineNosWithAddOn.Add(WPadLineOutBuffer."Attached to Line No.");
            until WPadLineOutBuffer.Next() = 0;

        //Second pass: a main line is plain when it has no add-on and no comment. Comment lines carry no attachment link, so
        //they are matched to the main line printed above them.
        WPadLineOutBuffer.Reset();
        if not WPadLineOutBuffer.FindSet() then
            exit;
        repeat
            if (WPadLineOutBuffer."Attached to Line No." = 0) and (WPadLineOutBuffer."Line Type" = WPadLineOutBuffer."Line Type"::Item) then begin
                AddPlainMainLineEntryNo(CurrentMainEntryNo, CurrentMainWaiterPadLineNo, CurrentMainQuantity, CurrentMainHasComment, MainLineNosWithAddOn, PlainLineEntryNos);
                CurrentMainEntryNo := WPadLineOutBuffer."Entry No.";
                CurrentMainWaiterPadLineNo := WPadLineOutBuffer."Waiter Pad Line No.";
                CurrentMainQuantity := WPadLineOutBuffer.Quantity;
                CurrentMainHasComment := false;
            end else
                if (WPadLineOutBuffer."Line Type" = WPadLineOutBuffer."Line Type"::Comment) and (CurrentMainEntryNo <> 0) then
                    CurrentMainHasComment := true;
        until WPadLineOutBuffer.Next() = 0;
        AddPlainMainLineEntryNo(CurrentMainEntryNo, CurrentMainWaiterPadLineNo, CurrentMainQuantity, CurrentMainHasComment, MainLineNosWithAddOn, PlainLineEntryNos);
    end;

    local procedure AddPlainMainLineEntryNo(MainEntryNo: Integer; MainWaiterPadLineNo: Integer; MainQuantity: Decimal; HasComment: Boolean; MainLineNosWithAddOn: List of [Integer]; var PlainLineEntryNos: List of [Integer])
    begin
        if MainEntryNo = 0 then
            exit;
        //A line reduced to zero or below (a removed line kept as a zero-quantity cancellation, or a reversal) must keep its own
        //line so the kitchen still sees the cancellation; bulking it would net it off against a new line of the same item.
        if MainQuantity <= 0 then
            exit;
        if HasComment then
            exit;
        if MainLineNosWithAddOn.Contains(MainWaiterPadLineNo) then
            exit;
        PlainLineEntryNos.Add(MainEntryNo);
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
