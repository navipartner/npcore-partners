table 6059811 "NPR Retail Sales Cue"
{
    Caption = 'NaviConnect Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Import Pending"; Integer)
        {
            CalcFormula = Count("NPR Nc Import Entry" WHERE(Imported = CONST(false)));
            Caption = 'Import Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Tasks Unprocessed"; Integer)
        {
            CalcFormula = Count("NPR Nc Task" WHERE(Processed = CONST(false)));
            Caption = 'Tasks Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Sales Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Order)));
            Caption = 'Sales Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Sales Quotes"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Quote)));
            Caption = 'Sales Quotes';
            FieldClass = FlowField;
        }
        field(22; "Sales Return Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER("Return Order")));
            Caption = 'Sales Return Orders';
            FieldClass = FlowField;
        }
        field(23; "Magento Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "NPR External Order No." = FILTER(<> '')));
            Caption = 'Magento Orders';
            FieldClass = FlowField;
        }
        field(30; "Daily Sales Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "Posting Date" = FIELD("Date Filter")));
            Caption = 'Daily Sales Orders';
            FieldClass = FlowField;
        }
        field(31; "Daily Sales Invoices"; Integer)
        {
            CalcFormula = Count("Sales Invoice Header" WHERE("Posting Date" = FIELD("Date Filter")));
            Caption = 'Daily Sales Invoices';
            FieldClass = FlowField;
        }
        field(32; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(33; "Processed Error Tasks"; Integer)
        {
            CalcFormula = Count("NPR Nc Task" WHERE("Process Error" = FILTER(true)));
            Caption = 'Processed Error Tasks';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Pending Inc. Documents"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE("Document Type" = CONST(" "),
                                                           "Document No." = CONST('')));
            Caption = 'Pending Inc. Documents';
            Description = 'NPR5.30';
            FieldClass = FlowField;
        }
        field(45; "Failed Webshop Payments"; Integer)
        {
            CalcFormula = Count("NPR Magento Payment Line" WHERE("Document Table No." = CONST(112),
                                                              "Payment Gateway Code" = FILTER(<> ''),
                                                              "Date Captured" = FILTER(= 0D)));
            Caption = 'Failed Webshop Payments';
            Description = 'NPR5.53';
            FieldClass = FlowField;
        }
        field(100; "Blocked Customers"; Integer)
        {
            Caption = 'Blocked Customers';
            CalcFormula = Count(Customer WHERE(Blocked = filter(All)));
            FieldClass = FlowField;
        }
        field(101; "Imported Magento SOs"; Integer)
        {
            Caption = 'Imported Magento Sales Orders';
            FieldClass = FlowField;
            CalcFormula = Count("Sales Header" where("Salesperson Code" = filter('WEB')));
            Editable = false;
        }
        field(102; "Retail Vouchers"; Integer)
        {
            Caption = 'Retail Vouchers';
            FieldClass = FlowField;
            CalcFormula = Count("NPR NpRv Voucher");
            Editable = false;
        }
        field(103; "Gift Vouchers"; Integer)
        {
            Caption = 'Gift Vouchers';
            FieldClass = FlowField;
            Editable = false;
        }
        field(104; "Credit Vouchers"; Integer)
        {
            Caption = 'Credit Vouchers';
            FieldClass = FlowField;
            Editable = false;
        }
        field(105; "Task List"; Integer)
        {
            Caption = 'Task List';
            FieldClass = FlowField;
            CalcFormula = count("NPR Nc Task" where(Processed = filter(false)));
            Editable = false;
        }
        field(106; "Shipped Sales Orders"; Integer)
        {
            Caption = 'Shipped Sales Orders';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Shipped Not Invoiced" = filter(true)));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

