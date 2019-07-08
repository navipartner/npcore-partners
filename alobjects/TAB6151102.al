table 6151102 "NpRi Reimbursement"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement';
    DrillDownPageID = "NpRi Reimbursements";
    LookupPageID = "NpRi Reimbursements";

    fields
    {
        field(1;"Party Type";Code[20])
        {
            Caption = 'Party Type';
            NotBlank = true;
            TableRelation = "NpRi Party Type";
        }
        field(5;"Party No.";Code[20])
        {
            Caption = 'Party No.';
            NotBlank = true;
            TableRelation = "NpRi Party"."No." WHERE ("Party Type"=FIELD("Party Type"));
        }
        field(10;"Template Code";Code[20])
        {
            Caption = 'Template Code';
            NotBlank = true;
            TableRelation = "NpRi Reimbursement Template";
        }
        field(100;"Data Collection Module";Code[20])
        {
            CalcFormula = Lookup("NpRi Reimbursement Template"."Data Collection Module" WHERE (Code=FIELD("Template Code")));
            Caption = 'Data Collection Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105;"Data Collection Company";Text[30])
        {
            Caption = 'Data Collection Company';
            TableRelation = Company;
        }
        field(110;"Data Collection Summary";Text[250])
        {
            CalcFormula = Lookup("NpRi Reimbursement Template"."Data Collection Summary" WHERE (Code=FIELD("Template Code")));
            Caption = 'Data Collection Summary';
            Editable = false;
            FieldClass = FlowField;
        }
        field(115;"Last Data Collect Entry No.";Integer)
        {
            BlankZero = true;
            Caption = 'Last Data Collect Entry No.';
        }
        field(120;"Last Data Collection at";DateTime)
        {
            Caption = 'Last Data Collection at';
        }
        field(200;"Reimbursement Module";Code[20])
        {
            CalcFormula = Lookup("NpRi Reimbursement Template"."Reimbursement Module" WHERE (Code=FIELD("Template Code")));
            Caption = 'Reimbursement Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210;"Reimbursement Summary";Text[250])
        {
            CalcFormula = Lookup("NpRi Reimbursement Template"."Reimbursement Summary" WHERE (Code=FIELD("Template Code")));
            Caption = 'Reimbursement Summary';
            Editable = false;
            FieldClass = FlowField;
        }
        field(215;"Last Posting Date";Date)
        {
            Caption = 'Last Posting Date';
        }
        field(220;"Last Reimbursement at";DateTime)
        {
            Caption = 'Last Reimbursement at';
        }
        field(225;"Reimbursement Date";Date)
        {
            Caption = 'Reimbursement Date';
        }
        field(230;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(300;Balance;Decimal)
        {
            CalcFormula = Sum("NpRi Reimbursement Entry".Amount WHERE ("Party Type"=FIELD("Party Type"),
                                                                       "Party No."=FIELD("Party No."),
                                                                       "Template Code"=FIELD("Template Code"),
                                                                       "Posting Date"=FIELD("Date Filter")));
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(305;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1;"Party Type","Party No.","Template Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
    begin
        NpRiReimbursementEntry.SetRange("Party Type","Party Type");
        NpRiReimbursementEntry.SetRange("Party No.","Party No.");
        NpRiReimbursementEntry.SetRange("Template Code","Template Code");
        if NpRiReimbursementEntry.FindFirst then begin
          if not Confirm(Text000,false) then
            Error(Text001);

          NpRiReimbursementEntry.DeleteAll;
        end;
    end;

    trigger OnRename()
    var
        NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
    begin
        NpRiReimbursementEntry.SetRange("Party Type",xRec."Party Type");
        NpRiReimbursementEntry.SetRange("Party No.",xRec."Party No.");
        NpRiReimbursementEntry.SetRange("Template Code",xRec."Template Code");
        if NpRiReimbursementEntry.FindFirst then
          Error(Text002);
    end;

    var
        Text000: Label 'Are you sure you want to delete this Reimbursement including all Entries?';
        Text001: Label 'Delete aborted';
        Text002: Label 'Rename is not allowed on Reimbursements with entries';
}

