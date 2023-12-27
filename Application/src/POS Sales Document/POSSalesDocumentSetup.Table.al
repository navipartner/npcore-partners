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
            trigger OnValidate()
            var
            begin
                if not Rec."Post with Job Queue" then
                    Rec."Generate Posting No." := false;
            end;
        }
        field(20; "Generate Posting No."; Boolean)
        {
            Caption = 'Generate Posting No. for Scheduled Documents';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                if Rec."Generate Posting No." then
                    Rec.TestField("Post with Job Queue", true);
            end;
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
