tableextension 6014432 "NPR Sales Header" extends "Sales Header"
{
    fields
    {
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(6014401; "NPR Buy-From Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            DataClassification = CustomerContent;
        }
        field(6014406; "NPR Document Time"; Time)
        {
            Caption = 'Document Time';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used.';
        }
        field(6014407; "NPR Bill-to Company"; Text[30])
        {
            Caption = 'Bill-to Company (IC)';
            DataClassification = CustomerContent;
            TableRelation = Company;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used.';
        }
        field(6014408; "NPR Bill-To Vendor No."; Code[10])
        {
            Caption = 'Bill-to Vendor No. (IC)';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used.';
        }
        field(6014410; "NPR Bill-to Phone No."; Text[30])
        {
            Caption = 'Bill-to Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(6014414; "NPR Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Document Sending Profile from Customer is used.';
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014420; "NPR Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            DataClassification = CustomerContent;
        }
        field(6014421; "NPR Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Package Code".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            DataClassification = CustomerContent;
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
        }
        field(6014450; "NPR Kolli"; Integer)
        {
            Caption = 'Number of packages';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(6014451; "NPR Package Quantity"; Integer)
        {
            Caption = 'Package Quantity';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Sum("NPR Package Dimension".Quantity where("Document Type" = const(Order),
                                                                           "Document No." = FIELD("No.")));
        }
        field(6014452; "NPR Delivery Instructions"; Text[50])
        {
            Caption = 'Delivery Instructions';
            DataClassification = CustomerContent;
        }
        field(6151400; "NPR Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Magento Payment Line".Amount WHERE("Document Table No." = CONST(36),
                                                                   "Document Type" = FIELD("Document Type"),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151401; "NPR POS Pricing Profile"; Code[20])
        {
            Caption = 'Price Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Pricing Profile";
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = CustomerContent;
        }
        field(6151415; "NPR Payment No."; Text[50])
        {
            Caption = 'Payment No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used.';
        }
        field(6151420; "NPR Magento Coupon"; Text[20])
        {
            Caption = 'Magento Coupon';
            DataClassification = CustomerContent;
        }
        field(6151425; "NPR Exchange Label Barcode"; Code[20])
        {
            Caption = 'Exchange Label Barcode';
            DataClassification = CustomerContent;
        }
        field(6151435; "NPR Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Group Code".Code;
        }
        field(6151436; "NPR POS Trans. Sch. For Post"; boolean)
        {
            Caption = 'POS Transactions Scheduled For Posting';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Exist("NPR POS Entry Sales Doc. Link" WHERE("Orig. Sales Document No." = field("No."),
                                                      "Orig. Sales Document Type" = field("Document Type"),
                                                     "Post Sales Document Status" = filter("Error while Posting" | "Unposted")));
        }

        field(6151440; "NPR Sales Channel"; Code[20])
        {
            Caption = 'Sales Channel';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Sales Channel".Code;
        }

    }
}
