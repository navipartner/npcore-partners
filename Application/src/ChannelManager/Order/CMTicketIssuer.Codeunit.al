codeunit 6151055 "NPR CMTicketIssuer"
{
    Access = Internal;

    internal procedure ReshapeToTicketImport(
        var Order: Record "NPR CMOrder";
        var JobId: Code[40];
        var TempImportHeader: Record "NPR TM ImportTicketHeader" temporary;
        var TempImportLine: Record "NPR TM ImportTicketLine" temporary;
        var TempOrderWallet: Record "NPR CMOrderWallet" temporary)
    begin
        TempImportHeader.DeleteAll();
        TempImportLine.DeleteAll();
        JobId := NewJobId();

        BuildTicketImportHeader(Order, JobId, TempImportHeader);
        BuildTicketImportLines(Order, TempOrderWallet, JobId, TempImportLine);
    end;

    internal procedure RunTicketImport(
        JobId: Code[40];
        var TempImportHeader: Record "NPR TM ImportTicketHeader" temporary;
        var TempImportLine: Record "NPR TM ImportTicketLine" temporary;
        var FailureMessage: Text): Boolean
    var
        ImportTicket: Codeunit "NPR TM ImportTicketWorker";
    begin
        ClearLastError();
        ImportTicket.SetImportBuffer(TempImportHeader, TempImportLine);
        if (not ImportTicket.Run()) then begin
            FailureMessage := GetLastErrorText();
            ImportTicket.CleanUpFailedImport(JobId);
            exit(false);
        end;

        // TODO: Capacity hold for draft tickets.
        //   Mirror the tour-reservation override at TMTicketBOM.Page.al MakeTourTicket
        //   lines 426-434: close DetTicketAccessEntry rows of type INITIAL_ENTRY so unpaid
        //   draft tickets count toward admission capacity. The "Initial Entry" flow field
        //   on Admission Schedule Entry only sums closed entries — without this override a
        //   draft order does not hold capacity until ConfirmOrder runs and FinalizePayment
        //   closes the rows naturally.
        //   Open question: should CM drafts hold capacity at all, or only once confirmed?
        //   Capacity-limited interactions with OTA/CM partners are non-trivial — settle the
        //   policy with stakeholders before implementing. Until then a stale draft sitting
        //   for more than a few hours is the operational worry, not capacity double-booking.

        exit(true);
    end;

    internal procedure AttachTicketsToWallet(JobId: Code[40]; WalletEntryNo: Integer; LineNo: Integer; SeqNo: Integer)
    var
        WalletFacade: Codeunit "NPR AttractionWallet";
        TicketIds: List of [Guid];
        Token: Text[100];
    begin
        Token := GetTokenForJobId(JobId);
        CollectTicketIdsForWallet(Token, LineNo, SeqNo, TicketIds);
        if (TicketIds.Count() > 0) then
            WalletFacade.AddTicketsToWallet(WalletEntryNo, TicketIds);
    end;

    internal procedure ConfirmTickets(var Order: Record "NPR CMOrder")
    var
        ImportHeader: Record "NPR TM ImportTicketHeader";
        Token: Text[100];
        MissingJobErr: Label 'Order %1 has no JobId. This is a programming bug.';
        MissingImportHeaderErr: Label 'Import header for JobId %1 not found. This is a programming bug.';
    begin
        if (Order.JobId = '') then
            Error(MissingJobErr, Format(Order.OrderId, 0, 4));

        ImportHeader.SetCurrentKey(JobId);
        ImportHeader.SetFilter(JobId, '=%1', Order.JobId);
        ImportHeader.SetLoadFields(TicketRequestToken);
        if (not ImportHeader.FindFirst()) then
            Error(MissingImportHeaderErr, Order.JobId);

        Token := ImportHeader.TicketRequestToken;

        ConfirmReservationsForToken(Token, Order);
    end;

    local procedure ConfirmReservationsForToken(Token: Text[100]; var Order: Record "NPR CMOrder")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseCode: Code[10];
        ResponseMessage: Text;
    begin

        if (Token = '') then
            exit;

        TicketRequestManager.SetReservationRequestExtraInfo(Token, Order.SellToEmail, Order.DocumentNo, Order.SellToName, Order.SellToLanguage);

        if (not TicketRequestManager.ConfirmReservationRequest(Token, 0, ResponseCode, ResponseMessage)) then
            Error(ResponseMessage);
    end;

    internal procedure DeleteTicketImportJob(JobId: Code[40])
    var
        ImportHeader: Record "NPR TM ImportTicketHeader";
        Token: Text[100];
    begin
        if (JobId = '') then
            exit;

        ImportHeader.SetCurrentKey(JobId);
        ImportHeader.SetFilter(JobId, '=%1', JobId);
        ImportHeader.SetLoadFields(OrderId, JobId, TicketRequestToken);
        if (not ImportHeader.FindFirst()) then
            exit;
        Token := ImportHeader.TicketRequestToken;

        PatchConfirmedReservationsToCancelled(Token);
        DeleteReservationsByToken(Token);

        DeleteImportArchiveLinesByJobId(JobId);
        DeleteImportArchiveHeaderByJobId(JobId);
    end;

    local procedure PatchConfirmedReservationsToCancelled(Token: Text[100])
    var
        Request: Record "NPR TM Ticket Reservation Req.";
        InnerRequest: Record "NPR TM Ticket Reservation Req.";
        EntryNos: List of [Integer];
        EntryNo: Integer;
    begin
        Request.SetCurrentKey("Session Token ID");
        Request.SetFilter("Session Token ID", '=%1', Token);
        Request.SetFilter("Request Status", '=%1', Request."Request Status"::CONFIRMED);
        Request.SetLoadFields("Entry No.");
        if (Request.FindSet()) then
            repeat
                EntryNos.Add(Request."Entry No.");
            until (Request.Next() = 0);

        foreach EntryNo in EntryNos do
            if (InnerRequest.Get(EntryNo)) then begin
                InnerRequest."Request Status" := InnerRequest."Request Status"::CANCELED;
                InnerRequest.Modify();
            end;
    end;

    local procedure DeleteReservationsByToken(Token: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.DeleteReservationRequest(Token, true);
    end;

    local procedure DeleteImportArchiveLinesByJobId(JobId: Code[40])
    var
        Line: Record "NPR TM ImportTicketLine";
        InnerLine: Record "NPR TM ImportTicketLine";
        TempKeys: Record "NPR TM ImportTicketLine" temporary;
    begin
        Line.SetCurrentKey(JobId);
        Line.SetFilter(JobId, '=%1', JobId);
        Line.SetLoadFields(OrderId, JobId, PreAssignedTicketNumber);
        if (Line.FindSet()) then
            repeat
                TempKeys := Line;
                TempKeys.Insert();
            until (Line.Next() = 0);

        TempKeys.Reset();
        if (TempKeys.FindSet()) then
            repeat
                if (InnerLine.Get(TempKeys.OrderId, TempKeys.JobId, TempKeys.PreAssignedTicketNumber)) then
                    InnerLine.Delete(false);
            until (TempKeys.Next() = 0);
    end;

    local procedure DeleteImportArchiveHeaderByJobId(JobId: Code[40])
    var
        Header: Record "NPR TM ImportTicketHeader";
        InnerHeader: Record "NPR TM ImportTicketHeader";
        OrderIds: List of [Code[20]];
        OrderId: Code[20];
    begin
        Header.SetCurrentKey(JobId);
        Header.SetFilter(JobId, '=%1', JobId);
        Header.SetLoadFields(OrderId);
        if (Header.FindSet()) then
            repeat
                OrderIds.Add(Header.OrderId);
            until (Header.Next() = 0);

        foreach OrderId in OrderIds do
            if (InnerHeader.Get(OrderId, JobId)) then
                InnerHeader.Delete(false);
    end;

    local procedure BuildTicketImportHeader(var Order: Record "NPR CMOrder"; JobId: Code[40]; var TempImportHeader: Record "NPR TM ImportTicketHeader" temporary)
    begin
        TempImportHeader.Init();
        TempImportHeader.OrderId := Order.DocumentNo;
        TempImportHeader.JobId := JobId;
        TempImportHeader.SalesDate := DT2Date(Order.ReceivedAt);
        TempImportHeader.TicketHolderEMail := Order.SellToEmail;
        TempImportHeader.TicketHolderName := Order.SellToName;
        TempImportHeader.TicketHolderPreferredLang := Order.SellToLanguage;

        // If PaymentReference is blank, it means the order is still in draft stage — don't populate the PaymentReference on the import header, 
        // Actual Payment Reference is the internal and stable DocumentNo, not the one provided by partner 
        // — this is because we want the payment reference on the TM reservation and Det. entry to be consistent and immutable after the order is created, 
        // so that we can reliably identify and correlate reconciliation records in TM and ERP via DocumentNo
        // Also note, payment reference is wider (code 50) to allow for guid-values
        TempImportHeader.PaymentReference := '';
        if (Order.PaymentReference <> '') then
            TempImportHeader.PaymentReference := Order.DocumentNo;

        TempImportHeader.Insert();
    end;

    local procedure BuildTicketImportLines(var Order: Record "NPR CMOrder"; var TempOrderWallet: Record "NPR CMOrderWallet" temporary; JobId: Code[40]; var TempImportLine: Record "NPR TM ImportTicketLine" temporary)
    var
        OrderLine: Record "NPR CMOrderLine";
        MasterItem, AddonItem : Record Item;
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        GLSetup: Record "General Ledger Setup";
        PricesExcl: Dictionary of [Integer, Decimal];
        PricesIncl: Dictionary of [Integer, Decimal];
        UnitPriceExclVat: Decimal;
        UnitPriceInclVat: Decimal;
        CurrencyCode: Code[10];
        VisitDate: Date;
        VisitTime: Time;
        ImportIdxWithinSeqNo: Integer;
        InstanceIdx: Integer;
        LastLineNo: Integer;
        NonPackageCacheKey: Integer;
    begin
        TempOrderWallet.Reset();
        if (not TempOrderWallet.FindSet()) then
            exit;

        GLSetup.Get();
        CurrencyCode := GLSetup."LCY Code";
        LastLineNo := 0;
        NonPackageCacheKey := 0;

        repeat
            OrderLine.SetFilter(OrderId, '=%1', TempOrderWallet.OrderId);
            OrderLine.SetFilter(LineNo, '=%1', TempOrderWallet.LineNo);
            OrderLine.FindFirst();

            MasterItem.Get(OrderLine.ItemNo);
            ImportIdxWithinSeqNo := 0;

            if (TempOrderWallet.LineNo <> LastLineNo) then begin
                Clear(PricesExcl);
                Clear(PricesIncl);
                LastLineNo := TempOrderWallet.LineNo;
            end;

            if (OrderLine.IsPackage) then begin
                AddOnLine.SetFilter("AddOn No.", '=%1', MasterItem."NPR Item AddOn No.");
                AddOnLine.SetFilter(Type, '=%1', AddOnLine.Type::Quantity);
                AddOnLine.SetFilter("Item No.", '<>%1', '');
                if (AddOnLine.FindSet()) then
                    repeat
                        AddonItem.Get(AddOnLine."Item No.");
                        if (AddonItem."NPR Ticket Type" <> '') then begin
                            ResolveVisitForComponent(OrderLine, AddOnLine."Item No.", VisitDate, VisitTime);
                            GetOrComputeAddOnLinePrice(AddOnLine, VisitDate, VisitTime, PricesExcl, PricesIncl, UnitPriceExclVat, UnitPriceInclVat);
                            for InstanceIdx := 1 to GetAddOnQuantity(AddOnLine) do begin
                                ImportIdxWithinSeqNo += 1;
                                BuildOneTicketImportLine(
                                    Order, OrderLine, TempOrderWallet.SeqNo, ImportIdxWithinSeqNo,
                                    AddOnLine."Item No.", AddonItem."NPR Ticket Type", VisitDate, VisitTime, JobId,
                                    TempImportLine, UnitPriceExclVat, UnitPriceInclVat, CurrencyCode, 0);
                                AccumulatePriceOnWallet(TempOrderWallet, UnitPriceExclVat, UnitPriceInclVat, CurrencyCode);
                            end;
                        end;
                    until (AddOnLine.Next() = 0);
            end else begin
                if (MasterItem."NPR Ticket Type" <> '') then begin
                    if (not PricesExcl.ContainsKey(NonPackageCacheKey)) then begin
                        CalculateDynamicTicketPrice(OrderLine.ItemNo, '', OrderLine.VisitDate, OrderLine.VisitTime, UnitPriceExclVat, UnitPriceInclVat);
                        PricesExcl.Add(NonPackageCacheKey, UnitPriceExclVat);
                        PricesIncl.Add(NonPackageCacheKey, UnitPriceInclVat);
                    end else begin
                        UnitPriceExclVat := PricesExcl.Get(NonPackageCacheKey);
                        UnitPriceInclVat := PricesIncl.Get(NonPackageCacheKey);
                    end;

                    ImportIdxWithinSeqNo += 1;
                    if (OrderLine.IsGroupTicket) then begin
                        BuildOneTicketImportLine(
                            Order, OrderLine, TempOrderWallet.SeqNo, ImportIdxWithinSeqNo,
                            OrderLine.ItemNo, MasterItem."NPR Ticket Type", OrderLine.VisitDate, OrderLine.VisitTime, JobId,
                            TempImportLine, UnitPriceExclVat * OrderLine.Quantity, UnitPriceInclVat * OrderLine.Quantity, CurrencyCode, OrderLine.Quantity);
                        AccumulatePriceOnWallet(TempOrderWallet, UnitPriceExclVat * OrderLine.Quantity, UnitPriceInclVat * OrderLine.Quantity, CurrencyCode);
                    end else begin
                        BuildOneTicketImportLine(
                            Order, OrderLine, TempOrderWallet.SeqNo, ImportIdxWithinSeqNo,
                            OrderLine.ItemNo, MasterItem."NPR Ticket Type", OrderLine.VisitDate, OrderLine.VisitTime, JobId,
                            TempImportLine, UnitPriceExclVat, UnitPriceInclVat, CurrencyCode, 0);
                        AccumulatePriceOnWallet(TempOrderWallet, UnitPriceExclVat, UnitPriceInclVat, CurrencyCode);
                    end;
                end;
            end;
        until (TempOrderWallet.Next() = 0);
    end;

    local procedure GetOrComputeAddOnLinePrice(
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        VisitDate: Date; VisitTime: Time;
        var PricesExcl: Dictionary of [Integer, Decimal];
        var PricesIncl: Dictionary of [Integer, Decimal];
        var UnitPriceExclVat: Decimal; var UnitPriceInclVat: Decimal)
    var
        WalletMgr: Codeunit "NPR AttractionWallet";
    begin
        if (PricesExcl.ContainsKey(AddOnLine."Line No.")) then begin
            UnitPriceExclVat := PricesExcl.Get(AddOnLine."Line No.");
            UnitPriceInclVat := PricesIncl.Get(AddOnLine."Line No.");
            exit;
        end;

        WalletMgr.CalculateAddOnLineUnitPrice(AddOnLine, '', VisitDate, VisitTime, UnitPriceExclVat, UnitPriceInclVat);
        PricesExcl.Add(AddOnLine."Line No.", UnitPriceExclVat);
        PricesIncl.Add(AddOnLine."Line No.", UnitPriceInclVat);
    end;

    local procedure BuildOneTicketImportLine(
        var Order: Record "NPR CMOrder";
        var OrderLine: Record "NPR CMOrderLine";
        SeqNo: Integer; ImportIdxWithinSeqNo: Integer;
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        VisitDate: Date; VisitTime: Time;
        JobId: Code[40];
        var TempImportLine: Record "NPR TM ImportTicketLine" temporary;
        UnitPriceExclVat: Decimal;
        UnitPriceInclVat: Decimal;
        CurrencyCode: Code[10];
        GroupTicketQuantity: Integer)
    var
        TokenLine: Integer;
        NotificationAddress: Text[100];
        TicketType: Record "NPR TM Ticket Type";
    begin
        TokenLine := EncodeTokenLine(OrderLine.LineNo, SeqNo, ImportIdxWithinSeqNo);
        TicketType.Get(TicketTypeCode);

        NotificationAddress := OrderLine.NotificationAddress;

        TempImportLine.Init();
        TempImportLine.OrderId := Order.DocumentNo;
        TempImportLine.JobId := JobId;
        TempImportLine.PreAssignedTicketNumber := GenerateTicketNumber(TicketType."External Ticket Pattern", TicketType."No. Series");
        TempImportLine.TicketRequestTokenLine := TokenLine;
        TempImportLine.ItemReferenceNumber := ItemNo;
        TempImportLine.ExpectedVisitDate := VisitDate;
        TempImportLine.ExpectedVisitTime := VisitTime;
        TempImportLine.TicketHolderEMail := CopyStr(NotificationAddress, 1, MaxStrLen(TempImportLine.TicketHolderEMail));
        TempImportLine.TicketHolderName := OrderLine.Name;
        TempImportLine.TicketHolderPreferredLang := OrderLine.Language;
        if (GroupTicketQuantity > 0) then
            TempImportLine.GroupTicketQuantity := GroupTicketQuantity;
        TempImportLine.Amount := UnitPriceExclVat;
        TempImportLine.AmountInclVat := UnitPriceInclVat;
        TempImportLine.CurrencyCode := CurrencyCode;
        TempImportLine.Insert();
    end;

    local procedure CalculateDynamicTicketPrice(ItemNo: Code[20]; VariantCode: Code[10]; VisitDate: Date; VisitTime: Time; var UnitPriceExclVat: Decimal; var UnitPriceInclVat: Decimal)
    var
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
        TicketUnitPrice: Decimal;
        ErpUnitPrice: Decimal;
        ErpDiscountPct: Decimal;
        ErpUnitPriceIncludesVat: Boolean;
        ErpUnitPriceVatPercentage: Decimal;
    begin
        TicketUnitPrice := DynamicPrice.CalculatePrice(
            ItemNo, VariantCode, '', VisitDate, VisitTime, 1,
            ErpUnitPrice, ErpDiscountPct, ErpUnitPriceIncludesVat, ErpUnitPriceVatPercentage);

        if (ErpUnitPriceIncludesVat) then begin
            UnitPriceInclVat := TicketUnitPrice;
            if (ErpUnitPriceVatPercentage <> 0) then
                UnitPriceExclVat := Round(UnitPriceInclVat / (1 + ErpUnitPriceVatPercentage / 100), 0.01)
            else
                UnitPriceExclVat := UnitPriceInclVat;
        end else begin
            UnitPriceExclVat := TicketUnitPrice;
            UnitPriceInclVat := Round(UnitPriceExclVat * (1 + ErpUnitPriceVatPercentage / 100), 0.01);
        end;
    end;

    local procedure AccumulatePriceOnWallet(var TempOrderWallet: Record "NPR CMOrderWallet" temporary; UnitPriceExclVat: Decimal; UnitPriceInclVat: Decimal; CurrencyCode: Code[10])
    begin
        TempOrderWallet.UnitPriceExclVat += UnitPriceExclVat;
        TempOrderWallet.UnitPriceInclVat += UnitPriceInclVat;
        if (TempOrderWallet.CurrencyCode = '') then
            TempOrderWallet.CurrencyCode := CurrencyCode;
        TempOrderWallet.Modify();
    end;


#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
    local procedure GetTicketSequenceNumber(NoSeries: Code[20]) Number: Code[20]
    var
        NoSeriesManagement: Codeunit "No. Series";
    begin
        Number := NoSeriesManagement.GetNextNo(NoSeries);
    end;
#ELSE
    local procedure GetTicketSequenceNumber(NoSeries: Code[20]) Number: Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        NoSeriesManagement.InitSeries(NoSeries, '', Today(), Number, NoSeries);
    end;
#ENDIF


    local procedure GenerateTicketNumber(ExternalTicketPattern: Code[30]; NoSeries: Code[20]) Number: Code[30]
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Attempts: Integer;
        UnableToGenerateUniqueNumberErr: Label 'Unable to generate a unique pre-assigned ticket number after 10 attempts.';
        EmptyPatternErr: Label 'cannot be empty when issuing channel manager tickets without externally provided ticket numbers.';
        TicketNumberFromSeries: Code[20];
    begin
        if (NoSeries = '') then begin
            TicketSetup.Get();
            if (TicketSetup."Imp. Def. Ext. Ticket Pattern" = '') then
                TicketSetup.FieldError("Imp. Def. Ext. Ticket Pattern", EmptyPatternErr);
            ExternalTicketPattern := TicketSetup."Imp. Def. Ext. Ticket Pattern";
            TicketNumberFromSeries := '';
        end else begin
            TicketNumberFromSeries := GetTicketSequenceNumber(NoSeries);
            if (ExternalTicketPattern = '') then
                ExternalTicketPattern := '[S]'; // from number sequence, no additional pattern specified
        end;

        Number := CopyStr(TicketManagement.GenerateNumberPattern(ExternalTicketPattern, TicketNumberFromSeries), 1, MaxStrLen(Number));
        if (Ticket.CheckIsUnique(Number)) then
            exit;

        for Attempts := 1 to 10 do begin
            Number := CopyStr(TicketManagement.GenerateNumberPattern(ExternalTicketPattern, TicketNumberFromSeries), 1, MaxStrLen(Number));
            if (Ticket.CheckIsUnique(Number)) then
                exit;
        end;

        Error(UnableToGenerateUniqueNumberErr);
    end;

    local procedure ResolveVisitForComponent(var OrderLine: Record "NPR CMOrderLine"; ComponentItemNo: Code[20]; var VisitDate: Date; var VisitTime: Time)
    var
        Component: Record "NPR CMOrderComponent";
    begin
        Component.SetFilter(OrderId, '=%1', OrderLine.OrderId);
        Component.SetFilter(LineNo, '=%1', OrderLine.LineNo);
        Component.SetFilter(ComponentItemNo, '=%1', ComponentItemNo);
        if (Component.FindFirst()) then begin
            VisitDate := Component.VisitDate;
            VisitTime := Component.VisitTime;
            exit;
        end;
        VisitDate := OrderLine.VisitDate;
        VisitTime := OrderLine.VisitTime;
    end;

    local procedure GetAddOnQuantity(var AddOnLine: Record "NPR NpIa Item AddOn Line"): Integer
    begin
        if (AddOnLine.Quantity < 1) then
            exit(1);
        exit(Round(AddOnLine.Quantity, 1, '<'));
    end;

    local procedure CollectTicketIdsForWallet(Token: Text[100]; LineNo: Integer; SeqNo: Integer; var TicketIds: List of [Guid])
    var
        ReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TokenLineMin: Integer;
        TokenLineMax: Integer;
    begin
        TokenLineMin := EncodeTokenLine(LineNo, SeqNo, 1);
        TokenLineMax := EncodeTokenLine(LineNo, SeqNo, 9);

        ReservationReq.SetFilter("Session Token ID", '=%1', Token);
        ReservationReq.SetFilter("Ext. Line Reference No.", '>=%1&<=%2', TokenLineMin, TokenLineMax);
        ReservationReq.SetLoadFields("Entry No.");
        if (not ReservationReq.FindSet()) then
            exit;

        repeat
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', ReservationReq."Entry No.");
            Ticket.SetLoadFields(SystemId);
            if (Ticket.FindSet()) then
                repeat
                    TicketIds.Add(Ticket.SystemId);
                until (Ticket.Next() = 0);
        until (ReservationReq.Next() = 0);
    end;

    // ---- TokenLine encoding ----
    // Layout: LineNo (multiples of 100000) + SeqNo*10 + ImportIdxWithinSeqNo
    // Valid up to SeqNo<10000 and ImportIdxWithinSeqNo<10 (max 9 tickets per wallet from a package template expansion).
    local procedure EncodeTokenLine(LineNo: Integer; SeqNo: Integer; ImportIdxWithinSeqNo: Integer): Integer
    var
        EncodingOverflowErr: Label 'CMTicketIssuer token line encoding overflow: LineNo=%1 SeqNo=%2 ImportIdx=%3. SeqNo must stay below 10000 and ImportIdx below 10. This is a programming bug.', Locked = true;
    begin
        if ((SeqNo >= 10000) or (ImportIdxWithinSeqNo >= 10)) then
            Error(EncodingOverflowErr, LineNo, SeqNo, ImportIdxWithinSeqNo);
        exit(LineNo + SeqNo * 10 + ImportIdxWithinSeqNo);
    end;

    local procedure NewJobId(): Code[40]
    begin
        exit(CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, 40));
    end;

    local procedure GetTokenForJobId(JobId: Code[40]): Text[100]
    var
        ImportHeader: Record "NPR TM ImportTicketHeader";
        MissingJobErr: Label 'Order with JobId %1 not found. This is a programming bug.';
    begin
        ImportHeader.SetCurrentKey(JobId);
        ImportHeader.SetFilter(JobId, '=%1', JobId);
        ImportHeader.SetLoadFields(TicketRequestToken);
        if (not ImportHeader.FindFirst()) then
            Error(MissingJobErr, JobId);
        exit(ImportHeader.TicketRequestToken);
    end;
}
