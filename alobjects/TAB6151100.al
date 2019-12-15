table 6151100 "NpRi Reimbursement Module"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Module';
    DrillDownPageID = "NpRi Reimbursement Modules";
    LookupPageID = "NpRi Reimbursement Modules";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Data Collection,Reimbursement';
            OptionMembers = "Data Collection",Reimbursement;
        }
        field(15;"Subscriber Codeunit ID";Integer)
        {
            BlankZero = true;
            Caption = 'Subscriber Codeunit ID';
        }
        field(20;"Subscriber Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Subscriber Codeunit ID")));
            Caption = 'Subscriber Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

