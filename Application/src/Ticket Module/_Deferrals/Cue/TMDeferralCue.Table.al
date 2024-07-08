table 6150782 "NPR TM DeferralCue"
{
    Access = Internal;
    TableType = Temporary;
    Caption = 'Ticket Deferral Cue';

    fields
    {
        field(1; DeferralCueID; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Deferral Cue ID';
        }
        field(10; UnresolvedCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Unresolved Count';
        }
        field(20; PendingDeferralCount; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Pending Deferral Count';
        }
    }

    keys
    {
        key(PK; DeferralCueID)
        {
            Clustered = true;
        }
    }
}

