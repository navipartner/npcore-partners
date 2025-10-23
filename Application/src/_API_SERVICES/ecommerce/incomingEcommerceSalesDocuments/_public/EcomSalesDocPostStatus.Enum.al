/// <summary>
/// Defines the posting status for ecommerce sales documents.
/// Indicates whether a document is pending, partially invoiced, or fully invoiced.
/// </summary>
enum 6059945 "NPR EcomSalesDocPostStatus"
{
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
