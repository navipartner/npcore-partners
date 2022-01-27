table 6059990 "NPR Retail Admin Cue"
{
    Access = Internal;
    Caption = 'Retail Admin Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = CustomerContent;
        }
        field(20; "User Setups"; Integer)
        {
            CalcFormula = Count("User Setup");
            Caption = 'User Setups';
            FieldClass = FlowField;
        }
        field(30; Salespersons; Integer)
        {
            CalcFormula = Count("Salesperson/Purchaser");
            Caption = 'Salespersons';
            FieldClass = FlowField;
        }
        field(40; "POS Stores"; Integer)
        {
            CalcFormula = Count("NPR POS Store");
            Caption = 'POS Stores';
            FieldClass = FlowField;
        }
        field(50; "POS Units"; Integer)
        {
            CalcFormula = Count("NPR POS Unit");
            Caption = 'POS Units';
            FieldClass = FlowField;
        }
        field(60; "Cash Registers"; Integer)
        {
            CalcFormula = Count("NPR POS Unit");
            Caption = 'Cash Registers';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use POS Units instead of Cash Registers';
        }
        field(70; "POS Payment Bins"; Integer)
        {
            CalcFormula = Count("NPR POS Payment Bin");
            Caption = 'POS Payment Bins';
            FieldClass = FlowField;
        }
        field(80; "POS Payment Methods"; Integer)
        {
            CalcFormula = Count("NPR POS Payment Method");
            Caption = 'POS Payment Methods';
            FieldClass = FlowField;
        }
        field(81; "POS Posting Setups"; Integer)
        {
            CalcFormula = Count("NPR POS Posting Setup");
            Caption = 'POS Posting Setups';
            FieldClass = FlowField;
        }
        field(82; "Ticket Types"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Type");
            Caption = 'Ticket Types';
            FieldClass = FlowField;
        }
        field(83; "Ticket Admission BOMs"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Admission BOM");
            Caption = 'Ticket Admission BOMs';
            FieldClass = FlowField;
        }
        field(84; "Ticket Schedules"; Integer)
        {
            CalcFormula = Count("NPR TM Admis. Schedule");
            Caption = 'Ticket Schedules';
            FieldClass = FlowField;
        }
        field(85; "Ticket Admissions"; Integer)
        {
            CalcFormula = Count("NPR TM Admission");
            Caption = 'Ticket Admissions';
            FieldClass = FlowField;
        }
        field(86; "Membership Setup"; Integer)
        {
            CalcFormula = Count("NPR MM Membership Setup");
            Caption = 'Membership Setup';
            FieldClass = FlowField;
        }
        field(87; "Membership Sales Setup"; Integer)
        {
            CalcFormula = Count("NPR MM Members. Sales Setup");
            Caption = 'Membership Sales Setup';
            FieldClass = FlowField;
        }
        field(88; "Member Alteration"; Integer)
        {
            CalcFormula = Count("NPR MM Members. Alter. Setup");
            Caption = 'Member Alteration';
            FieldClass = FlowField;
        }
        field(89; "Member Community"; Integer)
        {
            CalcFormula = Count("NPR MM Member Community");
            Caption = 'Member Community';
            FieldClass = FlowField;
        }
        field(90; "Workflow Steps Enabled"; Integer)
        {
            CalcFormula = Count("NPR POS Sales Workflow Step" WHERE(Enabled = CONST(true)));
            Caption = 'Workflow Steps Enabled';
            FieldClass = FlowField;
        }
        field(91; "Workflow Steps Not Enabled"; Integer)
        {
            CalcFormula = Count("NPR POS Sales Workflow Step" WHERE(Enabled = CONST(false)));
            Caption = 'Workflow Steps Not Enabled';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Primary key")
        {
        }
    }
}

