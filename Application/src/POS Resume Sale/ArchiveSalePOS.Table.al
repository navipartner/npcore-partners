table 6014418 "NPR Archive Sale POS"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved here for possible future reference (6014418 - header, 6014419 - lines).
    //   The table may be deleted later, when it is no longer relevant.

    Caption = 'Sale';
    DrillDownPageID = "NPR Archive POS Sale";
    LookupPageID = "NPR Archive POS Sale";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
        }
        field(4; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser".Code;
            DataClassification = CustomerContent;
        }
        field(5; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(6; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = IF ("Customer Type" = CONST(Ord)) Customer."No."
            ELSE
            IF ("Customer Type" = CONST(Cash)) Contact."No.";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(8; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(9; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(10; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(11; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(12; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(15; "Contact No."; Text[30])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(16; Reference; Text[30])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(33; "Allow Line Discount"; Boolean)
        {
            Caption = 'Allow Line Discount';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(34; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
        }
        field(36; "Sales Document Type"; Option)
        {
            Caption = 'Sales Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(37; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
            DataClassification = CustomerContent;
        }
        field(39; "Last Shipping No."; Code[20])
        {
            Caption = 'Last Shipping No.';
            DataClassification = CustomerContent;
        }
        field(40; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            DataClassification = CustomerContent;
        }
        field(45; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";
            DataClassification = CustomerContent;
        }
        field(50; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            DataClassification = CustomerContent;
        }
        field(60; "Send Receipt Email"; Boolean)
        {
            Caption = 'Send Receipt Email';
            DataClassification = CustomerContent;
        }
        field(74; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(100; "Saved Sale"; Boolean)
        {
            Caption = 'Saved Sale';
            DataClassification = CustomerContent;
        }
        field(101; "Customer Relations"; Option)
        {
            Caption = 'Customer Relations';
            OptionCaption = ' ,Customer,Cash Customer';
            OptionMembers = " ",Customer,"Cash Customer";
            DataClassification = CustomerContent;
        }
        field(102; "Last Sale"; Boolean)
        {
            Caption = 'Last Sale';
            DataClassification = CustomerContent;
        }
        field(105; Kontankundenr; Code[20])
        {
            Caption = 'Cash Customer No.';
            DataClassification = CustomerContent;
        }
        field(106; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ord,Cash;
            DataClassification = CustomerContent;
        }
        field(107; "Org. Bonnr."; Code[20])
        {
            Caption = 'Original Ticket No.';
            DataClassification = CustomerContent;
        }
        field(108; "Non-editable sale"; Boolean)
        {
            Caption = 'Non-Editable Sale';
            DataClassification = CustomerContent;
        }
        field(109; "Sale type"; Option)
        {
            Caption = 'Sale type';
            OptionCaption = 'Sale,Annullment';
            OptionMembers = Sale,Annullment;
            DataClassification = CustomerContent;
        }
        field(111; "Retursalg Bonnummer"; Code[20])
        {
            Caption = 'Reversesale Ticket No.';
            Description = 'Giver mulighed for at tilbagef¢re KUN ÉN bon - benyttet i CU Ekspeditionsmenu';
            DataClassification = CustomerContent;
        }
        field(112; Parameters; Text[250])
        {
            Caption = 'Parameters';
            Description = 'Overf¢r parametre fra ekspeditionen til underfunktioner. Brug f.eks.  Ÿ som separator';
            DataClassification = CustomerContent;
        }
        field(113; "From Quote no."; Code[20])
        {
            Caption = 'From Quote no.';
            DataClassification = CustomerContent;
        }
        field(115; "Service No."; Code[20])
        {
            Caption = 'Service No.';
            DataClassification = CustomerContent;
        }
        field(116; "Stats - Customer Post Code"; Code[20])
        {
            Caption = 'Stats - Customer Post Code';
            DataClassification = CustomerContent;
        }
        field(117; "Retail Document Type"; Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            DataClassification = CustomerContent;
        }
        field(118; "Retail Document No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(119; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
        }
        field(120; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(121; TouchScreen; Boolean)
        {
            Caption = 'TouchScreen';
            DataClassification = CustomerContent;
        }
        field(123; Deposit; Decimal)
        {
            Caption = 'Deposit';
            DataClassification = CustomerContent;
        }
        field(126; "Alternative Register No."; Code[20])
        {
            Caption = 'Alternative POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(127; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(128; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(130; "Custom Print Object ID"; Integer)
        {
            Caption = 'Custom Print Object ID';
            DataClassification = CustomerContent;
        }
        field(131; "Custom Print Object Type"; Text[10])
        {
            Caption = 'Custom Print Object Type';
            DataClassification = CustomerContent;
        }
        field(140; "Issue Tax Free Voucher"; Boolean)
        {
            Caption = 'Issue Tax Free Voucher';
            DataClassification = CustomerContent;
        }
        field(141; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
            DataClassification = CustomerContent;
        }
        field(142; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(143; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(150; "Customer Location No."; Code[20])
        {
            Caption = 'Customer Location No.';
            DataClassification = CustomerContent;
        }
        field(160; "POS Sale ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'POS Sale ID';
            DataClassification = CustomerContent;
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
        }
        field(180; "Event No."; Code[20])
        {
            Caption = 'Event No.';
            TableRelation = Job WHERE("NPR Event" = CONST(true));
            DataClassification = CustomerContent;
        }
        field(300; Amount; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NPR Archive Sale Line POS".Amount WHERE("Register No." = FIELD("Register No."),
                                                                    "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                    "Sale Type" = FILTER(Sale | "Debit Sale" | Deposit),
                                                                    Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                Trans0001: Label 'The sign on quantity and amount must be the same';
            begin
            end;
        }
        field(310; "Amount Including VAT"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NPR Archive Sale Line POS"."Amount Including VAT" WHERE("Register No." = FIELD("Register No."),
                                                                                    "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                                    "Sale Type" = FILTER(Sale | "Debit Sale" | Deposit),
                                                                                    Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Amount Including VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(320; "Payment Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NPR Archive Sale Line POS"."Amount Including VAT" WHERE("Register No." = FIELD("Register No."),
                                                                                    "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                                    "Sale Type" = FILTER(Payment | "Out payment"),
                                                                                    Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Payment Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;
        }
        field(485; "Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(700; "NPRE Pre-Set Seating Code"; Code[10])
        {
            Caption = 'Pre-Set Seating Code';
            TableRelation = "NPR NPRE Seating";
            DataClassification = CustomerContent;
        }
        field(701; "NPRE Pre-Set Waiter Pad No."; Code[20])
        {
            Caption = 'Pre-Set Waiter Pad No.';
            TableRelation = "NPR NPRE Waiter Pad";
            DataClassification = CustomerContent;
        }
        field(710; "NPRE Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.")
        {
        }
        key(Key2; "Salesperson Code", "Saved Sale")
        {
        }
        key(Key3; "Register No.", "Saved Sale")
        {
        }
        key(Key4; "Retail ID")
        {
        }
    }

    fieldgroups
    {
    }
}

