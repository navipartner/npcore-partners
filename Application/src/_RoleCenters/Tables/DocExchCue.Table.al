table 6059932 "NPR Doc. Exch. Cue"
{
    Access = Internal;
    Caption = 'Doc. Exch. Cue';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Requests to Approve"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE(Status = CONST(Open),
                                                        "Approver ID" = CONST('USERID')));
            Caption = 'Requests to Approve';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Ongoing Sales Invoices"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Invoice)));
            Caption = 'Ongoing Sales Invoices';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Incoming Documents"; Integer)
        {
            CalcFormula = Count("Incoming Document");
            Caption = 'My Incoming Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Incoming Documents New"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST(New)));
            Caption = 'Incoming Documents New';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Incoming Documents Failed"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST(Failed)));
            Caption = 'Incoming Documents Failed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Incoming Documents Created"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST(Created)));
            Caption = 'Incoming Documents Created';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Incoming Documents Released"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST(Released)));
            Caption = 'Incoming Documents Released';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Incoming Documents Rejected"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST(Rejected)));
            Caption = 'Incoming Documents Rejected';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Incoming Documents Pending Ap."; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Status = CONST("Pending Approval")));
            Caption = 'Incoming Documents Pending Ap.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Ongoing Purchase Invoices"; Integer)
        {
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = FILTER(Invoice)));
            Caption = 'Ongoing Purchase Invoices';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(30; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(31; "Date Filter2"; Date)
        {
            Caption = 'Date Filter2';
            Editable = false;
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

