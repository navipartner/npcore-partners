table 6059811 "Retail Sales Cue"
{
    // NC1.17 /BHR /20140428  CASE 212069 ADDED FIELDS 20..23
    // NC1.17 /MHA /20150514  CASE 213393 Updated Captions
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.17 to NPR5.23.03
    // NPR5.26/BHR /20160830  CASE 250405 Task processed with errors on NC
    // NPR5.27/BHR /20161025  CASE 254757 Modified the Field 20, Removed filter
    // NPR5.30/MHA /20170130  CASE 264958 Field added: 40 Pending Inc. Documents
    // NPR5.30/BHR /20170207  CASE 264863 Field 45 for failed payments
    // NPR5.53/MHA /20191118  CASE 377965 Updated CalcFormula on Field 45 "Failed Webshop Payments"

    Caption = 'NaviConnect Cue';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Import Pending";Integer)
        {
            CalcFormula = Count("Nc Import Entry" WHERE (Imported=CONST(false)));
            Caption = 'Import Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15;"Tasks Unprocessed";Integer)
        {
            CalcFormula = Count("Nc Task" WHERE (Processed=CONST(false)));
            Caption = 'Tasks Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20;"Sales Orders";Integer)
        {
            CalcFormula = Count("Sales Header" WHERE ("Document Type"=FILTER(Order)));
            Caption = 'Sales Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21;"Sales Quotes";Integer)
        {
            CalcFormula = Count("Sales Header" WHERE ("Document Type"=FILTER(Quote)));
            Caption = 'Sales Quotes';
            FieldClass = FlowField;
        }
        field(22;"Sales Return Orders";Integer)
        {
            CalcFormula = Count("Sales Header" WHERE ("Document Type"=FILTER("Return Order")));
            Caption = 'Sales Return Orders';
            FieldClass = FlowField;
        }
        field(23;"Magento Orders";Integer)
        {
            CalcFormula = Count("Sales Header" WHERE ("Document Type"=FILTER(Order),
                                                      "External Order No."=FILTER(<>'')));
            Caption = 'Magento Orders';
            FieldClass = FlowField;
        }
        field(30;"Daily Sales Orders";Integer)
        {
            CalcFormula = Count("Sales Header" WHERE ("Document Type"=FILTER(Order),
                                                      "Posting Date"=FIELD("Date Filter")));
            Caption = 'Daily Sales Orders';
            FieldClass = FlowField;
        }
        field(31;"Daily Sales Invoices";Integer)
        {
            CalcFormula = Count("Sales Invoice Header" WHERE ("Posting Date"=FIELD("Date Filter")));
            Caption = 'Daily Sales Invoices';
            FieldClass = FlowField;
        }
        field(32;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(33;"Processed Error Tasks";Integer)
        {
            CalcFormula = Count("Nc Task" WHERE ("Process Error"=FILTER(true)));
            Caption = 'Processed Error Tasks';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40;"Pending Inc. Documents";Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE ("Document Type"=CONST(" "),
                                                           "Document No."=CONST('')));
            Caption = 'Pending Inc. Documents';
            Description = 'NPR5.30';
            FieldClass = FlowField;
        }
        field(45;"Failed Webshop Payments";Integer)
        {
            CalcFormula = Count("Magento Payment Line" WHERE ("Document Table No."=CONST(112),
                                                              "Payment Gateway Code"=FILTER(<>''),
                                                              "Date Captured"=FILTER(=0D)));
            Caption = 'Failed Webshop Payments';
            Description = 'NPR5.53';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

