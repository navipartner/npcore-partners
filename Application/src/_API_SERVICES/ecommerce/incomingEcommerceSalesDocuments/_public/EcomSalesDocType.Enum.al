/// <summary>
/// Defines document types for ecommerce sales transactions.
/// Distinguishes between regular sales orders and return orders.
/// </summary>
enum 6059941 "NPR Ecom Sales Doc Type"
{
    Extensible = false;
    value(1; "Order")
    {
        Caption = 'Order';
    }

    value(2; "Return Order")
    {
        Caption = 'Return Order';
    }
}