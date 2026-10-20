enum 6014660 "NPR Customer Metric" implements "NPR ICustomer Metric"
{
    Access = Internal;
    Extensible = false;

    value(1; ActivePOSUnits7D)
    {
        Caption = 'Active POS Units (7 Days)';
        Implementation = "NPR ICustomer Metric" = "NPR Active POS Units Metric";
    }
    value(2; GLRevenue)
    {
        Caption = 'G/L Revenue';
        Implementation = "NPR ICustomer Metric" = "NPR GL Revenue Metric";
    }
    value(3; TicketsSold)
    {
        Caption = 'Tickets Sold';
        Implementation = "NPR ICustomer Metric" = "NPR Tickets Sold Metric";
    }
    value(4; ZReportRevenue)
    {
        Caption = 'POS Z-Report Revenue';
        Implementation = "NPR ICustomer Metric" = "NPR Z-Report Revenue Metric";
    }
}
