table 6014418 "Archive Sale POS"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved here for possible future reference (6014418 - header, 6014419 - lines).
    //   The table may be deleted later, when it is no longer relevant.
    // 
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization

    Caption = 'Sale';
    DrillDownPageID = "Archive POS Sale";
    LookupPageID = "Archive POS Sale";

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
        }
        field(2;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            NotBlank = true;
        }
        field(3;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
        }
        field(4;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(5;Date;Date)
        {
            Caption = 'Date';
        }
        field(6;"Start Time";Time)
        {
            Caption = 'Start Time';
        }
        field(7;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = IF ("Customer Type"=CONST(Ord)) Customer."No."
                            ELSE IF ("Customer Type"=CONST(Cash)) Contact."No.";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(8;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(9;Address;Text[50])
        {
            Caption = 'Address';
        }
        field(10;"Address 2";Text[50])
        {
            Caption = 'Address 2';
        }
        field(11;"Post Code";Code[20])
        {
            Caption = 'Post Code';
        }
        field(12;City;Text[30])
        {
            Caption = 'City';
        }
        field(15;"Contact No.";Text[30])
        {
            Caption = 'Contact';
        }
        field(16;Reference;Text[30])
        {
            Caption = 'Reference';
        }
        field(20;"Location Code";Code[10])
        {
            Caption = 'Location Code';
        }
        field(29;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(30;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(33;"Allow Line Discount";Boolean)
        {
            Caption = 'Allow Line Discount';
            InitValue = true;
        }
        field(34;"Customer Price Group";Code[10])
        {
            Caption = 'Customer Price Group';
        }
        field(36;"Sales Document Type";Option)
        {
            Caption = 'Sales Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(37;"Sales Document No.";Code[20])
        {
            Caption = 'Sales Document No.';
        }
        field(39;"Last Shipping No.";Code[20])
        {
            Caption = 'Last Shipping No.';
        }
        field(40;"Last Posting No.";Code[20])
        {
            Caption = 'Last Posting No.';
        }
        field(45;"Customer Disc. Group";Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";
        }
        field(50;"Drawer Opened";Boolean)
        {
            Caption = 'Drawer Opened';
        }
        field(60;"Send Receipt Email";Boolean)
        {
            Caption = 'Send Receipt Email';
        }
        field(74;"Gen. Bus. Posting Group";Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(100;"Saved Sale";Boolean)
        {
            Caption = 'Saved Sale';
        }
        field(101;"Customer Relations";Option)
        {
            Caption = 'Customer Relations';
            OptionCaption = ' ,Customer,Cash Customer';
            OptionMembers = " ",Customer,"Cash Customer";
        }
        field(102;"Last Sale";Boolean)
        {
            Caption = 'Last Sale';
        }
        field(105;Kontankundenr;Code[20])
        {
            Caption = 'Cash Customer No.';
        }
        field(106;"Customer Type";Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ord,Cash;
        }
        field(107;"Org. Bonnr.";Code[20])
        {
            Caption = 'Original Ticket No.';
        }
        field(108;"Non-editable sale";Boolean)
        {
            Caption = 'Non-Editable Sale';
        }
        field(109;"Sale type";Option)
        {
            Caption = 'Sale type';
            OptionCaption = 'Sale,Annullment';
            OptionMembers = Sale,Annullment;
        }
        field(111;"Retursalg Bonnummer";Code[20])
        {
            Caption = 'Reversesale Ticket No.';
            Description = 'Giver mulighed for at tilbagef¢re KUN ÉN bon - benyttet i CU Ekspeditionsmenu';
        }
        field(112;Parameters;Text[250])
        {
            Caption = 'Parameters';
            Description = 'Overf¢r parametre fra ekspeditionen til underfunktioner. Brug f.eks.  Ÿ som separator';
        }
        field(113;"From Quote no.";Code[20])
        {
            Caption = 'From Quote no.';
        }
        field(115;"Service No.";Code[20])
        {
            Caption = 'Service No.';
        }
        field(116;"Stats - Customer Post Code";Code[20])
        {
            Caption = 'Stats - Customer Post Code';
        }
        field(117;"Retail Document Type";Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(118;"Retail Document No.";Code[20])
        {
            Caption = 'No.';
        }
        field(119;"Payment Terms Code";Code[10])
        {
            Caption = 'Payment Terms Code';
        }
        field(120;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(121;TouchScreen;Boolean)
        {
            Caption = 'TouchScreen';
        }
        field(123;Deposit;Decimal)
        {
            Caption = 'Deposit';
        }
        field(126;"Alternative Register No.";Code[20])
        {
            Caption = 'Alternative Cash Register No.';
        }
        field(127;"Country Code";Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "Country/Region";
        }
        field(128;"External Document No.";Code[20])
        {
            Caption = 'External Document No.';
        }
        field(130;"Custom Print Object ID";Integer)
        {
            Caption = 'Custom Print Object ID';
        }
        field(131;"Custom Print Object Type";Text[10])
        {
            Caption = 'Custom Print Object Type';
        }
        field(140;"Issue Tax Free Voucher";Boolean)
        {
            Caption = 'Issue Tax Free Voucher';
        }
        field(141;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(142;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(143;"VAT Bus. Posting Group";Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(150;"Customer Location No.";Code[20])
        {
            Caption = 'Customer Location No.';
        }
        field(160;"POS Sale ID";Integer)
        {
            AutoIncrement = true;
            Caption = 'POS Sale ID';
        }
        field(170;"Retail ID";Guid)
        {
            Caption = 'Retail ID';
        }
        field(180;"Event No.";Code[20])
        {
            Caption = 'Event No.';
            TableRelation = Job WHERE (Event=CONST(true));
        }
        field(300;Amount;Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Archive Sale Line POS".Amount WHERE ("Register No."=FIELD("Register No."),
                                                                    "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                    "Sale Type"=FILTER(Sale|"Debit Sale"|"Gift Voucher"|"Credit Voucher"|Deposit),
                                                                    Type=FILTER(<>Comment&<>"Open/Close")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                Trans0001: Label 'The sign on quantity and amount must be the same';
            begin
            end;
        }
        field(310;"Amount Including VAT";Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Archive Sale Line POS"."Amount Including VAT" WHERE ("Register No."=FIELD("Register No."),
                                                                                    "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                                    "Sale Type"=FILTER(Sale|"Debit Sale"|"Gift Voucher"|"Credit Voucher"|Deposit),
                                                                                    Type=FILTER(<>Comment&<>"Open/Close")));
            Caption = 'Amount Including VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(320;"Payment Amount";Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Archive Sale Line POS"."Amount Including VAT" WHERE ("Register No."=FIELD("Register No."),
                                                                                    "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                                    "Sale Type"=FILTER(Payment|"Out payment"),
                                                                                    Type=FILTER(<>Comment&<>"Open/Close")));
            Caption = 'Payment Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(485;"Customer Name";Text[50])
        {
            CalcFormula = Lookup(Customer.Name WHERE ("No."=FIELD("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(700;"NPRE Pre-Set Seating Code";Code[10])
        {
            Caption = 'Pre-Set Seating Code';
            TableRelation = "NPRE Seating";
        }
        field(701;"NPRE Pre-Set Waiter Pad No.";Code[20])
        {
            Caption = 'Pre-Set Waiter Pad No.';
            TableRelation = "NPRE Waiter Pad";
        }
        field(710;"NPRE Number of Guests";Integer)
        {
            Caption = 'Number of Guests';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.")
        {
        }
        key(Key2;"Salesperson Code","Saved Sale")
        {
        }
        key(Key3;"Register No.","Saved Sale")
        {
        }
        key(Key4;"Retail ID")
        {
        }
    }

    fieldgroups
    {
    }
}

