enum 6014495 "NPR MPOS Data View Category" implements "NPR MPOS IDataViewCategory"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
        Implementation = "NPR MPOS IDataViewCategory" = "NPR MPOS Data View - Bar. Inv.";
    }
    value(1; "Barcode Inventory")
    {
        Caption = 'Inventory from Barcode';
        Implementation = "NPR MPOS IDataViewCategory" = "NPR MPOS Data View - Bar. Inv.";
    }
}