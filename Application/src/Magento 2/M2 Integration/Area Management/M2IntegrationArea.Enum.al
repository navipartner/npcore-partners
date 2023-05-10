enum 6014534 "NPR M2 Integration Area"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

#if not (BC17 or BC18 or BC19 or BC20)
    value(1; "MSI Stock Data")
    {
        Caption = 'Multi Source Inventory Integration';
    }
#endif
}