#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248288 "NPR TicketingReportAgent"
{
    Access = Internal;


    internal procedure GetDynamicPriceProfileList(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        DynamicPriceRuleQuery: Query "NPR TMDynamicPriceProfileRule";
        ResultJson: Codeunit "NPR Json Builder";
    begin
        ResultJson.StartArray();
        if (DynamicPriceRuleQuery.Open()) then
            while (DynamicPriceRuleQuery.Read()) do begin
                ResultJson.StartObject()
                    .AddProperty('id', Format(DynamicPriceRuleQuery.SystemId, 0, 4))
                    .AddProperty('profileCode', DynamicPriceRuleQuery.ProfileCode)
                    .AddProperty('lineNo', DynamicPriceRuleQuery.LineNo)

                    .AddProperty('amount', DynamicPriceRuleQuery.Amount)
                    .AddProperty('amountIncludesVAT', DynamicPriceRuleQuery.AmountIncludesVAT)

                    .AddProperty('blocked', DynamicPriceRuleQuery.Blocked)

                    .AddObject(AddValueOrNull(ResultJson, 'bookingDateFrom', DynamicPriceRuleQuery.BookingDateFrom))
                    .AddObject(AddValueOrNull(ResultJson, 'bookingDateUntil', DynamicPriceRuleQuery.BookingDateUntil))
                    .AddProperty('description', DynamicPriceRuleQuery.Description)
                    .AddObject(AddValueOrNull(ResultJson, 'eventDateFrom', DynamicPriceRuleQuery.EventDateFrom))
                    .AddObject(AddValueOrNull(ResultJson, 'eventDateUntil', DynamicPriceRuleQuery.EventDateUntil))

                    .AddProperty('percentage', DynamicPriceRuleQuery.Percentage)
                    .AddProperty('pricingOption', DynamicPriceRuleQuery.PricingOption)
                    .AddProperty('relativeBookingDateFormula', Format(DynamicPriceRuleQuery.RelativeBookingDateFormula, 0, 9))
                    .AddProperty('relativeEventDateFormula', Format(DynamicPriceRuleQuery.RelativeEventDateFormula, 0, 9))
                    .AddProperty('relativeUntilEventDate', Format(DynamicPriceRuleQuery.RelativeUntilEventDate, 0, 9))
                    .AddProperty('roundingDirection', DynamicPriceRuleQuery.RoundingDirection)
                    .AddProperty('roundingPrecision', DynamicPriceRuleQuery.RoundingPrecision)
                    .EndObject();
            end;
        ResultJson.EndArray();
        Response.RespondOK(ResultJson.BuildAsArray());
    end;


    internal procedure GetDynamicPriceProfileWhereUsed(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        FindBy: Option ITEM,ADMISSION_SCHEDULE,PROFILE_CODE;
    begin
        if (Request.QueryParams().ContainsKey('admissionCode')) then
            FindBy := FindBy::ADMISSION_SCHEDULE;
        if (Request.QueryParams().ContainsKey('scheduleCode')) then
            FindBy := FindBy::ADMISSION_SCHEDULE;

        if (Request.QueryParams().ContainsKey('itemNumber')) then
            FindBy := FindBy::ITEM;

        if (Request.QueryParams().ContainsKey('profileCode')) then
            FindBy := FindBy::PROFILE_CODE;

        case FindBy of
            FindBy::ITEM: // Default is all ticket items
                exit(GetDynamicPriceProfileWhereUsedByItem(Request));
            FindBy::ADMISSION_SCHEDULE:
                exit(GetDynamicPriceProfileWhereUsedByAdmissionSchedule(Request));
            FindBy::PROFILE_CODE:
                exit(GetDynamicPriceProfileWhereUsedByProfileCode(Request));
        end;
    end;


    local procedure GetDynamicPriceProfileWhereUsedByItem(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    var
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
        TempPriceProfiles: Record "NPR TM DynamicPriceItemList" temporary;
        ItemNumber, AdmissionCode : Code[20];
        VariantCode: Code[10];
    begin

        if (Request.QueryParams().ContainsKey('itemNumber')) then
            ItemNumber := CopyStr(Request.QueryParams().Get('itemNumber'), 1, MaxStrLen(ItemNumber));

        if (Request.QueryParams().ContainsKey('variantCode')) then
            VariantCode := CopyStr(Request.QueryParams().Get('variantCode'), 1, MaxStrLen(VariantCode));

        if (Request.QueryParams().ContainsKey('admissionCode')) then
            AdmissionCode := CopyStr(Request.QueryParams().Get('admissionCode'), 1, MaxStrLen(AdmissionCode));

        DynamicPrice.FindPriceProfiles(ItemNumber, VariantCode, AdmissionCode, TempPriceProfiles);

        exit(PriceProfileDTO(TempPriceProfiles));
    end;


    local procedure GetDynamicPriceProfileWhereUsedByAdmissionSchedule(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
        TempPriceProfiles: Record "NPR TM DynamicPriceItemList" temporary;
        AdmissionCode, ScheduleCode : Code[20];
    begin
        if (not Request.QueryParams().ContainsKey('admissionCode')) then
            exit(Response.RespondBadRequest('Missing required parameter: admissionCode'));
        AdmissionCode := CopyStr(Request.QueryParams().Get('admissionCode'), 1, MaxStrLen(AdmissionCode));

        if (Request.QueryParams().ContainsKey('scheduleCode')) then
            ScheduleCode := CopyStr(Request.QueryParams().Get('scheduleCode'), 1, MaxStrLen(ScheduleCode));

        DynamicPrice.FindPriceProfiles(AdmissionCode, ScheduleCode, TempPriceProfiles);

        exit(PriceProfileDTO(TempPriceProfiles));
    end;


    local procedure GetDynamicPriceProfileWhereUsedByProfileCode(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
        TempPriceProfiles: Record "NPR TM DynamicPriceItemList" temporary;
        ProfileCode: Code[10];
    begin
        if (not Request.QueryParams().ContainsKey('profileCode')) then
            exit(Response.RespondBadRequest('Missing required parameter: profileCode'));
        ProfileCode := CopyStr(Request.QueryParams().Get('profileCode'), 1, MaxStrLen(ProfileCode));

        DynamicPrice.FindPriceProfiles(ProfileCode, TempPriceProfiles);

        exit(PriceProfileDTO(TempPriceProfiles));
    end;

    local procedure PriceProfileDTO(var TempPriceProfiles: Record "NPR TM DynamicPriceItemList" temporary) Response: Codeunit "NPR API Response"
    var
        ResultJson: Codeunit "NPR Json Builder";
        ShowProfileCode: Code[10];
        ListOfProfileCodes: List of [Code[10]];
        ProfileCode: Code[10];
    begin
        TempPriceProfiles.Reset();

        ResultJson.StartObject().StartArray('priceProfileAssignments');
        TempPriceProfiles.SetAutoCalcFields(AdmissionSchedulePriceCode);

        if (TempPriceProfiles.FindSet()) then begin
            repeat
                ShowProfileCode := TempPriceProfiles.AdmissionSchedulePriceCode;
                if (TempPriceProfiles.ItemPriceCode <> '') then
                    ShowProfileCode := TempPriceProfiles.ItemPriceCode;

                if (ShowProfileCode <> '') then
                    if (not ListOfProfileCodes.Contains(ShowProfileCode)) then
                        ListOfProfileCodes.Add(ShowProfileCode);

                ResultJson.StartObject()
                    .AddProperty('itemNo', TempPriceProfiles.ItemNo)
                    .AddProperty('variantCode', TempPriceProfiles.VariantCode)
                    .AddProperty('admissionCode', TempPriceProfiles.AdmissionCode)
                    .AddProperty('scheduleCode', TempPriceProfiles.ScheduleCode)
                    .AddProperty('priceProfileCode', ShowProfileCode)
                    .EndObject();

            until (TempPriceProfiles.Next() = 0);
        end;
        ResultJson.EndArray();

        ResultJson.StartArray('priceProfiles');
        foreach ProfileCode in ListOfProfileCodes do
            ResultJson.StartObject().AddProperty('profileCode', ProfileCode).AddArray(PriceProfileLinesDTO(ResultJson, ProfileCode)).EndObject();

        ResultJson.EndArray()
            .EndObject();

        exit(Response.RespondOK(ResultJson.Build()));
    end;


    local procedure PriceProfileLinesDTO(ResultJson: Codeunit "NPR Json Builder"; ProfileCode: Code[20]): Codeunit "NPR Json Builder"
    var
        DynamicPriceRuleQuery: Query "NPR TMDynamicPriceProfileRule";
    begin
        ResultJson.StartArray('lines');

        DynamicPriceRuleQuery.SetFilter(ProfileCode, '=%1', ProfileCode);
        if (DynamicPriceRuleQuery.Open()) then
            while (DynamicPriceRuleQuery.Read()) do begin
                ResultJson.StartObject()
                    .AddProperty('id', Format(DynamicPriceRuleQuery.SystemId, 0, 4))
                    .AddProperty('lineNo', DynamicPriceRuleQuery.LineNo)

                    .AddProperty('amount', DynamicPriceRuleQuery.Amount)
                    .AddProperty('amountIncludesVAT', DynamicPriceRuleQuery.AmountIncludesVAT)

                    .AddProperty('blocked', DynamicPriceRuleQuery.Blocked)

                    .AddObject(AddValueOrNull(ResultJson, 'bookingDateFrom', DynamicPriceRuleQuery.BookingDateFrom))
                    .AddObject(AddValueOrNull(ResultJson, 'bookingDateUntil', DynamicPriceRuleQuery.BookingDateUntil))
                    .AddProperty('description', DynamicPriceRuleQuery.Description)
                    .AddObject(AddValueOrNull(ResultJson, 'eventDateFrom', DynamicPriceRuleQuery.EventDateFrom))
                    .AddObject(AddValueOrNull(ResultJson, 'eventDateUntil', DynamicPriceRuleQuery.EventDateUntil))
                    .AddProperty('percentage', DynamicPriceRuleQuery.Percentage)
                    .AddProperty('pricingOption', DynamicPriceRuleQuery.PricingOption)
                    .AddProperty('relativeBookingDateFormula', Format(DynamicPriceRuleQuery.RelativeBookingDateFormula, 0, 9))
                    .AddProperty('relativeEventDateFormula', Format(DynamicPriceRuleQuery.RelativeEventDateFormula, 0, 9))
                    .AddProperty('relativeUntilEventDate', Format(DynamicPriceRuleQuery.RelativeUntilEventDate, 0, 9))
                    .AddProperty('roundingDirection', DynamicPriceRuleQuery.RoundingDirection)
                    .AddProperty('roundingPrecision', DynamicPriceRuleQuery.RoundingPrecision)
                    .EndObject();
            end;
        ResultJson.EndArray();

        exit(ResultJson);
    end;

    local procedure AddValueOrNull(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: Date): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue <> 0D) then
            ResponseJson.AddProperty(PropertyName, PropertyValue)
        else
            ResponseJson.AddProperty(PropertyName);
        exit(ResponseJson);
    end;


}
#endif