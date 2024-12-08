#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185044 "NPR TicketingCapacityAgent"
{

    Access = Internal;

    var
        _CapacityStatusCodeOption: Option ,OK,CAPACITY_EXCEEDED,NON_WORKING,CALENDAR_WARNING,UNLIMITED_CAPACITY,CLOSED;

    internal procedure GetTimeSlots(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ItemResolver: Integer;
        ItemNo: Code[20];
        VariantCode: Code[10];
        QueryParameterValue: Text;
        ResponseMessage: Text;

        // Request parameters
        ItemReferenceNumber: Code[50];
        ReferenceDate: Date;
        Quantity: Integer;
        AdmissionCode: Code[20];
        CustomerNumber: Code[20];
    begin
        if (Request.QueryParams().ContainsKey('itemNumber')) then
            ItemReferenceNumber := CopyStr(UpperCase(Request.QueryParams().Get('itemNumber')), 1, MaxStrLen(ItemReferenceNumber));
        if (ItemReferenceNumber = '') then
            exit(Response.RespondBadRequest('Missing required field item number'));

        if (Request.QueryParams().ContainsKey('referenceDate')) then
            QueryParameterValue := Request.QueryParams().Get('referenceDate');
        if (QueryParameterValue <> '') then
            if (not Evaluate(ReferenceDate, QueryParameterValue, 9)) then
                exit(Response.RespondBadRequest('Invalid reference date, expected format is yyyy-mm-dd'));

        if (Request.QueryParams().ContainsKey('quantity')) then
            QueryParameterValue := Request.QueryParams().Get('quantity');
        if (QueryParameterValue <> '') then
            if (not Evaluate(Quantity, QueryParameterValue)) then
                exit(Response.RespondBadRequest('Invalid quantity, expected integer'));
        if (Quantity < 1) then
            exit(Response.RespondBadRequest('Quantity must be greater than 0'));

        if (Request.QueryParams().ContainsKey('admissionCode')) then
            AdmissionCode := CopyStr(UpperCase(Request.QueryParams().Get('admissionCode')), 1, MaxStrLen(AdmissionCode));

        if (Request.QueryParams().ContainsKey('customerNumber')) then
            CustomerNumber := CopyStr(UpperCase(Request.QueryParams().Get('customerNumber')), 1, MaxStrLen(CustomerNumber));

        exit(GetTimeSlots(ItemReferenceNumber, ItemNo, VariantCode, ItemResolver, ReferenceDate, Quantity, AdmissionCode, CustomerNumber, AdmCapacityPriceBuffer, ResponseMessage, TicketRequestManager));

    end;

    internal procedure GetTimeSlots(ItemReferenceNumber: Code[50]; ItemNo: Code[20]; VariantCode: Code[10]; ItemResolver: Integer; ReferenceDate: Date; Quantity: Integer; AdmissionCode: Code[20]; CustomerNumber: Code[20]; var AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseMessage: Text; var TicketRequestManager: Codeunit "NPR TM Ticket Request Manager") Response: Codeunit "NPR API Response"
    begin
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(ItemReferenceNumber, ItemNo, VariantCode, ItemResolver)) then
            exit(Response.RespondBadRequest('Invalid Item Number'));

        if (not FindAdmissionItemErpPrice(ItemNo, VariantCode, ReferenceDate, Quantity, AdmissionCode, CustomerNumber, AdmCapacityPriceBuffer, ResponseMessage)) then
            exit(Response.RespondBadRequest(ResponseMessage));

        exit(GenerateCapacityDTO(AdmCapacityPriceBuffer));
    end;

    local procedure GenerateCapacityDTO(var AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer") Response: Codeunit "NPR API Response"
    var
        ResponseJson: Codeunit "NPR JSON Builder";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        LocalDateTime: DateTime;
        LocalDate: Date;
        LocalTime: Time;
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";

    begin

        AdmCapacityPriceBuffer.Reset();
        AdmCapacityPriceBuffer.FindSet();

        ResponseJson.Initialize();
        ResponseJson.StartArray();

        repeat
            TicketBom.Get(AdmCapacityPriceBuffer.RequestItemNumber, AdmCapacityPriceBuffer.RequestVariantCode, AdmCapacityPriceBuffer.AdmissionCode);
            Admission.Get(AdmCapacityPriceBuffer.AdmissionCode);

            LocalDateTime := TimeHelper.GetLocalTimeAtAdmission(AdmCapacityPriceBuffer.AdmissionCode);
            LocalDate := DT2Date(LocalDateTime);
            LocalTime := DT2Time(LocalDateTime);

            ResponseJson.StartObject()
                .AddProperty('code', AdmCapacityPriceBuffer.AdmissionCode)
                .AddProperty('default', AdmCapacityPriceBuffer.DefaultAdmissionCode)
                .AddProperty('included', EnumEncoder.EncodeInclusion(TicketBom."Admission Inclusion"))
                .AddProperty('capacityControl', EnumEncoder.EncodeCapacity(Admission."Capacity Control"))
                .AddProperty('referenceDate', Format(AdmCapacityPriceBuffer.ReferenceDate, 0, 9))
                .AddProperty('quantity', Format(AdmCapacityPriceBuffer.Quantity, 0, 9))
                .AddProperty('unitPrice', Format(AdmCapacityPriceBuffer.UnitPrice, 0, 9))
                .AddProperty('discountPct', Format(AdmCapacityPriceBuffer.DiscountPct, 0, 9))
                .AddProperty('unitPriceIncludesVat', AdmCapacityPriceBuffer.UnitPriceIncludesVat)
                .AddProperty('vatPct', Format(AdmCapacityPriceBuffer.UnitPriceVatPercentage, 0, 9))
                .AddArray(ScheduleEntryDTO(AdmCapacityPriceBuffer, ResponseJson, LocalDate, LocalTime, (Admission."Capacity Control" = Admission."Capacity Control"::"NONE")))
            .EndObject();

        until (AdmCapacityPriceBuffer.Next() = 0);

        ResponseJson.EndArray();
        Response.RespondOK(ResponseJson.BuildAsArray());

    end;

    local procedure ScheduleEntryDTO(AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder"; LocalDate: Date; LocalTime: Time; AdmissionCapacityControlNone: Boolean): Codeunit "NPR JSON Builder"
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";

        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
        CapacityStatusCode: Option;
        BlockSaleReason: Enum "NPR TM Sch. Block Sales Reason";
        RemainingCapacity: Integer;
        CalendarExceptionText: Text;
        IsNonWorking: Boolean;
    begin
        ResponseJson.StartArray('schedules');

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmCapacityPriceBuffer.AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', AdmCapacityPriceBuffer.ReferenceDate);
        AdmissionScheduleEntry.SetFilter("Visibility On Web", '=%1', AdmissionScheduleEntry."Visibility On Web"::VISIBLE);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindSet()) then begin
            repeat
                CapacityStatusCode := _CapacityStatusCodeOption::OK;
                BlockSaleReason := BlockSaleReason::OpenForSales;

                if (not TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry,
                    AdmCapacityPriceBuffer.RequestItemNumber,
                    AdmCapacityPriceBuffer.RequestVariantCode,
                    LocalDate, LocalTime,
                    BlockSaleReason, RemainingCapacity)) then begin

                    CapacityStatusCode := _CapacityStatusCodeOption::CAPACITY_EXCEEDED;
                    if (BlockSaleReason = BlockSaleReason::ScheduleExceedTicketDuration) then
                        exit;
                end;

                if (RemainingCapacity < 1) then begin
                    CapacityStatusCode := _CapacityStatusCodeOption::CAPACITY_EXCEEDED;
                    BlockSaleReason := BlockSaleReason::RemainingCapacityZeroOrLess;
                end;

                if (AdmissionCapacityControlNone) then begin
                    CapacityStatusCode := _CapacityStatusCodeOption::UNLIMITED_CAPACITY;
                    BlockSaleReason := BlockSaleReason::OpenForSales;
                end;

                TicketManagement.CheckTicketBaseCalendar(AdmCapacityPriceBuffer.AdmissionCode,
                    AdmCapacityPriceBuffer.RequestItemNumber,
                    AdmCapacityPriceBuffer.RequestVariantCode,
                    AdmCapacityPriceBuffer.ReferenceDate,
                    IsNonWorking,
                    CalendarExceptionText);

                if (IsNonWorking) then
                    CapacityStatusCode := _CapacityStatusCodeOption::NON_WORKING;

                if ((CapacityStatusCode = _CapacityStatusCodeOption::OK) and (CalendarExceptionText <> '')) then
                    CapacityStatusCode := _CapacityStatusCodeOption::CALENDAR_WARNING;

                if (CapacityStatusCode in [_CapacityStatusCodeOption::OK, _CapacityStatusCodeOption::UNLIMITED_CAPACITY]) then begin
                    if (AdmissionScheduleEntry."Admission Is" = AdmissionScheduleEntry."Admission Is"::CLOSED) then
                        CapacityStatusCode := _CapacityStatusCodeOption::CLOSED;
                    if (AdmissionScheduleEntry."Admission End Date" < LocalDate) then
                        CapacityStatusCode := _CapacityStatusCodeOption::CLOSED;
                    if ((AdmissionScheduleEntry."Admission End Date" = LocalDate) and (AdmissionScheduleEntry."Admission End Time" < LocalTime)) then
                        CapacityStatusCode := _CapacityStatusCodeOption::CLOSED;
                end;

                ResponseJson.StartObject()
                    .AddProperty('allocatable', CapacityStatusCode in [_CapacityStatusCodeOption::OK, _CapacityStatusCodeOption::CALENDAR_WARNING, _CapacityStatusCodeOption::UNLIMITED_CAPACITY])
                    .AddProperty('allocationModel', EnumEncoder.EncodeAllocationBy(AdmissionScheduleEntry."Allocation By"))
                    .AddProperty('remainingCapacity', Format(RemainingCapacity, 0, 9))
                    .AddProperty('explanation', GetMessageText(CapacityStatusCode, CalendarExceptionText, BlockSaleReason.AsInteger()))
                    .AddObject(ScheduleDTO(ResponseJson, AdmissionScheduleEntry))
                    .AddObject(PriceDTO(AdmCapacityPriceBuffer, ResponseJson, AdmissionScheduleEntry, LocalDate, LocalTime))
                    .AddObject(SalesDTO(ResponseJson, AdmissionScheduleEntry))
                .EndObject()

            until (AdmissionScheduleEntry.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;


    local procedure SalesDTO(var ResponseJson: Codeunit "NPR JSON Builder"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"): Codeunit "NPR JSON Builder"
    begin
        ResponseJson.StartObject('sales')
            .AddProperty('salesFromDate', Format(AdmissionScheduleEntry."Sales From Date", 0, 9))
            .AddProperty('salesFromTime', Format(AdmissionScheduleEntry."Sales From Time", 0, 9))
            .AddProperty('salesUntilDate', Format(AdmissionScheduleEntry."Sales Until Date", 0, 9))
            .AddProperty('salesUntilTime', Format(AdmissionScheduleEntry."Sales Until Time", 0, 9))
        .EndObject();

        exit(ResponseJson);
    end;

    local procedure ScheduleDTO(var ResponseJson: Codeunit "NPR JSON Builder"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"): Codeunit "NPR JSON Builder"
    var
        Schedule: Record "NPR TM Admis. Schedule";
    begin
        if (not Schedule.Get(AdmissionScheduleEntry."Schedule Code")) then
            Schedule.Init();

        ResponseJson.StartObject('schedule')
            .AddProperty('id', Format(AdmissionScheduleEntry."External Schedule Entry No.", 0, 9))
            .AddProperty('code', AdmissionScheduleEntry."Schedule Code")
            .AddProperty('description', Schedule.Description)
            .AddProperty('startDate', Format(AdmissionScheduleEntry."Admission Start Date", 0, 9))
            .AddProperty('startTime', Format(AdmissionScheduleEntry."Admission Start Time", 0, 9))
            .AddProperty('endDate', Format(AdmissionScheduleEntry."Admission End Date", 0, 9))
            .AddProperty('endTime', Format(AdmissionScheduleEntry."Admission End Time", 0, 9))
            .AddProperty('duration', Format((AdmissionScheduleEntry."Admission End Time" - AdmissionScheduleEntry."Admission Start Time") / 1000, 0, 9))
            .AddProperty('arrivalFromTime', Format(AdmissionScheduleEntry."Event Arrival From Time", 0, 9))
            .AddProperty('arrivalUntilTime', Format(AdmissionScheduleEntry."Event Arrival Until Time", 0, 9))
        .EndObject();

        exit(ResponseJson);
    end;

    local procedure PriceDTO(AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseJson: Codeunit "NPR JSON Builder"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; LocalDate: Date; LocalTime: Time): Codeunit "NPR JSON Builder"
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        HavePriceRule: Boolean;
        PriceRule: Record "NPR TM Dynamic Price Rule";
        BasePrice: Decimal;
        AddonPrice: Decimal;

        PriceOptionName: Text;
        AdjustmentAmount: Text;
        AdjustmentPct: Text;
        AdjustedTotalPrice: Text;
        CustomerPriceOut: Decimal;
        AdjustedUnitPrice: Decimal;
    begin

        HavePriceRule := TicketPrice.SelectPriceRule(AdmissionScheduleEntry, AdmCapacityPriceBuffer.ItemNumber, AdmCapacityPriceBuffer.VariantCode, LocalDate, LocalTime, PriceRule);
        if (HavePriceRule) then
            TicketPrice.EvaluatePriceRule(PriceRule, AdmCapacityPriceBuffer.UnitPrice, AdmCapacityPriceBuffer.UnitPriceIncludesVat, AdmCapacityPriceBuffer.UnitPriceVatPercentage, false, BasePrice, AddonPrice);

        if (not HavePriceRule) then
            PriceRule.Init();

        case (PriceRule.PricingOption) of
            PriceRule.PricingOption::NA:
                begin
                    PriceOptionName := 'standard';
                    AdjustedUnitPrice := AdmCapacityPriceBuffer.UnitPrice;
                end;
            PriceRule.PricingOption::FIXED:
                begin
                    PriceOptionName := 'fixed_amount';
                    AdjustedUnitPrice := BasePrice;
                end;
            PriceRule.PricingOption::RELATIVE:
                begin
                    PriceOptionName := 'relative_amount';
                    AdjustedUnitPrice := AdmCapacityPriceBuffer.UnitPrice + AddonPrice;
                end;
            PriceRule.PricingOption::PERCENT:
                begin
                    PriceOptionName := 'percentage';
                    AdjustedUnitPrice := AdmCapacityPriceBuffer.UnitPrice + AddonPrice;
                end;
        end;
        AdjustmentAmount := Format(PriceRule.Amount, 0, 9);
        AdjustmentPct := Format(PriceRule.Percentage, 0, 9);

        if (AdjustedUnitPrice < 0) then
            AdjustedUnitPrice := 0;

        CustomerPriceOut := AdmCapacityPriceBuffer.Quantity * AdjustedUnitPrice - AdmCapacityPriceBuffer.Quantity * AdjustedUnitPrice * AdmCapacityPriceBuffer.DiscountPct / 100;
        AdjustedTotalPrice := Format(TicketPrice.RoundAmount(CustomerPriceOut, PriceRule.RoundingPrecision, PriceRule.RoundingDirection), 0, 9);

        ResponseJson.StartObject('price')
            .AddProperty('pricingOption', PriceOptionName)
            .AddProperty('adjustmentAmount', AdjustmentAmount)
            .AddProperty('adjustmentPct', AdjustmentPct)
            .AddProperty('adjustedUnitPrice', Format(AdjustedUnitPrice, 0, 9))
            .AddProperty('adjustedTotalPrice', AdjustedTotalPrice)
        .EndObject();

        exit(ResponseJson);
    end;

    local procedure GetMessageText(CapacityStatusCode: Option; ReasonText: Text; BlockSalesReason: Integer): Text
    var
        ResponseLbl: Label 'Capacity Status Code %1 does not have a dedicated message.';
        OK: Label 'Ok.';
        CAPACITY_EXCEEDED: Label 'Capacity Exceeded (code %1).';
        CLOSED: Label 'Closed.';
    begin
        case CapacityStatusCode of
            _CapacityStatusCodeOption::OK:
                exit(OK);
            _CapacityStatusCodeOption::NON_WORKING:
                exit(ReasonText);
            _CapacityStatusCodeOption::CAPACITY_EXCEEDED:
                exit(StrSubstNo(CAPACITY_EXCEEDED, BlockSalesReason));
            _CapacityStatusCodeOption::CALENDAR_WARNING:
                exit(ReasonText);
            _CapacityStatusCodeOption::UNLIMITED_CAPACITY:
                exit(OK);
            _CapacityStatusCodeOption::CLOSED:
                exit(CLOSED);
            else
                exit(StrSubstNo(ResponseLbl, CapacityStatusCode));
        end;
    end;

    local procedure FindAdmissionItemErpPrice(ItemNo: Code[20]; VariantCode: Code[10]; ReferenceDate: Date; Quantity: Integer; AdmissionCode: Code[20]; CustomerNumber: Code[20]; var AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseMessage: Text): Boolean
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        BomIndex: Integer;
    begin

        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        if (AdmissionCode <> '') then
            TicketBom.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (not TicketBom.FindSet()) then
            exit(SetErrorMessage(ResponseMessage, 'Not a Ticket Item Number or invalid Admission Code'));

        BomIndex := 0;
        repeat
            clear(AdmCapacityPriceBuffer);
            AdmCapacityPriceBuffer.EntryNo := BomIndex;
            AdmCapacityPriceBuffer.AdmissionCode := TicketBom."Admission Code";
            AdmCapacityPriceBuffer.DefaultAdmission := TicketBom.Default;
            AdmCapacityPriceBuffer.AdmissionInclusion := TicketBom."Admission Inclusion";
            AdmCapacityPriceBuffer.RequestItemNumber := ItemNo;
            AdmCapacityPriceBuffer.RequestVariantCode := VariantCode;
            AdmCapacityPriceBuffer.ItemNumber := ItemNo;
            AdmCapacityPriceBuffer.VariantCode := VariantCode;
            AdmCapacityPriceBuffer.Quantity := Quantity;
            AdmCapacityPriceBuffer.ReferenceDate := ReferenceDate;
            AdmCapacityPriceBuffer.CustomerNo := CustomerNumber;

            if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
                if (TicketBom.Default) then
                    if (not CalculateErpPrice(AdmCapacityPriceBuffer, ResponseMessage)) then
                        exit(false);

            if (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::REQUIRED) then begin
                Admission.Get(TicketBom."Admission Code");
                AdmCapacityPriceBuffer.ItemNumber := Admission."Additional Experience Item No.";
                AdmCapacityPriceBuffer.VariantCode := '';
                if (AdmCapacityPriceBuffer.ItemNumber <> '') then
                    if (not CalculateErpPrice(AdmCapacityPriceBuffer, ResponseMessage)) then
                        exit(false);
            end;

            if (not AdmCapacityPriceBuffer.Insert()) then;
            BomIndex += 1;

        until (TicketBom.Next() = 0);
        exit(true);
    end;

    local procedure SetErrorMessage(var ResponseMessage: Text; MessageText: Text): Boolean
    begin
        ResponseMessage := MessageText;
        exit(false);
    end;

    local procedure CalculateErpPrice(var AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer"; var ResponseMessage: Text): Boolean
    var
        TicketPriceService: Codeunit "NPR TM Dynamic Price";
    begin
        if (TicketPriceService.CalculateErpPrice(AdmCapacityPriceBuffer)) then
            exit(true);

        exit(SetErrorMessage(ResponseMessage, 'Error calculating price: ' + GetLastErrorText()));
    end;

}
#endif