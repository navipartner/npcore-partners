enum 6014481 "NPR Print Object Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    value(0; No_Print)
    {
        Caption = 'No Print';
    }
    value(1; "Codeunit")
    {
        Caption = 'Codeunit';
    }
    value(2; "Report")
    {
        Caption = 'Report';
    }
    value(3; Template)
    {
        Caption = 'Template';
    }
}
