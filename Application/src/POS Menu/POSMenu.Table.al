table 6150700 "NPR POS Menu"
{
    Access = Internal;
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Fields are not used. Removed in case 508876.';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Fields are not used. Removed in case 508876.';
        }
        field(6; "Custom Class Attribute"; Text[30])
        {
            Caption = 'Custom Class Attribute';
            DataClassification = CustomerContent;
        }
        field(41; "Register Type"; Code[20])
        {
            Caption = 'POS View Profile';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Fields are not used. Removed in case 508876.';
        }
        field(42; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(44; "Available on Desktop"; Boolean)
        {
            Caption = 'Available on Desktop';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(45; "Available in App"; Boolean)
        {
            Caption = 'Available in App';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; Blocked, "Register Type", "Register No.", "Salesperson Code")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Fields are not used. Removed in case 508876.';
        }
        key(Key3; "Register No.", "Salesperson Code")
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
        POSParameterValue.SetRange("Table No.", DATABASE::"NPR POS Menu Button");
        POSParameterValue.SetRange(Code, Code);
        if POSParameterValue.FindFirst() then
            POSParameterValue.DeleteAll();

        POSMenuButton.SetRange("Menu Code", Code);
        if POSMenuButton.FindFirst() then
            POSMenuButton.DeleteAll();
    end;
}

