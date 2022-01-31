enum 6014486 "NPR Shipping Provider Enum" implements "NPR IShipping Provider Interface"
{
    Extensible = true;


    value(0; Shipmondo)
    {
        Caption = 'Shipmondo';
        Implementation = "NPR IShipping Provider Interface" = "NPR Shipmondo Mgnt.";
    }
    value(1; Pacsoft)
    {
        Caption = 'Pacsoft';
        Implementation = "NPR IShipping Provider Interface" = "NPR Pacsoft Management";
    }
    value(2; Consignor)
    {
        Caption = 'Consignor';
        Implementation = "NPR IShipping Provider Interface" = "NPR Consignor Mgt.";
    }

}