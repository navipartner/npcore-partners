table 6150721 "NPR POS Theme"
{
    Access = Internal;
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    Caption = 'POS Theme';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Dependency: Record "NPR POS Theme Dependency";
    begin
        Dependency.SetRange("POS Theme Code", Code);
        Dependency.DeleteAll();
    end;
}

