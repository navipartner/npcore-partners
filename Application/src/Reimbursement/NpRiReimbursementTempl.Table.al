table 6151101 "NPR NpRi Reimbursement Templ."
{
    Access = Internal;

    Caption = 'Reimbursement Template';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRi Reimbursement Templ.";
    LookupPageID = "NPR NpRi Reimbursement Templ.";

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
        field(100; "Data Collection Module"; Code[20])
        {
            Caption = 'Data Collection Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRi Reimbursement Module".Code WHERE(Type = CONST("Data Collection"));
        }
        field(105; "Data Collection Description"; Text[50])
        {
            CalcFormula = Lookup("NPR NpRi Reimbursement Module".Description WHERE(Code = FIELD("Data Collection Module")));
            Caption = 'Data Collection Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Data Collection Filters"; BLOB)
        {
            Caption = 'Data Collection Filters';
            DataClassification = CustomerContent;
        }
        field(115; "Data Collection Summary"; Text[250])
        {
            Caption = 'Data Collection Summary';
            DataClassification = CustomerContent;
        }
        field(200; "Reimbursement Module"; Code[20])
        {
            Caption = 'Reimbursement Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRi Reimbursement Module".Code WHERE(Type = CONST(Reimbursement));
        }
        field(205; "Reimbursement Description"; Text[50])
        {
            CalcFormula = Lookup("NPR NpRi Reimbursement Module".Description WHERE(Code = FIELD("Reimbursement Module")));
            Caption = 'Reimbursement Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(215; "Reimbursement Summary"; Text[250])
        {
            Caption = 'Reimbursement Summary';
            DataClassification = CustomerContent;
        }
        field(220; "Posting Description"; Text[50])
        {
            Caption = 'Posting Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        NpRiReimbursement: Record "NPR NpRi Reimbursement";
    begin
        NpRiReimbursement.SetRange("Template Code", Code);
        if NpRiReimbursement.FindFirst() then
            Error(Text000);
    end;

    var
        Text000: Label 'Unable to delete as Reimbursement %1 uses this template';
}

