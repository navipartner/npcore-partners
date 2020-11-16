table 6151480 "NPR Magento Cue"
{
    // MAG1.17/BHR/20140428 CASE 212069 ADDED FIELDS 20..23
    // MAG1.17/MH/20150514  CASE 213393 Updated Captions
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Cue';
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
            CalcFormula = Count ("NPR Nc Import Entry" WHERE(Imported = CONST(false)));
            Caption = 'Import Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Tasks Unprocessed"; Integer)
        {
            CalcFormula = Count ("NPR Nc Task" WHERE(Processed = CONST(false)));
            Caption = 'Tasks Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Sales Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "NPR External Order No." = FILTER(= '')));
            Caption = 'Sales Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Sales Quotes"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Quote)));
            Caption = 'Sales Quotes';
            FieldClass = FlowField;
        }
        field(22; "Sales Return Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER("Return Order")));
            Caption = 'Sales Return Orders';
            FieldClass = FlowField;
        }
        field(23; "Magento Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "NPR External Order No." = FILTER(<> '')));
            Caption = 'Magento Orders';
            FieldClass = FlowField;
        }
        field(30; "Daily Sales Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "NPR External Order No." = FILTER(<> ''),
                                                      "Posting Date" = FIELD("Date Filter")));
            Caption = 'Daily Sales Orders';
            Description = 'MAG1.17';
            FieldClass = FlowField;
        }
        field(31; "Daily Sales Invoices"; Integer)
        {
            CalcFormula = Count ("Sales Invoice Header" WHERE("Posting Date" = FIELD("Date Filter"),
                                                              "NPR External Order No." = FILTER(<> '')));
            Caption = 'Daily Sales Invoices';
            Description = 'MAG1.17';
            FieldClass = FlowField;
        }
        field(32; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            Description = 'MAG1.17';
            FieldClass = FlowFilter;
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

