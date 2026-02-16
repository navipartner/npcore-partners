table 6059890 "NPR MM Loyalty Jnl Line Tag"
{
    DataClassification = CustomerContent;
    Caption = 'Loyalty Journal Line Tag';
    Extensible = False;
    Access = Internal;

    fields
    {
        field(1; "Journal Line Entry No."; Integer)
        {
            Caption = 'Journal Line Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM MembershipLoyaltyJnl".EntryNo;
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
        key(Key1; "Journal Line Entry No.", "Tag Key", "Tag Value")
        {
            Clustered = true;
        }
    }
}
