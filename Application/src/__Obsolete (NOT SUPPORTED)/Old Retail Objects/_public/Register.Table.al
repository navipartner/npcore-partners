table 6014401 "NPR Register"
{
    Caption = 'Cash Register';
    DataClassification = CustomerContent;
    Permissions =;
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced with POS Unit, POS store, POS unit profiles';

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                Int: Integer;
                Dec: Decimal;
            begin
                if not (Evaluate(Int, "Register No.") and Evaluate(Dec, "Register No.")) then
                    if not (int = dec) then
                        FieldError("Register No.");
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
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register -> NPR POS Unit';
        }
        field(3; "Opening Cash"; Decimal)
        {
            Caption = 'Opening Cash';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(4; "Closing Cash"; Decimal)
        {
            Caption = 'Closing Cash';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(5; Balanced; Date)
        {
            Caption = 'Balanced';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(6; "Balanced on Sales Ticket"; Code[20])
        {
            Caption = 'Balanced on Sales Ticket';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(7; "Opened Date"; Date)
        {
            Caption = 'Opened Date';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(9; "Register Type"; Code[10])
        {
            Caption = 'Register Type';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register Types to NPR POS View Profile';
        }
        field(11; Account; Code[20])
        {
            Caption = 'Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(12; "Gift Voucher Account"; Code[20])
        {
            Caption = 'Gift Voucher Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(13; "Credit Voucher Account"; Code[20])
        {
            Caption = 'Credit Voucher Account';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(14; "Difference Account"; Code[20])
        {
            Caption = 'Difference Account';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register -> NPR POS Posting Profile';
        }
        field(15; "Balance Account"; Code[20])
        {
            Caption = 'Balance Account';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(16; "Difference Account - Neg."; Code[20])
        {
            Caption = 'Difference Account - Neg.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register -> NPR POS Posting Profile';
        }
        field(17; "Gift Voucher Discount Account"; Code[20])
        {
            Caption = 'Gift Voucher Discount Account';
            DataClassification = CustomerContent;
            NotBlank = true;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(18; "Gen. Business Posting Group"; Code[10])
        {
            Caption = 'Gen. Business Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(19; "VAT Gen. Business Post.Gr"; Code[20])
        {
            Caption = 'VAT Gen. Business Posting Group (Price)';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(22; "Status Set By Sales Ticket"; Code[20])
        {
            Caption = 'Status set by Sales Ticket';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(23; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(26; "Register Change Account"; Code[20])
        {
            Caption = 'Register Change Account';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(27; "City Gift Voucher Account"; Code[20])
        {
            Caption = 'City gift voucher account';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(28; "City Gift Voucher Discount"; Code[20])
        {
            Caption = 'City Gift Voucher Discount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(47; "Change Register"; Decimal)
        {
            Caption = 'Change Register';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(79; "Opened By Salesperson"; Code[20])
        {
            Caption = 'Opened By Salesperson';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(80; "Opened on Sales Ticket"; Code[20])
        {
            Caption = 'Opened on Sales Ticket';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(81; "Use Sales Statistics"; Boolean)
        {
            Caption = 'Use Sales Statistics';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(90; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(91; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(92; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(100; "Customer Display"; Boolean)
        {
            Caption = 'Customer Display';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';

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
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(103; "Credit Card Solution"; Option)
        {
            Caption = 'Credit Card Solution';
            DataClassification = CustomerContent;
            OptionCaption = ' ,01,02,03,04,05,06 - POINT,07,08,Steria,10 - SAGEM Flexiterm .NET,SAGEM Flexiterm JavaScript,Pepper';
            OptionMembers = " ","MSP DOS","MSP Navision",OCC,"SAGEM Flexiterminal","SAGEM Flexiterm via console",POINT,TPOS3,"SAGEM Flexitermina from server",Steria,"SAGEM Flexiterm .NET","SAGEM Flexiterm JavaScript",Pepper;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(150; "Primary Payment Type"; Code[10])
        {
            Caption = 'Primary Payment Type';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(160; "Return Payment Type"; Code[10])
        {
            Caption = 'Return Payment Type';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register -> POS Payment Method';
        }
        field(250; "Display 1"; Text[20])
        {
            Caption = 'Display 1';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(251; "Display 2"; Text[20])
        {
            Caption = 'Display 2';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(252; Touchscreen; Boolean)
        {
            Caption = 'Touch Screen';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(255; "Connected To Server"; Boolean)
        {
            Caption = 'Connected to Server';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(256; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(257; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(258; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(259; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(260; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register -> NPR POS Store';
        }
        field(261; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(262; "Giro No."; Text[20])
        {
            Caption = 'Giro No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(263; "Bank Name"; Text[50])
        {
            Caption = 'Bank Name';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(264; "Bank Registration No."; Text[20])
        {
            Caption = 'Bank Registration No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(265; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(266; "Automatic Payment No."; Text[20])
        {
            Caption = 'Automatic Payment No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(267; "VAT No."; Text[20])
        {
            Caption = 'VAT No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(268; "E-mail"; Text[80])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(270; "Logon-User Name"; Code[20])
        {
            Caption = 'Logon-User Name';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(271; "Sales Ticket Print Output"; Option)
        {
            Caption = 'Sales Ticket Print-Out';
            DataClassification = CustomerContent;
            OptionCaption = 'STANDARD,ASK LARGE,NEVER,CUSTOMER,DEVELOPMENT';
            OptionMembers = STANDARD,"ASK LARGE",NEVER,CUSTOMER,DEVELOPMENT;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(273; "Sales Ticket Email Output"; Option)
        {
            Caption = 'Sales Ticket Email Output';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Auto,Prompt,Prompt With Print Overrule';
            OptionMembers = "None",Auto,Prompt,"Prompt With Print Overrule";
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(274; Website; Text[50])
        {
            Caption = 'Website';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table is not used anymore. Move contact data to POS Store';
            ObsoleteTag = 'NPR Register to NPR POS Store';
        }
        field(277; CloseOnRegBal; Boolean)
        {
            Caption = 'Close Terminal at Register Balance';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(300; "Sales Ticket Line Text off"; Option)
        {
            Caption = 'Sales Ticket Line Text off';
            DataClassification = CustomerContent;
            OptionCaption = 'NP Config,Register,Comment Line';
            OptionMembers = "NP Config",Register,Comment;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(301; "Sales Ticket Line Text1"; Code[50])
        {
            Caption = 'Sales Ticket Line Text1';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(302; "Sales Ticket Line Text2"; Code[50])
        {
            Caption = 'Sales Ticket Line Text2';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(303; "Sales Ticket Line Text3"; Code[50])
        {
            Caption = 'Sales Ticket Line Text3';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(304; "Sales Ticket Line Text4"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 4';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(305; "Sales Ticket Line Text5"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 5';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(306; "Sales Ticket Line Text6"; Code[50])
        {
            Caption = 'Sales Ticket Line Text6';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(307; "Sales Ticket Line Text7"; Code[50])
        {
            Caption = 'Sales Ticket Line Text7';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(308; "Sales Ticket Line Text8"; Code[50])
        {
            Caption = 'Sales Ticket Line Text8';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(309; "Sales Ticket Line Text9"; Code[50])
        {
            Caption = 'Sales Ticket Line Text9';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(325; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register -> NPR POS Unit -> NPR POS Pricing Profile';
        }
        field(328; "Customer Price Group"; Code[10])
        {
            Caption = 'Item price group';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register -> NPR POS Unit -> NPR POS Pricing Profile';
        }
        field(329; "Balanced Type"; Option)
        {
            Caption = 'Balanced Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Finance,Bank';
            OptionMembers = Finans,Bank;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(330; "Receipt Printer Type"; Option)
        {
            Caption = 'Receipt Printer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'TM-T88,Samsung,Star';
            OptionMembers = "TM-T88",Samsung,Star;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(340; "Send Receipt Logo from NAV"; Boolean)
        {
            Caption = 'Send Receipt Logo from NAV';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(411; "Sales Ticket Filter"; Code[20])
        {
            Caption = 'Sales Ticket Filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(412; "Sales Person Filter"; Code[20])
        {
            Caption = 'Sales Person Filter';
            FieldClass = FlowFilter;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(414; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        field(417; "Balancing every"; Option)
        {
            Caption = 'Registerstatement';
            DataClassification = CustomerContent;
            OptionCaption = 'Day before 00:00pm,Manual';
            OptionMembers = Day,Manual;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(512; "End of day - Exchange Amount"; Boolean)
        {
            Caption = 'Exchange Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(513; "Customer No. auto debit sale"; Option)
        {
            Caption = 'Ask for customer';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Auto,Ask payment,Ask debit';
            OptionMembers = " ",Auto,AskPayment,AskDebit;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(515; "Money drawer attached"; Boolean)
        {
            Caption = 'Money drawer attached';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(520; "Lock Register To Salesperson"; Boolean)
        {
            Caption = 'Lock Register To Salesperson';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(604; "Use Fee"; Boolean)
        {
            Caption = 'Use fee';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(605; "Confirm Fee"; Boolean)
        {
            Caption = 'Confirm Fee';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(609; "Gen. Business Posting Override"; Option)
        {
            Caption = 'Gen. Business Posting Override';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Register';
            OptionMembers = Register,Customer;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(610; "Terminal Auto Print"; Boolean)
        {
            Caption = 'Terminal Auto Print';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(611; "Money drawer - open on special"; Boolean)
        {
            Caption = 'Money drawer at debit/credit card';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(620; "Exchange Label Exchange Period"; DateFormula)
        {
            Caption = 'Exchange Label Exchange Period';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(630; "Enable Contactless"; Boolean)
        {
            Caption = 'Enable Contactless';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(700; "Tax Free Enabled"; Boolean)
        {
            Caption = 'Tax Free Enabled';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(701; "Tax Free Merchant ID"; Text[20])
        {
            Caption = 'Tax Free Merchant ID';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(702; "Tax Free VAT Number"; Text[20])
        {
            Caption = 'Tax Free VAT Number';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(703; "Tax Free Country Code"; Text[3])
        {
            Caption = 'Tax Free Country Code';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(704; "Tax Free Amount Threshold"; Decimal)
        {
            Caption = 'Tax Free Amount Threshold';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(705; "Tax Free Check Terminal Prefix"; Boolean)
        {
            Caption = 'Tax Free Check Terminal Prefix';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(790; "Register Layout"; Code[20])
        {
            Caption = 'Register Layout';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(830; "Encrypt Protocol Data"; Boolean)
        {
            Caption = 'Encrypt Protocol Data';
            DataClassification = CustomerContent;
            Description = 'CASE 226832';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(831; "Secure Protocol Data"; Boolean)
        {
            Caption = 'Secure Protocol Data';
            DataClassification = CustomerContent;
            Description = 'CASE 226832';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(832; "Install Client-side Assemblies"; Boolean)
        {
            Caption = 'Install Client-side Assemblies';
            DataClassification = CustomerContent;
            Description = 'CASE 226832';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(834; "Skip Infobox Update in Sale"; Boolean)
        {
            Caption = 'Skip Infobox Update in Sale';
            DataClassification = CustomerContent;
            Description = 'NPR5.28';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(850; "VAT Customer No."; Code[20])
        {
            Caption = 'VAT Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(855; "Touch Screen Login Type"; Option)
        {
            BlankNumbers = DontBlank;
            Caption = 'Login Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Automatic,Quick Buttons,Normal Numeric,Never';
            OptionMembers = Automatic,Quick,"Normal Numeric",Never;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(860; "Touch Screen Customerclub"; Option)
        {
            Caption = 'Touch Screen Customerclub';
            DataClassification = CustomerContent;
            OptionCaption = 'Functions,Invoice Customer,Contact';
            OptionMembers = Functions,"Invoice Customer",Contact;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(865; "Touch Screen Connected"; Boolean)
        {
            Caption = 'Touch screen connection';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(870; "Touch Screen Credit Card"; Code[10])
        {
            Caption = 'Credit card button';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(875; "Touch Screen Extended info"; Boolean)
        {
            Caption = 'Touch Screen Auto Unwrap If Single';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(880; "Touch Screen Login autopopup"; Boolean)
        {
            Caption = 'Login - Auto popup';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(885; "Touch Screen Terminal Offline"; Code[10])
        {
            Caption = 'Credit card offline';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(890; "Shop id"; Code[20])
        {
            Caption = 'Shop id';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register -> NPR POS Unit';
        }
        field(900; "Active Event No."; Code[20])
        {
            Caption = 'Active Event No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.52 [368673]';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register -> NPR POS Unit';
        }
        field(6184471; "MobilePay Payment Type"; Code[10])
        {
            Caption = 'MobilePay Payment Type';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(6184472; "MobilePay Location ID"; Code[20])
        {
            Caption = 'MobilePay Location ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(6184473; "MobilePay PoS ID"; Text[50])
        {
            Caption = 'MobilePay PoS ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(6184474; "MobilePay PoS Unit ID"; Code[20])
        {
            Caption = 'MobilePay PoS Unit ID';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(6184475; "MobilePay PoS Registered"; Boolean)
        {
            Caption = 'MobilePay PoS Registered';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(6184476; "MobilePay PoS Unit Assigned"; Boolean)
        {
            Caption = 'MobilePay PoS Unit Assigned';
            DataClassification = CustomerContent;
            Description = 'MbP1.80';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore.';
            ObsoleteTag = 'NPR Register';
        }
        field(6184491; "mPos Payment Type"; Code[10])
        {
            Caption = 'mPos Payment Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {

        }
        key(Key2; "Logon-User Name")
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register';
        }
        key(Key3; Status)
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'This table won''t be used anymore';
            ObsoleteTag = 'NPR Register -> NPR POS Unit';
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        Int: Integer;
        Dec: Decimal;
    begin
        if not (Evaluate(Int, "Register No.") and Evaluate(Dec, "Register No.")) then
            if not (int = dec) then
                FieldError("Register No.");
    end;

    trigger OnRename()
    begin
        Error(Text1060003, xRec."Register No.");
    end;

    var
        Text1060003: Label 'Register %1 cannot be renamed!';
        TXT001: Label '2nd Display is already activated on register %1\. Deactivate 2nd Display before activating Customer Display';

    procedure DimsAreDiscontinuedOnRegister()
    var
        CannotChangeHereLbl: Label 'Dimensions cannot be changed on Cash Register. Please update them on POS Unit instead.';
    begin
        Error(CannotChangeHereLbl);
    end;
}

