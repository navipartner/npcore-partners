tableextension 6014420 tableextension6014420 extends "Resource Group"
{
    // NPR5.29/TJ/20161124 CASE 248723 New field 6060150 E-Mail
    fields
    {
        field(6060150; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
        }
    }
}

