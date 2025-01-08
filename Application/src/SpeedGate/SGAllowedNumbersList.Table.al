table 6150986 "NPR SG AllowedNumbersList"
{
    DataClassification = CustomerContent;
    Access = Internal;

    LookupPageId = "NPR SG AllowedNumbersLists";

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

        field(20; ValidateMode; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Validate Mode';
            OptionMembers = FLEXIBLE,STRICT;
            OptionCaption = 'Flexible (allow undefined),Strict (reject undefined)';
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
            Caption = 'Speedgate Number White List';
        }
    }


    trigger OnDelete()
    var
        NumberWhiteListLine: Record "NPR SG NumberWhiteListLine";
    begin
        NumberWhiteListLine.SetFilter(Code, '=%1', Rec.Code);
        NumberWhiteListLine.DeleteAll();
    end;

}