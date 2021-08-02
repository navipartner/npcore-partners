table 6151018 "NPR NpRv Arch. Voucher"
{
    Caption = 'Archived Retail Voucher';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Arch. Vouchers";
    LookupPageID = "NPR NpRv Arch. Vouchers";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(5; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Type";
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Reference No."; Text[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(30; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(35; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(40; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(45; "Arch. No. Series"; Code[20])
        {
            Caption = 'Archivation No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50; "Arch. No."; Code[20])
        {
            Caption = 'Pre-archivation No.';
            DataClassification = CustomerContent;
        }
        field(55; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(60; "Provision Account No."; Code[20])
        {
            Caption = 'Provision Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 "Direct Posting" = CONST(true));
        }
        field(62; "Allow Top-up"; Boolean)
        {
            Caption = 'Allow Top-up';
            DataClassification = CustomerContent;
        }
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151013));
        }
        field(75; Amount; Decimal)
        {
            CalcFormula = Sum("NPR NpRv Arch. Voucher Entry"."Remaining Amount" WHERE("Arch. Voucher No." = FIELD("No.")));
            Caption = 'Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(76; "Initial Amount"; Decimal)
        {
            CalcFormula = Sum("NPR NpRv Arch. Voucher Entry".Amount WHERE("Arch. Voucher No." = FIELD("No."),
                                                                       "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher" | "Top-up")));
            Caption = 'Initial Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(95; "SMS Template Code"; Code[10])
        {
            Caption = 'SMS Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header" WHERE("Table No." = CONST(6151013));
        }
        field(100; "Send Voucher Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpRv Voucher Type"."Send Voucher Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Send Voucher Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Send via Print"; Boolean)
        {
            Caption = 'Send via Print';
            DataClassification = CustomerContent;
        }
        field(105; "Send via E-mail"; Boolean)
        {
            Caption = 'Send via E-mail';
            DataClassification = CustomerContent;
        }
        field(107; "Send via SMS"; Boolean)
        {
            Caption = 'Send via SMS';
            DataClassification = CustomerContent;
        }
        field(110; "Validate Voucher Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpRv Voucher Type"."Validate Voucher Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Validate Voucher Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Apply Payment Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpRv Voucher Type"."Apply Payment Module" WHERE(Code = FIELD("Voucher Type")));
            Caption = 'Apply Payment Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(205; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;
        }
        field(210; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(215; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(220; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(225; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(230; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(235; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(240; County; Text[30])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(245; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(255; "E-mail"; Text[80])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(260; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(270; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(300; "Voucher Message"; Text[250])
        {
            Caption = 'Voucher Message';
            DataClassification = CustomerContent;
        }
        field(305; Barcode; BLOB)
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            // ObsoleteState = Removed;
            // ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(306; "Barcode Image"; Media)
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
        field(1000; "Issue Date"; Date)
        {
            CalcFormula = Min("NPR NpRv Arch. Voucher Entry"."Posting Date" WHERE("Arch. Voucher No." = FIELD("No."),
                                                                               "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005; "Issue Register No."; Code[10])
        {
            CalcFormula = Max("NPR NpRv Arch. Voucher Entry"."Register No." WHERE("Arch. Voucher No." = FIELD("No."),
                                                                               "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue POS Unit No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1007; "Issue Document Type"; Option)
        {
            CalcFormula = Max("NPR NpRv Arch. Voucher Entry"."Document Type" WHERE("Arch. Voucher No." = FIELD("No."),
                                                                                "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Document Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'POS Entry,Invoice,Credit Memo';
            OptionMembers = "Audit Roll",Invoice,"Credit Memo";
        }
        field(1010; "Issue Document No."; Code[20])
        {
            CalcFormula = Max("NPR NpRv Arch. Voucher Entry"."Document No." WHERE("Arch. Voucher No." = FIELD("No."),
                                                                               "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Document No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1013; "Issue External Document No."; Code[20])
        {
            CalcFormula = Max("NPR NpRv Arch. Voucher Entry"."External Document No." WHERE("Arch. Voucher No." = FIELD("No."),
                                                                                        "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue External Document No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1015; "Issue User ID"; Code[50])
        {
            CalcFormula = Max("NPR NpRv Arch. Voucher Entry"."User ID" WHERE("Arch. Voucher No." = FIELD("No."),
                                                                          "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue User ID';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Issue Partner Code"; Code[20])
        {
            CalcFormula = Max("NPR NpRv Arch. Voucher Entry"."Partner Code" WHERE("Arch. Voucher No." = FIELD("No."),
                                                                               "Entry Type" = FILTER("Issue Voucher" | "Partner Issue Voucher")));
            Caption = 'Issue Partner Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025; "Partner Clearing"; Boolean)
        {
            CalcFormula = Max("NPR NpRv Arch. Voucher Entry"."Partner Clearing" WHERE("Arch. Voucher No." = FIELD("No.")));
            Caption = 'Partner Clearing';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1030; "No. Send"; Integer)
        {
            CalcFormula = Count("NPR NpRv Arch. Sending Log" WHERE("Arch. Voucher No." = FIELD("No."),
                                                                "Error during Send" = CONST(false)));
            Caption = 'No. Send';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Voucher Type")
        {
        }
        key(Key3; "Reference No.")
        {
        }
        key(Key4; "Arch. No.")
        {
        }
    }
}
