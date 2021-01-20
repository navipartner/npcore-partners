table 6151250 "NPR Retail Entertainment Cue"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; No; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Issued Tickets"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Type");
            FieldClass = FlowField;
        }
        field(3; "Ticket Requests"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Admission BOM");
            FieldClass = FlowField;
        }
        field(4; "Ticket Schedules"; Integer)
        {
            CalcFormula = Count("NPR TM Admis. Schedule");
            FieldClass = FlowField;
        }
        field(5; "Ticket Admissions"; Integer)
        {
            CalcFormula = Count("NPR TM Admis. Schedule Lines");
            FieldClass = FlowField;
        }
        field(6; Items; Integer)
        {
            CalcFormula = Count(Item);
            FieldClass = FlowField;
        }
        field(7; Contacts; Integer)
        {
            CalcFormula = Count(Contact);
            FieldClass = FlowField;
        }
        field(8; Customers; Integer)
        {
            CalcFormula = Count(Customer);
            FieldClass = FlowField;
        }
        field(9; Members; Integer)
        {
            CalcFormula = Count("NPR MM Member");
            FieldClass = FlowField;
        }
        field(10; Memberships; Integer)
        {
            CalcFormula = Count("NPR MM Membership");
            FieldClass = FlowField;
        }
        field(11; Membercards; Integer)
        {
            CalcFormula = Count("NPR MM Member Card");
            FieldClass = FlowField;
        }

    }

    keys
    {
        key(Key1; No)
        {
        }
    }

}

