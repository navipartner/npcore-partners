table 6059898 "Data Log Record"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Table contains Record ID's of logged Record Changes.
    // DL1.04/MH/20141017  CASE 187739 NP-AddOn: Data Log
    //   - Renamed table from Integration Record.
    // DL1.06/MH/20150126  CASE 203653 Added Log Date to Key for optimizing Cleanup: Log Date,Table ID.

    Caption = 'Data Log Record';

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Record ID";RecordID)
        {
            Caption = 'Record ID';
        }
        field(6;"Old Record ID";RecordID)
        {
            Caption = 'Old Record ID';
        }
        field(10;"Table ID";Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(20;"Log Date";DateTime)
        {
            Caption = 'Log Date';
        }
        field(21;"Type of Change";Option)
        {
            Caption = 'Type of Change';
            OptionCaption = 'Insert,Modify,Rename,Delete';
            OptionMembers = Insert,Modify,Rename,Delete;
        }
        field(30;"Field Values";Integer)
        {
            CalcFormula = Count("Data Log Field" WHERE ("Table ID"=FIELD("Table ID"),
                                                        "Data Log Record Entry No."=FIELD("Entry No.")));
            Caption = 'Field Values';
            FieldClass = FlowField;
        }
        field(110;"User ID";Code[250])
        {
            Caption = 'User ID';
            Editable = false;
        }
        field(1000;"Table Name";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Table ID")
        {
        }
        key(Key3;"Log Date","Table ID")
        {
        }
    }

    fieldgroups
    {
    }
}

