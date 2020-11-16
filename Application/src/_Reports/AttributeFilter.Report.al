report 6014555 "NPR Attribute Filter"
{
    // NPR5.37/MHA /20171026  Object created - NPR Attribute Filter
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ReqFilterFields property referencing to invalid field1030
    // NPR5.38/JLK /20180125  CASE 303595 Added ENU object caption
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/NPR Attribute Filter.rdlc';

    Caption = 'NPR Attribute Filter';

    dataset
    {
        dataitem("NPR Attribute Value Set"; "NPR Attribute Value Set")
        {
            RequestFilterFields = "Attribute Code", "Text Value";
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }
}

