table 6151250 "NPR Retail Entertainment Cue"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Retail Entertainment Cue';
    fields
    {
        field(1; No; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'No';
        }
        field(2; "Issued Tickets"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket");
            FieldClass = FlowField;
            Caption = 'Issued Tickets';
        }
        field(3; "Ticket Requests"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Reservation Req.");
            FieldClass = FlowField;
            Caption = 'Ticket Requests';
        }
        field(4; "Ticket Schedules"; Integer)
        {
            CalcFormula = Count("NPR TM Admis. Schedule");
            FieldClass = FlowField;
            Caption = 'Ticket Schedules';
        }
        field(5; "Ticket Admissions"; Integer)
        {
            CalcFormula = Count("NPR TM Admission");
            FieldClass = FlowField;
            Caption = 'Ticket Admissions';
        }
        field(6; Items; Integer)
        {
            CalcFormula = Count(Item);
            FieldClass = FlowField;
            Caption = 'Items';
        }
        field(7; Contacts; Integer)
        {
            CalcFormula = Count(Contact);
            FieldClass = FlowField;
            Caption = 'Contacts';
        }
        field(8; Customers; Integer)
        {
            CalcFormula = Count(Customer);
            FieldClass = FlowField;
            Caption = 'Customers';
        }
        field(9; Members; Integer)
        {
            CalcFormula = Count("NPR MM Member");
            FieldClass = FlowField;
            Caption = 'Members';
        }
        field(10; Memberships; Integer)
        {
            CalcFormula = Count("NPR MM Membership");
            FieldClass = FlowField;
            Caption = 'Memberships';
        }
        field(11; Membercards; Integer)
        {
            CalcFormula = Count("NPR MM Member Card");
            FieldClass = FlowField;
            Caption = 'Membercards';
        }
        field(12; "Ticket Types"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Type");
            FieldClass = FlowField;
            Caption = 'Ticket Types';
        }
        field(13; "Ticket Admission BOM"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Admission BOM");
            FieldClass = FlowField;
            Caption = 'Ticket BOM';
        }
    }

    keys
    {
        key(Key1; No)
        {
        }
    }

}

