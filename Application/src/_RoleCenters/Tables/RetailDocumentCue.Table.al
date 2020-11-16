table 6059985 "NPR Retail Document Cue"
{
    // NPR4.14/RMT/20150826 CASE 216519 Added fields 30 "Number of Open Orders" and 31 "Number of Posted Orders"

    Caption = 'Retail Document Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Selection Contracts Open"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Selection Contract"),
                                                                Cashed = CONST(false)));
            Caption = 'Selection Contracts Open';
            FieldClass = FlowField;
        }
        field(3; "Retail Orders Open"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Retail Order"),
                                                                Cashed = CONST(false)));
            Caption = 'Retail Orders Open';
            FieldClass = FlowField;
        }
        field(4; "Wishlist Open"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST(Wish),
                                                                Cashed = CONST(false)));
            Caption = 'Wishlist Open';
            FieldClass = FlowField;
        }
        field(5; "Customizations Open"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST(Customization),
                                                                Cashed = CONST(true)));
            Caption = 'Customizations Open';
            FieldClass = FlowField;
        }
        field(6; "Rental Contracts Open"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Rental contract"),
                                                                Cashed = CONST(false)));
            Caption = 'Rental Contracts Open';
            FieldClass = FlowField;
        }
        field(7; "Purchase Contracts Open"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Purchase contract"),
                                                                Cashed = CONST(false)));
            Caption = 'Purchase Contracts Open';
            FieldClass = FlowField;
        }
        field(8; "Quotes Open"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST(Quote),
                                                                Cashed = CONST(false)));
            Caption = 'Quotes Open';
            FieldClass = FlowField;
        }
        field(12; "Selection Contracts Cashed"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Selection Contract"),
                                                                Cashed = CONST(true)));
            Caption = 'Selection Contracts Cashed';
            FieldClass = FlowField;
        }
        field(13; "Retail Orders Cashed"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Retail Order"),
                                                                Cashed = CONST(false)));
            Caption = 'Retail Orders Cashed';
            FieldClass = FlowField;
        }
        field(14; "Wishlist Cashed"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST(Wish),
                                                                Cashed = CONST(false)));
            Caption = 'Wishlist Cashed';
            FieldClass = FlowField;
        }
        field(15; "Customizations Cashed"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST(Customization),
                                                                Cashed = CONST(false)));
            Caption = 'Customizations Cashed';
            FieldClass = FlowField;
        }
        field(16; "Rental Contracts Cashed"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Rental contract"),
                                                                Cashed = CONST(false)));
            Caption = 'Rental Contracts Cashed';
            FieldClass = FlowField;
        }
        field(17; "Purchase Contracts Cashed"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST("Purchase contract"),
                                                                Cashed = CONST(false)));
            Caption = 'Purchase Contracts Cashed';
            FieldClass = FlowField;
        }
        field(18; "Quotes Cashed"; Integer)
        {
            CalcFormula = Count ("NPR Retail Document Header" WHERE("Document Type" = CONST(Quote),
                                                                Cashed = CONST(false)));
            Caption = 'Quotes Cashed';
            FieldClass = FlowField;
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(21; "Date Filter 2"; Date)
        {
            Caption = 'Date Filter 2';
            FieldClass = FlowFilter;
        }
        field(30; "Number of Open Orders"; Integer)
        {
            CalcFormula = Count ("Sales Header" WHERE("Document Type" = CONST(Order),
                                                      "NPR Order Type" = CONST(Order)));
            Caption = 'Open Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Number of Posted Orders"; Integer)
        {
            CalcFormula = Count ("Sales Invoice Header" WHERE("NPR Order Type" = CONST(Order)));
            Caption = 'Posted Orders';
            Editable = false;
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

