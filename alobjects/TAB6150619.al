table 6150619 "POS Unit to Bin Relation"
{
    // NPR5.36/TSA /20170707 CASE 282251 First Version
    // NPR5.40/TSA /20180302 CASE 282251 Changed primary key to include bin number

    Caption = 'POS Unit to Bin Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Unit";
        }
        field(2; "POS Payment Bin No."; Code[10])
        {
            Caption = 'POS Payment Bin No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Payment Bin";
        }
        field(10; "POS Unit Status"; Option)
        {
            CalcFormula = Lookup ("POS Unit".Status WHERE("No." = FIELD("POS Unit No.")));
            Caption = 'POS Unit Status';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Open,Closed,End of Day';
            OptionMembers = OPEN,CLOSED,ENDOFDAY;
        }
        field(11; "POS Unit Name"; Text[50])
        {
            CalcFormula = Lookup ("POS Unit".Name WHERE("No." = FIELD("POS Unit No.")));
            Caption = 'POS Unit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "POS Payment Bin Status"; Option)
        {
            CalcFormula = Lookup ("POS Payment Bin".Status WHERE("No." = FIELD("POS Payment Bin No.")));
            Caption = 'POS Payment Bin Status';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Open,Closed,Being Counted';
            OptionMembers = OPEN,CLOSED,BEING_COUNTED;
        }
        field(21; "POS Payment Bin Description"; Text[50])
        {
            CalcFormula = Lookup ("POS Payment Bin".Description WHERE("No." = FIELD("POS Payment Bin No.")));
            Caption = 'POS Payment Bin Description';
            Enabled = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "POS Unit No.", "POS Payment Bin No.")
        {
        }
    }

    fieldgroups
    {
    }
}

