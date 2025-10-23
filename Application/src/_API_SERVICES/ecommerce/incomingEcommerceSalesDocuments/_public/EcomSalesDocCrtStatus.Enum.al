/// <summary>
/// Defines the creation status for ecommerce sales documents.
/// Tracks document lifecycle from pending through created, canceled, or error states.
/// </summary>
enum 6059944 "NPR EcomSalesDocCrtStatus"
{
    Extensible = false;
    value(0; "Pending")
    {
        Caption = 'Pending';
    }

    value(1; "Created")
    {
        Caption = 'Created';
    }

    value(2; "Canceled")
    {
        Caption = 'Canceled';
    }

    value(4; "Error")
    {
        Caption = 'Error';
    }

}
