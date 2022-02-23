table 6014575 "NPR Package Printers"
{
    Access = Public;
    Caption = 'Package Printers';
    fields
    {
        field(1; Name; Text[50])
        {
            Caption = 'Printernavn';
            DataClassification = CustomerContent;
        }
        field(2; "Host Name"; Text[50])
        {
            Caption = 'Printer hostnavn';
            DataClassification = CustomerContent;
        }
        field(3; Printer; Text[50])
        {
            Caption = 'Printer';
            DataClassification = CustomerContent;
        }
        field(4; "Label Format"; Text[30])
        {
            Caption = 'Labelformat';
            DataClassification = CustomerContent;
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Profil ID';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(6; "User ID"; Guid)
        {
            TableRelation = User;
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(7; "User Name"; text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(user."User Name" where("user security ID" = field("user ID")));
        }
    }

    keys
    {
        key(Key1; Name, "Location Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, "Host Name", Printer, "Label Format")
        {
        }
    }
}

