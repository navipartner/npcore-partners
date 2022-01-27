table 6151502 "NPR Nc Task"
{
    Caption = 'Nc Task';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Insert,Modify,Delete,Rename';
            OptionMembers = Insert,Modify,Delete,Rename;
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
            Editable = false;
        }
        field(4; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Description = 'NC1.14';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Record Position"; Text[200])
        {
            Caption = 'Record Position';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
            Editable = false;
        }
        field(6; "Log Date"; DateTime)
        {
            Caption = 'Log Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Company Name"; Text[80])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            Description = 'NC1.22';
        }
        field(9; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Last Processing Started at"; DateTime)
        {
            Caption = 'Last Processing Started at';
            DataClassification = CustomerContent;
            Description = 'NC1.14';
            Editable = false;
        }
        field(11; "Process Error"; Boolean)
        {
            Caption = 'Error';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Clear(Response);
            end;
        }
        field(12; "Process Count"; Integer)
        {
            Caption = 'Process Count';
            DataClassification = CustomerContent;
            Description = 'NC1.01';
            Editable = false;
        }
        field(15; "Last Processing Completed at"; DateTime)
        {
            Caption = 'Last Processing Completed at';
            DataClassification = CustomerContent;
            Description = 'NC1.14';
            Editable = false;
        }
        field(20; "Last Processing Duration"; Decimal)
        {
            Caption = 'Last Processing Duration (sec.)';
            DataClassification = CustomerContent;
            Description = 'NC1.14';
            Editable = false;
        }
        field(25; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
            Description = 'NC2.14';
        }
        field(100; Response; BLOB)
        {
            Caption = 'Response';
            DataClassification = CustomerContent;
            Description = 'NC1.01';
        }
        field(110; "Data Output"; BLOB)
        {
            Caption = 'Data Output';
            DataClassification = CustomerContent;
        }
        field(200; "Record Value"; Text[50])
        {
            Caption = 'Record Value';
            DataClassification = CustomerContent;
            Description = 'NC1.13';
            Editable = false;
        }
        field(6059906; "Task Processor Code"; Code[20])
        {
            Caption = 'Task Processor Code';
            DataClassification = CustomerContent;
            Description = 'NC1.22';
            Editable = false;
            TableRelation = "NPR Nc Task Processor";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; Type, "Table No.", "Record Position")
        {
        }
        key(Key3; "Log Date", Processed)
        {
        }
        key(Key4; "Record Value")
        {
        }
        key(Key5; "Task Processor Code", Processed) { }
    }

    trigger OnDelete()
    var
        NaviConnectTaskField: Record "NPR Nc Task Field";
        NcTaskOutput: Record "NPR Nc Task Output";
    begin
        NaviConnectTaskField.SetRange("Task Entry No.", "Entry No.");
        NaviConnectTaskField.DeleteAll();

        NcTaskOutput.SetRange("Task Entry No.", "Entry No.");
        NcTaskOutput.DeleteAll();
    end;
}

