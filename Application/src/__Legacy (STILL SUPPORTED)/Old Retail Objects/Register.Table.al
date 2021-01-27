table 6014401 "NPR Register"
{
    Caption = 'Cash Register';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Register List";
    Permissions =;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                RetailTableCode: Codeunit "NPR Retail Table Code";
            begin
                RetailTableCode.RegisterCheckNo("Register No.");
            end;
        }
        field(2; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            FieldClass = Normal;
            InitValue = " ";
            OptionCaption = ' ,Sale,Balanced,Doing Balancing';
            OptionMembers = " ",Ekspedition,Afsluttet,"Under afslutning";
        }
        field(3; "Opening Cash"; Decimal)
        {
            Caption = 'Opening Cash';
            DataClassification = CustomerContent;
        }
        field(4; "Closing Cash"; Decimal)
        {
            Caption = 'Closing Cash';
            DataClassification = CustomerContent;
        }
        field(5; Balanced; Date)
        {
            Caption = 'Balanced';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(6; "Balanced on Sales Ticket"; Code[20])
        {
            Caption = 'Balanced on Sales Ticket';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(7; "Opened Date"; Date)
        {
            Caption = 'Opened Date';
            DataClassification = CustomerContent;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(9; "Register Type"; Code[10])
        {
            Caption = 'Register Type';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register Types to NPR POS View Profile';
        }
        field(11; Account; Code[20])
        {
            Caption = 'Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if Account <> '' then begin
                    if Account = "Gift Voucher Account" then
                        Error(ErrGavekort);

                    if Account = "Credit Voucher Account" then
                        Error(ErrTilgode);
                end;
            end;
        }
        field(12; "Gift Voucher Account"; Code[20])
        {
            Caption = 'Gift Voucher Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if "Gift Voucher Account" <> '' then begin
                    if "Gift Voucher Account" = Account then
                        Error(ErrKasse);
                    if "Gift Voucher Account" = "Credit Voucher Account" then
                        Error(ErrTilgode);
                    if "Gift Voucher Account" = "Gift Voucher Discount Account" then
                        Error(Text1060006, "Gift Voucher Account", FieldCaption("Gift Voucher Discount Account"));
                end;
            end;
        }
        field(13; "Credit Voucher Account"; Code[20])
        {
            Caption = 'Credit Voucher Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if "Credit Voucher Account" <> '' then begin
                    if "Credit Voucher Account" = Account then
                        Error(ErrKasse);

                    if "Credit Voucher Account" = "Gift Voucher Account" then
                        Error(ErrGavekort);
                end;
            end;
        }
        field(14; "Difference Account"; Code[20])
        {
            Caption = 'Difference Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(15; "Balance Account"; Code[20])
        {
            Caption = 'Balance Account';
            DataClassification = CustomerContent;
            TableRelation = IF ("Balanced Type" = CONST(Finans)) "G/L Account"
            ELSE
            IF ("Balanced Type" = CONST(Bank)) "Bank Account";
        }
        field(16; "Difference Account - Neg."; Code[20])
        {
            Caption = 'Difference Account - Neg.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(17; "Gift Voucher Discount Account"; Code[20])
        {
            Caption = 'Gift Voucher Discount Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if "Gift Voucher Discount Account" <> '' then
                    if "Gift Voucher Discount Account" = "Gift Voucher Account" then
                        Error(Text1060006, "Gift Voucher Discount Account", FieldCaption("Gift Voucher Account"));
            end;
        }
        field(18; "Gen. Business Posting Group"; Code[10])
        {
            Caption = 'Gen. Business Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(19; "VAT Gen. Business Post.Gr"; Code[10])
        {
            Caption = 'VAT Gen. Business Posting Group (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(22; "Status Set By Sales Ticket"; Code[20])
        {
            Caption = 'Status set by Sales Ticket';
            DataClassification = CustomerContent;
        }
        field(23; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(26; "Register Change Account"; Code[20])
        {
            Caption = 'Register Change Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(27; "City Gift Voucher Account"; Code[20])
        {
            Caption = 'City gift voucher account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(28; "City Gift Voucher Discount"; Code[20])
        {
            Caption = 'City Gift Voucher Discount';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(47; "Change Register"; Decimal)
        {
            Caption = 'Change Register';
            DataClassification = CustomerContent;
        }
        field(79; "Opened By Salesperson"; Code[20])
        {
            Caption = 'Opened By Salesperson';
            DataClassification = CustomerContent;
        }
        field(80; "Opened on Sales Ticket"; Code[20])
        {
            Caption = 'Opened on Sales Ticket';
            DataClassification = CustomerContent;
        }
        field(81; "Use Sales Statistics"; Boolean)
        {
            Caption = 'Use Sales Statistics';
            DataClassification = CustomerContent;
        }
        field(90; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(91; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(92; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(100; "Customer Display"; Boolean)
        {
            Caption = 'Customer Display';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DisplaySetup: Record "NPR Display Setup";
            begin
                if DisplaySetup.Get("Register No.") then
                    if DisplaySetup.Activate then
                        Error(TXT001, "Register No.");
            end;
        }
        field(101; "Credit Card"; Boolean)
        {
            Caption = 'Credit Card';
            DataClassification = CustomerContent;
        }
        field(103; "Credit Card Solution"; Option)
        {
            Caption = 'Credit Card Solution';
            DataClassification = CustomerContent;
            OptionCaption = ' ,01,02,03,04,05,06 - POINT,07,08,Steria,10 - SAGEM Flexiterm .NET,SAGEM Flexiterm JavaScript,Pepper';
            OptionMembers = " ","MSP DOS","MSP Navision",OCC,"SAGEM Flexiterminal","SAGEM Flexiterm via console",POINT,TPOS3,"SAGEM Flexitermina from server",Steria,"SAGEM Flexiterm .NET","SAGEM Flexiterm JavaScript",Pepper;
        }
        field(150; "Primary Payment Type"; Code[10])
        {
            Caption = 'Primary Payment Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR Payment Type POS"."No." WHERE(Status = CONST(Active));
        }
        field(160; "Return Payment Type"; Code[10])
        {
            Caption = 'Return Payment Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR Payment Type POS"."No." WHERE(Status = CONST(Active));
        }
        field(250; "Display 1"; Text[20])
        {
            Caption = 'Display 1';
            DataClassification = CustomerContent;
        }
        field(251; "Display 2"; Text[20])
        {
            Caption = 'Display 2';
            DataClassification = CustomerContent;
        }
        field(252; Touchscreen; Boolean)
        {
            Caption = 'Touch Screen';
            DataClassification = CustomerContent;
        }
        field(255; "Connected To Server"; Boolean)
        {
            Caption = 'Connected to Server';
            DataClassification = CustomerContent;
        }
        field(256; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(257; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(258; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(259; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            ValidateTableRelation = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(260; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(261; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(262; "Giro No."; Text[20])
        {
            Caption = 'Giro No.';
            DataClassification = CustomerContent;
        }
        field(263; "Bank Name"; Text[50])
        {
            Caption = 'Bank Name';
            DataClassification = CustomerContent;
        }
        field(264; "Bank Registration No."; Text[20])
        {
            Caption = 'Bank Registration No.';
            DataClassification = CustomerContent;
        }
        field(265; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
            DataClassification = CustomerContent;
        }
        field(266; "Automatic Payment No."; Text[20])
        {
            Caption = 'Automatic Payment No.';
            DataClassification = CustomerContent;
        }
        field(267; "VAT No."; Text[20])
        {
            Caption = 'VAT No.';
            DataClassification = CustomerContent;
        }
        field(268; "E-mail"; Text[80])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(270; "Logon-User Name"; Code[20])
        {
            Caption = 'Logon-User Name';
            DataClassification = CustomerContent;
        }
        field(271; "Sales Ticket Print Output"; Option)
        {
            Caption = 'Sales Ticket Print-Out';
            DataClassification = CustomerContent;
            OptionCaption = 'STANDARD,ASK LARGE,NEVER,CUSTOMER,DEVELOPMENT';
            OptionMembers = STANDARD,"ASK LARGE",NEVER,CUSTOMER,DEVELOPMENT;
        }
        field(273; "Sales Ticket Email Output"; Option)
        {
            Caption = 'Sales Ticket Email Output';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Auto,Prompt,Prompt With Print Overrule';
            OptionMembers = "None",Auto,Prompt,"Prompt With Print Overrule";
        }
        field(274; Website; Text[50])
        {
            Caption = 'Website';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(277; CloseOnRegBal; Boolean)
        {
            Caption = 'Close Terminal at Register Balance';
            DataClassification = CustomerContent;
        }
        field(300; "Sales Ticket Line Text off"; Option)
        {
            Caption = 'Sales Ticket Line Text off';
            DataClassification = CustomerContent;
            OptionCaption = 'NP Config,Register,Comment Line';
            OptionMembers = "NP Config",Register,Comment;
        }
        field(301; "Sales Ticket Line Text1"; Code[50])
        {
            Caption = 'Sales Ticket Line Text1';
            DataClassification = CustomerContent;
        }
        field(302; "Sales Ticket Line Text2"; Code[50])
        {
            Caption = 'Sales Ticket Line Text2';
            DataClassification = CustomerContent;
        }
        field(303; "Sales Ticket Line Text3"; Code[50])
        {
            Caption = 'Sales Ticket Line Text3';
            DataClassification = CustomerContent;
        }
        field(304; "Sales Ticket Line Text4"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 4';
            DataClassification = CustomerContent;
        }
        field(305; "Sales Ticket Line Text5"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 5';
            DataClassification = CustomerContent;
        }
        field(306; "Sales Ticket Line Text6"; Code[50])
        {
            Caption = 'Sales Ticket Line Text6';
            DataClassification = CustomerContent;
        }
        field(307; "Sales Ticket Line Text7"; Code[50])
        {
            Caption = 'Sales Ticket Line Text7';
            DataClassification = CustomerContent;
        }
        field(308; "Sales Ticket Line Text8"; Code[50])
        {
            Caption = 'Sales Ticket Line Text8';
            DataClassification = CustomerContent;
        }
        field(309; "Sales Ticket Line Text9"; Code[50])
        {
            Caption = 'Sales Ticket Line Text9';
            DataClassification = CustomerContent;
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(325; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
        }
        field(328; "Customer Price Group"; Code[10])
        {
            Caption = 'Item price group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
        }
        field(329; "Balanced Type"; Option)
        {
            Caption = 'Balanced Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Finance,Bank';
            OptionMembers = Finans,Bank;

            trigger OnValidate()
            begin
                if "Balanced Type" <> xRec."Balanced Type" then
                    "Balance Account" := '';
            end;
        }
        field(330; "Receipt Printer Type"; Option)
        {
            Caption = 'Receipt Printer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'TM-T88,Samsung,Star';
            OptionMembers = "TM-T88",Samsung,Star;
        }
        field(340; "Send Receipt Logo from NAV"; Boolean)
        {
            Caption = 'Send Receipt Logo from NAV';
            DataClassification = CustomerContent;
        }
        field(402; "Attendance Count in Audit Roll"; Integer)
        {
            CalcFormula = Count("NPR Audit Roll" WHERE("Register No." = FIELD("Register No."),
                                                    "Sales Ticket No." = FIELD("Sales Ticket Filter"),
                                                    "Sale Type" = CONST(Sale),
                                                    "Line No." = CONST(1),
                                                    "Sale Date" = FIELD("Date Filter"),
                                                    "Salesperson Code" = FIELD("Sales Person Filter"),
                                                    "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                    "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Attendance Count in Audit Roll';
            FieldClass = FlowField;
        }
        field(403; "Normal Sales in Audit Roll"; Decimal)
        {
            CalcFormula = Sum("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
                                                                         "Register No." = FIELD("Register No."),
                                                                         "Sale Type" = CONST(Sale),
                                                                         Type = CONST(Item),
                                                                         "Salesperson Code" = FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Normal Sales in Audit Roll';
            FieldClass = FlowField;
        }
        field(404; "Debit Sales in Audit Roll"; Decimal)
        {
            CalcFormula = Sum("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
                                                                         "Register No." = FIELD("Register No."),
                                                                         "Sale Type" = CONST("Debit Sale"),
                                                                         "Gift voucher ref." = FILTER(= ''),
                                                                         "Salesperson Code" = FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Dabit Sales in Audit Roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(410; "Item Count in Audit Roll Debit"; Integer)
        {
            CalcFormula = Count("NPR Audit Roll" WHERE("Register No." = FIELD("Register No."),
                                                    "Sales Ticket No." = FIELD("Sales Ticket Filter"),
                                                    Type = CONST("Debit Sale"),
                                                    "Line No." = CONST(2),
                                                    "Gift voucher ref." = FILTER(= ''),
                                                    "No." = FIELD("Sales Ticket Filter"),
                                                    "Sale Date" = FIELD("Date Filter"),
                                                    "Salesperson Code" = FIELD("Sales Person Filter"),
                                                    "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                    "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Item Count in Audit Debit Roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(411; "Sales Ticket Filter"; Code[20])
        {
            Caption = 'Sales Ticket Filter';
            FieldClass = FlowFilter;
        }
        field(412; "Sales Person Filter"; Code[20])
        {
            Caption = 'Sales Person Filter';
            FieldClass = FlowFilter;
        }
        field(414; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(417; "Balancing every"; Option)
        {
            Caption = 'Registerstatement';
            DataClassification = CustomerContent;
            OptionCaption = 'Day before 00:00pm,Manual';
            OptionMembers = Day,Manual;
        }
        field(503; "All Normal Sales in Audit Roll"; Decimal)
        {
            CalcFormula = Sum("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
                                                                         "Sale Type" = CONST(Sale),
                                                                         Type = CONST(Item),
                                                                         "Salesperson Code" = FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Normal Sales in Audit Roll';
            FieldClass = FlowField;
        }
        field(504; "All Debit Sales in Audit Roll"; Decimal)
        {
            CalcFormula = Sum("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
                                                                         "Sale Type" = CONST("Debit Sale"),
                                                                         Type = CONST(Item),
                                                                         "Gift voucher ref." = FILTER(= ''),
                                                                         "Salesperson Code" = FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Dabit Sales in Audit Roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(512; "End of day - Exchange Amount"; Boolean)
        {
            Caption = 'Exchange Amount';
            DataClassification = CustomerContent;
        }
        field(513; "Customer No. auto debit sale"; Option)
        {
            Caption = 'Ask for customer';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Auto,Ask payment,Ask debit';
            OptionMembers = " ",Auto,AskPayment,AskDebit;
        }
        field(515; "Money drawer attached"; Boolean)
        {
            Caption = 'Money drawer attached';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(520; "Lock Register To Salesperson"; Boolean)
        {
            Caption = 'Lock Register To Salesperson';
            DataClassification = CustomerContent;
        }
        field(604; "Use Fee"; Boolean)
        {
            Caption = 'Use fee';
            DataClassification = CustomerContent;
        }
        field(605; "Confirm Fee"; Boolean)
        {
            Caption = 'Confirm Fee';
            DataClassification = CustomerContent;
        }
        field(609; "Gen. Business Posting Override"; Option)
        {
            Caption = 'Gen. Business Posting Override';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Register';
            OptionMembers = Register,Customer;
        }
        field(610; "Terminal Auto Print"; Boolean)
        {
            Caption = 'Terminal Auto Print';
            DataClassification = CustomerContent;
        }
        field(611; "Money drawer - open on special"; Boolean)
        {
            Caption = 'Money drawer at debit/credit card';
            DataClassification = CustomerContent;
        }
        field(620; "Exchange Label Exchange Period"; DateFormula)
        {
            Caption = 'Exchange Label Exchange Period';
            DataClassification = CustomerContent;
        }
        field(630; "Enable Contactless"; Boolean)
        {
            Caption = 'Enable Contactless';
            DataClassification = CustomerContent;
        }
        field(700; "Tax Free Enabled"; Boolean)
        {
            Caption = 'Tax Free Enabled';
            DataClassification = CustomerContent;
        }
        field(701; "Tax Free Merchant ID"; Text[20])
        {
            Caption = 'Tax Free Merchant ID';
            DataClassification = CustomerContent;
        }
        field(702; "Tax Free VAT Number"; Text[20])
        {
            Caption = 'Tax Free VAT Number';
            DataClassification = CustomerContent;
        }
        field(703; "Tax Free Country Code"; Text[3])
        {
            Caption = 'Tax Free Country Code';
            DataClassification = CustomerContent;
        }
        field(704; "Tax Free Amount Threshold"; Decimal)
        {
            Caption = 'Tax Free Amount Threshold';
            DataClassification = CustomerContent;
        }
        field(705; "Tax Free Check Terminal Prefix"; Boolean)
        {
            Caption = 'Tax Free Check Terminal Prefix';
            DataClassification = CustomerContent;
        }
        field(790; "Register Layout"; Code[20])
        {
            Caption = 'Register Layout';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(830; "Encrypt Protocol Data"; Boolean)
        {
            Caption = 'Encrypt Protocol Data';
            DataClassification = CustomerContent;
            Description = 'CASE 226832';
        }
        field(831; "Secure Protocol Data"; Boolean)
        {
            Caption = 'Secure Protocol Data';
            DataClassification = CustomerContent;
            Description = 'CASE 226832';
        }
        field(832; "Install Client-side Assemblies"; Boolean)
        {
            Caption = 'Install Client-side Assemblies';
            DataClassification = CustomerContent;
            Description = 'CASE 226832';
        }
        field(834; "Skip Infobox Update in Sale"; Boolean)
        {
            Caption = 'Skip Infobox Update in Sale';
            DataClassification = CustomerContent;
            Description = 'NPR5.28';
        }
        field(850; "VAT Customer No."; Code[20])
        {
            Caption = 'VAT Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = Customer;
        }
        field(855; "Touch Screen Login Type"; Option)
        {
            BlankNumbers = DontBlank;
            Caption = 'Login Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Automatic,Quick Buttons,Normal Numeric,Never';
            OptionMembers = Automatic,Quick,"Normal Numeric",Never;
        }
        field(860; "Touch Screen Customerclub"; Option)
        {
            Caption = 'Touch Screen Customerclub';
            DataClassification = CustomerContent;
            OptionCaption = 'Functions,Invoice Customer,Contact';
            OptionMembers = Functions,"Invoice Customer",Contact;
        }
        field(865; "Touch Screen Connected"; Boolean)
        {
            Caption = 'Touch screen connection';
            DataClassification = CustomerContent;
        }
        field(870; "Touch Screen Credit Card"; Code[10])
        {
            Caption = 'Credit card button';
            DataClassification = CustomerContent;
            TableRelation = "NPR Payment Type POS";
        }
        field(875; "Touch Screen Extended info"; Boolean)
        {
            Caption = 'Touch Screen Auto Unwrap If Single';
            DataClassification = CustomerContent;
        }
        field(880; "Touch Screen Login autopopup"; Boolean)
        {
            Caption = 'Login - Auto popup';
            DataClassification = CustomerContent;
        }
        field(885; "Touch Screen Terminal Offline"; Code[10])
        {
            Caption = 'Credit card offline';
            DataClassification = CustomerContent;
            TableRelation = "NPR Payment Type POS";
        }
        field(890; "Shop id"; Code[20])
        {
            Caption = 'Shop id';
            DataClassification = CustomerContent;
        }
        field(900; "Active Event No."; Code[20])
        {
            Caption = 'Active Event No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.52 [368673]';
            TableRelation = Job WHERE("NPR Event" = CONST(true));
        }
        field(6184471; "MobilePay Payment Type"; Code[10])
        {
            Caption = 'MobilePay Payment Type';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            TableRelation = "NPR Payment Type POS";
        }
        field(6184472; "MobilePay Location ID"; Code[20])
        {
            Caption = 'MobilePay Location ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
        }
        field(6184473; "MobilePay PoS ID"; Text[50])
        {
            Caption = 'MobilePay PoS ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
        }
        field(6184474; "MobilePay PoS Unit ID"; Code[20])
        {
            Caption = 'MobilePay PoS Unit ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
        }
        field(6184475; "MobilePay PoS Registered"; Boolean)
        {
            Caption = 'MobilePay PoS Registered';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
        }
        field(6184476; "MobilePay PoS Unit Assigned"; Boolean)
        {
            Caption = 'MobilePay PoS Unit Assigned';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
        }
        field(6184491; "mPos Payment Type"; Code[10])
        {
            Caption = 'mPos Payment Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            TableRelation = "NPR Payment Type POS";
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
            SumIndexFields = "Opening Cash";
        }
        key(Key2; "Logon-User Name")
        {
        }
        key(Key3; Status)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        AuditRoll.SetRange("Register No.", "Register No.");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        if AuditRoll.FindLast then begin
            if not Confirm(StrSubstNo(Text1060008, "Register No.", AuditRoll."Sale Date"), false) then
                Error('');
        end else begin
            if not Confirm(StrSubstNo(Text1060009, "Register No."), false) then
                Error('');
        end;
        DimMgt.DeleteDefaultDim(DATABASE::"NPR Register", "Register No.");
    end;

    trigger OnInsert()
    var
        RetailTableCode: Codeunit "NPR Retail Table Code";
    begin
        RetailTableCode.RegisterCheckNo("Register No.");

        "Connected To Server" := true;
    end;

    trigger OnRename()
    begin
        Error(Text1060003, xRec."Register No.");
    end;

    var
        Text1060003: Label 'Register %1 cannot be renamed!';
        RetailSetup: Record "NPR Retail Setup";
        DimMgt: Codeunit DimensionManagement;
        PostCode: Record "Post Code";
        Text1060006: Label 'Acount No. %1 is used for  %2.';
        ErrGavekort: Label 'Acount No. %1 is used for Gift Vouchers.';
        ErrTilgode: Label 'Acount No. %1 is used for Credit Vouchers!';
        ErrKasse: Label 'Acount No. %1 is used for Register Acount!';
        Text1060008: Label 'Warning:\You are about to delete register %1\Last entry is registered on %2\Do you wish to delete it anyway?';
        Text1060009: Label 'Warning:\You are about to delete register %1\Do you wish to delete it anyway?';
        TXT001: Label '2nd Display is already activated on register %1\. Deactivate 2nd Display before activating Customer Display';

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimsAreDiscontinuedOnRegister;  //NPR5.53 [371956]
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"NPR Register", "Register No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;

    procedure setThisRegisterNo(RegNo: Code[10])
    var
        Register: Record "NPR Register";
        Fil: File;
        TextLinie: Text[30];
        Text10600002: Label '\npk.dll';
        Text10600003: Label 'An error occured during setup';
        Text10600005: Label '%1 is not implemented!';
        UserSetup: Record "User Setup";
        Int: Integer;
    begin
        RetailSetup.Get;
        case RetailSetup."Get register no. using" of
            RetailSetup."Get register no. using"::USERPROFILE,
            RetailSetup."Get register no. using"::COMPUTERNAME,
            RetailSetup."Get register no. using"::CLIENTNAME,
            RetailSetup."Get register no. using"::SESSIONNAME,
            RetailSetup."Get register no. using"::USERNAME,
            RetailSetup."Get register no. using"::USERDOMAINID:
                Error(Text10600005, RetailSetup."Get register no. using");
            RetailSetup."Get register no. using"::USERID:
                begin
                    Register.Get(RegNo);
                    Register."Logon-User Name" := UserId;
                    Register.Modify;
                end;
            RetailSetup."Get register no. using"::"USER SETUP TABLE":
                begin
                    if UserSetup.Get(UserId) then begin
                        UserSetup."NPR Backoffice Register No." := RegNo;
                        UserSetup.Modify;
                    end else begin
                        UserSetup.Init;
                        UserSetup."User ID" := UserId;
                        UserSetup."NPR Backoffice Register No." := RegNo;
                        UserSetup.Insert;
                    end;
                end;
        end;
    end;

    procedure CreateNewRegister()
    var
        t000: Label 'Create new register';
        t001: Label 'Password';
        t002: Label 'Create register no.';
        t003: Label 'Primo amount';
        PageAction: Action;
        InputDialog: Page "NPR Input Dialog";
        Pwd: Code[10];
        RegNo: Code[10];
        PaymentTypePOS: Record "NPR Payment Type POS";
        Register: Record "NPR Register";
        Primo: Decimal;
        Text10600006: Label 'You must create a payment option to cash sales!';
        Text10600007: Label 'You must create a payment choice for the journal entry for gift cards!';
        Text10600008: Label 'You must create a payment choice for the journal entry for vouchers!';
        CompInf: Record "Company Information";
        RetailTableCode: Codeunit "NPR Retail Table Code";
    begin
        Pwd := '';
        RegNo := '';
        Primo := 0;

        InputDialog.Caption := t000;

        repeat
            Pwd := '';
            InputDialog.SetInput(1, Pwd, t001);
            InputDialog.SetInput(2, RegNo, t002);
            InputDialog.SetInput(3, Primo, t003);
            PageAction := InputDialog.RunModal();
            InputDialog.InputCode(1, Pwd);
            InputDialog.InputCode(2, RegNo);
            InputDialog.InputDecimal(3, Primo);
            Clear(InputDialog);
        until (Pwd = '4552') or (Pwd = '1304') or (PageAction <> ACTION::OK);

        RetailTableCode.RegisterCheckNo(RegNo);

        Register.Init;
        Register."Register No." := RegNo;
        Register."Closing Cash" := Primo;
        Register."Opening Cash" := Primo;
        if CompInf.Get then begin
            Register."Giro No." := CompInf."Giro No.";
            Register."Bank Name" := CompInf."Bank Name";
            Register."Bank Registration No." := CompInf."Bank Branch No.";
            Register."Bank Account No." := CompInf."Bank Account No.";
            Register."Automatic Payment No." := CompInf."Payment Routing No.";
            Register."VAT No." := CompInf."VAT Registration No.";
        end;

        RetailSetup.Get();
        if RetailSetup."Payment Type By Register" then
            PaymentTypePOS.SetRange("Register No.", RegNo);

        PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::Cash);
        if not PaymentTypePOS.Find('-') then
            Error(Text10600006);

        Register.Account := PaymentTypePOS."G/L Account No.";

        PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
        if not PaymentTypePOS.Find('-') then
            Error(Text10600007);

        Register."Gift Voucher Account" := PaymentTypePOS."G/L Account No.";

        PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Credit Voucher");
        if not PaymentTypePOS.Find('-') then
            Error(Text10600008);

        Register."Credit Voucher Account" := PaymentTypePOS."G/L Account No.";
        Register.Status := Register.Status::Ekspedition;
        Register.Insert;
    end;

    procedure DimsAreDiscontinuedOnRegister()
    var
        CannotChangeHereLbl: Label 'Dimensions cannot be changed on Cash Register. Please update them on POS Unit instead.';
    begin
        Error(CannotChangeHereLbl);
    end;
}

