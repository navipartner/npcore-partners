table 6151102 "NPR NpRi Reimbursement"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.54/JKL /20191213  CASE 382066 New field 310 Deactivated added
    // NPR5.54/BHR /20200306  CASE 385924 Add fields 315, 316
    // NPR5.54/JAKUBV/20200408  CASE 368254 Transport NPR5.54 - 8 April 2020

    Caption = 'Reimbursement';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRi Reimbursements";
    LookupPageID = "NPR NpRi Reimbursements";

    fields
    {
        field(1; "Party Type"; Code[20])
        {
            Caption = 'Party Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRi Party Type";
        }
        field(5; "Party No."; Code[20])
        {
            Caption = 'Party No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRi Party"."No." WHERE("Party Type" = FIELD("Party Type"));
        }
        field(10; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRi Reimbursement Templ.";
        }
        field(100; "Data Collection Module"; Code[20])
        {
            CalcFormula = Lookup ("NPR NpRi Reimbursement Templ."."Data Collection Module" WHERE(Code = FIELD("Template Code")));
            Caption = 'Data Collection Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Data Collection Company"; Text[30])
        {
            Caption = 'Data Collection Company';
            DataClassification = CustomerContent;
            TableRelation = Company;
        }
        field(110; "Data Collection Summary"; Text[250])
        {
            CalcFormula = Lookup ("NPR NpRi Reimbursement Templ."."Data Collection Summary" WHERE(Code = FIELD("Template Code")));
            Caption = 'Data Collection Summary';
            Editable = false;
            FieldClass = FlowField;
        }
        field(115; "Last Data Collect Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Last Data Collect Entry No.';
            DataClassification = CustomerContent;
        }
        field(120; "Last Data Collection at"; DateTime)
        {
            Caption = 'Last Data Collection at';
            DataClassification = CustomerContent;
        }
        field(200; "Reimbursement Module"; Code[20])
        {
            CalcFormula = Lookup ("NPR NpRi Reimbursement Templ."."Reimbursement Module" WHERE(Code = FIELD("Template Code")));
            Caption = 'Reimbursement Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; "Reimbursement Summary"; Text[250])
        {
            CalcFormula = Lookup ("NPR NpRi Reimbursement Templ."."Reimbursement Summary" WHERE(Code = FIELD("Template Code")));
            Caption = 'Reimbursement Summary';
            Editable = false;
            FieldClass = FlowField;
        }
        field(215; "Last Posting Date"; Date)
        {
            Caption = 'Last Posting Date';
            DataClassification = CustomerContent;
        }
        field(220; "Last Reimbursement at"; DateTime)
        {
            Caption = 'Last Reimbursement at';
            DataClassification = CustomerContent;
        }
        field(225; "Reimbursement Date"; Date)
        {
            Caption = 'Reimbursement Date';
            DataClassification = CustomerContent;
        }
        field(230; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(300; Balance; Decimal)
        {
            CalcFormula = Sum ("NPR NpRi Reimbursement Entry".Amount WHERE("Party Type" = FIELD("Party Type"),
                                                                       "Party No." = FIELD("Party No."),
                                                                       "Template Code" = FIELD("Template Code"),
                                                                       "Posting Date" = FIELD("Date Filter")));
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(305; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(310; Deactivated; Boolean)
        {
            Caption = 'Deactivated';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(315; "From Date"; Date)
        {
            Caption = 'From Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(316; "To Date"; Date)
        {
            Caption = 'To Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';

            trigger OnValidate()
            begin
                if "From Date" = 0D then
                    Error(Err000);
            end;
        }
    }

    keys
    {
        key(Key1; "Party Type", "Party No.", "Template Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
    begin
        NpRiReimbursementEntry.SetRange("Party Type", "Party Type");
        NpRiReimbursementEntry.SetRange("Party No.", "Party No.");
        NpRiReimbursementEntry.SetRange("Template Code", "Template Code");
        if NpRiReimbursementEntry.FindFirst then begin
            if not Confirm(Text000, false) then
                Error(Text001);

            NpRiReimbursementEntry.DeleteAll;
        end;
    end;

    trigger OnRename()
    var
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
    begin
        NpRiReimbursementEntry.SetRange("Party Type", xRec."Party Type");
        NpRiReimbursementEntry.SetRange("Party No.", xRec."Party No.");
        NpRiReimbursementEntry.SetRange("Template Code", xRec."Template Code");
        if NpRiReimbursementEntry.FindFirst then
            Error(Text002);
    end;

    var
        Text000: Label 'Are you sure you want to delete this Reimbursement including all Entries?';
        Text001: Label 'Delete aborted';
        Text002: Label 'Rename is not allowed on Reimbursements with entries';
        Err000: Label 'From Date should not be blank';
}

