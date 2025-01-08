table 6150997 "NPR SG MemberCardProfile"
{
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "NPR SG MemberCardProfiles";
    Caption = 'MemberCard Profiles';
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
            Caption = 'MemberCard Profiles for Speedgate';
        }
    }

    trigger OnDelete()
    var
        MemberCardProfileLine: Record "NPR SG MemberCardProfileLine";
    begin
        MemberCardProfileLine.SetFilter(Code, '=%1', Rec.Code);
        MemberCardProfileLine.DeleteAll();
    end;
}