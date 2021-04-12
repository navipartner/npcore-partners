report 6014555 "NPR Attribute Filter"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/NPR Attribute Filter.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'NPR Attribute Filter';

    dataset
    {
        dataitem("NPR Attribute Value Set"; "NPR Attribute Value Set")
        {
            RequestFilterFields = "Attribute Code", "Text Value";
        }
    }
}

