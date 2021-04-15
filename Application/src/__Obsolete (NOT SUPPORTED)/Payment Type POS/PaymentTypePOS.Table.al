table 6014402 "NPR Payment Type POS"
{

    Caption = 'Payment Type';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Is replaced by POS Payment Method';

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;

        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(3; "Processing Type"; Option)
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Cash,Terminal Card,Manual Card,Other Credit Cards,Credit Voucher,Gift Voucher,Electronic Funds Transfer,Foreign Currency,Foreign Credit Voucher,Foreign Gift Voucher,Debit sale,Invoice,Finance Agreement,Payout,DIBS,Loyalty Card';
            OptionMembers = " ",Cash,"Terminal Card","Manual Card","Other Credit Cards","Credit Voucher","Gift Voucher",EFT,"Foreign Currency","Foreign Credit Voucher","Foreign Gift Voucher","Debit sale",Invoice,"Finance Agreement",Payout,DIBS,"Point Card";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(4; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Active,Passive';
            OptionMembers = " ",Active,Passive;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(6; Prefix; Code[20])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(7; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(21; "Cost Account No."; Code[20])
        {
            Caption = 'Cost Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';

        }
        field(22; "Sales Line Text"; Text[50])
        {
            Caption = 'Sale Line Text';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(23; "Search Description"; Text[50])
        {
            Caption = 'Search Description';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(24; Posting; Option)
        {
            Caption = 'Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'Condensed,Single Entry';
            OptionMembers = Condensed,"Single Entry";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(25; "Via Terminal"; Boolean)
        {
            Caption = 'Via Cash Terminal';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(26; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(27; "Amount in Audit Roll"; Decimal)
        {
            Caption = 'Amount in Audit Roll';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(28; "Customer No."; Code[20])
        {
            Caption = 'Customer';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(29; "Account Type"; Option)
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            OptionCaption = 'G/L Account,Customer,Bank';
            OptionMembers = "G/L Account",Customer,Bank;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(30; "Register Filter"; Code[10])
        {
            Caption = 'Cash Register Filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(31; "Fixed Rate"; Decimal)
        {
            Caption = 'Fixed Rate';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(32; "Reference Incoming"; Boolean)
        {
            Caption = 'Reference Incoming';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(33; "Receipt Filter"; Code[20])
        {
            Caption = 'Receipt filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(35; "Receipt - Post it Now"; Boolean)
        {
            Caption = 'Receipt - Post it now';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(36; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding precision';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(37; "No. of Sales in Audit Roll"; Integer)
        {
            Caption = 'No. Sales in audit roll';
            Description = 'Tæller kun linier m. linienr=10000,vare, salg';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(38; "Normal Sale in Audit Roll"; Decimal)
        {
            Caption = 'Normal sale in audit roll';
            Description = 'Tæller "bel¢b inkl. moms" hvis salg, vare';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(39; "Debit Sale in Audit Roll"; Decimal)
        {
            Caption = 'Debit sale in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(40; "No. of Items in Audit Roll"; Decimal)
        {
            Caption = 'No. items in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(41; "Cost Amount in Audit Roll"; Decimal)
        {
            Caption = 'Cost amount in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(42; "No. of Sale Lines in Aud. Roll"; Integer)
        {
            Caption = 'No. sales lines in audit roll';
            Description = 'Tæller alle linier m. type <>Afbrudt &<>Åben/Luk';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(43; "Salesperson Filter"; Code[20])
        {
            Caption = 'Salesperson filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser".Code;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(44; "No. of Items in Audit Debit"; Decimal)
        {
            Caption = 'No. items in audit debit';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(45; "No. of Item Lines in Aud. Deb."; Integer)
        {
            Caption = 'No. item linies in audit debit';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(46; "No. of Deb. Sales in Aud. Roll"; Integer)
        {
            Caption = 'No. debit sales in audit roll';
            Description = 'Tæller linie debetsalg,linienr=10000';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';

        }
        field(47; Euro; Boolean)
        {
            Caption = 'Euro';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';

        }
        field(48; "Bank Acc. No."; Code[20])
        {
            Caption = 'Bank';
            DataClassification = CustomerContent;
            TableRelation = "Bank Account"."No.";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(49; "Fee G/L Acc. No."; Code[20])
        {
            Caption = 'Fee';
            DataClassification = CustomerContent;
            Description = 'Deprecated';
            TableRelation = "G/L Account";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(50; "Fee Pct."; Decimal)
        {
            Caption = 'Fee Pct';
            DataClassification = CustomerContent;
            Description = 'Deprecated';
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(51; "Fixed Fee"; Decimal)
        {
            Caption = 'Fixed fee';
            DataClassification = CustomerContent;
            Description = 'Deprecated';
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(52; "Fee Item No."; Code[20])
        {
            Caption = 'Fee item';
            DataClassification = CustomerContent;
            Description = 'Deprecated';
            TableRelation = Item;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(53; "Norm. Sales in Audit Excl. VAT"; Decimal)
        {
            Caption = 'Norm sales in audit ex VAT';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(54; "Maximum Amount"; Decimal)
        {
            Caption = 'Max amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(55; "Minimum Amount"; Decimal)
        {
            Caption = 'Min amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(56; "Debit Cost Amount Audit Roll"; Decimal)
        {
            Caption = 'Cost amount in audit';
            Description = 'Calcformula tilf¢jet';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(57; "Debit Sales in Audit Excl. VAT"; Decimal)
        {
            Caption = 'Debit sales in audit ex VAT';
            Description = 'Calcformula tilf¢jet';
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(58; "Cardholder Verification Method"; Option)
        {
            Caption = 'Cardholder Verification Method';
            DataClassification = CustomerContent;
            Description = 'Cardholder Verification Method';
            OptionCaption = 'CVM not forced,Forced Signature,Forced Pin';
            OptionMembers = "CVM not Forced","Forced Signature","Forced Pin";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(59; "Type of Transaction"; Option)
        {
            Caption = 'Type of transaction';
            DataClassification = CustomerContent;
            OptionCaption = 'Not forced,Forced Online,Forced Offline';
            OptionMembers = "Not Forced","Forced Online","Forced Offline";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(60; "Global Dimension Code 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension Code 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(61; "Global Dimension Code 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension Code 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(62; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = Location;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(65; "Is Check"; Boolean)
        {
            Caption = 'Check';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(66; "Common Company Clearing"; Boolean)
        {
            Caption = 'Common Company Clearing';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(67; "Day Clearing Account"; Code[20])
        {
            Caption = 'Day Clearing Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(68; "Forced Amount"; Boolean)
        {
            Caption = 'Forced amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(70; "To be Balanced"; Boolean)
        {
            Caption = 'Incl. in balancing';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(71; "Balancing Total"; Decimal)
        {
            Caption = 'Counted';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(75; "Match Sales Amount"; Boolean)
        {
            Caption = 'Match Sales Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(80; "Fixed Amount"; Decimal)
        {
            Caption = 'Fixed Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(81; "Qty. Per Sale"; Integer)
        {
            Caption = 'Qty. Per Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(82; "Minimum Sales Amount"; Decimal)
        {
            Caption = 'Min Sales Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(83; "Human Validation"; Boolean)
        {
            Caption = 'Validated by user';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(90; "Immediate Posting"; Option)
        {
            Caption = 'Immediate Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'Never,Always,Negative,Positive';
            OptionMembers = Never,Always,Negative,Positive;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(100; "Reverse Unrealized VAT"; Boolean)
        {
            Caption = 'Reverse Unrealized VAT';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(110; "Open Drawer"; Boolean)
        {
            Caption = 'Open Drawer';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(120; "Allow Refund"; Boolean)
        {
            Caption = 'Allow Refund';
            DataClassification = CustomerContent;
            Description = 'NPR5.52,NPR5.53';
            InitValue = true;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(130; "Zero as Default on Popup"; Boolean)
        {
            Caption = 'Zero as Default on Popup';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(140; "No Min Amount on Web Orders"; Boolean)
        {
            Caption = 'No Min Amount on Web Orders';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(200; "PBS Gift Voucher"; Boolean)
        {
            Caption = 'PBS Gift Voucher';
            DataClassification = CustomerContent;
            Description = 'Deprecated';
            ObsoleteState = Pending;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(201; "PBS Customer ID"; Text[30])
        {
            Caption = 'PBS Customer ID';
            DataClassification = CustomerContent;
            Description = 'Deprecated';
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(202; "PBS Gift Voucher Barcode"; Boolean)
        {
            Caption = 'PBS Gift Voucher Barcode';
            DataClassification = CustomerContent;
            Description = 'Deprecated';
            ObsoleteState = Pending;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(250; "Loyalty Card Type"; Code[20])
        {
            Caption = 'Loyalty Card Type';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(318; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Only used by Global Dimension 1';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(319; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Only used by Global Dimension 2';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(320; "Auto End Sale"; Boolean)
        {
            Caption = 'Auto end sale';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(321; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(323; "Balancing Type"; Option)
        {
            Caption = 'Balancing type';
            DataClassification = CustomerContent;
            OptionCaption = 'Currency,New inventory,Transfer to Bank';
            OptionMembers = Normal,Primo,Bank;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(350; "Validation Codeunit"; Integer)
        {
            Caption = 'Validation Codeunit';
            DataClassification = CustomerContent;
            Description = 'Invokes this codeunit when a Sale Line POS with type payment is being inserted.';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type - Integration cleanup';
        }
        field(351; "On Sale End Codeunit"; Integer)
        {
            Caption = 'On Sale End Codeunit';
            DataClassification = CustomerContent;
            Description = 'Invokes this codeunit before a sale is finished. Can interrupt the end of a sale.';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type - Integration cleanup';
        }
        field(352; "Post Processing Codeunit"; Integer)
        {
            Caption = 'Post Processing Codeunit';
            DataClassification = CustomerContent;
            Description = 'Invokes this codeunit when a sale is finished eg. transferred to the auditroll.';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type - Integration cleanup';
        }
        field(501; "Payment Card Type"; Option)
        {
            Caption = 'Payment Card Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Other,Dankort,VisaDankort,Visa,VisaElectron,Mastercard,Maestro,JCB,DinersClub,AmericanExpress';
            OptionMembers = other,dankort,visadankort,visa,visaelectron,mastercard,maestro,jcb,dinersclub,americanexpress;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(505; "End Time Filter"; Time)
        {
            Caption = 'End time filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(510; "Dev Term"; Boolean)
        {
            Caption = 'Dev Term';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(520; "EFT Surcharge Service Item No."; Code[20])
        {
            Caption = 'Surcharge Service Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item WHERE(Type = CONST(Service));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(530; "EFT Tip Service Item No."; Code[20])
        {
            Caption = 'Tip Service Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item WHERE(Type = CONST(Service));
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'Moved to NPR POS Payment Method';
        }
        field(6184471; "MobilePay Merchant ID"; Code[20])
        {
            Caption = 'MobilePay Merchant ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(6184472; "MobilePay API Key"; Code[50])
        {
            Caption = 'MobilePay API Key';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
        field(6184473; "MobilePay Environment"; Option)
        {
            Caption = 'MobilePay Environment';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            OptionCaption = 'PROD,DEMO';
            OptionMembers = PROD,DEMO;
            ObsoleteState = Pending;
            ObsoleteReason = 'Payment Type POS cleanup';
            ObsoleteTag = 'NPR Payment Type POS';
        }
    }

    keys
    {
        key(Key1; "No.", "Register No.")
        {
        }
        key(Key2; "Via Terminal", Prefix)
        {
            Enabled = false;
        }
        key(Key3; "Search Description")
        {
        }
        key(Key5; "G/L Account No.")
        {
            Enabled = false;
        }
        key(Key6; "Processing Type")
        {
        }
        key(Key8; "Receipt - Post it Now")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
    end;

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin

    end;

    trigger OnRename()

    begin
    end;

    var

    procedure GetByRegister(PaymentCodeNo: Code[10]; RegisterNo: Code[10])
    begin
        Get(PaymentCodeNo, '');
    end;
}

