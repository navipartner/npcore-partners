table 6150632 "NPR POS Sales Document Setup"
{
    Access = Internal;
    Caption = 'POS Sales Document Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Post with Job Queue"; Boolean)
        {
            Caption = 'Post with Job Queue';
            DataClassification = CustomerContent;
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
