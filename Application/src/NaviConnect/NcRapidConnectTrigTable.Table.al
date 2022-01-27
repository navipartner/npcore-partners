table 6151091 "NPR Nc RapidConnect Trig.Table"
{
    Access = Internal;
    Caption = 'Nc RapidConnect Trigger Table';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used - Inter-company synchronizations will happen via the API replication module';

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(10; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Insert Trigger"; Option)
        {
            Caption = 'Insert Trigger';
            DataClassification = CustomerContent;
            Description = 'NC2.14';
            InitValue = Full;
            OptionCaption = 'None,Full';
            OptionMembers = "None",Full;
        }
        field(20; "Modify Trigger"; Option)
        {
            Caption = 'Modify Trigger';
            DataClassification = CustomerContent;
            Description = 'NC2.14';
            InitValue = Full;
            OptionCaption = 'None,Full,Partial';
            OptionMembers = "None",Full,Partial;
        }
        field(1000; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Config. Package";
        }
        field(1005; "Export Enabled"; Boolean)
        {
            Caption = 'Export Enabled';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(1010; "Task Processor Code"; Code[20])
        {
            Caption = 'Task Processor Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR Nc Task Processor";
        }
        field(1015; "Trigger Fields"; Integer)
        {
            Caption = 'Trigger Fields';
            DataClassification = CustomerContent;
            Description = 'NC2.14';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Setup Code", "Table ID")
        {
        }
    }
}

