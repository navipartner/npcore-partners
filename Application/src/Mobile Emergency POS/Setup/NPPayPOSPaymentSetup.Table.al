table 6150972 "NPR NP Pay POS Payment Setup"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR NP Pay POS Payment Setups";
    LookupPageId = "NPR NP Pay POS Payment Setups";
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Encryption Key Id"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Encryption Key Version"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Encryption Key Password"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Payment API Key"; Text[500])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(6; "Merchant Account"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(7; Environment; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Test","Live";
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}