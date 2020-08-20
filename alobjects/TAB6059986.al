table 6059986 "Sale POS Cue"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name

    Caption = 'Sale POS Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Saved Sales"; Integer)
        {
            CalcFormula = Count ("Sale POS" WHERE("Saved Sale" = CONST(true),
                                                  "Register No." = FIELD("Register Filter"),
                                                  "Salesperson Code" = FIELD("Salesperson Filter"),
                                                  Date = FIELD("Date Filter")));
            Caption = 'Saved Sales';
            FieldClass = FlowField;
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(25; "Register Filter"; Code[10])
        {
            Caption = 'Cash Register Filter';
            FieldClass = FlowFilter;
        }
        field(26; "Salesperson Filter"; Code[10])
        {
            Caption = 'Salesperson Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

