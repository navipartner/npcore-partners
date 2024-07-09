﻿table 6150905 "NPR HC Payment Type POS"
{
    Caption = 'HC Payment Type POS';
    DataClassification = CustomerContent;
    LookupPageID = "NPR HC Payment Types";
    ObsoleteState = Pending;
    ObsoleteTag = '2023-07-28';
    ObsoleteReason = 'HQ Connector will no longer be supported';

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

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := Description;
            end;
        }
        field(3; "Processing Type"; Option)
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Cash,Terminal Card,Manual Card,Other Credit Cards,Credit Voucher,Gift Voucher,Cash Terminal,Foreign Currency,Foreign Credit Voucher,Foreign Gift Voucher,Debit sale,Invoice,Finance Agreement,Payout,DIBS,Loyalty Card';
            OptionMembers = " ",Cash,"Terminal Card","Manual Card","Other Credit Cards","Credit Voucher","Gift Voucher","Cash Terminal","Foreign Currency","Foreign Credit Voucher","Foreign Gift Voucher","Debit sale",Invoice,"Finance Agreement",Payout,DIBS,"Point Card";

            trigger OnValidate()
            begin
                TestField("Via Terminal", false);
            end;
        }
        field(4; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                GLAccount.Get("G/L Account No.");
                GLAccount.TestField(Blocked, false);
            end;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Active,Passive';
            OptionMembers = " ",Active,Passive;

            trigger OnValidate()
            begin
                if Status = Status::Active then begin
                    if "Account Type" = "Account Type"::"G/L Account" then
                        TestField("G/L Account No.");
                    if "Account Type" = "Account Type"::Customer then
                        TestField("Customer No.");
                end;
            end;
        }
        field(6; Prefix; Code[20])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
        }
        field(7; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR HC Register";
        }
        field(20; "Cost Pct."; Decimal)
        {
            Caption = 'Cost %';
            DataClassification = CustomerContent;
        }
        field(21; "Cost Account No."; Code[20])
        {
            Caption = 'Cost Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                GLAccount.Get("Cost Account No.");
                GLAccount.TestField(Blocked, false);
            end;
        }
        field(22; "Sales Line Text"; Text[50])
        {
            Caption = 'Sale Line Text';
            DataClassification = CustomerContent;
        }
        field(23; "Search Description"; Text[50])
        {
            Caption = 'Search Description';
            DataClassification = CustomerContent;
        }
        field(24; Posting; Option)
        {
            Caption = 'Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'Condensed,Single Entry';
            OptionMembers = Condensed,"Single Entry";
        }
        field(25; "Via Terminal"; Boolean)
        {
            Caption = 'Via Cash Terminal';
            DataClassification = CustomerContent;
        }
        field(26; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(27; "Amount in Audit Roll"; Decimal)
        {
            Caption = 'Amount in Audit Roll';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(28; "Customer No."; Code[20])
        {
            Caption = 'Customer';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                ErrNoCurrencyCode: Label 'Currency code for customer %1 must be blank';
                ErrNoCustomerNo: Label 'Debtorcode cannot be empty';
            begin
                if "Customer No." = '' then
                    Error(ErrNoCustomerNo);
                Customer.Get("Customer No.");
                if Customer."Currency Code" <> '' then
                    Error(ErrNoCurrencyCode, "Customer No.");
            end;
        }
        field(29; "Account Type"; Option)
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            OptionCaption = 'G/L Account,Customer,Bank';
            OptionMembers = "G/L Account",Customer,Bank;

            trigger OnValidate()
            var
                Cust: Record Customer;
                CustomerList: Page "Customer List";
                ErrCustomer: Label 'A deptor must be chosen for this accounttype';
            begin
                RetailSetup.Get();
                if "Account Type" = "Account Type"::Customer then begin
                    Clear(CustomerList);
                    CustomerList.LookupMode(true);
                    if CustomerList.RunModal() <> ACTION::LookupOK then
                        Error(ErrCustomer);

                    CustomerList.GetRecord(Cust);
                    Validate("Customer No.", Cust."No.");
                end;
            end;
        }
        field(30; "Register Filter"; Code[10])
        {
            Caption = 'Cash Register Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR HC Register";
        }
        field(31; "Fixed Rate"; Decimal)
        {
            Caption = 'Fixed Rate';
            DataClassification = CustomerContent;
        }
        field(32; "Reference Incoming"; Boolean)
        {
            Caption = 'Reference Incoming';
            DataClassification = CustomerContent;
        }
        field(33; "Receipt Filter"; Code[10])
        {
            Caption = 'Receipt filter';
            FieldClass = FlowFilter;
        }
        field(34; "Receipt Copies"; Integer)
        {
            Caption = 'Receipt copies';
            DataClassification = CustomerContent;
        }
        field(35; "Receipt - Post it Now"; Boolean)
        {
            Caption = 'Receipt - Post it now';
            DataClassification = CustomerContent;
        }
        field(36; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding precision';
            DataClassification = CustomerContent;
        }
        field(37; "No. of Sales in Audit Roll"; Integer)
        {
            Caption = 'No. Sales in audit roll';
            Description = 'Tæller kun linier m. linienr=10000,vare, salg';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(38; "Normal Sale in Audit Roll"; Decimal)
        {
            Caption = 'Normal sale in audit roll';
            Description = 'Tæller "bel¢b inkl. moms" hvis salg, vare';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(39; "Debit Sale in Audit Roll"; Decimal)
        {
            Caption = 'Debit sale in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(40; "No. of Items in Audit Roll"; Decimal)
        {
            Caption = 'No. items in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(41; "Cost Amount in Audit Roll"; Decimal)
        {
            Caption = 'Cost amount in audit roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(42; "No. of Sale Lines in Aud. Roll"; Integer)
        {
            Caption = 'No. sales lines in audit roll';
            Description = 'Tæller alle linier m. type <>Afbrudt &<>Åben/Luk';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(43; "Salesperson Filter"; Code[20])
        {
            Caption = 'Salesperson filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(44; "No. of Items in Audit Debit"; Decimal)
        {
            Caption = 'No. items in audit debit';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(45; "No. of Item Lines in Aud. Deb."; Integer)
        {
            Caption = 'No. item linies in audit debit';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(46; "No. of Deb. Sales in Aud. Roll"; Integer)
        {
            Caption = 'No. debit sales in audit roll';
            Description = 'Tæller linie debetsalg,linienr=10000';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(47; Euro; Boolean)
        {
            Caption = 'Euro';
            DataClassification = CustomerContent;
        }
        field(48; "Bank Acc. No."; Code[20])
        {
            Caption = 'Bank';
            DataClassification = CustomerContent;
            TableRelation = "Bank Account"."No.";
        }
        field(49; "Fee G/L Acc. No."; Code[20])
        {
            Caption = 'Fee';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if "Fee G/L Acc. No." = '' then begin
                    "Fee Pct." := 0;
                    "Fixed Fee" := 0;
                    "Maximum Amount" := 0;
                    "Minimum Amount" := 0;
                    "Fee Item No." := '';
                end;
            end;
        }
        field(50; "Fee Pct."; Decimal)
        {
            Caption = 'Fee Pct';
            DataClassification = CustomerContent;
        }
        field(51; "Fixed Fee"; Decimal)
        {
            Caption = 'Fixed fee';
            DataClassification = CustomerContent;
        }
        field(52; "Fee Item No."; Code[20])
        {
            Caption = 'Fee item';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(53; "Norm. Sales in Audit Excl. VAT"; Decimal)
        {
            Caption = 'Norm sales in audit ex VAT';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(54; "Maximum Amount"; Decimal)
        {
            Caption = 'Max amount';
            DataClassification = CustomerContent;
            Description = 'Maksimalt bel¢b, hvor prisen skal gælde';
        }
        field(55; "Minimum Amount"; Decimal)
        {
            Caption = 'Min amount';
            DataClassification = CustomerContent;
            Description = 'Minimumsbel¢b, hvor gebyret skal gælde';
        }
        field(56; "Debit Cost Amount Audit Roll"; Decimal)
        {
            Caption = 'Cost amount in audit';
            Description = 'Calcformula tilf¢jet';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(57; "Debit Sales in Audit Excl. VAT"; Decimal)
        {
            Caption = 'Debit sales in audit ex VAT';
            Description = 'Calcformula tilf¢jet';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(58; "Cardholder Verification Method"; Option)
        {
            Caption = 'Cardholder Verification Method';
            DataClassification = CustomerContent;
            Description = 'Cardholder Verification Method';
            OptionCaption = 'CVM not forced,Forced Signature,Forced Pin';
            OptionMembers = "CVM not Forced","Forced Signature","Forced Pin";
        }
        field(59; "Type of Transaction"; Option)
        {
            Caption = 'Type of transaction';
            DataClassification = CustomerContent;
            OptionCaption = 'Not forced,Forced Online,Forced Offline';
            OptionMembers = "Not Forced","Forced Online","Forced Offline";
        }
        field(60; "Global Dimension Code 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension Code 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(61; "Global Dimension Code 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension Code 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(62; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(65; "Is Check"; Boolean)
        {
            Caption = 'Check';
            DataClassification = CustomerContent;
        }
        field(66; "Common Company Clearing"; Boolean)
        {
            Caption = 'Common Company Clearing';
            DataClassification = CustomerContent;
        }
        field(67; "Day Clearing Account"; Code[20])
        {
            Caption = 'Day Clearing Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(68; "Forced Amount"; Boolean)
        {
            Caption = 'Forced amount';
            DataClassification = CustomerContent;
        }
        field(69; Hidden; Boolean)
        {
            Caption = 'Hidden';
            DataClassification = CustomerContent;
        }
        field(70; "To be Balanced"; Boolean)
        {
            Caption = 'Incl. in balancing';
            DataClassification = CustomerContent;
        }
        field(71; "Balancing Total"; Decimal)
        {
            Caption = 'Counted';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(75; "Match Sales Amount"; Boolean)
        {
            Caption = 'Match Sales Amount';
            DataClassification = CustomerContent;
        }
        field(80; "Fixed Amount"; Decimal)
        {
            Caption = 'Fixed Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';
        }
        field(81; "Qty. Per Sale"; Integer)
        {
            Caption = 'Qty. Per Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';

            trigger OnValidate()
            begin
                TestField("Processing Type", "Processing Type"::"Gift Voucher");
            end;
        }
        field(82; "Minimum Sales Amount"; Decimal)
        {
            Caption = 'Min Sales Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';
        }
        field(83; "Human Validation"; Boolean)
        {
            Caption = 'Validated by user';
            DataClassification = CustomerContent;
        }
        field(90; "Immediate Posting"; Option)
        {
            Caption = 'Immediate Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'Never,Always,Negative,Positive';
            OptionMembers = Never,Always,Negative,Positive;
        }
        field(200; "PBS Gift Voucher"; Boolean)
        {
            Caption = 'PBS Gift Voucher';
            DataClassification = CustomerContent;
            Description = 'PBS Gift Voucher if true card balance will be checked.';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';
        }
        field(201; "PBS Customer ID"; Text[30])
        {
            Caption = 'PBS Customer ID';
            DataClassification = CustomerContent;
            Description = 'PBS Inquiry ID';
        }
        field(202; "PBS Gift Voucher Barcode"; Boolean)
        {
            Caption = 'PBS Gift Voucher Barcode';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';
        }
        field(250; "Loyalty Card Type"; Code[20])
        {
            Caption = 'Loyalty Card Type';
            DataClassification = CustomerContent;
        }
        field(318; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Only used by Global Dimension 1';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(319; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Only used by Global Dimension 2';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(320; "Auto End Sale"; Boolean)
        {
            Caption = 'Auto end sale';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(321; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(323; "Balancing Type"; Option)
        {
            Caption = 'Balancing type';
            DataClassification = CustomerContent;
            OptionCaption = 'Currency,New inventory,Transfer to Bank';
            OptionMembers = Normal,Primo,Bank;
        }
        field(329; "Payment Disc. Calc. Codeunit"; Integer)
        {
            Caption = 'Payment Disc. Calc. Codeunit';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(350; "Validation Codeunit"; Integer)
        {
            Caption = 'Validation Codeunit';
            DataClassification = CustomerContent;
            Description = 'Invokes this codeunit when a Sale Line POS with type payment is being inserted.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(351; "On Sale End Codeunit"; Integer)
        {
            Caption = 'On Sale End Codeunit';
            DataClassification = CustomerContent;
            Description = 'Invokes this codeunit before a sale is finished. Can interrupt the end of a sale.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(352; "Post Processing Codeunit"; Integer)
        {
            Caption = 'Post Processing Codeunit';
            DataClassification = CustomerContent;
            Description = 'Invokes this codeunit when a sale is finished eg. transferred to the auditroll.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(500; "Payment Type"; Option)
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Other,Payment Card,Voucher,Cash,Credit Voucher,Deposit';
            OptionMembers = Other,PaymentCard,Voucher,Cash,CreditVoucher,Deposit;
        }
        field(501; "Payment Card Type"; Option)
        {
            Caption = 'Payment Card Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Other,Dankort,VisaDankort,Visa,VisaElectron,Mastercard,Maestro,JCB,DinersClub,AmericanExpress';
            OptionMembers = other,dankort,visadankort,visa,visaelectron,mastercard,maestro,jcb,dinersclub,americanexpress;
        }
        field(600; "HQ Processing"; Option)
        {
            Caption = 'HQ Processing';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            OptionCaption = 'Normal,Sales Quote,Sales Order/Return Order,Sales Invoice/ Credit Memo';
            OptionMembers = Normal,SalesQuote,SalesOrder,SalesInvoice;
        }
        field(601; "HQ Post Sales Document"; Boolean)
        {
            Caption = 'HQ Post Sales Document';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(602; "HQ Post Payment"; Boolean)
        {
            Caption = 'HQ Post Payment';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(700; "End Time Filter"; Time)
        {
            Caption = 'End time filter';
            FieldClass = FlowFilter;
        }
        field(701; "Dev Term"; Boolean)
        {
            Caption = 'Dev Term';
            DataClassification = CustomerContent;
        }
        field(6184471; "MobilePay Merchant ID"; Code[20])
        {
            Caption = 'MobilePay Merchant ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
        }
        field(6184472; "MobilePay API Key"; Code[50])
        {
            Caption = 'MobilePay API Key';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
        }
        field(6184473; "MobilePay Environment"; Option)
        {
            Caption = 'MobilePay Environment';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            OptionCaption = 'PROD,DEMO';
            OptionMembers = PROD,DEMO;
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
        key(Key4; "Register No.", "Processing Type")
        {
        }
        key(Key5; "G/L Account No.")
        {
        }
        key(Key6; "Processing Type")
        {
        }
        key(Key7; "No.", "Via Terminal")
        {
        }
        key(Key8; "Receipt - Post it Now")
        {
        }
        key(Key9; Euro)
        {
        }
    }

    trigger OnDelete()
    var
    begin
        exit;
    end;

    trigger OnInsert()
    begin
        DimMgt.UpdateDefaultDim(DATABASE::"NPR HC Payment Type POS", "No.",
                                "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    var
        RetailSetup: Record "NPR HC Retail Setup";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        DimMgt: Codeunit DimensionManagement;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR HC Payment Type POS", "No.", FieldNumber, ShortcutDimCode);
        Modify();
    end;
}

