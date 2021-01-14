table 6151100 "NPR NpRi Reimbursement Module"
{
    Caption = 'Reimbursement Module';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRi Reimburs. Modules";
    LookupPageID = "NPR NpRi Reimburs. Modules";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Data Collection,Reimbursement';
            OptionMembers = "Data Collection",Reimbursement;
        }
        field(15; "Subscriber Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Subscriber Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(20; "Subscriber Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Subscriber Codeunit ID")));
            Caption = 'Subscriber Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

