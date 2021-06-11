table 6059899 "NPR Data Log Field"
{
    //   - This Table contains Field Values of logged Record Changes.

    Caption = 'Data Log Field';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(20; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(21; "Field Value"; Text[250])
        {
            Caption = 'Field Value';
            DataClassification = CustomerContent;
        }
        field(30; "Log Date"; DateTime)
        {
            Caption = 'Log Date';
            DataClassification = CustomerContent;
        }
        field(50; "Field Value Changed"; Boolean)
        {
            Caption = 'Field Value Changed';
            DataClassification = CustomerContent;
        }
        field(51; "Previous Field Value"; Text[250])
        {
            Caption = 'Previous Field Value';
            DataClassification = CustomerContent;
        }
        field(100; "Data Log Record Entry No."; BigInteger)
        {
            Caption = 'Data Log Record Entry No.';
            Editable = false;
            TableRelation = "NPR Data Log Record";
            DataClassification = CustomerContent;
        }
        field(110; "User ID"; Code[250])
        {
            CalcFormula = Lookup("NPR Data Log Record"."User ID" WHERE("Entry No." = FIELD("Data Log Record Entry No.")));
            Caption = 'User ID';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1000; "Field Name"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table ID"),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Obsolete State"; Option)
        {
            OptionMembers = No,Pending,Removed;
            OptionCaption = 'No,Pending,Removed';
            Caption = 'Obsolete State';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Field".ObsoleteState where(TableNo = field("Table ID"), "No." = field("Field No.")));
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table ID", "Data Log Record Entry No.")
        {
        }
        key(Key3; "Log Date", "Table ID")
        {
        }
    }

    fieldgroups
    {
    }
}

