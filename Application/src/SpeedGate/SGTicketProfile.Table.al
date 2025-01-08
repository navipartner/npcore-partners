table 6150983 "NPR SG TicketProfile"
{
    DataClassification = CustomerContent;
    Access = Internal;

    LookupPageId = "NPR SG TicketProfiles";

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(10; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }

        field(100; ValidationMode; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Validate Mode';
            OptionMembers = FLEXIBLE,STRICT;
            OptionCaption = 'Flexible (allow undefined),Strict (reject undefined)';
            InitValue = STRICT;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Main; Code, Description)
        {
            Caption = 'Ticket Profiles for Speedgate';
        }
    }

    trigger OnDelete()
    var
        TicketProfileLine: Record "NPR SG TicketProfileLine";
    begin
        TicketProfileLine.SetFilter(Code, '=%1', Rec.Code);
        TicketProfileLine.DeleteAll();
    end;
}