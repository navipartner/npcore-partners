enum 6014494 "NPR MPOS Data View Type" implements "NPR MPOS IDataViewType"
{
    Extensible = true;

    value(0; NaviConnect)
    {
        Caption = 'NaviConnect';
        Implementation = "NPR MPOS IDataViewType" = "NPR MPOS Data View NaviConnect";
    }
}