table 6014405 "NPR POS Sale"
{
    Caption = 'POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("POS Store Code"));
            end;
        }
        field(4; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser".Code;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Salesperson Code"));
            end;
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
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                SaleLinePOS: Record "NPR POS Sale Line";
                Item: Record Item;
                POSPostingProfile: Record "NPR POS Posting Profile";
                Cust: Record Customer;
                POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
                xSaleLinePOS: Record "NPR POS Sale Line";
                POSSaleLine: Codeunit "NPR POS Sale Line";
                PricingProfile: Codeunit "NPR POS Pricing Profile";
                POSSaleTranslation: Codeunit "NPR POS Sale Translation";
                FoundPostingProfile: Boolean;
                CustomerHasBeenBlockedMsg: Label 'The customer has been blocked for further business.';
            begin
                GetPOSUnit();
                "POS Store Code" := _POSUnit."POS Store Code";
                GetPOSStore();
                CheckCustomerOnConnectedSO();

                PricingProfile.GetCustomerGroupsIfProfileExist(_POSUnit."POS Pricing Profile", Rec."Customer Disc. Group", Rec."Customer Price Group");

                FoundPostingProfile := _POSStore.GetProfile(POSPostingProfile);
                "Gen. Bus. Posting Group" := POSPostingProfile."Gen. Bus. Posting Group";
                "Tax Area Code" := POSPostingProfile."Tax Area Code";
                "Tax Liable" := POSPostingProfile."Tax Liable";
                "VAT Bus. Posting Group" := POSPostingProfile."VAT Bus. Posting Group";

                if "Customer No." <> '' then begin
                    "Contact No." := '';
                    Cust.Get("Customer No.");

                    if Cust.Blocked = Cust.Blocked::All then
                        Error(CustomerHasBeenBlockedMsg);

                    Name := Cust.Name;
                    Address := Cust.Address;
                    "Address 2" := Cust."Address 2";
                    "Post Code" := Cust."Post Code";
                    City := Cust.City;
                    Validate("Country Code", Cust."Country/Region Code");
                    if Cust."Customer Price Group" <> '' then
                        "Customer Price Group" := Cust."Customer Price Group";
                    if Cust."Customer Disc. Group" <> '' then
                        "Customer Disc. Group" := Cust."Customer Disc. Group";

                    if (POSPostingProfile."Default POS Posting Setup" = POSPostingProfile."Default POS Posting Setup"::Customer) or not FoundPostingProfile then begin
                        if not Cust.NPR_IsRestrictedOnPOS(Cust.FieldNo("Gen. Bus. Posting Group")) then
                            "Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
                        "Tax Area Code" := Cust."Tax Area Code";
                        "Tax Liable" := Cust."Tax Liable";
                        if not Cust.NPR_IsRestrictedOnPOS(Cust.FieldNo("VAT Bus. Posting Group")) then
                            "VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group";
                    end;
                end;

                if "Customer No." = '' then begin
                    Name := '';
                    Address := '';
                    "Address 2" := '';
                    "Post Code" := '';
                    City := '';
                    "Contact No." := '';
                    Validate("Country Code", '');
                end;

                if Cust."No." <> '' then
                    "Prices Including VAT" := Cust."Prices Including VAT"
                else
                    "Prices Including VAT" := _POSUnit.ShowPricesIncludingVAT();

                if not Modify() then;

                SaleLinePOS.Reset();
                SaleLinePOS.SetRange("Register No.", "Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
                SaleLinePOS.SetRange(Date, Date);
                if not SaleLinePOS.IsEmpty and ("Prices Including VAT" <> xRec."Prices Including VAT") then begin
                    SaleLinePOS.ModifyAll(Amount, 0);
                    SaleLinePOS.ModifyAll("Amount Including VAT", 0);
                    SaleLinePOS.ModifyAll("VAT Base Amount", 0);
                    SaleLinePOS.ModifyAll("Line Amount", 0);
                end;
                if SaleLinePOS.FindSet(true) then begin
                    repeat
                        xSaleLinePOS := SaleLinePOS;
                        Item.Get(SaleLinePOS."No.");
                        SaleLinePOS."Customer Price Group" := "Customer Price Group";
                        SaleLinePOS."Allow Line Discount" := "Allow Line Discount";
                        SaleLinePOS."Price Includes VAT" := "Prices Including VAT";
                        SaleLinePOS."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
                        SaleLinePOS."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
                        SaleLinePOS."Tax Area Code" := "Tax Area Code";
                        SaleLinePOS."Tax Liable" := "Tax Liable";
                        SaleLinePOS.UpdateVATSetup();

                        //Recalc.existing price to reflect possible VAT Rate/Price Inc. VAT change
                        POSSaleLine.ConvertPriceToVAT(
                            xSaleLinePOS."Price Includes VAT", xSaleLinePOS."VAT Bus. Posting Group", xSaleLinePOS."VAT Prod. Posting Group",
                            SaleLinePOS, SaleLinePOS."Unit Price");

                        SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
                        SaleLinePOS.GetAmount(SaleLinePOS, Item, SaleLinePOS."Unit Price");

                        OnBeforeModifySaleLineCustomerInformation(Rec, xRec, SaleLinePOS, xSaleLinePOS);
                        SaleLinePOS.Modify();
                    until SaleLinePOS.Next() = 0;
                end;

                POSSalesDiscountCalcMgt.RecalculateAllSaleLinePOS(Rec);

                case true of
                    (Rec."Customer No." <> ''):
                        POSSaleTranslation.AssignLanguageCodeFrom(Rec, Cust);
                    (Rec."Customer No." = ''):
                        POSSaleTranslation.AssignLanguageCodeFrom(Rec, _POSStore);
                end;

                CreateDimFromDefaultDim(Rec.FieldNo("Customer No."));

                //Ændring foretaget for at kunne validere på nummer og slette rabatter på linier, ved ændring af kundenummer.
                Modify();
            end;
        }
        field(8; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(9; Address; Text[100])
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
        field(16; Reference; Text[35])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Location Code"));
            end;
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if LookUpShortcutDimCode(1, "Shortcut Dimension 1 Code") then
                    Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if LookUpShortcutDimCode(2, "Shortcut Dimension 2 Code") then
                    Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(33; "Allow Line Discount"; Boolean)
        {
            Caption = 'Allow Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(34; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
        }
        field(36; "Sales Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Sales Document Type';
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
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(40; "Last Posting No."; Code[20])
        {
            Caption = 'Last Posting No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(45; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
        }
        field(50; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(60; "Send Receipt Email"; Boolean)
        {
            Caption = 'Send Receipt Email';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(74; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Gen. Business Posting Group";
        }
        field(99; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            DataClassification = CustomerContent;
        }
        field(100; "Saved Sale"; Boolean)
        {
            Caption = 'Saved Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(101; "Customer Relations"; Option)
        {
            Caption = 'Customer Relations';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Customer,Cash Customer';
            OptionMembers = " ",Customer,"Cash Customer";
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(102; "Last Sale"; Boolean)
        {
            Caption = 'Last Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(105; Kontankundenr; Code[20])
        {
            Caption = 'Cash Customer No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(106; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ord,Cash;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(107; "Org. Bonnr."; Code[20])
        {
            Caption = 'Original Ticket No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(108; "Non-editable sale"; Boolean)
        {
            Caption = 'Non-Editable Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(109; "Sale type"; Option)
        {
            Caption = 'Sale type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Annullment';
            OptionMembers = Sale,Annullment;
        }
        field(110; "Header Type"; Enum "NPR POS Sale Type")
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
        }
        field(111; "Retursalg Bonnummer"; Code[20])
        {
            Caption = 'Reversesale Ticket No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(112; Parameters; Text[250])
        {
            Caption = 'Parameters';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(113; "From Quote no."; Code[20])
        {
            Caption = 'From Quote no.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(115; "Service No."; Code[20])
        {
            Caption = 'Service No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(116; "Stats - Customer Post Code"; Code[20])
        {
            Caption = 'Stats - Customer Post Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(117; "Retail Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(118; "Retail Document No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
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

            trigger OnValidate()
            var
                SaleLinePOS: Record "NPR POS Sale Line";
                xSaleLinePOS: Record "NPR POS Sale Line";
                POSSaleLine: Codeunit "NPR POS Sale Line";
            begin
                if "Prices Including VAT" = xRec."Prices Including VAT" then
                    exit;

                SaleLinePOS.SetRange("Register No.", "Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLinePOS.SetRange(Date, Date);
                if SaleLinePOS.FindSet(true) then begin
                    SaleLinePOS.ModifyAll(Amount, 0);
                    SaleLinePOS.ModifyAll("Amount Including VAT", 0);
                    SaleLinePOS.ModifyAll("VAT Base Amount", 0);
                    SaleLinePOS.ModifyAll("Line Amount", 0);
                    repeat
                        xSaleLinePOS := SaleLinePOS;

                        SaleLinePOS.Validate("Price Includes VAT", "Prices Including VAT");
                        POSSaleLine.ConvertPriceToVAT(
                          xSaleLinePOS."Price Includes VAT", xSaleLinePOS."VAT Bus. Posting Group", xSaleLinePOS."VAT Prod. Posting Group", SaleLinePOS, SaleLinePOS."Unit Price");

                        SaleLinePOS.UpdateAmounts(SaleLinePOS);
                        SaleLinePOS.Modify(true);
                    until SaleLinePOS.Next() = 0;
                end;
            end;
        }
        field(121; TouchScreen; Boolean)
        {
            Caption = 'TouchScreen';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(123; Deposit; Decimal)
        {
            Caption = 'Deposit';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(126; "Alternative Register No."; Code[20])
        {
            Caption = 'Alternative POS Unit No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(127; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(128; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(130; "Custom Print Object ID"; Integer)
        {
            Caption = 'Custom Print Object ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(131; "Custom Print Object Type"; Text[10])
        {
            Caption = 'Custom Print Object Type';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(140; "Issue Tax Free Voucher"; Boolean)
        {
            Caption = 'Issue Tax Free Voucher';
            DataClassification = CustomerContent;
        }
        field(141; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(142; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(143; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "VAT Business Posting Group";
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
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use systemID instead';
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use systemID instead';
        }
        field(180; "Event No."; Code[20])
        {
            Caption = 'Event No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53 [376035]';
            TableRelation = Job WHERE("NPR Event" = CONST(true));

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Event No."));
            end;
        }
        field(181; "Event Task No."; Code[20])
        {
            Caption = 'Event Task No.';
            DataClassification = CustomerContent;
            TableRelation = "Job Task"."Job Task No." where("Job No." = field("Event No."));
        }
        field(200; "Device ID"; Text[50])
        {
            Caption = 'Device ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(201; "Host Name"; Text[100])
        {
            Caption = 'Host Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(210; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Description = 'NPR5.54';
        }
        field(220; "Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = SystemMetadata;
        }
        field(230; "User Session ID"; Integer)
        {
            Caption = 'User Session ID';
            DataClassification = SystemMetadata;
        }
        field(300; Amount; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NPR POS Sale Line".Amount WHERE("Register No." = FIELD("Register No."),
                                                            "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                            "Line Type" = filter(Item | "Item Category" | "BOM List" | "Issue Voucher" | "Customer Deposit")));
            Caption = 'Amount';
            Description = 'NPR5.54';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            begin
            end;
        }
        field(310; "Amount Including VAT"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NPR POS Sale Line"."Amount Including VAT" WHERE("Register No." = FIELD("Register No."),
                                                                            "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                            "Line Type" = filter(Item | "Item Category" | "BOM List" | "Issue Voucher" | "Customer Deposit")));
            Caption = 'Amount Including VAT';
            Description = 'NPR5.54';
            Editable = false;
            FieldClass = FlowField;
        }
        field(320; "Payment Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NPR POS Sale Line"."Amount Including VAT" WHERE("Register No." = FIELD("Register No."),
                                                                            "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                            "Line Type" = filter("POS Payment" | Rounding | "GL Payment")));
            Caption = 'Payment Amount';
            Description = 'NPR5.54';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim();
            end;
        }
        field(485; "Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer No.")));
            Caption = 'Customer Name';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
        field(700; "NPRE Pre-Set Seating Code"; Code[20])
        {
            Caption = 'Pre-Set Seating Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPR NPRE Seating";

            trigger OnValidate()
            var
                SaleLinePOS: Record "NPR POS Sale Line";
                SaleLinePOS2: Record "NPR POS Sale Line";
            begin
                SaleLinePOS.SetRange("Register No.", "Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                if "NPRE Pre-Set Seating Code" <> '' then
                    SaleLinePOS.SetRange("NPRE Seating Code", xRec."NPRE Pre-Set Seating Code");
                if SaleLinePOS.FindSet(true) then
                    repeat
                        SaleLinePOS2 := SaleLinePOS;
                        SaleLinePOS2.Validate("NPRE Seating Code", "NPRE Pre-Set Seating Code");
                        SaleLinePOS2.Modify();
                    until SaleLinePOS.Next() = 0;
            end;
        }
        field(701; "NPRE Pre-Set Waiter Pad No."; Code[20])
        {
            Caption = 'Pre-Set Waiter Pad No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPR NPRE Waiter Pad";
        }
        field(710; "NPRE Number of Guests"; Integer)
        {
            Caption = 'Number of Guests';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }

        field(720; "Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Group Code".Code;
        }

        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            DataClassification = CustomerContent;
            TableRelation = "Responsibility Center";

            trigger OnValidate()
            var
                SaleLinePOS: Record "NPR POS Sale Line";
                SaleLinePOS2: Record "NPR POS Sale Line";
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Responsibility Center"));

                if xRec."Responsibility Center" <> "Responsibility Center" then begin
                    SaleLinePOS.SetRange("Register No.", "Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                    if SaleLinePOS.FindSet(true) then
                        repeat
                            SaleLinePOS2 := SaleLinePOS;
                            SaleLinePOS2.Validate("Responsibility Center", "Responsibility Center");
                            SaleLinePOS2.Modify();
                        until SaleLinePOS.Next() = 0;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.")
        {
        }
        key(ByUserID; "User ID") { }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
    begin
        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.DeleteAll(true);

        POSSaleMediaInfo.DeleteEntriesForPosSale(Rec);
    end;

    trigger OnInsert()
    var
        PricingProfile: Codeunit "NPR POS Pricing Profile";
    begin
        GetPOSUnit();
        GetPOSStore();

        "Location Code" := _POSStore."Location Code";
        Rec."Customer Disc. Group" := PricingProfile.GetCustomerDiscountGroupIfProfileExist(_POSUnit."POS Pricing Profile");
        "Event No." := _POSUnit.FindActiveEventFromCurrPOSUnit();
        "User ID" := CopyStr(UserId, 1, MaxStrLen(Rec."User ID"));
        "Server Instance ID" := Database.ServiceInstanceId();
        "User Session ID" := Database.SessionId();
        "Language Code" := _POSStore."Language Code";
        "Responsibility Center" := _POSStore."Responsibility Center";

        AvoidGUIDCollision();
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        NPRDimMgt: Codeunit "NPR Dimension Mgt.";
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";

    internal procedure LookUpShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]): Boolean
    begin
        exit(NPRDimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode));
    end;

    local procedure ModifyRec()
    begin
        if not IsNullGuid(Rec.SystemId) then
            Rec.Modify();
    end;
#IF BC17 or BC18 or BC19

    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]). Use CreateDimFromDefaultDim(FieldNo: Integer) to update document dimensions from default dims starting from BC 20.0', 'NPR23.0')]
    internal procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20]; Type5: Integer; No5: Code[20]; Type6: Integer; No6: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        OldDimSetID: Integer;
    begin
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;
        TableID[5] := Type5;
        No[5] := No5;
        TableID[6] := Type6;
        No[6] := No6;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";

        "Dimension Set ID" :=
            DimMgt.GetRecDefaultDimID(
                Rec, CurrFieldNo, TableID, No, GetPOSSourceCode(), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        if (OldDimSetID <> "Dimension Set ID") and SalesLinesExist() then begin
            Modify();
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    internal procedure CreateDimFromDefaultDim(FieldNo: Integer)
    begin
        case FieldNo of
            Rec.FieldNo("Customer No."):
                CreateDimensionsFromValidateCustomerNo();
            Rec.FieldNo("Salesperson Code"):
                CreateDimensionsFromValidateSalesPersonCode();
            Rec.FieldNo("POS Store Code"):
                CreateDimensionsFromValidatePOSStoreCode();
            Rec.FieldNo("Responsibility Center"):
                CreateDimensionsFromValidateResponsibilityCenter();
            Rec.FieldNo("Event No."):
                CreateDimensionsFromValidateEventNo();
        end;
    end;
#ELSE

    internal procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::Customer, "Customer No.", FieldNo = FieldNo("Customer No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", "Salesperson Code", FieldNo = FieldNo("Salesperson Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::"NPR POS Unit", "Register No.", FieldNo = FieldNo("Register No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::"NPR POS Store", "POS Store Code", FieldNo = FieldNo("POS Store Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, "Location Code", FieldNo = FieldNo("Location Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", "Responsibility Center", FieldNo = FieldNo("Responsibility Center"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Job, "Event No.", FieldNo = FieldNo("Event No."));

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource, FieldNo);
    end;

    local procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDim(Rec, IsHandled, DefaultDimSource);
        if IsHandled then
            exit;

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
            DimMgt.GetRecDefaultDimID(
                Rec, CurrFieldNo, DefaultDimSource, GetPOSSourceCode(), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        OnCreateDimOnBeforeUpdateLines(Rec, xRec, CurrFieldNo, OldDimSetID, DefaultDimSource);
        if (OldDimSetID <> "Dimension Set ID") and SalesLinesExist() then begin
            Modify();
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;
#ENDIF

    internal procedure GetPOSSourceCode() SourceCode: Code[10]
    var
        NPRPOSUnit: Record "NPR Pos Unit";
        NPRPOSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        SourceCode := '';

        if NPRPOSUnit.Get(Rec."Register No.") then begin
            NPRPOSStore.Get(NPRPOSUnit."POS Store Code");
            if NPRPOSStore.GetProfile(POSPostingProfile) then begin
                SourceCode := POSPostingProfile."Source Code";
            end;
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := Rec."Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, Rec."Dimension Set ID");
        if Rec."Sales Ticket No." <> '' then
            Rec.Modify();

        if OldDimSetID <> Rec."Dimension Set ID" then begin
            ModifyRec();
            if SalesLinesExist() then
                UpdateAllLineDim(Rec."Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
        DimSetIdLbl: Label '%1 %2', Locked = true;
    begin
        OldDimSetID := Rec."Dimension Set ID";
        Rec."Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            Rec."Dimension Set ID", StrSubstNo(DimSetIdLbl, Rec."Register No.", Rec."Sales Ticket No."),
            Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then begin
            ModifyRec();
            if SalesLinesExist() then
                UpdateAllLineDim(Rec."Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        POSSaleLine: Record "NPR POS Sale Line";
        xPOSSaleLine: Record "NPR POS Sale Line";
        NewDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateAllLineDim(Rec, NewParentDimSetID, OldParentDimSetID, IsHandled, xRec);
        if IsHandled then
            exit;

        if NewParentDimSetID = OldParentDimSetID then
            exit;

        POSSaleLine.SetRange("Register No.", "Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", "Sales Ticket No.");
        POSSaleLine.LockTable();
        if POSSaleLine.FindSet(true) then
            repeat
                OnUpdateAllLineDimOnBeforeGetPOSSaleLineNewDimSetID(POSSaleLine, NewParentDimSetID, OldParentDimSetID);
                NewDimSetID := DimMgt.GetDeltaDimSetID(POSSaleLine."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                OnUpdateAllLineDimOnAfterGetPOSSaleLineNewDimSetID(Rec, xRec, POSSaleLine, NewDimSetID, NewParentDimSetID, OldParentDimSetID);
                if POSSaleLine."Dimension Set ID" <> NewDimSetID then begin
                    xPOSSaleLine := POSSaleLine;
                    POSSaleLine."Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                        POSSaleLine."Dimension Set ID", POSSaleLine."Shortcut Dimension 1 Code", POSSaleLine."Shortcut Dimension 2 Code");
                    OnUpdateAllLineDimOnBeforePOSSaleLineModify(POSSaleLine, xPOSSaleLine);
                    POSSaleLine.Modify();
                    OnUpdateAllLineDimOnAfterPOSSaleLineModify(POSSaleLine);
                end;
            until POSSaleLine.Next() = 0;
    end;

    procedure SalesLinesExist(): Boolean
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetRange("Register No.", "Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", "Sales Ticket No.");
        exit(not POSSaleLine.IsEmpty());
    end;

    local procedure GetPOSUnit()
    begin
        if _POSUnit."No." <> "Register No." then
            _POSUnit.Get("Register No.");
    end;

    local procedure GetPOSStore()
    begin
        if "POS Store Code" = '' then begin
            if _POSStore.Code <> _POSUnit."POS Store Code" then
                _POSStore.get(_POSUnit."POS Store Code");
            "POS Store Code" := _POSStore.Code;
        end else begin
            if _POSStore.Code <> "POS Store Code" then
                _POSStore.Get("POS Store Code");
        end;
    end;

    local procedure AvoidGUIDCollision()
    var
        PosEntry: Record "NPR POS Entry";
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin

        while (IsNullGuid(Rec.SystemId) or (PosEntry.GetBySystemId(Rec.SystemId))) do begin

            if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
                Clear(ActiveSession);

            CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
            CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
            CustomDimensions.Add('NPR_TenantId', Database.TenantId());
            CustomDimensions.Add('NPR_CompanyName', CompanyName());
            CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
            CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
            CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
            CustomDimensions.Add('NPR_OffendingGuid', Rec.SystemId);

            if (not IsNullGuid(Rec.SystemId)) then
                Session.LogMessage('NPR_3b1ef24f-53d4-4570-a227-14ad27ff9f7c', 'GUID collision avoided.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
            Rec.SystemId := CreateGuid();

        end;
    end;

    local procedure CheckCustomerOnConnectedSO()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        CustomerExistLbl: Label 'You are trying to select customer that is different from the existing customer on selected sales order.';
    begin
        if xRec."Customer No." <> "Customer No." then begin
            SaleLinePOS.SetLoadFields("Register No.", "Sales Ticket No.", "Sales Document No.");
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetFilter("Sales Document No.", '<>%1', '');
            SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"Customer Deposit");
            SaleLinePOS.SetFilter("No.", '<>%1', "Customer No.");
            if not SaleLinePOS.IsEmpty() then
                Error(CustomerExistLbl);
        end;
    end;
#IF BC17 or BC18 or BC19

    [Obsolete('Replaced by CreateDimFromDefaultDim(POSSale.FieldNo("Salesperson Code")) starting from BC 20.0', 'NPR23.0')]
    local procedure CreateDimensionsFromValidateSalesPersonCode()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDimensionsFromValidateSalesPersonCode(Rec, IsHandled);
        if IsHandled then
            exit;

        CreateDim(
            Database::"Salesperson/Purchaser", "Salesperson Code",
            Database::"NPR POS Unit", "Register No.",
            Database::"NPR POS Store", "POS Store Code",
            Database::Job, "Event No.",
            Database::Customer, "Customer No.",
            Database::"Responsibility Center", "Responsibility Center");
    end;

    [Obsolete('Replaced by CreateDimFromDefaultDim(POSSale.FieldNo("Event No.")) starting from BC 20.0', 'NPR23.0')]
    local procedure CreateDimensionsFromValidateEventNo()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDimensionsFromValidateEventNo(Rec, IsHandled);
        if IsHandled then
            exit;

        CreateDim(
            Database::Job, "Event No.",
            Database::"NPR POS Unit", "Register No.",
            Database::"NPR POS Store", "POS Store Code",
            Database::Customer, "Customer No.",
            Database::"Salesperson/Purchaser", "Salesperson Code",
            Database::"Responsibility Center", "Responsibility Center");
    end;

    [Obsolete('Replaced by CreateDimFromDefaultDim(POSSale.FieldNo("POS Store Code")) starting from BC 20.0', 'NPR23.0')]
    local procedure CreateDimensionsFromValidatePOSStoreCode()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDimensionsFromValidatePOSStoreCode(Rec, IsHandled);
        if IsHandled then
            exit;

        CreateDim(
            Database::"NPR POS Store", "POS Store Code",
            Database::"NPR POS Unit", "Register No.",
            Database::Job, "Event No.",
            Database::Customer, "Customer No.",
            Database::"Salesperson/Purchaser", "Salesperson Code",
            Database::"Responsibility Center", "Responsibility Center");
    end;

    [Obsolete('Replaced by CreateDimFromDefaultDim(POSSale.FieldNo("Customer No.")) starting from BC 20.0', 'NPR23.0')]
    local procedure CreateDimensionsFromValidateCustomerNo()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDimensionsFromValidateCustomerNo(Rec, IsHandled);
        if IsHandled then
            exit;

        CreateDim(
            Database::Customer, "Customer No.",
            Database::"NPR POS Unit", "Register No.",
            Database::"NPR POS Store", "POS Store Code",
            Database::Job, "Event No.",
            Database::"Salesperson/Purchaser", "Salesperson Code",
            Database::"Responsibility Center", "Responsibility Center");
    end;

    [Obsolete('Replaced by CreateDimFromDefaultDim(POSSale.FieldNo("Responsibility Center")) starting from BC 20.0', 'NPR23.0')]
    local procedure CreateDimensionsFromValidateResponsibilityCenter()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDimensionsFromValidateResponsibilityCenter(Rec, IsHandled);
        if IsHandled then
            exit;

        CreateDim(
            Database::"Responsibility Center", "Responsibility Center",
            Database::"NPR POS Unit", "Register No.",
            Database::"NPR POS Store", "POS Store Code",
            Database::Job, "Event No.",
            Database::Customer, "Customer No.",
            Database::"Salesperson/Purchaser", "Salesperson Code");
    end;
#ENDIF

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAllLineDim(var POSSale: Record "NPR POS Sale"; NewParentDimSetID: Integer; OldParentDimSetID: Integer; var IsHandled: Boolean; xPOSSale: Record "NPR POS Sale")
    begin
    end;
#IF BC17 or BC18 or BC19

    [Obsolete('New way of dimension handling starting from BC 20.0', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDimensionsFromValidateSalesPersonCode(var POSSale: Record "NPR POS Sale"; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('New way of dimension handling starting from BC 20.0', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDimensionsFromValidateCustomerNo(var POSSale: Record "NPR POS Sale"; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('New way of dimension handling starting from BC 20.0', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDimensionsFromValidatePOSStoreCode(var POSSale: Record "NPR POS Sale"; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('New way of dimension handling starting from BC 20.0', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDimensionsFromValidateEventNo(var POSSale: Record "NPR POS Sale"; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('New way of dimension handling starting from BC 20.0', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDimensionsFromValidateResponsibilityCenter(var POSSale: Record "NPR POS Sale"; var IsHandled: Boolean)
    begin
    end;
#ELSE

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var POSSale: Record "NPR POS Sale"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDim(var POSSale: Record "NPR POS Sale"; var IsHandled: Boolean; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateDimOnBeforeUpdateLines(var POSSale: Record "NPR POS Sale"; xPOSSale: Record "NPR POS Sale"; CurrentFieldNo: Integer; OldDimSetID: Integer; DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;
#ENDIF

    [IntegrationEvent(false, false)]
    local procedure OnUpdateAllLineDimOnBeforeGetPOSSaleLineNewDimSetID(var POSSaleLine: Record "NPR POS Sale Line"; NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateAllLineDimOnAfterGetPOSSaleLineNewDimSetID(POSSale: Record "NPR POS Sale"; xPOSSale: Record "NPR POS Sale"; POSSaleLine: Record "NPR POS Sale Line"; var NewDimSetID: Integer; NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateAllLineDimOnBeforePOSSaleLineModify(var POSSaleLine: Record "NPR POS Sale Line"; xPOSSaleLine: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateAllLineDimOnAfterPOSSaleLineModify(var POSSaleLine: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySaleLineCustomerInformation(var POSSale: Record "NPR POS Sale"; xPOSSale: Record "NPR POS Sale"; var POSSaleLine: Record "NPR POS Sale Line"; xPOSSaleLine: Record "NPR POS Sale Line")
    begin
    end;
}
