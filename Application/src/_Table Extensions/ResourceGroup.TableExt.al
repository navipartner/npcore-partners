tableextension 6014420 "NPR Resource Group" extends "Resource Group"
{
    // NPR5.29/TJ/20161124 CASE 248723 New field 6060150 E-Mail
    fields
    {
        field(6060150; "NPR E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
        }
    }
}

