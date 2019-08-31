table 6059990 "Retail Admin Cue"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.


    fields
    {
        field(1;"Primary key";Code[10])
        {
        }
        field(20;"User Setups";Integer)
        {
            CalcFormula = Count("User Setup");
            FieldClass = FlowField;
        }
        field(30;Salespersons;Integer)
        {
            CalcFormula = Count("Salesperson/Purchaser");
            FieldClass = FlowField;
        }
        field(40;"POS Stores";Integer)
        {
            CalcFormula = Count("POS Store");
            FieldClass = FlowField;
        }
        field(50;"POS Units";Integer)
        {
            CalcFormula = Count("POS Unit");
            FieldClass = FlowField;
        }
        field(60;"Cash Registers";Integer)
        {
            CalcFormula = Count(Register);
            FieldClass = FlowField;
        }
        field(70;"POS Payment Bins";Integer)
        {
            CalcFormula = Count("POS Payment Bin");
            FieldClass = FlowField;
        }
        field(80;"POS Payment Methods";Integer)
        {
            CalcFormula = Count("POS Payment Method");
            FieldClass = FlowField;
        }
        field(81;"POS Posting Setups";Integer)
        {
            CalcFormula = Count("POS Posting Setup");
            FieldClass = FlowField;
        }
        field(82;"Ticket Types";Integer)
        {
            CalcFormula = Count("TM Ticket Type");
            FieldClass = FlowField;
        }
        field(83;"Ticket Admission BOMs";Integer)
        {
            CalcFormula = Count("TM Ticket Admission BOM");
            FieldClass = FlowField;
        }
        field(84;"Ticket Schedules";Integer)
        {
            CalcFormula = Count("TM Admission Schedule");
            FieldClass = FlowField;
        }
        field(85;"Ticket Admissions";Integer)
        {
            CalcFormula = Count("TM Admission");
            FieldClass = FlowField;
        }
        field(86;"Membership Setup";Integer)
        {
            CalcFormula = Count("MM Membership Setup");
            FieldClass = FlowField;
        }
        field(87;"Membership Sales Setup";Integer)
        {
            CalcFormula = Count("MM Membership Sales Setup");
            FieldClass = FlowField;
        }
        field(88;"Member Alteration";Integer)
        {
            CalcFormula = Count("MM Membership Alteration Setup");
            FieldClass = FlowField;
        }
        field(89;"Member Community";Integer)
        {
            CalcFormula = Count("MM Member Community");
            FieldClass = FlowField;
        }
        field(90;"Workflow Steps Enabled";Integer)
        {
            CalcFormula = Count("POS Sales Workflow Step" WHERE (Enabled=CONST(true)));
            FieldClass = FlowField;
        }
        field(91;"Workflow Steps Not Enabled";Integer)
        {
            CalcFormula = Count("POS Sales Workflow Step" WHERE (Enabled=CONST(false)));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Primary key")
        {
        }
    }

    fieldgroups
    {
    }
}

