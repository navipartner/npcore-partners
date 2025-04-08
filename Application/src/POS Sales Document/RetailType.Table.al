table 6151147 "NPR Retail Type"
{
    Access = Internal;
    Caption = 'Retail Type';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Retail Type"; Code[20])
        {
            Caption = 'Retail Type';
            DataClassification = CustomerContent;
        }
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Retail Type")
        {
            Clustered = true;
        }
    }
}
