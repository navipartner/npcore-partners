report 6151051 "NPR Retail Replnm. Item Update"
{
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

