#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059873 "NPR SalesApiFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }
    value(10; GET_SALES_INVOICE_PDF)
    {
        Caption = 'get sales invoice as PDF';
    }
}
#endif