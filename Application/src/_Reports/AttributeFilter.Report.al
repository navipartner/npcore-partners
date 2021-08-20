report 6014555 "NPR Attribute Filter"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/NPR Attribute Filter.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'NPR Attribute Filter';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("NPR Attribute Value Set"; "NPR Attribute Value Set")
        {
            RequestFilterFields = "Attribute Code", "Text Value";
        }
    }
}

