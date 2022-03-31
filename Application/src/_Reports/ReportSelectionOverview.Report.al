report 6014613 "NPR Report Selection Overview"
{
    //Obsolete
    
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Report Selection Overview.rdlc';
    UsageCategory = None;
    Caption = 'Report Selection Overview';
    DataAccessIntent = ReadOnly;
}

