enum 6059904 "NPR MemberAlterPriceFunction" implements "NPR IMemberAlterationPriceHandler"
{
    Caption = 'Member Alteration Price Function';
    Extensible = true;

    value(0; UNIT_PRICE)
    {
        Caption = 'Unit Price';
        Implementation = "NPR IMemberAlterationPriceHandler" = "NPR MemberAlterUnitPrice";
    }
    value(1; PRICE_DIFFERENCE)
    {
        Caption = 'Price Difference';
        Implementation = "NPR IMemberAlterationPriceHandler" = "NPR MemberAlterPriceDifference";
    }
    value(2; TIME_DIFFERENCE)
    {
        Caption = 'Time Difference';
        Implementation = "NPR IMemberAlterationPriceHandler" = "NPR MemberAlterTimeDifference";
    }
}