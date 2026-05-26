#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151041 "NPR TicketingTimeSlotsAgent"
{
    Access = Internal;

    var
        TSL001Err: Label '[TSL001] Missing required field itemNumber', Locked = true;
        TSL002Err: Label '[TSL002] Invalid fromDate, expected format is yyyy-mm-dd', Locked = true;
        TSL003Err: Label '[TSL003] Invalid toDate, expected format is yyyy-mm-dd', Locked = true;
        TSL004Err: Label '[TSL004] fromDate must be on or before toDate', Locked = true;
        TSL005Err: Label '[TSL005] Date range exceeds maximum of %1 days', Locked = true;
        TSL006Err: Label '[TSL006] Invalid withPrice, expected boolean (true/false)', Locked = true;
        TSL007Err: Label '[TSL007] Invalid withCapacity, expected boolean (true/false)', Locked = true;
        TSL008Err: Label '[TSL008] Invalid Item Number', Locked = true;
        TSL009Err: Label '[TSL009] Item is not a ticket item and has no ticket Item AddOn', Locked = true;
        TSL010Err: Label '[TSL010] No ticket admissions resolved for the requested item', Locked = true;
        TSL011Err: Label '[TSL011] Ticket item AddOn quantity must be a positive whole number (AddOn ''%1'' line %2, item ''%3'', quantity %4)', Locked = true;
        TSL012Err: Label '[TSL012] No required ticket admissions found for AddOn line item ''%1'' variant ''%2''', Locked = true;
        TSL013Err: Label '[TSL013] No required ticket admissions found for item ''%1'' variant ''%2''', Locked = true;

    internal procedure GetTimeSlots(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        QueryParameterValue: Text;
        ResponseMessage: Text;

        // Request parameters
        ItemReferenceNumber: Code[50];
        FromDate: Date;
        ToDate: Date;
        WithPrice: Boolean;
        WithCapacity: Boolean;
        MaxDateRangeDays: Integer;
    begin
        MaxDateRangeDays := 62; // ~2 months — common UI window (e.g. July + August)
        FromDate := Today();
        ToDate := CalcDate('<+1M>', FromDate);

        if (Request.QueryParams().ContainsKey('itemNumber')) then
            ItemReferenceNumber := CopyStr(UpperCase(Request.QueryParams().Get('itemNumber')), 1, MaxStrLen(ItemReferenceNumber));
        if (ItemReferenceNumber = '') then
            exit(Response.RespondBadRequest(TSL001Err));

        QueryParameterValue := '';
        if (Request.QueryParams().ContainsKey('fromDate')) then
            QueryParameterValue := Request.QueryParams().Get('fromDate');
        if (QueryParameterValue <> '') then
            if (not Evaluate(FromDate, QueryParameterValue, 9)) then
                exit(Response.RespondBadRequest(TSL002Err));

        QueryParameterValue := '';
        if (Request.QueryParams().ContainsKey('toDate')) then
            QueryParameterValue := Request.QueryParams().Get('toDate');
        if (QueryParameterValue <> '') then
            if (not Evaluate(ToDate, QueryParameterValue, 9)) then
                exit(Response.RespondBadRequest(TSL003Err));

        if (FromDate > ToDate) then
            exit(Response.RespondBadRequest(TSL004Err));

        if ((ToDate - FromDate + 1) > MaxDateRangeDays) then
            exit(Response.RespondBadRequest(StrSubstNo(TSL005Err, MaxDateRangeDays)));

        QueryParameterValue := '';
        if (Request.QueryParams().ContainsKey('withPrice')) then
            QueryParameterValue := Request.QueryParams().Get('withPrice');
        if (QueryParameterValue <> '') then
            if (not Evaluate(WithPrice, QueryParameterValue)) then
                exit(Response.RespondBadRequest(TSL006Err));

        QueryParameterValue := '';
        if (Request.QueryParams().ContainsKey('withCapacity')) then
            QueryParameterValue := Request.QueryParams().Get('withCapacity');
        if (QueryParameterValue <> '') then
            if (not Evaluate(WithCapacity, QueryParameterValue)) then
                exit(Response.RespondBadRequest(TSL007Err));

        exit(GenerateResponse(ItemReferenceNumber, FromDate, ToDate, WithPrice, WithCapacity, ResponseMessage));
    end;

    local procedure GenerateResponse(ItemReferenceNumber: Code[50]; FromDate: Date; ToDate: Date; WithPrice: Boolean; WithCapacity: Boolean; var ResponseMessage: Text) Response: Codeunit "NPR API Response"
    var
        ResolvedBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ItemResolver: Integer;
    begin
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(ItemReferenceNumber, ItemNo, VariantCode, ItemResolver)) then
            exit(Response.RespondBadRequest(TSL008Err));

        if (not ResolveAdmissions(ItemNo, VariantCode, ResolvedBuffer, ResponseMessage)) then
            exit(Response.RespondBadRequest(ResponseMessage));

        ResponseJson.Initialize();
        ResponseJson.StartObject()
            .AddProperty('itemNumber', ItemReferenceNumber);

        EmitItems(ResolvedBuffer, ResponseJson);

        if (WithPrice) then
            EmitDatePrices(ResolvedBuffer, FromDate, ToDate, DatePriceBuffer, ResponseJson);

        EmitTimeSlots(ResolvedBuffer, FromDate, ToDate, WithPrice, WithCapacity, DatePriceBuffer, ResponseJson);

        ResponseJson.EndObject();
        Response.RespondOK(ResponseJson.Build());
        exit(Response);
    end;

    local procedure ResolveAdmissions(InputItemNo: Code[20]; InputVariantCode: Code[10]; var ResolvedBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseMessage: Text): Boolean
    var
        Item: Record Item;
        EntryNo: Integer;
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        AddOnItem: Record Item;
        AddonQuantity: Integer;
    begin
        if (not Item.Get(InputItemNo)) then
            exit(SetErrorMessage(ResponseMessage, TSL008Err));

        ResolvedBuffer.Reset();
        ResolvedBuffer.DeleteAll();
        EntryNo := 0;

        if (Item."NPR Item AddOn No." <> '') then begin
            AddOnLine.SetFilter("AddOn No.", '=%1', Item."NPR Item AddOn No.");
            AddOnLine.SetFilter("Item No.", '<>%1', '');
            if (AddOnLine.FindSet()) then
                repeat
                    if (AddOnItem.Get(AddOnLine."Item No.")) then
                        if (AddOnItem."NPR Ticket Type" <> '') then begin

                            if ((AddOnLine.Quantity <> Round(AddOnLine.Quantity, 1)) or (AddOnLine.Quantity < 1)) then
                                exit(SetErrorMessage(ResponseMessage, StrSubstNo(TSL011Err, AddOnLine."AddOn No.", AddOnLine."Line No.", AddOnLine."Item No.", AddOnLine.Quantity)));

                            AddonQuantity := Round(AddOnLine.Quantity, 1);
                            if (not AppendBomToBuffer(AddOnLine."Item No.", AddOnLine."Variant Code", AddonQuantity, ResolvedBuffer, EntryNo)) then
                                exit(SetErrorMessage(ResponseMessage, StrSubstNo(TSL012Err, AddOnLine."Item No.", AddOnLine."Variant Code")));
                        end;
                until (AddOnLine.Next() = 0);
        end else begin
            if (Item."NPR Ticket Type" = '') then
                exit(SetErrorMessage(ResponseMessage, TSL009Err));
            if (not AppendBomToBuffer(InputItemNo, InputVariantCode, 1, ResolvedBuffer, EntryNo)) then
                exit(SetErrorMessage(ResponseMessage, StrSubstNo(TSL013Err, InputItemNo, InputVariantCode)));
        end;

        if (EntryNo = 0) then
            exit(SetErrorMessage(ResponseMessage, TSL010Err));

        exit(true);
    end;

    local procedure AppendBomToBuffer(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; Quantity: Integer; var ResolvedBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var EntryNo: Integer): Boolean
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.SetFilter("Item No.", '=%1', TicketItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', TicketVariantCode);
        TicketBom.SetFilter("Admission Inclusion", '=%1', TicketBom."Admission Inclusion"::REQUIRED);
        if (not TicketBom.FindSet()) then
            exit(false);
        repeat
            ResolvedBuffer.Reset();
            ResolvedBuffer.SetFilter(RequestItemNumber, '=%1', TicketItemNo);
            ResolvedBuffer.SetFilter(RequestVariantCode, '=%1', TicketVariantCode);
            ResolvedBuffer.SetFilter(AdmissionCode, '=%1', TicketBom."Admission Code");
            if (ResolvedBuffer.FindFirst()) then begin
                ResolvedBuffer.Quantity += Quantity;
                ResolvedBuffer.Modify();
            end else begin
                Clear(ResolvedBuffer);
                EntryNo += 1;
                ResolvedBuffer.EntryNo := EntryNo;
                ResolvedBuffer.RequestItemNumber := TicketItemNo;
                ResolvedBuffer.RequestVariantCode := TicketVariantCode;
                ResolvedBuffer.ItemNumber := TicketItemNo;
                ResolvedBuffer.VariantCode := TicketVariantCode;
                ResolvedBuffer.Quantity := Quantity;
                ResolvedBuffer.AdmissionCode := TicketBom."Admission Code";
                ResolvedBuffer.AdmissionInclusion := TicketBom."Admission Inclusion";
                ResolvedBuffer.DefaultAdmission := TicketBom.Default;
                if (not ResolvedBuffer.Insert()) then;
            end;
        until (TicketBom.Next() = 0);
        ResolvedBuffer.Reset();
        exit(true);
    end;

    local procedure EmitItems(var ResolvedBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
        CurrentItem: Code[20];
        CurrentVariant: Code[10];
        ItemOpen: Boolean;
    begin
        ResponseJson.StartArray('items');

        ResolvedBuffer.Reset();
        if (ResolvedBuffer.FindSet()) then
            repeat
                if ((ResolvedBuffer.RequestItemNumber <> CurrentItem) or (ResolvedBuffer.RequestVariantCode <> CurrentVariant)) then begin
                    if (ItemOpen) then begin
                        ResponseJson.EndArray();
                        ResponseJson.EndObject();
                    end;
                    CurrentItem := ResolvedBuffer.RequestItemNumber;
                    CurrentVariant := ResolvedBuffer.RequestVariantCode;
                    ResponseJson.StartObject()
                        .AddProperty('ticketItemNumber', ResolvedBuffer.RequestItemNumber)
                        .AddProperty('variantCode', ResolvedBuffer.RequestVariantCode)
                        .AddProperty('quantity', ResolvedBuffer.Quantity);
                    ResponseJson.StartArray('admissions');
                    ItemOpen := true;
                end;

                ResponseJson.StartObject()
                    .AddProperty('admissionCode', ResolvedBuffer.AdmissionCode)
                    .AddProperty('inclusion', EnumEncoder.EncodeInclusion(ResolvedBuffer.AdmissionInclusion))
                    .AddProperty('default', ResolvedBuffer.DefaultAdmission)
                .EndObject();
            until (ResolvedBuffer.Next() = 0);

        if (ItemOpen) then begin
            ResponseJson.EndArray();
            ResponseJson.EndObject();
        end;

        ResponseJson.EndArray();
    end;

    local procedure EmitDatePrices(var ResolvedBuffer: Record "NPR TM AdmCapacityPriceBuffer"; FromDate: Date; ToDate: Date; var DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        GLSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
        IterationDate: Date;
        NextEntryNo: Integer;
        HavePrice: Boolean;
    begin
        GLSetup.Get();
        CurrencyCode := GLSetup."LCY Code";

        DatePriceBuffer.Reset();
        DatePriceBuffer.DeleteAll();
        NextEntryNo := 0;

        ResponseJson.StartArray('datePrices');

        ResolvedBuffer.Reset();
        ResolvedBuffer.SetFilter(DefaultAdmission, '=%1', true);
        if (ResolvedBuffer.FindSet()) then
            repeat
                IterationDate := FromDate;
                while (IterationDate <= ToDate) do begin
                    Clear(DatePriceBuffer);
                    NextEntryNo += 1;
                    DatePriceBuffer.EntryNo := NextEntryNo;
                    DatePriceBuffer.AdmissionCode := ResolvedBuffer.AdmissionCode;
                    DatePriceBuffer.RequestItemNumber := ResolvedBuffer.RequestItemNumber;
                    DatePriceBuffer.RequestVariantCode := ResolvedBuffer.RequestVariantCode;
                    DatePriceBuffer.ItemNumber := ResolvedBuffer.RequestItemNumber;
                    DatePriceBuffer.VariantCode := ResolvedBuffer.RequestVariantCode;
                    DatePriceBuffer.Quantity := ResolvedBuffer.Quantity;
                    DatePriceBuffer.DefaultAdmission := true;
                    DatePriceBuffer.AdmissionInclusion := ResolvedBuffer.AdmissionInclusion;
                    DatePriceBuffer.ReferenceDate := IterationDate;

                    HavePrice := TicketPrice.CalculateErpPrice(DatePriceBuffer);
                    if (not HavePrice) then
                        DatePriceBuffer.UnitPrice := 0;

                    ResponseJson.StartObject()
                        .AddProperty('ticketItemNumber', DatePriceBuffer.RequestItemNumber)
                        .AddProperty('variantCode', DatePriceBuffer.RequestVariantCode)
                        .AddProperty('admissionCode', DatePriceBuffer.AdmissionCode)
                        .AddProperty('date', IterationDate)
                        .AddProperty('basePrice', DatePriceBuffer.UnitPrice)
                        .AddProperty('currencyCode', CurrencyCode)
                    .EndObject();

                    if (not DatePriceBuffer.Insert()) then;

                    IterationDate += 1;
                end;
            until (ResolvedBuffer.Next() = 0);

        ResolvedBuffer.Reset();
        ResponseJson.EndArray();
    end;

    local procedure EmitTimeSlots(var ResolvedBuffer: Record "NPR TM AdmCapacityPriceBuffer"; FromDate: Date; ToDate: Date; WithPrice: Boolean; WithCapacity: Boolean; var DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        DefaultAdmissionByItem: Dictionary of [Text, Code[20]];
        DefaultAdmissionCode: Code[20];
        DefaultLookupKey: Text;
        BasePrice: Decimal;
        AddonPrice: Decimal;
        MaxCapacity: Integer;
        CurrentCapacity: Integer;
        RemainingCapacity: Integer;
        CapacityControl: Option;
    begin
        // Cost of this function depends on date range, withPrice (date-keyed base + per-slot delta),
        // and withCapacity (GetTicketCapacity + CalculateCurrentCapacity per slot). Surface the dimensions
        // in the span description so timings are interpretable without joining to other data.
        Sentry.StartSpan(Span, StrSubstNo('EmitTimeSlots withPrice=%1 withCapacity=%2 %3..%4 (%5 days)', WithPrice, WithCapacity, FromDate, ToDate, ToDate - FromDate + 1));
        Sentry.AddTransactionData('timeslots.with_price', Format(WithPrice, 0, 9));
        Sentry.AddTransactionData('timeslots.with_capacity', Format(WithCapacity, 0, 9));
        Sentry.AddTransactionData('timeslots.days', Format(ToDate - FromDate + 1));
        if (WithPrice) then begin
            ResolvedBuffer.Reset();
            ResolvedBuffer.SetFilter(DefaultAdmission, '=%1', true);
            if (ResolvedBuffer.FindSet()) then
                repeat
                    // Key by (item, variant) so two variants of the same item don't collide on a single default admission.
                    DefaultLookupKey := StrSubstNo('%1|%2', ResolvedBuffer.RequestItemNumber, ResolvedBuffer.RequestVariantCode);
                    if (not DefaultAdmissionByItem.ContainsKey(DefaultLookupKey)) then
                        DefaultAdmissionByItem.Add(DefaultLookupKey, ResolvedBuffer.AdmissionCode);
                until (ResolvedBuffer.Next() = 0);
            ResolvedBuffer.Reset();
        end;

        ResponseJson.StartArray('timeSlots');

        ResolvedBuffer.Reset();
        if (ResolvedBuffer.FindSet()) then begin

            AdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
            repeat
                AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', ResolvedBuffer.AdmissionCode);
                AdmissionScheduleEntry.SetFilter("Admission Start Date", '%1..', FromDate);
                AdmissionScheduleEntry.SetFilter("Admission End Date", '..%1', ToDate);
                AdmissionScheduleEntry.SetFilter("Visibility On Web", '=%1', AdmissionScheduleEntry."Visibility On Web"::VISIBLE);
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindSet()) then
                    repeat
                        ResponseJson.StartObject()
                            .AddProperty('scheduleNumber', AdmissionScheduleEntry."External Schedule Entry No.")
                            .AddProperty('ticketItemNumber', ResolvedBuffer.RequestItemNumber)
                            .AddProperty('variantCode', ResolvedBuffer.RequestVariantCode)
                            .AddProperty('admissionCode', ResolvedBuffer.AdmissionCode)
                            .AddProperty('scheduleCode', AdmissionScheduleEntry."Schedule Code")
                            .AddProperty('startDate', AdmissionScheduleEntry."Admission Start Date")
                            .AddProperty('startTime', AdmissionScheduleEntry."Admission Start Time")
                            .AddProperty('endDate', AdmissionScheduleEntry."Admission End Date")
                            .AddProperty('endTime', AdmissionScheduleEntry."Admission End Time");

                        if (WithPrice) then begin
                            DefaultAdmissionCode := '';
                            DefaultLookupKey := StrSubstNo('%1|%2', ResolvedBuffer.RequestItemNumber, ResolvedBuffer.RequestVariantCode);
                            if (DefaultAdmissionByItem.ContainsKey(DefaultLookupKey)) then
                                DefaultAdmissionCode := DefaultAdmissionByItem.Get(DefaultLookupKey);

                            BasePrice := 0;
                            AddonPrice := 0;
                            DatePriceBuffer.Reset();
                            DatePriceBuffer.SetFilter(RequestItemNumber, '=%1', ResolvedBuffer.RequestItemNumber);
                            DatePriceBuffer.SetFilter(AdmissionCode, '=%1', DefaultAdmissionCode);
                            DatePriceBuffer.SetFilter(ReferenceDate, '=%1', AdmissionScheduleEntry."Admission Start Date");
                            DatePriceBuffer.SetFilter(RequestVariantCode, '=%1', ResolvedBuffer.RequestVariantCode);
                            if (DatePriceBuffer.FindFirst()) then
                                TicketPrice.CalculateScheduleEntryPrice(
                                    ResolvedBuffer.RequestItemNumber,
                                    ResolvedBuffer.RequestVariantCode,
                                    ResolvedBuffer.AdmissionCode,
                                    AdmissionScheduleEntry."External Schedule Entry No.",
                                    DatePriceBuffer.UnitPrice,
                                    DatePriceBuffer.UnitPriceIncludesVat,
                                    DatePriceBuffer.UnitPriceVatPercentage,
                                    AdmissionScheduleEntry."Admission Start Date",
                                    AdmissionScheduleEntry."Admission Start Time",
                                    BasePrice,
                                    AddonPrice);

                            ResponseJson.AddProperty('priceDelta', AddonPrice);
                        end;

                        if (WithCapacity) then begin
                            MaxCapacity := 0;
                            CurrentCapacity := 0;
                            TicketManagement.GetTicketCapacity(
                                ResolvedBuffer.RequestItemNumber,
                                ResolvedBuffer.RequestVariantCode,
                                ResolvedBuffer.AdmissionCode,
                                AdmissionScheduleEntry."Schedule Code",
                                AdmissionScheduleEntry."Entry No.",
                                MaxCapacity,
                                CapacityControl);
                            ResponseJson.AddProperty('capacityControl', EnumEncoder.EncodeCapacity(CapacityControl));

                            if (CapacityControl <> Admission."Capacity Control"::"NONE") then begin
                                CurrentCapacity := TicketManagement.CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntry."Entry No.");
                                RemainingCapacity := MaxCapacity - CurrentCapacity;
                                if (RemainingCapacity < 0) then
                                    RemainingCapacity := 0;
                                ResponseJson.AddProperty('remainingCapacity', RemainingCapacity);
                            end;
                        end;

                        ResponseJson.EndObject();
                    until (AdmissionScheduleEntry.Next() = 0);
            until (ResolvedBuffer.Next() = 0);
        end;

        ResponseJson.EndArray();
        Span.Finish();
    end;

    local procedure SetErrorMessage(var ResponseMessage: Text; MessageText: Text): Boolean
    begin
        ResponseMessage := MessageText;
        exit(false);
    end;
}
#endif
