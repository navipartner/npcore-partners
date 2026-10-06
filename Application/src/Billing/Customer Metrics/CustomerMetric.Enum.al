enum 6014660 "NPR Customer Metric" implements "NPR ICustomer Metric"
{
    Access = Internal;
    Extensible = false;

    value(1; ActivePOSUnits7D)
    {
        Caption = 'Active POS Units (7 Days)';
        Implementation = "NPR ICustomer Metric" = "NPR Active POS Units Metric";
    }
}
