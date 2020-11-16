table 6150700 "NPR POS Menu"
{
    // NPR5.30/TJ  /20170215  CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.45/MHA /20180813  CASE 324677 Added cleanup to OnDelete()

    Caption = 'POS Menu';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Menus";
    LookupPageID = "NPR POS Menus";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; Caption; Text[50])
        {
            Caption = 'Caption';
            DataClassification = CustomerContent;
        }
        field(4; Tooltip; Text[250])
        {
            Caption = 'Tooltip';
            DataClassification = CustomerContent;
        }
        field(5; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(6; "Custom Class Attribute"; Text[30])
        {
            Caption = 'Custom Class Attribute';
            DataClassification = CustomerContent;
        }
        field(41; "Register Type"; Code[10])
        {
            Caption = 'Cash Register Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register Types";
        }
        field(42; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(44; "Available on Desktop"; Boolean)
        {
            Caption = 'Available on Desktop';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(45; "Available in App"; Boolean)
        {
            Caption = 'Available in App';
            DataClassification = CustomerContent;
            InitValue = true;
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
        POSMenuButton: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        //-NPR5.45 [324677]
        POSParameterValue.SetRange("Table No.", DATABASE::"NPR POS Menu Button");
        POSParameterValue.SetRange(Code, Code);
        if POSParameterValue.FindFirst then
            POSParameterValue.DeleteAll;

        POSMenuButton.SetRange("Menu Code", Code);
        if POSMenuButton.FindFirst then
            POSMenuButton.DeleteAll;
        //+NPR5.45 [324677]
    end;

    var
        Text001: Label 'The value for %1 you provided (%1) is not in the correct format. It has been automatically corrected.';
}

