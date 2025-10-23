enum 6059905 "NPR IncEcomSalesDocPostStatus"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with NPR EcomSalesDocPostStatus';
    Extensible = false;
    value(0; "Pending")
    {
        Caption = 'Pending';
    }

    value(1; "Partially Invoiced")
    {
        Caption = 'Partially Invoiced';
    }
    value(4; "Invoiced")
    {
        Caption = 'Invoiced';
    }
}
