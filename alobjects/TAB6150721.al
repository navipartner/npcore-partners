table 6150721 "POS Theme"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    Caption = 'POS Theme';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Dependency: Record "POS Theme Dependency";
    begin
        Dependency.SetRange("POS Theme Code",Code);
        Dependency.DeleteAll();
    end;
}

