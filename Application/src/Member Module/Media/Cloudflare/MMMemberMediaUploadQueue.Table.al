table 6060012 "NPR MM MemberMediaUploadQueue"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Caption = 'Member Media Upload Queue';

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(10; MemberSystemId; Guid)
        {
            Caption = 'Member System Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PrimaryKey; EntryNo)
        {
            Clustered = true;
        }

        key(MemberSystemIdIdx; MemberSystemId)
        {
            Clustered = false;
        }
    }

}