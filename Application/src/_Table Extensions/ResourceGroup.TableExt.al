tableextension 6014420 "NPR Resource Group" extends "Resource Group"
{
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

