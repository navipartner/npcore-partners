table 6059984 "Retail Order Cue"
{
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento reference updated according to MAG2.00

    Caption = 'Retail Order Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Open Sales Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = CONST(Order)));
            Caption = 'Open Sales Orders';
            FieldClass = FlowField;
        }
        field(3; "Open Credit Memos"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = CONST("Credit Memo")));
            Caption = 'Open Credit Memos';
            FieldClass = FlowField;
        }
        field(4; "Open Web Sales Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = CONST(Order),
                                                      "External Order No." = FILTER(<> '')));
            Caption = 'Open Web Sales Orders';
            Description = 'NPR5.23.03';
            FieldClass = FlowField;
        }
        field(5; "Posted Sales Invoices"; Integer)
        {
            CalcFormula = Count ("Sales Invoice Header");
            Caption = 'Posted Sales Invoices';
            FieldClass = FlowField;
        }
        field(6; "Posted Credit Memos"; Integer)
        {
            CalcFormula = Count ("Sales Cr.Memo Header");
            Caption = 'Posted Credit Memos';
            FieldClass = FlowField;
        }
        field(9; "Posted Web Sales Orders"; Integer)
        {
            CalcFormula = Count ("Sales Invoice Header" WHERE("External Order No." = FILTER(<> '')));
            Caption = 'Posted Web Sales Orders';
            Description = 'NPR5.23.03';
            FieldClass = FlowField;
        }
        field(12; "Open Purchase Orders"; Integer)
        {
            CalcFormula = Count ("Purchase Header" WHERE("Document Type" = CONST(Order)));
            Caption = 'Open Purchase Orders';
            FieldClass = FlowField;
        }
        field(15; "Posted Purchase Orders"; Integer)
        {
            CalcFormula = Count ("Purch. Inv. Header");
            Caption = 'Posted Purchase Orders';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

