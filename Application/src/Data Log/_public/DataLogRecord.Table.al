table 6059898 "NPR Data Log Record"
{
    Access = Public;
    Caption = 'Data Log Record';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(6; "Old Record ID"; RecordID)
        {
            Caption = 'Old Record ID';
            DataClassification = CustomerContent;
        }
        field(10; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(20; "Log Date"; DateTime)
        {
            Caption = 'Log Date';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-12-27';
            ObsoleteReason = 'Use the SystemCreatedAt field instead';
        }
        field(21; "Type of Change"; Option)
        {
            Caption = 'Type of Change';
            OptionCaption = 'Insert,Modify,Rename,Delete';
            OptionMembers = Insert,Modify,Rename,Delete;
            DataClassification = CustomerContent;
        }
        field(30; "Field Values"; Integer)
        {
            CalcFormula = Count("NPR Data Log Field" WHERE("Table ID" = FIELD("Table ID"),
                                                        "Data Log Record Entry No." = FIELD("Entry No.")));
            Caption = 'Field Values';
            FieldClass = FlowField;
        }
        field(110; "User ID"; Code[250])
        {
            Caption = 'User ID';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(1000; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table ID")
        {
        }
        key(Key3; "Log Date", "Table ID")
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2025-12-27';
            ObsoleteReason = 'Use one of the retention keys instead';
        }
        key(Retention; "Table ID", SystemCreatedAt) { }
        key(Retention2; SystemCreatedAt) { }
    }

    fieldgroups
    {
    }
}

