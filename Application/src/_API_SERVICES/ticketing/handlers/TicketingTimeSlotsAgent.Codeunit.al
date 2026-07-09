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
        TSL014Err: Label '[TSL014] Item ''%1'' variant ''%2'' is configured on more than one AddOn line; this endpoint represents each item/variant once and cannot price the same item split across lines', Locked = true;

        _TicketPrice: Codeunit "NPR TM Dynamic Price";
        _TicketManagement: Codeunit "NPR TM Ticket Management";
        _EnumEncoder: Codeunit "NPR TicketingApiTranslations";

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
        TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        NonTicketBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
        ItemNo: Code[20];
        VariantCode: Code[10];
        PackageAddOnNo: Code[20];
        ItemResolver: Integer;
    begin
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(ItemReferenceNumber, ItemNo, VariantCode, ItemResolver)) then
            exit(Response.RespondBadRequest(TSL008Err));

        if (not ResolveAdmissions(ItemNo, VariantCode, TicketBuffer, NonTicketBuffer, PackageAddOnNo, ResponseMessage)) then
            exit(Response.RespondBadRequest(ResponseMessage));

        ResponseJson.Initialize();
        ResponseJson.StartObject()
            .AddProperty('itemNumber', ItemReferenceNumber);

        EmitItems(TicketBuffer, NonTicketBuffer, ResponseJson);

        if (WithPrice) then
            EmitDatePrices(TicketBuffer, PackageAddOnNo, NonTicketBuffer, FromDate, ToDate, DatePriceBuffer, ResponseJson);

        EmitTimeSlots(TicketBuffer, PackageAddOnNo, FromDate, ToDate, WithPrice, WithCapacity, DatePriceBuffer, ResponseJson);

        ResponseJson.EndObject();
        Response.RespondOK(ResponseJson.Build());
        exit(Response);
    end;

    local procedure ResolveAdmissions(InputItemNo: Code[20]; InputVariantCode: Code[10]; var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var NonTicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var PackageAddOnNo: Code[20]; var ResponseMessage: Text): Boolean
    var
        Item: Record Item;
        EntryNo: Integer;
        NonTicketEntryNo: Integer;
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        AddOnItem: Record Item;
        AddonQuantity: Integer;
        SeenItemVariants: List of [Text];
        ItemVariantKey: Text;
    begin
        if (not Item.Get(InputItemNo)) then
            exit(SetErrorMessage(ResponseMessage, TSL008Err));

        PackageAddOnNo := Item."NPR Item AddOn No.";

        TicketBuffer.Reset();
        TicketBuffer.DeleteAll();
        NonTicketBuffer.Reset();
        NonTicketBuffer.DeleteAll();
        EntryNo := 0;
        NonTicketEntryNo := 0;

        if (Item."NPR Item AddOn No." <> '') then begin
            AddOnLine.SetFilter("AddOn No.", '=%1', Item."NPR Item AddOn No.");
            AddOnLine.SetFilter("Item No.", '<>%1', '');
            if (AddOnLine.FindSet()) then
                repeat
                    ItemVariantKey := StrSubstNo('%1|%2', AddOnLine."Item No.", AddOnLine."Variant Code");
                    if (SeenItemVariants.Contains(ItemVariantKey)) then
                        exit(SetErrorMessage(ResponseMessage, StrSubstNo(TSL014Err, AddOnLine."Item No.", AddOnLine."Variant Code")));
                    SeenItemVariants.Add(ItemVariantKey);

                    if (AddOnItem.Get(AddOnLine."Item No.")) then
                        if (AddOnItem."NPR Ticket Type" <> '') then begin

                            if ((AddOnLine.Quantity <> Round(AddOnLine.Quantity, 1)) or (AddOnLine.Quantity < 1)) then
                                exit(SetErrorMessage(ResponseMessage, StrSubstNo(TSL011Err, AddOnLine."AddOn No.", AddOnLine."Line No.", AddOnLine."Item No.", AddOnLine.Quantity)));

                            AddonQuantity := Round(AddOnLine.Quantity, 1);
                            if (not AppendBomToBuffer(AddOnLine."Item No.", AddOnLine."Variant Code", AddonQuantity, TicketBuffer, EntryNo)) then
                                exit(SetErrorMessage(ResponseMessage, StrSubstNo(TSL012Err, AddOnLine."Item No.", AddOnLine."Variant Code")));
                        end else begin
                            // Non-ticket component (e.g. coupon): captured once here so EmitItems and EmitDatePrices
                            // emit the same set from the buffer. 
                            NonTicketEntryNo += 1;
                            Clear(NonTicketBuffer);
                            NonTicketBuffer.EntryNo := NonTicketEntryNo;
                            NonTicketBuffer.ItemNumber := AddOnLine."Item No.";
                            NonTicketBuffer.VariantCode := AddOnLine."Variant Code";
                            NonTicketBuffer.DecimalQuantity := AddOnLine.Quantity;
                            if (not NonTicketBuffer.Insert()) then;
                        end;
                until (AddOnLine.Next() = 0);
        end else begin
            if (Item."NPR Ticket Type" = '') then
                exit(SetErrorMessage(ResponseMessage, TSL009Err));
            if (not AppendBomToBuffer(InputItemNo, InputVariantCode, 1, TicketBuffer, EntryNo)) then
                exit(SetErrorMessage(ResponseMessage, StrSubstNo(TSL013Err, InputItemNo, InputVariantCode)));
        end;

        if (EntryNo = 0) then
            exit(SetErrorMessage(ResponseMessage, TSL010Err));

        exit(true);
    end;

    local procedure AppendBomToBuffer(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; Quantity: Integer; var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var EntryNo: Integer): Boolean
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
    begin
        TicketBom.SetFilter("Item No.", '=%1', TicketItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', TicketVariantCode);
        TicketBom.SetFilter("Admission Inclusion", '=%1', TicketBom."Admission Inclusion"::REQUIRED);
        if (not TicketBom.FindSet()) then
            exit(false);

        repeat
            TicketBuffer.Reset();
            TicketBuffer.SetFilter(RequestItemNumber, '=%1', TicketItemNo);
            TicketBuffer.SetFilter(RequestVariantCode, '=%1', TicketVariantCode);
            TicketBuffer.SetFilter(AdmissionCode, '=%1', TicketBom."Admission Code");
            if (TicketBuffer.FindFirst()) then begin
                TicketBuffer.Quantity += Quantity;
                TicketBuffer.Modify();
            end else begin
                Clear(TicketBuffer);
                Admission.Get(TicketBom."Admission Code");

                EntryNo += 1;
                TicketBuffer.EntryNo := EntryNo;
                TicketBuffer.RequestItemNumber := TicketItemNo;
                TicketBuffer.RequestVariantCode := TicketVariantCode;
                TicketBuffer.ItemNumber := TicketItemNo;
                TicketBuffer.VariantCode := TicketVariantCode;
                TicketBuffer.Quantity := Quantity;
                TicketBuffer.AdmissionCode := TicketBom."Admission Code";
                TicketBuffer.AdmissionInclusion := TicketBom."Admission Inclusion";
                TicketBuffer.DefaultAdmission := TicketBom.Default;
                TicketBuffer.TicketScheduleSelection := TicketBom."Ticket Schedule Selection";
                TicketBuffer.AdmissionScheduleSelection := Admission."Default Schedule";
                if (not TicketBuffer.Insert()) then;
            end;
        until (TicketBom.Next() = 0);
        TicketBuffer.Reset();
        exit(true);
    end;

    local procedure EmitItems(var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var NonTicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        CurrentItem: Code[20];
        CurrentVariant: Code[10];
        ItemOpen: Boolean;
    begin
        ResponseJson.StartArray('items');

        // Admission components - each carries its required admissions; the price is emitted per date in datePrices.
        TicketBuffer.Reset();
        if (TicketBuffer.FindSet()) then
            repeat
                if ((TicketBuffer.RequestItemNumber <> CurrentItem) or (TicketBuffer.RequestVariantCode <> CurrentVariant)) then begin
                    if (ItemOpen) then begin
                        ResponseJson.EndArray();
                        ResponseJson.EndObject();
                    end;
                    CurrentItem := TicketBuffer.RequestItemNumber;
                    CurrentVariant := TicketBuffer.RequestVariantCode;
                    ResponseJson.StartObject()
                        .AddProperty('componentItemNumber', TicketBuffer.RequestItemNumber)
                        .AddProperty('variantCode', TicketBuffer.RequestVariantCode)
                        .AddProperty('quantity', TicketBuffer.Quantity);
                    ResponseJson.StartArray('admissions');
                    ItemOpen := true;
                end;

                ResponseJson.StartObject()
                    .AddProperty('admissionCode', TicketBuffer.AdmissionCode)
                    .AddProperty('inclusion', _EnumEncoder.EncodeInclusion(TicketBuffer.AdmissionInclusion))
                    .AddProperty('default', TicketBuffer.DefaultAdmission)
                    .AddProperty('scheduleSelection', _EnumEncoder.EncodeScheduleSelection(TicketBuffer.TicketScheduleSelection, TicketBuffer.AdmissionScheduleSelection))
                .EndObject();
            until (TicketBuffer.Next() = 0);

        if (ItemOpen) then begin
            ResponseJson.EndArray();
            ResponseJson.EndObject();
        end;

        // Non-admission components (e.g. coupons): resolved once in ResolveAdmissions so items[] and datePrices[]
        // list the exact same set. Empty admissions array so a consumer can iterate admissions unconditionally.
        NonTicketBuffer.Reset();
        if (NonTicketBuffer.FindSet()) then
            repeat
                ResponseJson.StartObject()
                    .AddProperty('componentItemNumber', NonTicketBuffer.ItemNumber)
                    .AddProperty('variantCode', NonTicketBuffer.VariantCode)
                    .AddProperty('quantity', NonTicketBuffer.DecimalQuantity);
                ResponseJson.StartArray('admissions');
                ResponseJson.EndArray();
                ResponseJson.EndObject();
            until (NonTicketBuffer.Next() = 0);

        ResponseJson.EndArray();
    end;

    local procedure EmitDatePrices(var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; PackageAddOnNo: Code[20]; var NonTicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; FromDate: Date; ToDate: Date; var DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        GLSetup: Record "General Ledger Setup";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        CurrencyCode: Code[10];
        TicketComponents: Integer;
        NonTicketComponents: Integer;
    begin
        GLSetup.Get();
        CurrencyCode := GLSetup."LCY Code";

        // Surface the component counts and day span so a slow request is interpretable from the span alone.
        TicketBuffer.Reset();
        TicketBuffer.SetFilter(DefaultAdmission, '=%1', true);
        TicketComponents := TicketBuffer.Count();
        TicketBuffer.Reset();
        NonTicketComponents := NonTicketBuffer.Count();

        Sentry.StartSpan(Span, StrSubstNo('EmitDatePrices %1..%2 (%3 days) ticketComponents=%4 nonTicketComponents=%5', Format(FromDate, 0, 9), Format(ToDate, 0, 9), ToDate - FromDate + 1, TicketComponents, NonTicketComponents));
        Sentry.AddTransactionData('date-prices.days', Format(ToDate - FromDate + 1));
        Sentry.AddTransactionData('date-prices.ticket-components', Format(TicketComponents));
        Sentry.AddTransactionData('date-prices.non-ticket-components', Format(NonTicketComponents));

        ResponseJson.StartArray('datePrices');
        EmitTicketDatePrices(PackageAddOnNo, TicketBuffer, FromDate, ToDate, CurrencyCode, DatePriceBuffer, ResponseJson);
        EmitNonTicketDatePrices(PackageAddOnNo, NonTicketBuffer, FromDate, ToDate, CurrencyCode, ResponseJson);
        ResponseJson.EndArray();

        Span.Finish();
    end;

    local procedure EmitTicketDatePrices(PackageAddOnNo: Code[20]; var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; FromDate: Date; ToDate: Date; CurrencyCode: Code[10]; var DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        IterationDate: Date;
        NextEntryNo: Integer;
        AddOnFound: Boolean;
        Forced: Boolean;
        ForcedUnitPrice: Decimal;
        ForcedIncludesVat: Boolean;
        ForcedVatPercentage: Decimal;
        DisplayBasePrice: Decimal;
    begin
        DatePriceBuffer.Reset();
        DatePriceBuffer.DeleteAll();
        NextEntryNo := 0;

        // Admission components: one base price per (item, default admission, date).
        TicketBuffer.Reset();
        TicketBuffer.SetFilter(DefaultAdmission, '=%1', true);
        if (TicketBuffer.FindSet()) then
            repeat
                AddOnFound := TryGetPackageAddOnLine(PackageAddOnNo, TicketBuffer.RequestItemNumber, TicketBuffer.RequestVariantCode, AddOnLine);

                Forced := false;
                if (AddOnFound) then
                    Forced := IsForcedPricedAddOnLine(AddOnLine);
                if (Forced) then begin
                    ForcedUnitPrice := AddOnLine."Unit Price";
                    GetItemPriceVatBasis(AddOnLine."Item No.", ForcedIncludesVat, ForcedVatPercentage);
                end;

                IterationDate := FromDate;
                while (IterationDate <= ToDate) do begin
                    Clear(DatePriceBuffer);
                    NextEntryNo += 1;
                    DatePriceBuffer.EntryNo := NextEntryNo;
                    DatePriceBuffer.AdmissionCode := TicketBuffer.AdmissionCode;
                    DatePriceBuffer.RequestItemNumber := TicketBuffer.RequestItemNumber;
                    DatePriceBuffer.RequestVariantCode := TicketBuffer.RequestVariantCode;
                    DatePriceBuffer.ItemNumber := TicketBuffer.RequestItemNumber;
                    DatePriceBuffer.VariantCode := TicketBuffer.RequestVariantCode;
                    DatePriceBuffer.Quantity := TicketBuffer.Quantity;
                    DatePriceBuffer.DefaultAdmission := true;
                    DatePriceBuffer.AdmissionInclusion := TicketBuffer.AdmissionInclusion;
                    DatePriceBuffer.ReferenceDate := IterationDate;

                    // Buffer keeps the un-discounted unit price (forced unit price, or raw ERP) for the timeSlots engine.
                    if (Forced) then begin
                        DatePriceBuffer.UnitPrice := ForcedUnitPrice;
                        DatePriceBuffer.UnitPriceIncludesVat := ForcedIncludesVat;
                        DatePriceBuffer.UnitPriceVatPercentage := ForcedVatPercentage;
                    end else
                        if (not _TicketPrice.CalculateErpPrice(DatePriceBuffer)) then
                            DatePriceBuffer.UnitPrice := 0;

                    // basePrice shown = that un-discounted base with the AddOn line discount applied
                    DisplayBasePrice := DatePriceBuffer.UnitPrice;
                    if (AddOnFound) then
                        DisplayBasePrice := ApplyAddOnLineDiscount(AddOnLine, DisplayBasePrice);

                    ResponseJson.StartObject()
                        .AddProperty('componentItemNumber', DatePriceBuffer.RequestItemNumber)
                        .AddProperty('variantCode', DatePriceBuffer.RequestVariantCode)
                        .AddProperty('admissionCode', DatePriceBuffer.AdmissionCode)
                        .AddProperty('date', IterationDate)
                        .AddProperty('basePrice', DisplayBasePrice)
                        .AddProperty('currencyCode', CurrencyCode)
                    .EndObject();

                    if (not DatePriceBuffer.Insert()) then;

                    IterationDate += 1;
                end;
            until (TicketBuffer.Next() = 0);
        TicketBuffer.Reset();
    end;

    local procedure EmitNonTicketDatePrices(PackageAddOnNo: Code[20]; var NonTicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; FromDate: Date; ToDate: Date; CurrencyCode: Code[10]; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        ErpBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        IterationDate: Date;
        AddOnFound: Boolean;
        Forced: Boolean;
        BasePrice: Decimal;
        ForcedBasePrice: Decimal;
    begin
        // Non-admission components (e.g. coupons)
        NonTicketBuffer.Reset();
        if (not NonTicketBuffer.FindSet()) then
            exit;
        repeat
            AddOnFound := TryGetPackageAddOnLine(PackageAddOnNo, NonTicketBuffer.ItemNumber, NonTicketBuffer.VariantCode, AddOnLine);

            Forced := false;
            if (AddOnFound) then
                Forced := IsForcedPricedAddOnLine(AddOnLine);
            if (Forced) then
                ForcedBasePrice := ApplyAddOnLineDiscount(AddOnLine, AddOnLine."Unit Price");

            IterationDate := FromDate;
            while (IterationDate <= ToDate) do begin
                if (Forced) then
                    BasePrice := ForcedBasePrice
                else begin
                    Clear(ErpBuffer);
                    ErpBuffer.EntryNo := 1;
                    ErpBuffer.ItemNumber := NonTicketBuffer.ItemNumber;
                    ErpBuffer.VariantCode := NonTicketBuffer.VariantCode;
                    ErpBuffer.DecimalQuantity := NonTicketBuffer.DecimalQuantity; // CalculateErpPrice quotes the fractional qty
                    ErpBuffer.ReferenceDate := IterationDate;
                    if (not _TicketPrice.CalculateErpPrice(ErpBuffer)) then
                        ErpBuffer.UnitPrice := 0;
                    BasePrice := ErpBuffer.UnitPrice;
                    if (AddOnFound) then
                        BasePrice := ApplyAddOnLineDiscount(AddOnLine, BasePrice);
                end;

                ResponseJson.StartObject()
                    .AddProperty('componentItemNumber', NonTicketBuffer.ItemNumber)
                    .AddProperty('variantCode', NonTicketBuffer.VariantCode)
                    .AddProperty('admissionCode', '')
                    .AddProperty('date', IterationDate)
                    .AddProperty('basePrice', BasePrice)
                    .AddProperty('currencyCode', CurrencyCode)
                .EndObject();

                IterationDate += 1;
            end;
        until (NonTicketBuffer.Next() = 0);
    end;

    local procedure IsForcedPricedAddOnLine(AddOnLine: Record "NPR NpIa Item AddOn Line"): Boolean
    begin
        exit((AddOnLine."Use Unit Price" = AddOnLine."Use Unit Price"::Always) or (AddOnLine."Unit Price" <> 0));
    end;

    local procedure ApplyAddOnLineDiscount(AddOnLine: Record "NPR NpIa Item AddOn Line"; UnitPriceIn: Decimal): Decimal
    begin
        if (AddOnLine."Discount %" <> 0) then
            exit(Round(UnitPriceIn * (1 - (AddOnLine."Discount %" / 100)), 0.01));

        if (AddOnLine.DiscountAmount = 0) then
            exit(UnitPriceIn);

        if (AddOnLine.Quantity <= 0) then
            exit(UnitPriceIn);

        exit(Round((UnitPriceIn * AddOnLine.Quantity - AddOnLine.DiscountAmount) / AddOnLine.Quantity, 0.01));
    end;

    local procedure GetItemPriceVatBasis(ItemNo: Code[20]; var IncludesVat: Boolean; var VatPercentage: Decimal)
    var
        Item: Record Item;
        VATSetup: Record "VAT Posting Setup";
    begin
        IncludesVat := false;
        VatPercentage := 0;
        Item.SetLoadFields("Price Includes VAT", "VAT Prod. Posting Group", "VAT Bus. Posting Gr. (Price)");
        if (not Item.Get(ItemNo)) then
            exit;

        IncludesVat := Item."Price Includes VAT";
        if (Item."VAT Bus. Posting Gr. (Price)" = '') then
            exit;

        if (VATSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group")) then
            VatPercentage := VATSetup."VAT %";
    end;

    local procedure TryGetPackageAddOnLine(PackageAddOnNo: Code[20]; TicketItemNo: Code[20]; TicketVariantCode: Code[10]; var AddOnLine: Record "NPR NpIa Item AddOn Line"): Boolean
    begin
        if (PackageAddOnNo = '') then
            exit(false);

        AddOnLine.SetRange("AddOn No.", PackageAddOnNo);
        AddOnLine.SetRange("Item No.", TicketItemNo);
        AddOnLine.SetRange("Variant Code", TicketVariantCode);
        exit(AddOnLine.FindFirst());
    end;

    local procedure EmitTimeSlots(var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; PackageAddOnNo: Code[20]; FromDate: Date; ToDate: Date; WithPrice: Boolean; WithCapacity: Boolean; var DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        DefaultAdmissionByItem: Dictionary of [Text, Code[20]];
        DefaultAdmissionCode: Code[20];
        DefaultLookupKey: Text;
        ResolvedItem: Code[20];
        ResolvedVariant: Code[10];
        AddOnFound: Boolean;
    begin
        // Surface the cost of this function, it depends on date range, withPrice and withCapacity 
        Sentry.StartSpan(Span, StrSubstNo('EmitTimeSlots withPrice=%1 withCapacity=%2 %3..%4 (%5 days)', WithPrice, WithCapacity, Format(FromDate, 0, 9), Format(ToDate, 0, 9), ToDate - FromDate + 1));
        Sentry.AddTransactionData('timeslots.with_price', Format(WithPrice, 0, 9));
        Sentry.AddTransactionData('timeslots.with_capacity', Format(WithCapacity, 0, 9));
        Sentry.AddTransactionData('timeslots.days', Format(ToDate - FromDate + 1));
        if (WithPrice) then begin
            TicketBuffer.Reset();
            TicketBuffer.SetFilter(DefaultAdmission, '=%1', true);
            if (TicketBuffer.FindSet()) then
                repeat
                    DefaultLookupKey := StrSubstNo('%1|%2', TicketBuffer.RequestItemNumber, TicketBuffer.RequestVariantCode);
                    if (not DefaultAdmissionByItem.ContainsKey(DefaultLookupKey)) then
                        DefaultAdmissionByItem.Add(DefaultLookupKey, TicketBuffer.AdmissionCode);
                until (TicketBuffer.Next() = 0);
            TicketBuffer.Reset();
        end;

        ResponseJson.StartArray('timeSlots');

        TicketBuffer.Reset();
        if (TicketBuffer.FindSet()) then begin

            AdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
            repeat
                // AddOn line + default admission are per (item, variant). Rows are grouped by item, so only
                // re-resolve when the item/variant changes - a multi-admission item then resolves its AddOn line
                // once instead of once per admission row.
                if (WithPrice and ((TicketBuffer.RequestItemNumber <> ResolvedItem) or (TicketBuffer.RequestVariantCode <> ResolvedVariant))) then begin
                    ResolvedItem := TicketBuffer.RequestItemNumber;
                    ResolvedVariant := TicketBuffer.RequestVariantCode;
                    AddOnFound := TryGetPackageAddOnLine(PackageAddOnNo, ResolvedItem, ResolvedVariant, AddOnLine);
                    DefaultAdmissionCode := '';
                    DefaultLookupKey := StrSubstNo('%1|%2', ResolvedItem, ResolvedVariant);
                    if (DefaultAdmissionByItem.ContainsKey(DefaultLookupKey)) then
                        DefaultAdmissionCode := DefaultAdmissionByItem.Get(DefaultLookupKey);
                end;

                AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TicketBuffer.AdmissionCode);
                AdmissionScheduleEntry.SetFilter("Admission Start Date", '%1..', FromDate);
                AdmissionScheduleEntry.SetFilter("Admission End Date", '..%1', ToDate);
                AdmissionScheduleEntry.SetFilter("Visibility On Web", '=%1', AdmissionScheduleEntry."Visibility On Web"::VISIBLE);
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindSet()) then
                    repeat
                        ResponseJson.StartObject()
                            .AddProperty('scheduleNumber', AdmissionScheduleEntry."External Schedule Entry No.")
                            .AddProperty('componentItemNumber', TicketBuffer.RequestItemNumber)
                            .AddProperty('variantCode', TicketBuffer.RequestVariantCode)
                            .AddProperty('admissionCode', TicketBuffer.AdmissionCode)
                            .AddProperty('scheduleCode', AdmissionScheduleEntry."Schedule Code")
                            .AddProperty('startDate', AdmissionScheduleEntry."Admission Start Date")
                            .AddProperty('startTime', AdmissionScheduleEntry."Admission Start Time")
                            .AddProperty('endDate', AdmissionScheduleEntry."Admission End Date")
                            .AddProperty('endTime', AdmissionScheduleEntry."Admission End Time");

                        if (WithPrice) then
                            ResponseJson.AddProperty('priceDelta', ResolveSlotPriceDelta(TicketBuffer, AdmissionScheduleEntry, DatePriceBuffer, DefaultAdmissionCode, AddOnFound, AddOnLine));

                        if (WithCapacity) then
                            EmitSlotCapacity(TicketBuffer, AdmissionScheduleEntry, ResponseJson);

                        ResponseJson.EndObject();
                    until (AdmissionScheduleEntry.Next() = 0);
            until (TicketBuffer.Next() = 0);
        end;

        ResponseJson.EndArray();
        Span.Finish();
    end;

    local procedure ResolveSlotPriceDelta(
        var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        var DatePriceBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        DefaultAdmissionCode: Code[20];
        AddOnFound: Boolean;
        AddOnLine: Record "NPR NpIa Item AddOn Line"): Decimal
    var
        BasePrice: Decimal;
        AddonPrice: Decimal;
        ItemBase: Decimal;
        SlotPriceBeforeDiscount: Decimal;
    begin
        DatePriceBuffer.Reset();
        DatePriceBuffer.SetFilter(RequestItemNumber, '=%1', TicketBuffer.RequestItemNumber);
        DatePriceBuffer.SetFilter(AdmissionCode, '=%1', DefaultAdmissionCode);
        DatePriceBuffer.SetFilter(ReferenceDate, '=%1', AdmissionScheduleEntry."Admission Start Date");
        DatePriceBuffer.SetFilter(RequestVariantCode, '=%1', TicketBuffer.RequestVariantCode);
        if (not DatePriceBuffer.FindFirst()) then
            exit(0);

        ItemBase := DatePriceBuffer.UnitPrice;
        _TicketPrice.CalculateScheduleEntryPrice(
            TicketBuffer.RequestItemNumber,
            TicketBuffer.RequestVariantCode,
            TicketBuffer.AdmissionCode,
            AdmissionScheduleEntry."External Schedule Entry No.",
            ItemBase,
            DatePriceBuffer.UnitPriceIncludesVat,
            DatePriceBuffer.UnitPriceVatPercentage,
            AdmissionScheduleEntry."Admission Start Date",
            AdmissionScheduleEntry."Admission Start Time",
            BasePrice,
            AddonPrice);

        // Only the default admission carries the item's base price (it is the single datePrices row for the item).
        // Default slot: base may be replaced (FIXED) or adjusted (RELATIVE/PERCENT) -> SlotPriceBeforeDiscount = BasePrice + AddonPrice.
        // Non-default slot: it contributes only its own per-slot addon; we measure against the default base so the
        // base cancels in the delta below. So a non-default priceDelta is the (discounted) incremental addon for that
        // admission - NOT a standalone price. The consumer reconstructs the line as datePrices.basePrice (default) +
        // the chosen slot's priceDelta per admission, never base + base.
        if (TicketBuffer.AdmissionCode = DefaultAdmissionCode) then
            SlotPriceBeforeDiscount := BasePrice + AddonPrice
        else
            SlotPriceBeforeDiscount := ItemBase + AddonPrice;

        // priceDelta = how much this slot changes the price the consumer already has (the discounted base). The AddOn
        // discount is applied last to the whole line, so we run both the slot price and the base through the same
        // ApplyAddOnLineDiscount and subtract: the base cancels, leaving the discounted addon (or, for FIXED,
        // discount(ruleAmount) - discount(base)). The %/amount split itself lives inside ApplyAddOnLineDiscount; by
        // differencing its output the caller doesn't repeat that fork, and base + priceDelta == the discounted total
        // holds for whatever discount shape it implements.
        if (AddOnFound) then
            exit(ApplyAddOnLineDiscount(AddOnLine, SlotPriceBeforeDiscount) - ApplyAddOnLineDiscount(AddOnLine, ItemBase));
        exit(SlotPriceBeforeDiscount - ItemBase);
    end;

    local procedure EmitSlotCapacity(var TicketBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var ResponseJson: Codeunit "NPR JSON Builder")
    var
        Admission: Record "NPR TM Admission";
        MaxCapacity: Integer;
        CurrentCapacity: Integer;
        RemainingCapacity: Integer;
        CapacityControl: Option;
    begin
        _TicketManagement.GetTicketCapacity(
            TicketBuffer.RequestItemNumber,
            TicketBuffer.RequestVariantCode,
            TicketBuffer.AdmissionCode,
            AdmissionScheduleEntry."Schedule Code",
            AdmissionScheduleEntry."Entry No.",
            MaxCapacity,
            CapacityControl);
        ResponseJson.AddProperty('capacityControl', _EnumEncoder.EncodeCapacity(CapacityControl));

        if (CapacityControl = Admission."Capacity Control"::"NONE") then
            exit;

        CurrentCapacity := _TicketManagement.CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntry."Entry No.");
        RemainingCapacity := MaxCapacity - CurrentCapacity;
        if (RemainingCapacity < 0) then
            RemainingCapacity := 0;
        ResponseJson.AddProperty('remainingCapacity', RemainingCapacity);
    end;

    local procedure SetErrorMessage(var ResponseMessage: Text; MessageText: Text): Boolean
    begin
        ResponseMessage := MessageText;
        exit(false);
    end;
}
#endif
