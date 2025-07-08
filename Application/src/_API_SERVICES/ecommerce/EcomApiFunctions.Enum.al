#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059868 "NPR EcomApiFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }
    value(50; CREATE_SALES_DOCUMENT)
    {
        Caption = 'create sales document';
    }
    value(60; GET_SALES_DOCUMENT)
    {
        Caption = 'get sales document';
    }
}
#endif