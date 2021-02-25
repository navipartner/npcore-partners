table 6014425 "NPR Retail Document Header"
{
    Caption = 'Retail Document Header';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Quote';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(4; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(5; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(6; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(7; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(8; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(9; ID; Code[20])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(10; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(11; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(12; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(13; Deposit; Decimal)
        {
            Caption = 'Deposit';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(14; "Time of Day"; Time)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(15; "Rent Salesperson"; Code[20])
        {
            Caption = 'Rent Salesperson';
            DataClassification = CustomerContent;
        }
        field(16; "Rent Register"; Code[10])
        {
            Caption = 'Rent Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(17; "Rent Sales Ticket"; Code[20])
        {
            Caption = 'Rent Sales Ticket';
            DataClassification = CustomerContent;
        }
        field(18; "Return Date"; Date)
        {
            Caption = 'Return Date';
            DataClassification = CustomerContent;
        }
        field(19; "Return Time"; Time)
        {
            Caption = 'Return Time';
            DataClassification = CustomerContent;
        }
        field(20; "Return Salesperson"; Code[20])
        {
            Caption = 'Return Salesperson';
            DataClassification = CustomerContent;
        }
        field(21; "Return Register"; Code[10])
        {
            Caption = 'Return Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(22; "Return Sales Ticket"; Code[20])
        {
            Caption = 'Return Sales Ticket';
            DataClassification = CustomerContent;
        }
        field(23; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(24; "Return Department"; Code[10])
        {
            Caption = 'Return Department';
            DataClassification = CustomerContent;
        }
        field(25; Phone; Text[30])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
        }
        field(26; "Return Date 2"; Date)
        {
            Caption = 'Return Date 2';
            DataClassification = CustomerContent;
        }
        field(27; "Return Time 2"; Time)
        {
            Caption = 'Return Time 2';
            DataClassification = CustomerContent;
        }
        field(28; "Rent Date"; Date)
        {
            Caption = 'Rent Date';
            DataClassification = CustomerContent;
        }
        field(29; "Rent Time"; Time)
        {
            Caption = 'Rent Time';
            DataClassification = CustomerContent;
        }
        field(30; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(31; "Date of Order"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(33; "Bank System Payment"; Boolean)
        {
            Caption = 'Bank System Payment';
            DataClassification = CustomerContent;
        }
        field(34; "Bank Reg. No."; Code[10])
        {
            Caption = 'Bank Registration No.';
            DataClassification = CustomerContent;
        }
        field(35; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(36; "Invoicing Period"; Option)
        {
            Caption = 'Invoicing Period';
            OptionCaption = '1 Month,2 Month,Quater,Semi Annual,Annual,None';
            OptionMembers = "1 Month","2 Month",Quater,"Semi Annual",Annual,"None";
            DataClassification = CustomerContent;
        }
        field(37; "Policy No. Private"; Code[20])
        {
            Caption = 'Policy No. Private';
            DataClassification = CustomerContent;
        }
        field(38; "Payment Date"; Date)
        {
            Caption = 'Payment Date';
            DataClassification = CustomerContent;
        }
        field(40; "Repurchase %"; Decimal)
        {
            Caption = 'Repurchase %';
            DataClassification = CustomerContent;
        }
        field(41; "Repurchase Amount Incl. VAT"; Decimal)
        {
            Caption = 'Repurchase Amount incl. VAT';
            DataClassification = CustomerContent;
        }
        field(42; "Annual Rental Amount"; Decimal)
        {
            Caption = 'Annual Rental Amount';
            DataClassification = CustomerContent;
        }
        field(44; Principal; Decimal)
        {
            Caption = 'Principal';
            DataClassification = CustomerContent;
        }
        field(45; "Next Invoice Date"; Date)
        {
            Caption = 'Next Invoice Date';
            DataClassification = CustomerContent;
        }
        field(46; "Last Invoice Date"; Date)
        {
            Caption = 'Last Invoice Date';
            DataClassification = CustomerContent;
        }
        field(48; "Establishment Charge"; Decimal)
        {
            Caption = 'Establishment Charge';
            DataClassification = CustomerContent;
        }
        field(53; "Periodic Fee"; Decimal)
        {
            Caption = 'Periodic Fee';
            DataClassification = CustomerContent;
        }
        field(54; Payout; Decimal)
        {
            Caption = 'Payout';
            DataClassification = CustomerContent;
        }
        field(55; "Sales Price Incl. Interest"; Decimal)
        {
            Caption = 'Sales Price Incl. Interest';
            DataClassification = CustomerContent;
        }
        field(56; "Interest Pct."; Decimal)
        {
            Caption = 'Interest Pct.';
            DataClassification = CustomerContent;
        }
        field(57; "Duration in Periods"; Decimal)
        {
            Caption = 'Duration in Periods';
            DataClassification = CustomerContent;
        }
        field(58; Payment; Decimal)
        {
            Caption = 'Payment ';
            DataClassification = CustomerContent;
        }
        field(59; "Last Payment"; Decimal)
        {
            Caption = 'Last Payment';
            DataClassification = CustomerContent;
        }
        field(61; Costs; Decimal)
        {
            Caption = 'Costs';
            DataClassification = CustomerContent;
        }
        field(62; "Purchase on Credit Amount"; Decimal)
        {
            Caption = 'Purchase on Credit Amount';
            DataClassification = CustomerContent;
        }
        field(63; "Repayment Date"; Date)
        {
            Caption = 'Repayment Date';
            DataClassification = CustomerContent;
        }
        field(64; "Rapayment Interest"; Decimal)
        {
            Caption = 'Rapayment Interest';
            DataClassification = CustomerContent;
        }
        field(65; "Calculation Method"; Option)
        {
            Caption = 'Calculation Method';
            OptionCaption = ',Rates,Output';
            OptionMembers = ,Rater,Ydelse;
            DataClassification = CustomerContent;
        }
        field(66; "First Payment Day"; Date)
        {
            Caption = 'First Payment Day';
            DataClassification = CustomerContent;
        }
        field(67; "Total Interest Amount"; Decimal)
        {
            Caption = 'Total Interest Amount';
            DataClassification = CustomerContent;
        }
        field(68; "Total Fee"; Decimal)
        {
            Caption = 'Total Fee';
            DataClassification = CustomerContent;
        }
        field(69; Factor; Integer)
        {
            Caption = 'Factor';
            Description = 'Forhold mellem måneder og perioder';
            DataClassification = CustomerContent;
        }
        field(70; "Delivery Date"; Date)
        {
            Caption = 'Delivery Date';
            DataClassification = CustomerContent;
        }
        field(71; "Contract Status"; Option)
        {
            Caption = 'Contract Status';
            OptionCaption = 'Ongoing,Finished,Transmitted to invoice,Financing,Selling company';
            OptionMembers = Ongoing,Finished,"Transmitted to invoice",Financing,"Selling company";
            DataClassification = CustomerContent;
        }
        field(73; "Posted Payment"; Decimal)
        {
            Caption = 'Posted Payment';
            DataClassification = CustomerContent;
        }
        field(74; "Posted Interest"; Decimal)
        {
            Caption = 'Posted Interest';
            DataClassification = CustomerContent;
        }
        field(75; "Repayment Amount"; Decimal)
        {
            Caption = 'Repayment Amount';
            DataClassification = CustomerContent;
        }
        field(76; "Posted Rent Incl. VAT"; Decimal)
        {
            Caption = 'Posted Rent Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(77; "Contract Value"; Decimal)
        {
            Caption = 'Contract Value';
            DataClassification = CustomerContent;
        }
        field(78; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(100; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(102; Cashed; Boolean)
        {
            Caption = 'Cashed';
            InitValue = false;
            DataClassification = CustomerContent;
        }
        field(103; "Vendor Index"; Code[20])
        {
            Caption = 'Vendor Index';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(104; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = ',Ordered,Got Home,To be Ordered,Customer Contact,Sold Out,Balance of Order';
            OptionMembers = " ",Bestilt,Hjemkommet,"Skal bestilles",Kundekontakt,Udsolgt,Restordre;
            DataClassification = CustomerContent;
        }
        field(105; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(106; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Alm,Kontant;
            DataClassification = CustomerContent;
        }
        field(107; Paid; Boolean)
        {
            Caption = 'Paid';
            InitValue = false;
            DataClassification = CustomerContent;
        }
        field(108; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(109; Via; Option)
        {
            Caption = 'Via';
            OptionCaption = ' ,POS,Order';
            OptionMembers = " ",POS,"Order";
            DataClassification = CustomerContent;
        }
        field(110; "Copy No."; Integer)
        {
            Caption = 'Copy No.';
            DataClassification = CustomerContent;
        }
        field(112; Mobile; Text[30])
        {
            Caption = 'Cell No.';
            DataClassification = CustomerContent;
        }
        field(113; Reference; Text[30])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(114; "E-mail"; Text[250])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(120; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Quote';
            DataClassification = CustomerContent;
        }
        field(121; "Lookup Unit Price"; Boolean)
        {
            Caption = 'Lookup Unit Price';
            DataClassification = CustomerContent;
        }
        field(122; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }
        field(123; "Shipping Type"; Option)
        {
            Caption = 'Shipping Method';
            OptionCaption = 'normal,express delivery,by external carrier';
            OptionMembers = Normal,Express,"External carrier";
            DataClassification = CustomerContent;
        }
        field(124; Delivery; Option)
        {
            Caption = 'Delivery';
            OptionCaption = 'Collected,Shipped';
            OptionMembers = Collected,Shipped;
            DataClassification = CustomerContent;
        }
        field(125; "Notify Customer"; Option)
        {
            Caption = 'Notify Customer';
            OptionCaption = 'Phone,Mail,SMS';
            OptionMembers = Phone,Mail,SMS;
            DataClassification = CustomerContent;
        }
        field(126; "ID Card"; Code[20])
        {
            Caption = 'ID card';
            DataClassification = CustomerContent;
        }
        field(127; "Req. Return Date"; Date)
        {
            Caption = 'Req. Return Date';
            DataClassification = CustomerContent;
        }
        field(128; "Expiry Date"; Date)
        {
            Caption = 'Expiry Date';
            Description = 'Hvornår en udlejningskontrakt oph¢rer';
            DataClassification = CustomerContent;
        }
        field(129; "Document Date"; Date)
        {
            Caption = 'Date Created';
            Description = 'kontrakt dato. Benyttes til at udregne expire date ved hjælp af antal betalinger og antal terminer';
            DataClassification = CustomerContent;
        }
        field(130; "Delivery Time 1"; Time)
        {
            Caption = 'Delivery Time 1';
            DataClassification = CustomerContent;
        }
        field(131; "Delivery Time 2"; Time)
        {
            Caption = 'Delivery Time 2';
            DataClassification = CustomerContent;
        }
        field(132; "Alternative Delivery Date"; Date)
        {
            Caption = 'Alternative Delivery Date';
            DataClassification = CustomerContent;
        }
        field(133; "Return with Used Goods"; Boolean)
        {
            Caption = 'Return with Used Goods';
            DataClassification = CustomerContent;
        }
        field(134; "Estimated Time Use"; Time)
        {
            Caption = 'Estimated Time Use';
            DataClassification = CustomerContent;
        }
        field(135; "Resource Ship-by Car"; Code[20])
        {
            Caption = 'Resource Ship-by Car';
            DataClassification = CustomerContent;
        }
        field(136; "Resource Ship-by Person"; Code[20])
        {
            Caption = 'Resource Ship-by Person';
            DataClassification = CustomerContent;
        }
        field(137; "Resource Ship-by Person 2"; Code[20])
        {
            Caption = 'Resource Ship-by Person 2';
            DataClassification = CustomerContent;
        }
        field(138; "Ship-to Resource Date"; Date)
        {
            Caption = 'Ship-to Resource Date';
            DataClassification = CustomerContent;
        }
        field(139; "Ship-to Resource Time"; Time)
        {
            Caption = 'Ship-to Resource Time';
            DataClassification = CustomerContent;
        }
        field(141; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
        }
        field(142; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(143; "Retail Order No."; Code[20])
        {
            Caption = 'Retail Order No.';
            DataClassification = CustomerContent;
        }
        field(144; "Rent Document No."; Code[20])
        {
            Caption = 'Rent Document No.';
            DataClassification = CustomerContent;
        }
        field(145; "Used Goods Return Text"; Text[50])
        {
            Caption = 'Used Goods Return Text';
            DataClassification = CustomerContent;
        }
        field(146; "Resource Ship-by n Persons"; Integer)
        {
            Caption = 'Persons';
            DataClassification = CustomerContent;
        }
        field(147; "Invoice Document Type"; Option)
        {
            Caption = 'Invoice Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(148; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
            DataClassification = CustomerContent;
        }
        field(149; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(150; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(151; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
        }
        field(152; "Delivery by Vendor"; Code[20])
        {
            Caption = 'Delivery by Vendor';
            DataClassification = CustomerContent;
        }
        field(154; "Retail Document Type Parent"; Option)
        {
            Caption = 'Document Type Link';
            OptionCaption = ' ,Contract,Retail Order,Wish';
            OptionMembers = " ",Contract,"Retail Order",Wish;
            DataClassification = CustomerContent;
        }
        field(155; "Retail Document No. Parent"; Code[20])
        {
            Caption = 'Retail Document No. Link';
            DataClassification = CustomerContent;
        }
        field(156; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
        }
        field(157; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
            FieldClass = FlowField;
        }
        field(158; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
        }
        field(165; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
        }
        field(1000; Outstanding; Boolean)
        {
            Caption = 'Outstanding';
            DataClassification = CustomerContent;
        }
        field(1001; "Show List"; Boolean)
        {
            Caption = 'Show List';
            DataClassification = CustomerContent;
        }
        field(1002; "Letter Printed"; Date)
        {
            Caption = 'Letter Printed';
            DataClassification = CustomerContent;
        }
        field(1003; "Max Amount"; Decimal)
        {
            Caption = 'Maximum Amount';
            DataClassification = CustomerContent;
        }
        field(1004; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
            DataClassification = CustomerContent;
        }
        field(1005; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
            DataClassification = CustomerContent;
        }
        field(1006; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
            DataClassification = CustomerContent;
        }
        field(1007; "Ship-to Post Code"; Text[30])
        {
            Caption = 'Ship-to Post Code';
            DataClassification = CustomerContent;
        }
        field(1008; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            DataClassification = CustomerContent;
        }
        field(1009; "Ship-to Attention"; Text[30])
        {
            Caption = 'Ship-to Attention';
            DataClassification = CustomerContent;
        }
        field(1010; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }
        field(1011; "Has Run"; Integer)
        {
            Caption = 'Has Run';
            DataClassification = CustomerContent;
        }
        field(1012; "Amount Incl. VAT"; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            FieldClass = FlowField;
        }
        field(1013; "Ship-to Country Code"; Code[10])
        {
            Caption = 'Ship-to Country Code';
            DataClassification = CustomerContent;
        }
        field(1014; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
        }
        field(1015; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(1016; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            DataClassification = CustomerContent;
        }
        field(1025; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.")
        {
        }
        key(Key2; "Document Type", Cashed, Outstanding, "Show List")
        {
        }
        key(Key3; "Document Type", Cashed, "Show List")
        {
        }
        key(Key4; "Rent Register", "Rent Sales Ticket")
        {
        }
        key(Key5; "Return Register", "Return Sales Ticket")
        {
        }
        key(Key6; "Document Type", Name)
        {
        }
        key(Key7; "Document Type", "First Name", Name)
        {
        }
        key(Key8; "Document Type", "Post Code")
        {
        }
        key(Key9; "Document Type", "Customer No.")
        {
        }
        key(Key10; "Document Type", Cashed, Status)
        {
        }
        key(Key11; "Document Type", Status)
        {
        }
        key(Key12; "Shortcut Dimension 1 Code", "No.")
        {
        }
        key(Key13; "Primary Key Length")
        {
        }
        key(Key14; "Invoice No.")
        {
        }
    }

    fieldgroups
    {
    }
}

