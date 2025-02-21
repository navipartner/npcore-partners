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
                    .AddProperty('amount', DynamicPriceRuleQuery.Amount)
                    .AddProperty('amountIncludesVAT', DynamicPriceRuleQuery.AmountIncludesVAT)
                    .AddProperty('blocked', DynamicPriceRuleQuery.Blocked)
                    .AddProperty('bookingDateFrom', DynamicPriceRuleQuery.BookingDateFrom)
                    .AddProperty('bookingDateUntil', DynamicPriceRuleQuery.BookingDateUntil)
                    .AddProperty('description', DynamicPriceRuleQuery.Description)
                    .AddProperty('eventDateFrom', DynamicPriceRuleQuery.EventDateFrom)
                    .AddProperty('eventDateUntil', DynamicPriceRuleQuery.EventDateUntil)
                    .AddProperty('lineNo', DynamicPriceRuleQuery.LineNo)
                    .AddProperty('percentage', DynamicPriceRuleQuery.Percentage)
                    .AddProperty('pricingOption', DynamicPriceRuleQuery.PricingOption)
                    .AddProperty('profileCode', DynamicPriceRuleQuery.ProfileCode)
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
}
#endif