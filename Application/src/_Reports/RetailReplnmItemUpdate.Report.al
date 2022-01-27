report 6151051 "NPR Retail Replnm. Item Update"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    Caption = 'Retail Replnm. Exclude Item Update';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    dataset
    {
        dataitem(Item; Item)
        {
        }
    }
    requestpage
    {
        SaveValues = true;
    }
}

