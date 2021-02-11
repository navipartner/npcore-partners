table 6014425 "NPR Retail Document Header"
{
    // NPR4.04/BHR /20150422  CASE 211688 UPDATE E-MAIL FROM CUSTOMER/CONTACT
    // NPR4.04/JDH /20150427  CASE 212229 Removed references to old Variant solution "Color Size"
    // 
    // NPR4.12/TSA /20150703  CASE 216800 - Created W1 Version, removed unused DK Fields
    //                                    - 1017 EAN No. Code 20,
    //                                    - 1018 Account Code Text 30
    // NPR5.27/TJ  /20160826  CASE 248281 Removing unused variables and fields, renaming fields and variables to use standard naming procedures
    // NPR5.27/MHA /20161025  CASE 255580 Unused functions deleted: AnyPayment(),AnyPaymentDebit(),AssistEdit(),CalcRepurchase(),DebitSaleStamp(),ConfirmDelete(),PostDocument()
    // NPR5.30/TJ  /20170215  CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.33/TS  /20161110  CASE 257587 Delete Lines and do not allow deletion if Cashed
    // NPR5.33/JDH /20170629  CASE 280329 Changed Contact to Local var. Chanegd Option Caption to match Option Values on field 36. Mobile Phone changed to text30
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.40/LS  /20180307  CASE 307431 Created field 1025 "POS Entry No."
    // NPR5.40/TJ  /20180319  CASE 307717 Replaced hardcoded dates with DMY2DATE structure
    // NPR5.40/TS  /20180330  CASE 309122 Corrected English Captions
    // NPR5.47/MHA /20181012  CASE 331971 Removed Test on Cashed in OnDelete()

    Caption = 'Retail Document Header';
    LookupPageID = "NPR Retail Document List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Quote';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = IF ("Customer Type" = CONST(Kontant)) Contact
            ELSE
            IF ("Customer Type" = CONST(Alm)) Customer;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Customer: Record Customer;
                Contact: Record Contact;
            begin
                RetailSetup.Get;

                if RetailFormCode.CreateCustomerOld("Customer No.", "Customer Type", "Salesperson Code") then begin
                    if "Customer Type" = "Customer Type"::Alm then begin
                        Customer.Get("Customer No.");
                        Name := Customer.Name;
                        Address := Customer.Address;
                        "Address 2" := Customer."Address 2";
                        City := Customer.City;
                        Phone := Customer."Phone No.";
                        "Post Code" := Customer."Post Code";
                        "Ship-to Name" := Customer.Name;
                        "Ship-to Address" := Customer.Address;
                        "Ship-to Address 2" := Customer."Address 2";
                        "Ship-to Post Code" := Customer."Post Code";
                        "Ship-to City" := Customer.City;
                        "Ship-to Country Code" := Customer."Country/Region Code";
                        Validate("Prices Including VAT", Customer."Prices Including VAT");
                        Validate("Payment Terms Code", Customer."Payment Terms Code");
                        Validate("Payment Method Code", Customer."Payment Method Code");
                        "Bill-to Customer No." := "Customer No.";
                        "E-mail" := Customer."E-Mail";
                    end else begin
                        Contact.Get("Customer No.");
                        Name := Contact.Name;
                        Address := Contact.Address;
                        "Address 2" := Contact."Address 2";
                        City := Contact.City;
                        Phone := Contact."Phone No.";
                        "Post Code" := Contact."Post Code";
                        Mobile := Contact."Mobile Phone No.";
                        Validate("Prices Including VAT", true);
                        "Payment Terms Code" := '';
                        "Payment Method Code" := '';
                        "Ship-to Name" := Contact.Name;
                        "Ship-to Address" := Contact.Address;
                        "Ship-to Address 2" := Contact."Address 2";
                        "Ship-to Post Code" := Contact."Post Code";
                        "Ship-to City" := Contact.City;
                        "Ship-to Country Code" := Contact."Country/Region Code";
                        "Bill-to Customer No." := "Customer No.";
                        "E-mail" := Contact."E-Mail";
                    end;
                end else begin
                    "Customer No." := '';
                    "Bill-to Customer No." := '';
                    Name := '';
                    Address := '';
                    "Address 2" := '';
                    City := '';
                    Phone := '';
                    "Post Code" := '';
                    Mobile := '';
                    "Ship-to Name" := '';
                    "Ship-to Address" := '';
                    "Ship-to Address 2" := '';
                    "Ship-to Post Code" := '';
                    "Ship-to City" := '';
                    "Ship-to Country Code" := '';
                    "E-mail" := '';
                end;
            end;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    RetailSetup.Get;
                    NoSeriesMgt.TestManual(GetNoSeriesCode);
                    "No. Series" := '';
                end;
            end;
        }
        field(4; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Ship-to Name" := Name;
            end;
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

            trigger OnValidate()
            begin
                "Ship-to Address" := Address;
            end;
        }
        field(7; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Ship-to Address 2" := "Address 2";
            end;
        }
        field(8; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Ship-to City" := City;
            end;
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
        field(11; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SalespersonPurchaser.SetRange("NPR Register Password", "Salesperson Code");
                SalespersonPurchaser.FindFirst;
                "Rent Salesperson" := SalespersonPurchaser.Code;
            end;
        }
        field(12; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PostCode.Reset;
                PostCode.SetRange(Code, "Post Code");
                if PostCode.FindFirst then
                    City := PostCode.City;

                "Ship-to Post Code" := "Post Code";
                "Ship-to City" := City;
            end;
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
        field(15; "Rent Salesperson"; Code[10])
        {
            Caption = 'Rent Salesperson';
            TableRelation = "Salesperson/Purchaser".Code;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SalespersonPurchaser.Get("Rent Salesperson");
                "Salesperson Code" := SalespersonPurchaser."NPR Register Password";
            end;
        }
        field(16; "Rent Register"; Code[10])
        {
            Caption = 'Rent Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(17; "Rent Sales Ticket"; Code[20])
        {
            Caption = 'Rent Sales Ticket';
            TableRelation = "NPR Audit Roll"."Sales Ticket No.";
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
        field(20; "Return Salesperson"; Code[10])
        {
            Caption = 'Return Salesperson';
            TableRelation = "Salesperson/Purchaser".Code;
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
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Modify;
            end;
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
            InitValue = "1 Month";
            OptionCaption = '1 Month,2 Month,Quater,Semi Annual,Annual,None';
            OptionMembers = "1 Month","2 Month",Quater,"Semi Annual",Annual,"None";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcExpireDate();

                "Calculation Method" := "Calculation Method"::Ydelse;
                CalcAmount();
            end;
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
        field(43; "Rent Incl. VAT"; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines"."Total Rental Amount incl. VAT" WHERE("Document Type" = FIELD("Document Type"),
                                                                                             "Document No." = FIELD("No.")));
            Caption = 'Rent incl. VAT';
            Editable = false;
            FieldClass = FlowField;
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

            trigger OnValidate()
            begin
                CalcAmount();
            end;
        }
        field(54; Payout; Decimal)
        {
            Caption = 'Payout';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //IF Status <> Status::Ny  THEN
                //  TESTFIELD(Udbetaling,xRec.Udbetaling);
                PhotoSetup.Get();
                CalcFields("Total Price");
                PaymentAmt := Round("Total Price" * PhotoSetup."Payout pct" / 100);
                if Payout < PaymentAmt then
                    Error(Text030, Format(PaymentAmt));
                Validate("Purchase on Credit Amount");
                CalcAmount();
            end;
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

            trigger OnValidate()
            begin
                CalcAmount();
            end;
        }
        field(57; "Duration in Periods"; Decimal)
        {
            Caption = 'Duration in Periods';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Calculation Method" := "Calculation Method"::Rater;
                CalcAmount();
            end;
        }
        field(58; Payment; Decimal)
        {
            Caption = 'Payment ';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Calculation Method" := "Calculation Method"::Ydelse;
                CalcAmount();
            end;
        }
        field(59; "Last Payment"; Decimal)
        {
            Caption = 'Last Payment';
            DataClassification = CustomerContent;
        }
        field(60; "Total Price"; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines"."Amount Including VAT" WHERE("Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("No.")));
            Caption = 'Total Price';
            Editable = false;
            FieldClass = FlowField;
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

            trigger OnValidate()
            begin
                "Purchase on Credit Amount" := "Total Price" + Costs - Payout;
            end;
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

            trigger OnValidate()
            begin
                CalcAmount();
            end;
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

            trigger OnValidate()
            begin
                case "Invoicing Period" of
                    "Invoicing Period"::"1 Month":
                        Factor := 1;
                    "Invoicing Period"::"2 Month":
                        Factor := 2;
                    "Invoicing Period"::Quater:
                        Factor := 3;
                    "Invoicing Period"::"Semi Annual":
                        Factor := 6;
                    "Invoicing Period"::Annual:
                        Factor := 12;
                    "Invoicing Period"::None:
                        Factor := 0;
                end;
            end;
        }
        field(70; "Delivery Date"; Date)
        {
            Caption = 'Delivery Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Ship-to Resource Date" := "Delivery Date";
            end;
        }
        field(71; "Contract Status"; Option)
        {
            Caption = 'Contract Status';
            OptionCaption = 'Ongoing,Finished,Transmitted to invoice,Financing,Selling company';
            OptionMembers = Ongoing,Finished,"Transmitted to invoice",Financing,"Selling company";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Contract Status" = xRec."Contract Status" then
                    exit;

                Validate(Status);
            end;
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
        field(100; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(101; Comment; Boolean)
        {
            CalcFormula = Exist("NPR Retail Comment" WHERE("Table ID" = CONST(6014425),
                                                        "No." = FIELD("No."),
                                                        Option = FIELD("Document Type")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
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

            trigger OnValidate()
            var
                SMSMsg: Text[250];
                ICommHere: Record "NPR I-Comm";
                TxtSms: Label 'Do you want to send the following SMS to the customer:\%1';
                SMS: Codeunit "NPR SMS";
                LocationHere: Record Location;
                POSUnit: Record "NPR POS Unit";
                POSStore: Record "NPR POS Store";
                LocationName: Text[30];
                RetailFormCode2: Codeunit "NPR Retail Form Code";
            begin
                if Status = xRec.Status then
                    exit;

                RetailSetup.Get;
                ICommHere.Get;
                SMSMsg := '';

                LocationName := '';
                if POSUnit.Get(RetailFormCode2.FetchRegisterNumber()) then begin
                    POSStore.Get(POSUnit."POS Store Code");
                    if LocationHere.Get(POSStore."Location Code") then
                        LocationName := LocationHere.Name;
                end;
                if Status = Status::Hjemkommet then begin
                    if ("Document Type" = "Document Type"::"Selection Contract") and RetailSetup."Rental Msg." and (Mobile <> '') then
                        SMSMsg := StrSubstNo(ICommHere."Rental Message", "No.", Format(Status), LocationName);

                    if ("Document Type" = "Document Type"::"Retail Order") and RetailSetup."Rental Msg." and (Mobile <> '') then
                        SMSMsg := StrSubstNo(ICommHere."Tailor Message", "No.", Format(Status), LocationName);
                end;

                if SMSMsg <> '' then
                    if Confirm(StrSubstNo(TxtSms, SMSMsg)) then
                        SMS.SendSMS(Mobile, SMSMsg);
            end;
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

            trigger OnValidate()
            var
                TxtAutoCreate: Label 'Do you want to create %1 as a Customer';
                Contact: Record Contact;
                Customer: Record Customer;
                TableCode: Codeunit "NPR Retail Table Code";
            begin
                if (xRec."Customer Type" = "Customer Type"::Kontant) and ("Customer Type" = "Customer Type"::Alm) then
                    if "Customer No." <> '' then begin
                        if Customer.Get("Customer No.") then begin
                            Validate("Customer No.");

                        end else begin
                            if Confirm(TxtAutoCreate, true, "Customer No.") then begin
                                Contact.Get("Customer No.");
                                TableCode.CreateCustFromContact(Contact);
                            end else begin
                                Validate("Customer No.", '');
                            end;
                        end;
                    end else
                        Validate("Customer No.", '');

                if (xRec."Customer Type" = "Customer Type"::Alm) and ("Customer Type" = "Customer Type"::Kontant) then begin
                    if Contact.Get("Customer No.") then
                        Validate("Customer No.")
                    else
                        Validate("Customer No.", '');
                end;
            end;
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
        field(115; Quantity; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines".Quantity WHERE("Document Type" = CONST("Retail Order"),
                                                                      "Document No." = FIELD("No.")));
            Caption = 'Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(116; "Quantity in Purchase Order"; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines"."Quantity in order" WHERE("Document Type" = CONST("Retail Order"),
                                                                                 "Document No." = FIELD("No.")));
            Caption = 'Quantity in Purchase Order';
            Editable = false;
            FieldClass = FlowField;
        }
        field(117; "Quantity Received"; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines"."Quantity received" WHERE("Document Type" = CONST("Retail Order"),
                                                                                 "Document No." = FIELD("No.")));
            Caption = 'Quantity Received';
            Editable = false;
            FieldClass = FlowField;
        }
        field(118; "Quantity Handed Over"; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines"."Quantity Shipped" WHERE("Document Type" = CONST("Retail Order"),
                                                                                "Document No." = FIELD("No.")));
            Caption = 'Quantity Handed Over';
            Editable = false;
            FieldClass = FlowField;
        }
        field(119; Amount; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines".Amount WHERE("Document Type" = FIELD("Document Type"),
                                                                    "Document No." = FIELD("No.")));
            Caption = 'Total amount';
            FieldClass = FlowField;
        }
        field(120; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Quote';
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Quote));
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
            TableRelation = IF ("Invoice Document Type" = CONST(Quote)) "Sales Header"."No." WHERE("Document Type" = CONST(Quote),
                                                                                                  "No." = FIELD("Invoice No."))
            ELSE
            IF ("Invoice Document Type" = CONST(Order)) "Sales Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                                                                                                             "No." = FIELD("Invoice No."))
            ELSE
            IF ("Invoice Document Type" = CONST(Invoice)) "Sales Header"."No." WHERE("Document Type" = CONST(Invoice),
                                                                                                                                                                                                                                                          "No." = FIELD("Invoice No."))
            ELSE
            IF ("Invoice Document Type" = CONST("Credit Memo")) "Sales Header"."No." WHERE("Document Type" = CONST("Credit Memo"),
                                                                                                                                                                                                                                                                                                                                             "No." = FIELD("Invoice No."));
            DataClassification = CustomerContent;
        }
        field(123; "Shipping Type"; Option)
        {
            Caption = 'Shipping Method';
            OptionCaption = 'normal,express delivery,by external carrier';
            OptionMembers = Normal,Express,"External carrier";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcDelivery;
            end;
        }
        field(124; Delivery; Option)
        {
            Caption = 'Delivery';
            OptionCaption = 'Collected,Shipped';
            OptionMembers = Collected,Shipped;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcDelivery;
            end;
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

            trigger OnValidate()
            begin
                CalcExpireDate();
                CalcFirstInvoice();
            end;
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
            TableRelation = Resource."No.";
            DataClassification = CustomerContent;
        }
        field(136; "Resource Ship-by Person"; Code[20])
        {
            Caption = 'Resource Ship-by Person';
            TableRelation = Resource."No." WHERE(Type = CONST(Person));
            DataClassification = CustomerContent;
        }
        field(137; "Resource Ship-by Person 2"; Code[20])
        {
            Caption = 'Resource Ship-by Person 2';
            TableRelation = Resource."No." WHERE(Type = CONST(Person));
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
        field(140; "VAT Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines"."VAT Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                          "Document No." = FIELD("No.")));
            Caption = 'Total VAT Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(141; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Payment Terms Code" <> '') and ("Document Date" <> 0D) then begin
                    PaymentTerms.Get("Payment Terms Code");
                    "Due Date" := CalcDate(PaymentTerms."Due Date Calculation", "Document Date");
                    //"Pmt. Discount Date" := CALCDATE(PaymentTerms."Discount Date Calculation","Document Date");
                    //VALIDATE("Payment Discount %",PaymentTerms."Discount %")
                end else begin
                    Validate("Due Date", "Document Date");
                    //VALIDATE("Pmt. Discount Date",0D);
                    //VALIDATE("Payment Discount %",0);
                end;
            end;
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
            InitValue = 1;
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
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Modify;
            end;
        }
        field(150; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(151; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(152; "Delivery by Vendor"; Code[20])
        {
            Caption = 'Delivery by Vendor';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(154; "Retail Document Type Parent"; Option)
        {
            Caption = 'Document Type Link';
            NotBlank = true;
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
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
        field(157; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("NPR Retail Document Lines"."VAT Base Amount" WHERE("Document Type" = FIELD("Document Type"),
                                                                               "Document No." = FIELD("No.")));
            Caption = 'VAT Base Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(158; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
            DataClassification = CustomerContent;
        }
        field(165; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Primary Key Length" := StrLen("No.");
            end;
        }
        field(1000; Outstanding; Boolean)
        {
            Caption = 'Outstanding';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Linie: Record "NPR Retail Document Lines";
            begin
                Linie.SetCurrentKey("Document Type", "Document No.", "Outstanding quantity");
                Linie.SetRange("Document Type", "Document Type");
                Linie.SetRange("Document No.", "No.");
                Linie.SetFilter("Outstanding quantity", '<>%1', 0);
                Outstanding := Linie.FindFirst;
            end;
        }
        field(1001; "Show List"; Boolean)
        {
            Caption = 'Show List';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Linie: Record "NPR Retail Document Lines";
            begin
                Linie.SetCurrentKey("Document Type", "Document No.", "Quantity in order", "Quantity received", HjemOverUd);
                Linie.SetRange("Document Type", "Document Type");
                Linie.SetRange("Document No.", "No.");
                Linie.SetFilter("Quantity in order", '<>%1', 0);
                Linie.SetFilter("Quantity received", '<>%1', 0);
                Linie.SetRange(HjemOverUd, true);
                "Show List" := Linie.FindFirst;
            end;
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
            TableRelation = "Post Code".Code;
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

            trigger OnValidate()
            var
                RecalculatePrice: Boolean;
            begin
                if Rec."Prices Including VAT" <> xRec."Prices Including VAT" then begin
                    RetailDocumentLine.SetFilter("Document Type", '=%1', "Document Type");
                    RetailDocumentLine.SetFilter("Document No.", "No.");
                    if RetailDocumentLine.FindFirst then begin
                        RecalculatePrice :=
                          Confirm(
                            StrSubstNo(
                              Text024 +
                              Text026,
                              FieldCaption("Prices Including VAT"), RetailDocumentLine.FieldCaption("Unit price")),
                            true);
                        if RecalculatePrice then
                            repeat
                                if (RetailDocumentLine.Quantity <> 0) then begin
                                    if (RetailDocumentLine."Price including VAT" = Rec."Prices Including VAT") then begin
                                        RetailDocumentLine."Price including VAT" := Rec."Prices Including VAT";
                                    end else begin
                                        if (RetailDocumentLine."Price including VAT" and not Rec."Prices Including VAT") then begin
                                            RetailDocumentLine."Unit price" := RetailDocumentLine."Unit price" / (1 + (RetailDocumentLine."Vat %" / 100));
                                            RetailDocumentLine."Price including VAT" := false;
                                            RetailDocumentLine.Validate("Unit price");
                                            if RetailDocumentLine.Quantity <> 0 then begin
                                                RetailDocumentLine.Validate("Line discount %");
                                                RetailDocumentLine.Validate("Line discount amount");
                                            end;
                                        end else begin
                                            RetailDocumentLine."Unit price" := RetailDocumentLine."Unit price" * (1 + (RetailDocumentLine."Vat %" / 100));
                                            RetailDocumentLine."Price including VAT" := true;
                                            RetailDocumentLine.Validate("Unit price");
                                            if RetailDocumentLine.Quantity <> 0 then begin
                                                RetailDocumentLine.Validate("Line discount %");
                                                RetailDocumentLine.Validate("Line discount amount");
                                            end;
                                        end;
                                    end;
                                    RetailDocumentLine.Modify(true);
                                end;
                            until RetailDocumentLine.Next = 0;
                        Modify();
                    end;
                end;
            end;
        }
        field(1011; "Has Run"; Integer)
        {
            Caption = 'Has Run';
            DataClassification = CustomerContent;
        }
        field(1012; "Amount Incl. VAT"; Decimal)
        {
            CalcFormula = Sum("NPR Retail Document Lines"."Amount Including VAT" WHERE("Document Type" = FIELD("Document Type"),
                                                                                    "Document No." = FIELD("No.")));
            Caption = 'Amount Incl. VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1013; "Ship-to Country Code"; Code[10])
        {
            Caption = 'Ship-to Country Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(1014; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PaymentMethod.Init;
                if "Payment Method Code" <> '' then
                    PaymentMethod.Get("Payment Method Code");
                //"Bal. Account Type" := PaymentMethod."Bal. Account Type";
                //"Bal. Account No." := PaymentMethod."Bal. Account No.";
                //IF "Bal. Account No." <> '' THEN BEGIN
                //  TESTFIELD("Applies-to Doc. No.",'');
                //  TESTFIELD("Applies-to ID",'');
                //END;
            end;
        }
        field(1015; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(1016; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Customer: Record Customer;
                Contact: Record Contact;
            begin
                if RetailFormCode.CreateCustomerOld("Bill-to Customer No.", "Customer Type", "Salesperson Code") then begin
                    if "Customer Type" = "Customer Type"::Alm then begin
                        Customer.Get("Bill-to Customer No.");
                        Name := Customer.Name;
                        Address := Customer.Address;
                        "Address 2" := Customer."Address 2";
                        City := Customer.City;
                        Phone := Customer."Phone No.";
                        "Post Code" := Customer."Post Code";
                        "Ship-to Name" := Customer.Name;
                        "Ship-to Address" := Customer.Address;
                        "Ship-to Address 2" := Customer."Address 2";
                        "Ship-to Post Code" := Customer."Post Code";
                        "Ship-to City" := Customer.City;
                        "Ship-to Country Code" := Customer."Country/Region Code";
                        Validate("Prices Including VAT", Customer."Prices Including VAT");
                        Validate("Payment Terms Code", Customer."Payment Terms Code");
                        Validate("Payment Method Code", Customer."Payment Method Code");
                        //-NPR4.04
                        "E-mail" := Customer."E-Mail";
                        //+NPR4.04

                        CopyCustomer(Customer, "Customer No.");
                    end else begin
                        Contact.Get("Bill-to Customer No.");
                        Name := Contact.Name;
                        Address := Contact.Address;
                        "Address 2" := Contact."Address 2";
                        City := Contact.City;
                        Phone := Contact."Phone No.";
                        "Post Code" := Contact."Post Code";
                        Mobile := Contact."Mobile Phone No.";
                        Validate("Prices Including VAT", true);
                        "Payment Terms Code" := '';
                        "Payment Method Code" := '';
                        "Ship-to Name" := Contact.Name;
                        "Ship-to Address" := Contact.Address;
                        "Ship-to Address 2" := Contact."Address 2";
                        "Ship-to Post Code" := Contact."Post Code";
                        "Ship-to City" := Contact.City;
                        "Ship-to Country Code" := Contact."Country/Region Code";
                        //-NPR4.04
                        "E-mail" := Contact."E-Mail";
                        //+NPR4.04

                    end;
                end else begin
                    "Customer No." := '';
                    Name := '';
                    Address := '';
                    "Address 2" := '';
                    City := '';
                    Phone := '';
                    "Post Code" := '';
                    Mobile := '';
                    "Ship-to Name" := '';
                    "Ship-to Address" := '';
                    "Ship-to Address 2" := '';
                    "Ship-to Post Code" := '';
                    "Ship-to City" := '';
                    "Ship-to Country Code" := '';
                    //-NPR4.04
                    "E-mail" := '';
                    //+NPR4.04

                end;
            end;
        }
        field(1025; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "NPR POS Entry"."Entry No.";
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

    trigger OnDelete()
    var
        RetailDocumentLines: Record "NPR Retail Document Lines";
    begin
        //-NPR5.47 [331971]
        // IF Cashed THEN
        //  ERROR(Text1060003);
        //+NPR5.47 [331971]
        RetailDocumentLines.SetCurrentKey("Document Type", "Document No.");
        RetailDocumentLines.SetRange("Document Type", "Document Type");
        RetailDocumentLines.SetRange("Document No.", "No.");
        RetailDocumentLines.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        RetailSetup.Get;

        RetailDocumentHeader."Copy No." := 0;

        if "No." = '' then begin
            TestNoSeries;
            NoSeriesMgt.InitSeries(GetNoSeriesCode, xRec."No. Series", Date, "No.", "No. Series");
        end;

        if RetailSetup."Use I-Comm" then begin
            PhotoSetup.Get;
            if (PhotoSetup."Contract No. by" = PhotoSetup."Contract No. by"::"Customer No.") and
               ("Document Type" = "Document Type"::"Selection Contract") then begin
                Cust.Init;
                Cust."No." := "No.";
                if Cust.Insert then;
                Validate("Customer No.", "No.");
            end;
        end;

        if GetFilter("Customer No.") <> '' then
            if GetRangeMin("Customer No.") = GetRangeMax("Customer No.") then
                Validate("Customer No.", GetRangeMin("Customer No."));

        "Document Date" := Today;
        "Time of Day" := Time;

        if "Document Type" = "Document Type"::"Selection Contract" then
            "Req. Return Date" := CalcDate('<+8D>', Today);

        "Primary Key Length" := StrLen("No.");
        SetReasonCode;
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        "Primary Key Length" := StrLen("No.");
    end;

    var
        Cust: Record Customer;
        RetailSetup: Record "NPR Retail Setup";
        RetailDocumentHeader: Record "NPR Retail Document Header";
        RetailDocumentLine: Record "NPR Retail Document Lines";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        PostCode: Record "Post Code";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        Text024: Label 'You have modified the %1 field. Note that the recalculation of VAT may cause penny differences, so you must check the amounts afterwards. ';
        Text026: Label 'Do you want to update the %2 field on the lines to reflect the new value of %1?';
        PhotoSetup: Record "NPR Retail Contr. Setup";
        PaymentAmt: Decimal;
        PaymentTerms: Record "Payment Terms";
        DimMgt: Codeunit DimensionManagement;
        Item: Record Item;
        PaymentMethod: Record "Payment Method";
        Text030: Label 'Payment must be at least ';

    procedure GetNoSeriesCode(): Code[10]
    begin
        RetailSetup.Get;
        case "Document Type" of
            "Document Type"::"Selection Contract":
                exit(RetailSetup."Selection No. Series");
            "Document Type"::"Retail Order":
                exit(RetailSetup."Order  No. Series");
            "Document Type"::"Rental contract":
                exit(RetailSetup."Rental Contract  No. Series");
            "Document Type"::"Purchase contract":
                exit(RetailSetup."Purchase Contract  No. Series");
            "Document Type"::Customization:
                exit(RetailSetup."Customization  No. Series");
            "Document Type"::Quote:
                exit(RetailSetup."Quote  No. Series");
        end;
    end;

    procedure TestNoSeries(): Boolean
    begin
        RetailSetup.Get;
        case "Document Type" of
            "Document Type"::"Selection Contract":
                RetailSetup.TestField("Selection No. Series");
            "Document Type"::"Retail Order":
                RetailSetup.TestField("Order  No. Series");
            "Document Type"::"Rental contract":
                RetailSetup.TestField("Rental Contract  No. Series");
            "Document Type"::"Purchase contract":
                RetailSetup.TestField("Purchase Contract  No. Series");
            "Document Type"::Customization:
                RetailSetup.TestField("Customization  No. Series");
            "Document Type"::Quote:
                RetailSetup.TestField("Quote  No. Series");
        end;
    end;

    procedure CreateInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        RetailDocLine: Record "NPR Retail Document Lines";
        LineNo: Integer;
        TxtCreated: Label 'The invoice has been created on number %1';
        CashThis: Boolean;
        TxtAskCash: Label 'Do you wish to cash this rental contract?';
        TxtCashed: Label '%1 number %2 has been cashed';
    begin
        if "Customer Type" = "Customer Type"::Kontant then
            Validate("Customer Type", "Customer Type"::Alm);

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", "Customer No.");
        SalesHeader.Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
        SalesHeader.Validate("Salesperson Code", "Salesperson Code");

        if "Ship-to Name" <> '' then
            SalesHeader."Ship-to Name" := "Ship-to Name";

        if "Ship-to Address" <> '' then
            SalesHeader."Ship-to Address" := "Ship-to Address";

        if "Ship-to Address 2" <> '' then
            SalesHeader."Ship-to Address 2" := "Ship-to Address 2";

        if "Ship-to Post Code" <> '' then
            SalesHeader."Ship-to Post Code" := "Ship-to Post Code";

        if "Ship-to City" <> '' then
            SalesHeader."Ship-to City" := "Ship-to City";

        if "Ship-to Attention" <> '' then
            SalesHeader."Ship-to Contact" := "Ship-to Attention";

        if Format("Document Date") <> '' then
            SalesHeader."Promised Delivery Date" := "Document Date";

        if Reference <> '' then
            SalesHeader."External Document No." := Reference
        else
            SalesHeader."External Document No." := "No.";

        SalesHeader.Modify;
        RetailDocLine.SetRange("Document Type", "Document Type");
        RetailDocLine.SetRange("Document No.", "No.");
        LineNo := 10000;
        if RetailDocLine.Find('-') then
            repeat
                SalesLine.Init;
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.Insert(true);
                LineNo += 10000;
                SalesLine.Validate("Sell-to Customer No.", "Customer No.");
                SalesLine.Type := SalesLine.Type::Item;
                SalesLine.Validate("No.", RetailDocLine."No.");
                SalesLine.Validate(Quantity, RetailDocLine.Quantity);
                SalesLine.Validate("Unit of Measure", RetailDocLine."Unit of measure");
                SalesLine.Validate("Variant Code", RetailDocLine."Variant Code");
                //IF ( RetailDocLine.Color <> '' ) AND ( RetailDocLine.Size <> '' ) THEN BEGIN
                //IF TmpItem.GET("No.") THEN BEGIN
                //END;
                //END;
                SalesLine.Validate("Unit Price", RetailDocLine."Unit price");
                SalesLine.Validate("Line Discount %", RetailDocLine."Line discount %");
                SalesLine.Modify;
            until RetailDocLine.Next = 0;

        "Invoice No." := SalesHeader."No.";
        "Invoice Document Type" := "Invoice Document Type"::Invoice;
        "Contract Status" := "Contract Status"::"Transmitted to invoice";
        Message(TxtCreated, SalesHeader."No.");
        CashThis := Confirm(TxtAskCash);
        if CashThis then begin
            Cashed := true;
            Message(TxtCashed, Format("Document Type"), "No.");
        end;

        Modify;
    end;

    procedure SendStatusSMS()
    var
        SMSMsg: Text[250];
        IComm: Record "NPR I-Comm";
        ErrNoNum: Label 'No Mobile No. has been given on %1 %2';
        SMS: Codeunit "NPR SMS";
        "Interaction Log Entry": Record "Interaction Log Entry";
    begin
        //SendStatusSMS()
        IComm.Get;
        if Mobile <> '' then begin
            if "Document Type" = "Document Type"::"Retail Order" then
                SMSMsg := StrSubstNo(IComm."Tailor Message", "No.", Format(Status));
            if "Document Type" = "Document Type"::"Selection Contract" then
                SMSMsg := StrSubstNo(IComm."Rental Message", "No.", Format(Status));
            SMS.SendSMS(Mobile, SMSMsg);
            SMS.CreateInteractionLog("Customer No.", '', 'SMS Send Status ' + Mobile, CopyStr(SMSMsg, 1, 50),
                 "Interaction Log Entry"."Document Type"::"Service Contract", "No.");
        end else
            Message(ErrNoNum, Format("Document Type"), "No.");
    end;

    procedure CreatePurchaseOrder()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        ItemHere: Record Item;
        RetailDocLine: Record "NPR Retail Document Lines";
        PurchOrderQty: Decimal;
        CreateManko: Boolean;
        Trans0001: Label '%1 of the order item %2 %3 has been added to the purchase quote %4';
        Trans0002: Label 'A purchaseorder with no. %1 allready exists on \item: %2 with a disposal quantity on %3\Would you like to add the item to this order?\(Answer no is the item should be included on the purchase quote)';
    begin
        //CreatePurchaseOrder

        RetailDocLine.SetRange("Document Type", "Document Type");
        RetailDocLine.SetRange("Document No.", "No.");
        CreateManko := true;

        if RetailDocLine.Find('-') then
            repeat
                PurchOrderQty := RetailDocLine.Quantity - RetailDocLine."Quantity in order";

                /*Er ¢nskede antal mindre end det bestilte ??*/
                if (PurchOrderQty > 0) then begin
                    CreateManko := true;

                    /*Sikrer at leverand¢r-nummeret for varen er udfyldt ellers stop og meddel*/
                    if RetailDocLine."No." <> '' then
                        ItemHere.Get(RetailDocLine."No.");

                    if ItemHere."NPR Group sale" = false then begin
                        ItemHere.TestField("Vendor No.");

                        /*Checker f¢rst om der findes en ordre, der passer til det bestilte antal*/
                        PurchLine2.SetCurrentKey("Document Type", Type, "No.");
                        PurchLine2.SetRange("Document Type", PurchLine2."Document Type"::Order);
                        PurchLine2.SetRange(Type, PurchLine2.Type::Item);
                        PurchLine2.SetRange("No.", RetailDocLine."No.");
                        PurchLine2.SetRange("Buy-from Vendor No.", ItemHere."Vendor No.");
                        PurchLine2.SetFilter("Outstanding Quantity", '>%1', PurchOrderQty);
                        if PurchLine2.Find('-') then
                            repeat
                                if PurchLine2."Outstanding Quantity" - PurchLine2."NPR Procure Quantity" > PurchOrderQty then begin
                                    if Confirm(StrSubstNo(Trans0002,
                                                        PurchLine2."Document No.", RetailDocLine.Description,
                                                        PurchLine2."Outstanding Quantity" - PurchLine2."NPR Procure Quantity")) then begin
                                        PurchLine2."NPR Procure Quantity" := PurchLine2."NPR Procure Quantity" - PurchOrderQty;
                                        PurchLine2.Modify;
                                        RetailDocLine."Quantity in order" := RetailDocLine."Quantity in order" + PurchOrderQty;
                                        RetailDocLine.Modify;
                                        CreateManko := false
                                    end;
                                end;
                            until ((PurchLine2.Next = 0) or (not CreateManko));

                        /*Der dannes Mankoliste dvs. der sliftes bilagstype til k¢bsrekvisition*/
                        /*Der findes en mankoliste til leverand¢ren med den samme vare*/
                        if CreateManko then begin
                            PurchLine2.Reset;
                            PurchLine2.SetCurrentKey("Document Type", Type, "No.");
                            PurchLine2.SetRange("Document Type", PurchLine2."Document Type"::Quote);
                            PurchLine2.SetRange(Type, PurchLine2.Type::Item);
                            PurchLine2.SetRange("No.", RetailDocLine."No.");
                            PurchLine2.SetRange("Buy-from Vendor No.", ItemHere."Vendor No.");
                            PurchLine2.SetRange("NPR Compaign Order", false);
                            if PurchLine2.Find('-') then begin
                                PurchLine2.Validate(Quantity, PurchLine2.Quantity + PurchOrderQty);
                                PurchLine2."NPR Procure Quantity" := PurchLine2."NPR Procure Quantity" + PurchOrderQty;
                                PurchLine2.Modify;
                                RetailDocLine."Quantity in order" := RetailDocLine."Quantity in order" + PurchOrderQty;
                                RetailDocLine.Modify;
                                Message(Trans0001,
                                        PurchOrderQty, PurchLine2."No.", PurchLine2.Description, PurchLine2."Document No.");
                            end else begin

                                /*Pr¢ver at finde en mankoliste til leverand¢ren, som man kan tilf¢je bestillingen til*/
                                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Quote);
                                PurchHeader.SetRange("Buy-from Vendor No.", ItemHere."Vendor No.");

                                /*Hvis ikke Mankoliste til leverand¢ren findes, dannes der én inder linien tilf¢jes*/
                                if not PurchHeader.Find('-') then begin
                                    PurchHeader.Init;
                                    PurchHeader."No." := '';
                                    PurchHeader."Document Type" := PurchLine."Document Type"::Quote;
                                    PurchHeader.Insert(true);
                                    PurchHeader.Validate("Buy-from Vendor No.", ItemHere."Vendor No.");
                                    PurchHeader.Modify;
                                end;

                                Validate("Purchase Order No.", PurchHeader."No.");
                                Modify;

                                /*Der tilf¢jes en linie til manko-listen*/
                                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                                PurchLine.SetRange("Document No.", PurchHeader."No.");
                                if not PurchLine.Find('+') then;
                                PurchLine.Init;
                                PurchLine."Document Type" := PurchHeader."Document Type";
                                PurchLine."Document No." := PurchHeader."No.";
                                PurchLine."Line No." := PurchLine."Line No." + 10000;
                                PurchLine.Validate(Type, PurchLine.Type::Item);
                                PurchLine.Validate("No.", ItemHere."No.");
                                PurchLine.Validate("Variant Code", RetailDocLine."Variant Code");
                                PurchLine.Validate(Quantity, PurchOrderQty);
                                PurchLine."NPR Procure Quantity" := PurchOrderQty;
                                PurchLine.Insert;
                                RetailDocLine."Quantity in order" := RetailDocLine."Quantity in order" + PurchOrderQty;
                                RetailDocLine.Modify;
                                Message(Trans0001,
                                        PurchOrderQty, PurchLine."No.", PurchLine.Description, PurchLine."Document No.");

                            end;
                        end;
                    end else begin
                        RetailDocLine."Quantity in order" := RetailDocLine.Quantity;
                        RetailDocLine."Quantity received" := RetailDocLine.Quantity;
                        RetailDocLine.Modify;
                    end;
                end;
            until RetailDocLine.Next = 0;
        //Status := Status::Bestilt;
        //MODIFY;

    end;

    procedure CashFromSale(var Sale: Record "NPR Sale POS")
    var
        RetailDocHeader: Record "NPR Retail Document Header";
    begin
        //CashFromSale()
        with Sale do begin
            RetailDocHeader.Reset;
            RetailDocHeader.SetCurrentKey("Return Register", "Return Sales Ticket");
            RetailDocHeader.SetRange("Return Register", "Register No.");
            RetailDocHeader.SetRange("Document Type", RetailDocHeader."Document Type"::"Selection Contract");
            if "Org. Bonnr." = '' then
                RetailDocHeader.SetRange("Return Sales Ticket", "Sales Ticket No.")
            else
                RetailDocHeader.SetRange("Return Sales Ticket", "Org. Bonnr.");

            if RetailDocHeader.Find('-') then begin
                RetailDocHeader.Cashed := true;
                RetailDocHeader.Modify;
            end;
        end;
    end;

    procedure CalcExpireDate()
    var
        Months: Integer;
    begin
        Validate(Factor);
        //-NPR5.40 [307717]
        //IF "Document Date" > 010180D THEN BEGIN
        if "Document Date" > DMY2Date(1, 1, 1980) then begin
            //+NPR5.40 [307717]
            Months := Factor * "Duration in Periods";
            "Expiry Date" := CalcDate('+' + Format(Months) + '<M>', "Document Date");
            if "Last Invoice Date" <> 0D then
                "Next Invoice Date" := CalcDate('+' + Format(Factor) + '<M>', "Last Invoice Date");

        end;
    end;

    procedure CalcAnualRent()
    var
        Factor2: Integer;
        DoCalc: Boolean;
    begin
        DoCalc := true;
        case "Invoicing Period" of
            "Invoicing Period"::"1 Month":
                Factor2 := 12;
            "Invoicing Period"::"2 Month":
                Factor2 := 6;
            "Invoicing Period"::Quater:
                Factor2 := 4;
            "Invoicing Period"::"Semi Annual":
                Factor2 := 2;
            "Invoicing Period"::Annual:
                Factor2 := 1;
            "Invoicing Period"::None:
                DoCalc := false;
        end;
        if DoCalc then
            "Annual Rental Amount" := "Rent Incl. VAT" * Factor2;
    end;

    procedure CalcAmount()
    var
        OverDiv: Decimal;
        UnderDiv: Decimal;
        AnnuityFactor: Decimal;
        NormalPayment: Decimal;
        RoundedPayment: Decimal;
        CalcLoanPeriod: Decimal;
        Interest: Decimal;
        Remainder: Decimal;
        SaveLoanPeriod: Decimal;
        InterestValue: Decimal;
        PaymentValue: Decimal;
        N: Integer;
        T001: Label 'The last payment will become negative!';
        T002: Label 'The periodic fee will be greater than the payment!';
        T003: Label 'The payment will be negative!';
    begin
        //BeregnBel¢b();

        CalcFields("Total Price");
        Validate(Factor);
        Validate("Purchase on Credit Amount");

        if "Purchase on Credit Amount" <= 0 then begin
            if "Calculation Method" = "Calculation Method"::Rater then begin
                Payment := 0;
                "Last Payment" := 0;
            end else begin
                "Duration in Periods" := 0;
                "Last Payment" := 0;
            end;
        end;

        if "Calculation Method" = 0 then
            exit;

        if "First Payment Day" = 0D
          then
            exit;

        if ("Duration in Periods" = 0) and (Payment = 0) then
            exit;

        if "Calculation Method" = "Calculation Method"::Rater then begin

            if "Duration in Periods" = 0 then
                exit;
            ;

            if "Duration in Periods" < 2 then
                exit;

            if "Interest Pct." > 0 then begin
                OverDiv := (Power((1 + "Interest Pct." / 100), "Duration in Periods" * Factor)) * ("Interest Pct." / 100);
                UnderDiv := (Power((1 + "Interest Pct." / 100), "Duration in Periods")) - (1);
                AnnuityFactor := OverDiv / UnderDiv;
                NormalPayment := ("Purchase on Credit Amount" * AnnuityFactor) + "Periodic Fee";
            end else
                NormalPayment := ("Purchase on Credit Amount" + ("Periodic Fee" * "Duration in Periods" * Factor))
                                     / ("Duration in Periods");
            RoundedPayment := Round(NormalPayment, 5, '>');
            CalcLoanPeriod := "Duration in Periods" * Factor;
            Interest := "Interest Pct.";
            Remainder := "Purchase on Credit Amount";
            SaveLoanPeriod := CalcLoanPeriod - 1;
            "Expiry Date" := "First Payment Day";
            repeat
                "Expiry Date" := CalcDate(Format(Factor) + '<M>', "Expiry Date");
                InterestValue := Remainder * Interest / 100;
                PaymentValue := RoundedPayment - InterestValue;
                Remainder := Remainder - PaymentValue + "Periodic Fee";
                SaveLoanPeriod := SaveLoanPeriod - 1;
                if Remainder < 0 then
                    Error(T001);
            until SaveLoanPeriod = 0;
            InterestValue := (Power((1 + "Interest Pct." / 100), 1) * Remainder) - Remainder;
            Remainder := Remainder + InterestValue + "Periodic Fee";
            Payment := RoundedPayment;
        end else begin
            Interest := "Interest Pct.";
            Remainder := "Purchase on Credit Amount";
            N := 0;
            RoundedPayment := Payment;
            "Expiry Date" := "First Payment Day";
            repeat
                "Expiry Date" := CalcDate(Format(Factor) + '<M>', "Expiry Date");
                InterestValue := Remainder * Interest / 100;
                PaymentValue := Payment - InterestValue;
                if "Periodic Fee" > PaymentValue then
                    Error(T002);
                Remainder := Remainder - PaymentValue + "Periodic Fee";
                if PaymentValue < 0 then
                    Error(T003);
                N += 1;
            until Remainder + "Periodic Fee" < Payment;
            if Remainder = 0 then begin
                Remainder := Payment;
                N -= 1;
            end;
            //interestValue := ((1 + "Interest pct."/100) * Remainder) - Remainder ;
            Remainder := (1 + "Interest Pct." / 100) * Remainder + "Periodic Fee";
            "Duration in Periods" := N + 1;
        end;

        if Remainder < 0 then
            Error(T001);

        "Last Payment" := Remainder;

        "Total Fee" := "Periodic Fee" * "Duration in Periods" * Factor;

        "Total Interest Amount" := Payment * (Factor * ("Duration in Periods" - 1)) +
                                   "Last Payment" -
                                   "Purchase on Credit Amount" -
                                   "Total Fee";

        if "Has Run" = 0 then
            "Next Invoice Date" := "First Payment Day";
    end;

    procedure PrintRetailDocument(ReqWindow: Boolean)
    var
        ReportSelectionRetail1: Record "NPR Report Selection Retail";
        ReportSelectionRetail2: Record "NPR Report Selection: Contract";
        RetailDocHeaderHere: Record "NPR Retail Document Header";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        "Table": Variant;
    begin
        //PrintRetailDocument
        case "Document Type" of
            "Document Type"::" ":
                ;

            "Document Type"::"Selection Contract":
                ReportSelectionRetail1.SetRange("Report Type", ReportSelectionRetail1."Report Type"::Rental);

            "Document Type"::"Retail Order":
                ReportSelectionRetail1.SetRange("Report Type", ReportSelectionRetail1."Report Type"::Order);

            "Document Type"::Wish:
                ;

            "Document Type"::Customization:
                ReportSelectionRetail1.SetRange("Report Type", ReportSelectionRetail1."Report Type"::Tailor);

            "Document Type"::Delivery:
                ;

            "Document Type"::"Rental contract":
                ReportSelectionRetail2.SetRange("Report Type", ReportSelectionRetail2."Report Type"::"Rental contract");

            "Document Type"::"Purchase contract":
                ReportSelectionRetail2.SetRange("Report Type", ReportSelectionRetail2."Report Type"::"Purchase contract");

            "Document Type"::Quote:
                ReportSelectionRetail2.SetRange("Report Type", ReportSelectionRetail2."Report Type"::"Repair Label");
        end;


        RetailDocHeaderHere := Rec;
        RetailDocHeaderHere.SetRecFilter;

        if (ReportSelectionRetail1.GetFilters <> '') and ReportSelectionRetail1.Find('-') then
            repeat
                case true of
                    ReportSelectionRetail1."Report ID" > 0:
                        REPORT.Run(ReportSelectionRetail1."Report ID", ReqWindow, false, RetailDocHeaderHere);
                    ReportSelectionRetail1."Codeunit ID" > 0:
                        begin
                            Table := RetailDocHeaderHere;
                            LinePrintMgt.ProcessCodeunit(ReportSelectionRetail1."Codeunit ID", Table);
                        end;
                end;
            until ReportSelectionRetail1.Next = 0;

        if (ReportSelectionRetail2.GetFilters <> '') and ReportSelectionRetail2.Find('-') then
            repeat
                case true of
                    ReportSelectionRetail2."Report ID" > 0:
                        REPORT.Run(ReportSelectionRetail2."Report ID", ReqWindow, false, RetailDocHeaderHere);
                    ReportSelectionRetail1."Codeunit ID" > 0:
                        begin
                            Table := RetailDocHeaderHere;
                            LinePrintMgt.ProcessCodeunit(ReportSelectionRetail2."Codeunit ID", Table);
                        end;
                end;
            until ReportSelectionRetail2.Next = 0;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        /*DIMISSUE
        IF "No." <> '' THEN begin
          DimMgt.SaveDocDim(
            DATABASE::"Sales Header","Document Type","No.",0,FieldNumber,ShortcutDimCode)
        end ELSE
          DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
        */

    end;

    procedure AnyPaymentDebit(var AuditRoll: Record "NPR Audit Roll"): Boolean
    begin
        //AnyPaymentDebit

        AuditRoll.SetRange("Retail Document Type", "Document Type");
        AuditRoll.SetRange("Retail Document No.", "No.");
        AuditRoll.SetFilter(Type, '=%1', AuditRoll.Type::Comment);
        AuditRoll.SetFilter("Sale Type", '=%1', AuditRoll."Sale Type"::"Debit Sale");
        exit(Find('-'));
    end;

    procedure CalcFirstInvoice()
    var
        NextMonth: Date;
    begin
        Validate(Factor);

        NextMonth := DMY2Date(1,
                              Date2DMY("Document Date", 2),
                              Date2DMY("Document Date", 3));

        "Next Invoice Date" := CalcDate('<+' + Format(Factor) + 'M>', NextMonth);
    end;

    procedure CalcDelivery(): Boolean
    var
        t001: Label 'You have to specify delivery express price on item no. %1';
        dec: Decimal;
    begin
        //calcDelivery

        RetailDocumentLine.Reset;
        RetailDocumentLine.SetRange("Document Type", "Document Type");
        RetailDocumentLine.SetRange("Document No.", "No.");
        RetailDocumentLine.SetRange("Delivery Item", true);

        if not RetailDocumentLine.Find('-') then begin
            case Delivery of
                Delivery::Collected:
                    ;
                Delivery::Shipped:
                    AddDelivery;
            end;
            exit;
        end else
            case Delivery of
                Delivery::Collected:
                    begin
                        RetailDocumentLine.Delete(true);
                        exit;
                    end;
            end;

        RetailSetup.Get;
        Item.Get(RetailSetup."Item No. Shipping");

        case "Shipping Type" of
            "Shipping Type"::Normal:
                dec := Item."Unit Price";
            "Shipping Type"::Express:
                Error(t001, Item."No.");
            "Shipping Type"::"External carrier":
                dec := 0;
        end;

        if RetailDocumentLine."Price including VAT" then
            RetailDocumentLine.Validate("Unit price", dec)
        else
            RetailDocumentLine.Validate("Unit price", dec / (1 + RetailDocumentLine."Vat %" / 100));

        RetailDocumentLine.Modify(true);
    end;

    procedure AddDelivery(): Boolean
    var
        nextLineNo: Integer;
    begin
        //addDelivery

        RetailSetup.Get;

        RetailDocumentLine.Reset;
        RetailDocumentLine.SetRange("Document Type", "Document Type");
        RetailDocumentLine.SetRange("Document No.", "No.");
        if RetailDocumentLine.Find('+') then
            nextLineNo := RetailDocumentLine."Line No." + 10000
        else
            nextLineNo := 10000;

        RetailDocumentLine.Reset;
        RetailDocumentLine.Init;
        RetailDocumentLine.Validate("Document Type", "Document Type");
        RetailDocumentLine.Validate("Document No.", "No.");
        RetailDocumentLine.Validate("Line No.", nextLineNo);
        RetailDocumentLine.Validate("Price including VAT", "Prices Including VAT");
        RetailDocumentLine.Validate("No.", RetailSetup."Item No. Shipping");
        RetailDocumentLine.Validate("Delivery Item", true);
        RetailDocumentLine.Validate(Quantity, 1);
        RetailDocumentLine.Validate("Qty. to Ship", 1);
        RetailDocumentLine.Insert(true);
    end;

    procedure AddDeposit(Deposit1: Decimal): Boolean
    begin
        //addDeposit

        RetailSetup.Get;

        /*
        "Rental Line".RESET;
        "Rental Line".SETRANGE("Document Type", "Document Type");
        "Rental Line".SETRANGE("Document No.", "No.");
        IF "Rental Line".FIND('+') THEN
          nextLineNo := "Rental Line"."Line No." + 10000
        ELSE
          nextLineNo := 10000;
        
        "Rental Line".RESET;
        "Rental Line".INIT;
        "Rental Line".VALIDATE("Document Type", "Document Type");
        "Rental Line".VALIDATE("Document No.", "No.");
        "Rental Line".VALIDATE("Line No.", nextLineNo);
        "Rental Line".VALIDATE("Price including VAT", "Prices Including VAT");
        "Rental Line".VALIDATE("No.", npc."Item No. Deposit");
        "Rental Line".VALIDATE("Deposit item", TRUE);
        "Rental Line".VALIDATE(Quantity, 1);
        "Rental Line".VALIDATE("Unit price", Deposit1);
        "Rental Line".VALIDATE("Qty. to Ship", 1);
        "Rental Line".INSERT( TRUE );
        */

        Deposit := Deposit1;
        Modify(true);

    end;

    procedure SetReasonCode()
    begin
        //setReasonCode

        PhotoSetup.Get;
        case "Document Type" of
            "Document Type"::"Selection Contract":
                ;
            "Document Type"::"Rental contract":
                begin
                    if PhotoSetup."Contract No. by" = PhotoSetup."Contract No. by"::Standard then
                        "Reason Code" := PhotoSetup."Rental Contract - Reason Code";
                    "Source Code" := PhotoSetup."Rental Contract - Source Code";
                end;
            "Document Type"::"Purchase contract":
                begin
                    if PhotoSetup."Contract No. by" = PhotoSetup."Contract No. by"::Standard then
                        "Reason Code" := PhotoSetup."Purch. Contract - Reason Code";
                    "Source Code" := PhotoSetup."Purch. Contract - Source Code";
                end;
        end;
    end;

    procedure GetAccountBalance(Acc1: Code[10]) Return: Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        //getAccountBalance

        Return := 0;

        PhotoSetup.Get;

        GLEntry.Reset;
        GLEntry.SetRange("G/L Account No.", Acc1);
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Invoice);
        GLEntry.SetRange("External Document No.", "No.");
        if PhotoSetup."Contract No. by" = PhotoSetup."Contract No. by"::Standard then
            GLEntry.SetRange("Reason Code", "Reason Code");
        if GLEntry.Find('-') then
            repeat
                Return += GLEntry.Amount + GLEntry."VAT Amount";
            until GLEntry.Next = 0;
    end;

    procedure CopyCustomer(FromCust: Record Customer; ToCustNo: Code[10])
    var
        NewCust: Record Customer;
    begin
        //

        NewCust.Get(ToCustNo);
        NewCust.TransferFields(FromCust, false);
        //newCust."No." := "Customer No.";
        NewCust.Modify;
    end;
}

