table 6151502 "Nc Task"
{
    // NC1.00/MHA /20150113  CASE 199932 Refactored object from Web Integration
    // NC1.01/MHA /20150128  CASE 199932 Added Field 12 "Process Count" for managing retry of failed tasks.
    // NC1.07/MHA /20150309  CASE 208131 Updated captions
    // NC1.13/MHA /20150414  CASE 211360 Added Primary Key Fields fields for easier record identification
    // NC1.14/MHA /20150415  CASE 211360 Added Timestamp Fields
    // NC1.22/MHA /20160125  CASE 232733 Task Queue Worker Group replaced by NaviConnect Task Processor
    // NC1.22/MHA /20160415  CASE 231214 Added field 7 Company Name
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.05/MHA /20170615  CASE 280860 NcTaskField.Processed has been deleted
    // NC2.12/MHA /20180418  CASE 308107 Added Task Output to OnDelete()
    // NC2.14/MHA /20180629  CASE 320762 Added field 25 "Record ID"
    // NC2.23/MHA /20190927  CASE 369170 Field 70220322 "NaviPartner Case Url" Removed

    Caption = 'Nc Task';

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2;Type;Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Insert,Modify,Delete,Rename';
            OptionMembers = Insert,Modify,Delete,Rename;
        }
        field(3;"Table No.";Integer)
        {
            Caption = 'Table No.';
            Description = 'NC1.07';
            Editable = false;
        }
        field(4;"Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            Description = 'NC1.14';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"Record Position";Text[200])
        {
            Caption = 'Record Position';
            Description = 'NC1.07';
            Editable = false;
        }
        field(6;"Log Date";DateTime)
        {
            Caption = 'Log Date';
            Editable = false;
        }
        field(7;"Company Name";Text[80])
        {
            Caption = 'Company Name';
            Description = 'NC1.22';
        }
        field(9;Processed;Boolean)
        {
            Caption = 'Processed';
            Editable = false;
        }
        field(10;"Last Processing Started at";DateTime)
        {
            Caption = 'Last Processing Started at';
            Description = 'NC1.14';
            Editable = false;
        }
        field(11;"Process Error";Boolean)
        {
            Caption = 'Error';

            trigger OnValidate()
            begin
                Clear(Response);
            end;
        }
        field(12;"Process Count";Integer)
        {
            Caption = 'Process Count';
            Description = 'NC1.01';
            Editable = false;
        }
        field(15;"Last Processing Completed at";DateTime)
        {
            Caption = 'Last Processing Completed at';
            Description = 'NC1.14';
            Editable = false;
        }
        field(20;"Last Processing Duration";Decimal)
        {
            Caption = 'Last Processing Duration (sec.)';
            Description = 'NC1.14';
            Editable = false;
        }
        field(25;"Record ID";RecordID)
        {
            Caption = 'Record ID';
            Description = 'NC2.14';
        }
        field(100;Response;BLOB)
        {
            Caption = 'Response';
            Description = 'NC1.01';
        }
        field(110;"Data Output";BLOB)
        {
            Caption = 'Data Output';
        }
        field(200;"Record Value";Text[50])
        {
            Caption = 'Record Value';
            Description = 'NC1.13';
            Editable = false;
        }
        field(6059906;"Task Processor Code";Code[20])
        {
            Caption = 'Task Processor Code';
            Description = 'NC1.22';
            Editable = false;
            TableRelation = "Nc Task Processor";
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;Type,"Table No.","Record Position")
        {
        }
        key(Key3;"Log Date",Processed)
        {
        }
        key(Key4;"Record Value")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NaviConnectTaskField: Record "Nc Task Field";
        NcTaskOutput: Record "Nc Task Output";
    begin
        NaviConnectTaskField.SetRange("Task Entry No.","Entry No.");
        NaviConnectTaskField.DeleteAll;

        //-NC2.12 [308107]
        NcTaskOutput.SetRange("Task Entry No.","Entry No.");
        NcTaskOutput.DeleteAll;
        //+NC2.12 [308107]
    end;
}

