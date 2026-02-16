table 6059888 "NPR MM Member Point Entry Tag"
{
    DataClassification = CustomerContent;
    Caption = 'Member Point Entry Tag';
    Extensible = False;
    Access = Internal;

    fields
    {
        field(1; "Member Point Entry No."; Integer)
        {
            Caption = 'Member Point Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Members. Points Entry"."Entry No.";
        }

        field(10; "Tag Key"; Code[20])
        {
            Caption = 'Tag Key';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Tag"."Key";
        }

        field(20; "Tag Value"; Code[100])
        {
            Caption = 'Tag Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Member Point Entry No.", "Tag Key", "Tag Value")
        {
            Clustered = true;
        }
    }
}
