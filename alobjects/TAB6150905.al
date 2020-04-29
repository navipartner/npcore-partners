table 6150905 "HC Payment Type POS"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector:  Created object based on Table 6014402
    // NPR5.38/BR  /20171128 CASE 297946 Added field 600 HQ Processing
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 329
    // NPR5.48/TJ  /20190128 CASE 340446 Fixed dimension table relations

    Caption = 'HC Payment Type POS';
    LookupPageID = "HC Payment Types";

    fields
    {
        field(1;"No.";Code[10])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                  "Search Description" := Description;
            end;
        }
        field(3;"Processing Type";Option)
        {
            Caption = 'Processing Type';
            OptionCaption = ' ,Cash,Terminal Card,Manual Card,Other Credit Cards,Credit Voucher,Gift Voucher,Cash Terminal,Foreign Currency,Foreign Credit Voucher,Foreign Gift Voucher,Debit sale,Invoice,Finance Agreement,Payout,DIBS,Loyalty Card';
            OptionMembers = " ",Cash,"Terminal Card","Manual Card","Other Credit Cards","Credit Voucher","Gift Voucher","Cash Terminal","Foreign Currency","Foreign Credit Voucher","Foreign Gift Voucher","Debit sale",Invoice,"Finance Agreement",Payout,DIBS,"Point Card";

            trigger OnValidate()
            begin
                TestField("Via Terminal",false);
            end;
        }
        field(4;"G/L Account No.";Code[20])
        {
            Caption = 'G/L Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                GLAccount.Get("G/L Account No.");
                GLAccount.TestField(Blocked,false);
            end;
        }
        field(5;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Active,Passive';
            OptionMembers = " ",Active,Passive;

            trigger OnValidate()
            var
                Trans0001: Label 'You cannot change status, since there exists one or more non-posted audit rolls';
            begin
                if Status = Status::Active then begin
                  if "Account Type" = "Account Type"::"G/L Account" then
                    TestField( "G/L Account No." );
                  if "Account Type" = "Account Type"::Customer then
                    TestField( "Customer No." );
                end;
                if (xRec.Status = xRec.Status::Active) and not (Status = Status::Active) then begin
                  AuditRoll.SetCurrentKey("Sale Type",Type,"No.",Posted);
                  AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
                  AuditRoll.SetRange(Type,AuditRoll.Type::"Debit Sale");
                  AuditRoll.SetRange(Posted,false);
                  AuditRoll.SetRange("No.",xRec."No.");
                  if AuditRoll.Find('-') then
                    Error(Trans0001);
                end;
            end;
        }
        field(6;Prefix;Code[20])
        {
            Caption = 'Prefix';
        }
        field(7;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = "HC Register";
        }
        field(20;"Cost Pct.";Decimal)
        {
            Caption = 'Cost %';
        }
        field(21;"Cost Account No.";Code[20])
        {
            Caption = 'Cost Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                GLAccount.Get("Cost Account No.");
                GLAccount.TestField(Blocked,false);
            end;
        }
        field(22;"Sales Line Text";Text[50])
        {
            Caption = 'Sale Line Text';
        }
        field(23;"Search Description";Text[50])
        {
            Caption = 'Search Description';
        }
        field(24;Posting;Option)
        {
            Caption = 'Posting';
            OptionCaption = 'Condensed,Single Entry';
            OptionMembers = Condensed,"Single Entry";
        }
        field(25;"Via Terminal";Boolean)
        {
            Caption = 'Via Cash Terminal';
        }
        field(26;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(27;"Amount in Audit Roll";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll"."Amount Including VAT" WHERE ("Register No."=FIELD("Register Filter"),
                                                                            "Sales Ticket No."=FIELD("Receipt Filter"),
                                                                            "Sale Date"=FIELD("Date Filter"),
                                                                            "Sale Type"=CONST(Payment),
                                                                            Type=CONST(Payment),
                                                                            "Salesperson Code"=FIELD("Salesperson Filter"),
                                                                            "Closing Time"=FIELD("End Time Filter"),
                                                                            "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                                            "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter"),
                                                                            "No."=FIELD("No.")));
            Caption = 'Amount in Audit Roll';
            FieldClass = FlowField;
        }
        field(28;"Customer No.";Code[20])
        {
            Caption = 'Customer';
            TableRelation = Customer;

            trigger OnValidate()
            var
                ErrNoCurrencyCode: Label 'Currency code for customer %1 must be blank';
                ErrNoCustomerNo: Label 'Debtorcode cannot be empty';
            begin
                if "Customer No." = '' then
                  Error( ErrNoCustomerNo );
                Customer.Get( "Customer No." );
                if Customer."Currency Code" <> '' then
                  Error( ErrNoCurrencyCode, "Customer No." );
            end;
        }
        field(29;"Account Type";Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'G/L Account,Customer,Bank';
            OptionMembers = "G/L Account",Customer,Bank;

            trigger OnValidate()
            var
                Cust: Record Customer;
                ErrCustomer: Label 'A deptor must be chosen for this accounttype';
                CustomerList: Page "Customer List";
            begin
                RetailSetup.Get;
                if "Account Type" = "Account Type"::Customer then begin
                  Clear( CustomerList );
                  CustomerList.LookupMode( true );
                  if CustomerList.RunModal <> ACTION::LookupOK then
                    Error( ErrCustomer );

                  CustomerList.GetRecord( Cust );
                  Validate( "Customer No.", Cust."No." );
                end;
            end;
        }
        field(30;"Register Filter";Code[10])
        {
            Caption = 'Cash Register Filter';
            FieldClass = FlowFilter;
            TableRelation = "HC Register";
        }
        field(31;"Fixed Rate";Decimal)
        {
            Caption = 'Fixed Rate';
        }
        field(32;"Reference Incoming";Boolean)
        {
            Caption = 'Reference Incoming';
        }
        field(33;"Receipt Filter";Code[10])
        {
            Caption = 'Receipt filter';
            FieldClass = FlowFilter;
        }
        field(34;"Receipt Copies";Integer)
        {
            Caption = 'Receipt copies';
        }
        field(35;"Receipt - Post it Now";Boolean)
        {
            Caption = 'Receipt - Post it now';
        }
        field(36;"Rounding Precision";Decimal)
        {
            Caption = 'Rounding precision';
        }
        field(37;"No. of Sales in Audit Roll";Integer)
        {
            CalcFormula = Count("HC Audit Roll" WHERE ("Register No."=FIELD("Register Filter"),
                                                       "Sales Ticket No."=FIELD("Receipt Filter"),
                                                       Type=CONST(Item),
                                                       "Sale Type"=CONST(Sale),
                                                       "Line No."=CONST(10000),
                                                       "Sale Date"=FIELD("Date Filter"),
                                                       "Salesperson Code"=FIELD("Salesperson Filter"),
                                                       "Closing Time"=FIELD("End Time Filter"),
                                                       "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                       "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. Sales in audit roll';
            Description = 'T�ller kun linier m. linienr=10000,vare, salg';
            FieldClass = FlowField;
        }
        field(38;"Normal Sale in Audit Roll";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll"."Amount Including VAT" WHERE ("Sale Date"=FIELD("Date Filter"),
                                                                            "Register No."=FIELD("Register Filter"),
                                                                            "Sale Type"=CONST(Sale),
                                                                            Type=CONST(Item),
                                                                            "Salesperson Code"=FIELD("Salesperson Filter"),
                                                                            "Closing Time"=FIELD("End Time Filter"),
                                                                            "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                                            "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter"),
                                                                            "Sales Ticket No."=FIELD("Receipt Filter")));
            Caption = 'Normal sale in audit roll';
            Description = 'T�ller "bel�b inkl. moms" hvis salg, vare';
            FieldClass = FlowField;
        }
        field(39;"Debit Sale in Audit Roll";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll"."Amount Including VAT" WHERE ("Sale Date"=FIELD("Date Filter"),
                                                                            "Register No."=FIELD("Register Filter"),
                                                                            "Sale Type"=CONST("Debit Sale"),
                                                                            Type=CONST(Item),
                                                                            "Gift voucher ref."=FILTER(=''),
                                                                            "Salesperson Code"=FIELD("Salesperson Filter"),
                                                                            "Closing Time"=FIELD("End Time Filter"),
                                                                            "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                                            "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter"),
                                                                            "Sales Ticket No."=FIELD("Receipt Filter")));
            Caption = 'Debit sale in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(40;"No. of Items in Audit Roll";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll".Quantity WHERE ("Register No."=FIELD("Register Filter"),
                                                              "Sales Ticket No."=FIELD("Receipt Filter"),
                                                              "Sale Date"=FIELD("Date Filter"),
                                                              Type=CONST(Item),
                                                              "Salesperson Code"=FIELD("Salesperson Filter"),
                                                              "Closing Time"=FIELD("End Time Filter"),
                                                              "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                              "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. items in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(41;"Cost Amount in Audit Roll";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll".Cost WHERE ("Register No."=FIELD("Register Filter"),
                                                          "Sales Ticket No."=FIELD("Receipt Filter"),
                                                          "Sale Date"=FIELD("Date Filter"),
                                                          Type=CONST(Item),
                                                          "Sale Type"=FILTER(<>"Debit Sale"),
                                                          "Salesperson Code"=FIELD("Salesperson Filter"),
                                                          "Closing Time"=FIELD("End Time Filter"),
                                                          "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                          "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Cost amount in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(42;"No. of Sale Lines in Aud. Roll";Integer)
        {
            CalcFormula = Count("HC Audit Roll" WHERE ("Register No."=FIELD("Register Filter"),
                                                       "Sales Ticket No."=FIELD("Receipt Filter"),
                                                       "Sale Date"=FIELD("Date Filter"),
                                                       Type=FILTER(<>Cancelled&<>"Open/Close"),
                                                       "Salesperson Code"=FIELD("Salesperson Filter"),
                                                       "Closing Time"=FIELD("End Time Filter"),
                                                       "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                       "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. sales lines in audit roll';
            Description = 'T�ller alle linier m. type <>Afbrudt &<>�ben/Luk';
            FieldClass = FlowField;
        }
        field(43;"Salesperson Filter";Code[10])
        {
            Caption = 'Salesperson filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(44;"No. of Items in Audit Debit";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll".Quantity WHERE ("Register No."=FIELD("Register Filter"),
                                                              "Sales Ticket No."=FIELD("Receipt Filter"),
                                                              "Sale Date"=FIELD("Date Filter"),
                                                              Type=CONST("Debit Sale"),
                                                              "Salesperson Code"=FIELD("Salesperson Filter"),
                                                              "Gift voucher ref."=FILTER(=''),
                                                              "Closing Time"=FIELD("End Time Filter"),
                                                              "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                              "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. items in audit debit';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(45;"No. of Item Lines in Aud. Deb.";Integer)
        {
            CalcFormula = Count("HC Audit Roll" WHERE ("Register No."=FIELD("Register Filter"),
                                                       "Sales Ticket No."=FIELD("Receipt Filter"),
                                                       Type=CONST("Debit Sale"),
                                                       "No."=FILTER(<>''),
                                                       "Gift voucher ref."=FILTER(=''),
                                                       "Sale Date"=FIELD("Date Filter"),
                                                       "Salesperson Code"=FIELD("Salesperson Filter"),
                                                       "Closing Time"=FIELD("End Time Filter"),
                                                       "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                       "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. item linies in audit debit';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(46;"No. of Deb. Sales in Aud. Roll";Integer)
        {
            CalcFormula = Count("HC Audit Roll" WHERE ("Register No."=FIELD("Register Filter"),
                                                       "Sales Ticket No."=FIELD("Receipt Filter"),
                                                       "Sale Type"=CONST("Debit Sale"),
                                                       "Line No."=CONST(10000),
                                                       "Gift voucher ref."=FILTER(=''),
                                                       "Sale Date"=FIELD("Date Filter"),
                                                       "Salesperson Code"=FIELD("Salesperson Filter"),
                                                       "Closing Time"=FIELD("End Time Filter"),
                                                       "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                       "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'No. debit sales in audit roll';
            Description = 'T�ller linie debetsalg,linienr=10000';
            FieldClass = FlowField;
        }
        field(47;Euro;Boolean)
        {
            Caption = 'Euro';
        }
        field(48;"Bank Acc. No.";Code[20])
        {
            Caption = 'Bank';
            TableRelation = "Bank Account"."No.";
        }
        field(49;"Fee G/L Acc. No.";Code[20])
        {
            Caption = 'Fee';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if "Fee G/L Acc. No." = '' then begin
                  "Fee Pct." := 0;
                  "Fixed Fee" := 0;
                  "Maximum Amount"  := 0;
                  "Minimum Amount"  := 0;
                  "Fee Item No." := '';
                end;
            end;
        }
        field(50;"Fee Pct.";Decimal)
        {
            Caption = 'Fee Pct';
        }
        field(51;"Fixed Fee";Decimal)
        {
            Caption = 'Fixed fee';
        }
        field(52;"Fee Item No.";Code[20])
        {
            Caption = 'Fee item';
            TableRelation = Item;
        }
        field(53;"Norm. Sales in Audit Excl. VAT";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll".Amount WHERE ("Sale Date"=FIELD("Date Filter"),
                                                            "Register No."=FIELD("Register Filter"),
                                                            "Sale Type"=CONST(Sale),
                                                            Type=CONST(Item),
                                                            "Salesperson Code"=FIELD("Salesperson Filter"),
                                                            "Closing Time"=FIELD("End Time Filter"),
                                                            "Sales Ticket No."=FIELD("Receipt Filter"),
                                                            "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                            "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter")));
            Caption = 'Norm sales in audit ex VAT';
            FieldClass = FlowField;
        }
        field(54;"Maximum Amount";Decimal)
        {
            Caption = 'Max amount';
            Description = 'Maksimalt bel�b, hvor prisen skal g�lde';
        }
        field(55;"Minimum Amount";Decimal)
        {
            Caption = 'Min amount';
            Description = 'Minimumsbel�b, hvor gebyret skal g�lde';
        }
        field(56;"Debit Cost Amount Audit Roll";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll".Cost WHERE ("Sale Date"=FIELD("Date Filter"),
                                                          "Register No."=FIELD("Register Filter"),
                                                          "Sale Type"=CONST("Debit Sale"),
                                                          Type=CONST(Item),
                                                          "Gift voucher ref."=FILTER(=''),
                                                          "Salesperson Code"=FIELD("Salesperson Filter"),
                                                          "Closing Time"=FIELD("End Time Filter"),
                                                          "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                          "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter"),
                                                          "Sales Ticket No."=FIELD("Receipt Filter")));
            Caption = 'Cost amount in audit';
            Description = 'Calcformula tilf�jet';
            FieldClass = FlowField;
        }
        field(57;"Debit Sales in Audit Excl. VAT";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll".Amount WHERE ("Sale Date"=FIELD("Date Filter"),
                                                            "Register No."=FIELD("Register Filter"),
                                                            "Sale Type"=CONST("Debit Sale"),
                                                            Type=CONST(Item),
                                                            "Gift voucher ref."=FILTER(=''),
                                                            "Salesperson Code"=FIELD("Salesperson Filter"),
                                                            "Closing Time"=FIELD("End Time Filter"),
                                                            "Shortcut Dimension 1 Code"=FIELD("Global Dimension Code 1 Filter"),
                                                            "Shortcut Dimension 2 Code"=FIELD("Global Dimension Code 2 Filter"),
                                                            "Sales Ticket No."=FIELD("Receipt Filter")));
            Caption = 'Debit sales in audit ex VAT';
            Description = 'Calcformula tilf�jet';
            FieldClass = FlowField;
        }
        field(58;"Cardholder Verification Method";Option)
        {
            Caption = 'Cardholder Verification Method';
            Description = 'Cardholder Verification Method';
            OptionCaption = 'CVM not forced,Forced Signature,Forced Pin';
            OptionMembers = "CVM not Forced","Forced Signature","Forced Pin";
        }
        field(59;"Type of Transaction";Option)
        {
            Caption = 'Type of transaction';
            OptionCaption = 'Not forced,Forced Online,Forced Offline';
            OptionMembers = "Not Forced","Forced Online","Forced Offline";
        }
        field(60;"Global Dimension Code 1 Filter";Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension Code 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(61;"Global Dimension Code 2 Filter";Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension Code 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(62;"Location Code";Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(65;"Is Check";Boolean)
        {
            Caption = 'Check';
        }
        field(66;"Common Company Clearing";Boolean)
        {
            Caption = 'Common Company Clearing';
        }
        field(67;"Day Clearing Account";Code[20])
        {
            Caption = 'Day Clearing Account';
            TableRelation = "G/L Account";
        }
        field(68;"Forced Amount";Boolean)
        {
            Caption = 'Forced amount';
        }
        field(69;Hidden;Boolean)
        {
            Caption = 'Hidden';
        }
        field(70;"To be Balanced";Boolean)
        {
            Caption = 'Incl. in balancing';
        }
        field(71;"Balancing Total";Decimal)
        {
            CalcFormula = Sum("HC Audit Roll"."Line No." WHERE ("Register No."=FIELD("No."),
                                                                "Sales Ticket No."=FIELD("Register Filter")));
            Caption = 'Counted';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75;"Match Sales Amount";Boolean)
        {
            Caption = 'Match Sales Amount';
        }
        field(80;"Fixed Amount";Decimal)
        {
            Caption = 'Fixed Amount';

            trigger OnValidate()
            begin
                TestField("Processing Type","Processing Type"::"Gift Voucher");
            end;
        }
        field(81;"Qty. Per Sale";Integer)
        {
            Caption = 'Qty. Per Sale';

            trigger OnValidate()
            begin
                TestField("Processing Type","Processing Type"::"Gift Voucher");
            end;
        }
        field(82;"Minimum Sales Amount";Decimal)
        {
            Caption = 'Min Sales Amount';

            trigger OnValidate()
            begin
                TestField("Processing Type","Processing Type"::"Gift Voucher");
            end;
        }
        field(83;"Human Validation";Boolean)
        {
            Caption = 'Validated by user';
        }
        field(90;"Immediate Posting";Option)
        {
            Caption = 'Immediate Posting';
            OptionCaption = 'Never,Always,Negative,Positive';
            OptionMembers = Never,Always,Negative,Positive;
        }
        field(200;"PBS Gift Voucher";Boolean)
        {
            Caption = 'PBS Gift Voucher';
            Description = 'PBS Gift Voucher if true card balance will be checked.';
        }
        field(201;"PBS Customer ID";Text[30])
        {
            Caption = 'PBS Customer ID';
            Description = 'PBS Inquiry ID';
        }
        field(202;"PBS Gift Voucher Barcode";Boolean)
        {
            Caption = 'PBS Gift Voucher Barcode';
        }
        field(250;"Loyalty Card Type";Code[20])
        {
            Caption = 'Loyalty Card Type';
        }
        field(318;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Only used by Global Dimension 1';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(319;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Only used by Global Dimension 2';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
        field(320;"Auto End Sale";Boolean)
        {
            Caption = 'Auto end sale';
            InitValue = true;
        }
        field(321;"Payment Method Code";Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(323;"Balancing Type";Option)
        {
            Caption = 'Balancing type';
            OptionCaption = 'Currency,New inventory,Transfer to Bank';
            OptionMembers = Normal,Primo,Bank;
        }
        field(329;"Payment Disc. Calc. Codeunit";Integer)
        {
            Caption = 'Payment Disc. Calc. Codeunit';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(350;"Validation Codeunit";Integer)
        {
            Caption = 'Validation Codeunit';
            Description = 'Invokes this codeunit when a Sale Line POS with type payment is being inserted.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(351;"On Sale End Codeunit";Integer)
        {
            Caption = 'On Sale End Codeunit';
            Description = 'Invokes this codeunit before a sale is finished. Can interrupt the end of a sale.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(352;"Post Processing Codeunit";Integer)
        {
            Caption = 'Post Processing Codeunit';
            Description = 'Invokes this codeunit when a sale is finished eg. transferred to the auditroll.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(500;"Payment Type";Option)
        {
            Caption = 'Payment Type';
            OptionCaption = 'Other,Payment Card,Voucher,Cash,Credit Voucher,Deposit';
            OptionMembers = Other,PaymentCard,Voucher,Cash,CreditVoucher,Deposit;
        }
        field(501;"Payment Card Type";Option)
        {
            Caption = 'Payment Card Type';
            OptionCaption = 'Other,Dankort,VisaDankort,Visa,VisaElectron,Mastercard,Maestro,JCB,DinersClub,AmericanExpress';
            OptionMembers = other,dankort,visadankort,visa,visaelectron,mastercard,maestro,jcb,dinersclub,americanexpress;
        }
        field(600;"HQ Processing";Option)
        {
            Caption = 'HQ Processing';
            Description = 'NPR5.38';
            OptionCaption = 'Normal,Sales Quote,Sales Order/Return Order,Sales Invoice/ Credit Memo';
            OptionMembers = Normal,SalesQuote,SalesOrder,SalesInvoice;
        }
        field(601;"HQ Post Sales Document";Boolean)
        {
            Caption = 'HQ Post Sales Document';
            Description = 'NPR5.38';
        }
        field(602;"HQ Post Payment";Boolean)
        {
            Caption = 'HQ Post Payment';
            Description = 'NPR5.38';
        }
        field(50000;"End Time Filter";Time)
        {
            Caption = 'End time filter';
            FieldClass = FlowFilter;
        }
        field(50001;"Dev Term";Boolean)
        {
            Caption = 'Dev Term';
        }
        field(6184471;"MobilePay Merchant ID";Code[20])
        {
            Caption = 'MobilePay Merchant ID';
            Description = 'MbP1.80';
        }
        field(6184472;"MobilePay API Key";Code[50])
        {
            Caption = 'MobilePay API Key';
            Description = 'MbP1.80';
        }
        field(6184473;"MobilePay Environment";Option)
        {
            Caption = 'MobilePay Environment';
            Description = 'MbP1.80';
            OptionCaption = 'PROD,DEMO';
            OptionMembers = PROD,DEMO;
        }
    }

    keys
    {
        key(Key1;"No.","Register No.")
        {
        }
        key(Key2;"Via Terminal",Prefix)
        {
            Enabled = false;
        }
        key(Key3;"Search Description")
        {
        }
        key(Key4;"Register No.","Processing Type")
        {
        }
        key(Key5;"G/L Account No.")
        {
        }
        key(Key6;"Processing Type")
        {
        }
        key(Key7;"No.","Via Terminal")
        {
        }
        key(Key8;"Receipt - Post it Now")
        {
        }
        key(Key9;Euro)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Trans0001: Label 'You cannot delete paymentmethod %1, since there non-posted postings in the audit roll';
    begin
        exit;//Temp
        AuditRoll.SetCurrentKey("Sale Type",Type,"No.",Posted);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
        AuditRoll.SetRange(Type,AuditRoll.Type::Payment);
        AuditRoll.SetRange(Posted,false);
        AuditRoll.SetRange("No.",xRec."No.");
        if AuditRoll.Find('-') then
          Error(Trans0001,"No.");

        //-NPR5.48 [340446]
        //DimMgt.DeleteDefaultDim(DATABASE::"Payment Type POS","No.");
        DimMgt.DeleteDefaultDim(DATABASE::"HC Payment Type POS","No.");
        //+NPR5.48 [340446]
    end;

    trigger OnInsert()
    begin
        //-NPR5.48 [340446]
        //DimMgt.UpdateDefaultDim(DATABASE::"Payment Type POS","No.",
        DimMgt.UpdateDefaultDim(DATABASE::"HC Payment Type POS","No.",
        //+NPR5.48 [340446]
                                "Global Dimension 1 Code","Global Dimension 2 Code");
    end;

    trigger OnRename()
    var
        ErrorNo1: Label 'All sales tickets in the audit roll concerning this payment type must be posted to rename payment type.';
    begin
        AuditRoll.Reset;
        AuditRoll.SetCurrentKey( "Sale Type",Type,"No.",Posted );
        AuditRoll.SetRange( "Sale Type", AuditRoll."Sale Type"::Payment );
        AuditRoll.SetRange( Type, AuditRoll.Type::Payment );
        AuditRoll.SetRange( Posted, false );
        AuditRoll.SetRange( "No.", xRec."No." );
        if AuditRoll.Find('-') then
          Error( ErrorNo1 );
    end;

    var
        Register: Record "HC Register";
        PaymentTypePOS: Record "HC Payment Type POS";
        RetailSetup: Record "HC Retail Setup";
        GLAccount: Record "G/L Account";
        AuditRoll: Record "HC Audit Roll";
        Customer: Record Customer;
        DimMgt: Codeunit DimensionManagement;

    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
        //-NPR5.48 [340446]
        //DimMgt.SaveDefaultDim(DATABASE::Customer,"No.",FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"HC Payment Type POS","No.",FieldNumber,ShortcutDimCode);
        //+NPR5.48 [340446]
        Modify;
    end;
}

