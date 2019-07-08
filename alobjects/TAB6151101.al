table 6151101 "NpRi Reimbursement Template"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Template';
    DrillDownPageID = "NpRi Reimbursement Templates";
    LookupPageID = "NpRi Reimbursement Templates";

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
        field(100;"Data Collection Module";Code[20])
        {
            Caption = 'Data Collection Module';
            TableRelation = "NpRi Reimbursement Module".Code WHERE (Type=CONST("Data Collection"));
        }
        field(105;"Data Collection Description";Text[50])
        {
            CalcFormula = Lookup("NpRi Reimbursement Module".Description WHERE (Code=FIELD("Data Collection Module")));
            Caption = 'Data Collection Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"Data Collection Filters";BLOB)
        {
            Caption = 'Data Collection Filters';
        }
        field(115;"Data Collection Summary";Text[250])
        {
            Caption = 'Data Collection Summary';
        }
        field(200;"Reimbursement Module";Code[20])
        {
            Caption = 'Reimbursement Module';
            TableRelation = "NpRi Reimbursement Module".Code WHERE (Type=CONST(Reimbursement));
        }
        field(205;"Reimbursement Description";Text[50])
        {
            CalcFormula = Lookup("NpRi Reimbursement Module".Description WHERE (Code=FIELD("Reimbursement Module")));
            Caption = 'Reimbursement Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(215;"Reimbursement Summary";Text[250])
        {
            Caption = 'Reimbursement Summary';
        }
        field(220;"Posting Description";Text[50])
        {
            Caption = 'Posting Description';
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

    trigger OnDelete()
    var
        NpRiReimbursement: Record "NpRi Reimbursement";
    begin
        NpRiReimbursement.SetRange("Template Code",Code);
        if NpRiReimbursement.FindFirst then
          Error(Text000);
    end;

    var
        Text000: Label 'Unable to delete as Reimbursement %1 uses this template';
}

