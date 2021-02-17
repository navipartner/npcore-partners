table 6014416 "NPR Alternative No."
{
    Caption = 'Alternative No.';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "Alt. No."; Code[20])
        {
            Caption = 'Alternative No.';
            DataClassification = CustomerContent;
        }
        field(3; "Created the"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Customer,CRM Customer,Register drawer,Salesperson';
            OptionMembers = Item,Customer,"CRM Customer",Register,SalesPerson;
            DataClassification = CustomerContent;
        }
        field(5; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(7; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(8; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(9; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(10; "Blocked Reason Code"; Code[10])
        {
            Caption = 'Blocked Reason';
            DataClassification = CustomerContent;
        }
        field(12; Discontinue; Boolean)
        {
            Caption = 'Discontinue Bar Code';
            DataClassification = CustomerContent;
        }
        field(5000; Auto; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
        }
        field(6014400; "Variant Description"; Text[100])
        {
            Caption = 'Variant Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Code", "Alt. No.")
        {
        }
    }

    fieldgroups
    {
    }
}

