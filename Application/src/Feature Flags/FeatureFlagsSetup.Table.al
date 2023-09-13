table 6060034 "NPR Feature Flags Setup"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Feature Flag Setup';
    DataPerCompany = false;
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; Identifier; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Identifier';
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }


}