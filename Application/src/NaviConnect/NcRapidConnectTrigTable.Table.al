table 6151091 "NPR Nc RapidConnect Trig.Table"
{
    Caption = 'Nc RapidConnect Trigger Table';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Nc RapidConnect Setup";
        }
        field(5; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));

            trigger OnLookup()
            var
                NcRapidConnectSetupMgt: Codeunit "NPR Nc RapidConnect Setup Mgt.";
                ObjectId: Integer;
            begin
                if NcRapidConnectSetupMgt.LookupTriggerTableID("Setup Code", ObjectId) then
                    Validate("Table ID", ObjectId);
            end;

            trigger OnValidate()
            begin
                TestTableID();
            end;
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
            CalcFormula = Lookup("NPR Nc RapidConnect Setup"."Package Code" WHERE(Code = FIELD("Setup Code")));
            Caption = 'Package Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Config. Package";
        }
        field(1005; "Export Enabled"; Boolean)
        {
            CalcFormula = Lookup("NPR Nc RapidConnect Setup"."Export Enabled" WHERE(Code = FIELD("Setup Code")));
            Caption = 'Export Enabled';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Task Processor Code"; Code[20])
        {
            CalcFormula = Lookup("NPR Nc RapidConnect Setup"."Task Processor Code" WHERE(Code = FIELD("Setup Code")));
            Caption = 'Task Processor Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "NPR Nc Task Processor";
        }
        field(1015; "Trigger Fields"; Integer)
        {
            CalcFormula = Count("NPR Nc RapidConnect Trig.Field" WHERE("Setup Code" = FIELD("Setup Code"),
                                                                       "Table ID" = FIELD("Table ID")));
            Caption = 'Trigger Fields';
            Description = 'NC2.14';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Setup Code", "Table ID")
        {
        }
    }

    var
        Text000: Label 'Table ID %1 is not included in Config. Package %2';

    local procedure TestTableID()
    var
        NcRapidConnectSetupMgt: Codeunit "NPR Nc RapidConnect Setup Mgt.";
    begin
        if NcRapidConnectSetupMgt.IsValidTableID("Setup Code", "Table ID") then
            exit;

        CalcFields("Package Code");
        Error(Text000, "Table ID", "Package Code");
    end;
}

