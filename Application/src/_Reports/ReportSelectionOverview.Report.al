report 6014613 "NPR Report Selection Overview"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Report Selection Overview.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Report Selection Overview';
    DataAccessIntent = ReadOnly;
    requestpage
    {
        SaveValues = true;
    }
}

