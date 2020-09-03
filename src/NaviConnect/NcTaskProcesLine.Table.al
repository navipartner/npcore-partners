table 6151506 "NPR Nc Task Proces. Line"
{
    // NC1.22/MHA/20160415 CASE 231214 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'Nc Task Proces. Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Task Processor Code"; Code[20])
        {
            Caption = 'Task Processor Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task Processor";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Custom,Company';
            OptionMembers = Custom,Company;

            trigger OnValidate()
            begin
                if (Type = Type::Company) and (Code = '') then
                    Code := DataLogCode();
            end;
        }
        field(15; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Value; Text[50])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Company)) Company.Name;
        }
    }

    keys
    {
        key(Key1; "Task Processor Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure DataLogCode(): Code[20]
    begin
        exit('DATA_LOG');
    end;
}

