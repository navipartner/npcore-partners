table 6151262 "NPR MemberImageMigrateToCFR2"
{
    Access = Internal;
    Extensible = false;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';

        }

        field(10; TaskId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Migration Task ID';
        }

        field(20; StartTime; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Migration Start Time';
        }
        field(30; CompletionTime; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Migration Completion Time';
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
