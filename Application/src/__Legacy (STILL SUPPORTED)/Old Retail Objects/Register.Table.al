table 6014401 "NPR Register"
{
    // //-NPR-Dankort1.0c ved Nikolai Pedersen
    //   Credit Card Solution - tilf¢jet Sagem terminal
    // 
    // NPR4.10/VB/20150601  CASE 213003 Added field Control Add-in Type
    // NPR4.12/VB/20150708  CASE 213003 Added fields Client Decimal Separator and client Thousands Separator
    // NPR4.13/MMV/20150715 CASE 215400 Added field 620 - Type and name matches field Exchange Label Exchange Period in retail setup.
    // NPR4.14/JS/20150922  CASE 223584 Added field 630 - Enable Contactless to allow the customer to switch contactless on and off.
    // NPR4.14/VB/20151001  CASE 224232 Added field 819 Client Formatting Culture ID
    // MbP1.80/AP/20151110  CASE 226725 MobilePay
    // NPR4.16/JDH/20151115 CASE 225415 Removed all unused fields, and translated vars to ENU (all undocumented in code by purpose)
    // NPR4.18/MMV/20160202  CASE 224257 New Tax Free integration:
    //                                   Added fields 700 - 704.
    //                                   Removed fields 613 - 615.
    // NPR4.21/MMV/20160202  CASE 224257 Added field 705, added missing danish captions.
    // NPR4.21/RMT/20160210 CASE 234145 Check that register no is an integer
    // NPR4.21/MMV/20160223  CASE 223223 Added field 340
    // NPR4.21/JLK/20160315  CASE 236022 Added Confirm dialog for delete register
    // NPR5.00/VB/20151130  CASE 226832 Added fields 830, 831, and 832 to support changed POS device protocol functionality
    // NPR5.00/VB/20151203  CASE 228807 Added option "SAGEM Flexiterm JavaScript" to field 103 Credit Card Solution
    // NPR5.00/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 226832 NP Retail 2016
    // NPR5.20/BR/20160215 CASE 231481 Added option "Pepper" to field 103 Credit Card Solution
    // NPR5.22/VB/20160407 CASE 237866 Added field "Line Order on Screen"
    // NPR5.25/TTH/20160718 CASE 238859 Added fields for Swipp Payment processing
    // NPR5.26/BR /20160812 CASE 248762 Credit Card Solution Fixed ENU OptionCaption of Field 103 "Credit Card Solution"
    // NPR5.28/MMV /20161104 CASE 254575 Added field 273 : "Sales Ticket Email Output"
    // NPR5.28/VB/20161107 CASE 257796 Added field 834 : "Skip Infobox Update in Sale"
    // NPR5.28/VB/20161122 CASE 259086 Removed Control Add-in Type field
    // NPR5.29/CLVA/20161222 CASE 251884 Added field Adyen Payment Type
    // NPR5.29/MMV /20161216 CASE 241549 Removed deprecated print/report code & fields.
    //                                   Renamed F 271 along with A4 option in optionstring.
    // NPR5.30/TJ  /20170213 CASE 264909 Removed Swipp fields
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.31/MHA /20170113 CASE 263093 Added field 325 "Customer Disc. Group"
    // NPR5.31/CLVA/20170328 CASE 251884 Change field name on field 6184491 from "Adyen Payment Type" to "mPos Payment Type"
    // NPR5.36/BR  /20170914  CASE 289641 Added field VAT Customer No.
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range below 50000
    // NPR5.40/TS  /20180308  CASE 307432 Removed reference to Field Import credit card transact. and Auto Open/Close Terminal
    // NPR5.40/TSA /20180209 CASE 303065 Added option AutoSplitKey to field 833 "Line Order on Screen"
    // NPR5.40/JDH /20180330 CASE 309516 Removed Unused code
    // NPR5.43/CLVA/20180606 CASE 300254 Added 2nd Display validaton on "Customer Display"
    // NPR5.46/MMV /20181002 CASE 290734 EFT Framework refactoring
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality
    // NPR5.49/TJ  /20190201 CASE 335739 Fields 20,819,820,821,822,833 and 6150721 moved to new table POS View Profile
    //                                   Function DetectDecimalThousandsSeparator moved to same new table
    // NPR5.50/BHR /20190410 CASE 348128 Rename field 274 (www.address)
    // NPR5.52/ALPO/20190926 CASE 368673 Active event (from Event Management module) on cash register. Copy dimension from event on selection
    // NPR5.53/ALPO/20191013 CASE 371955 Removed field 25 "Rounding": moved to "POS Posting Profile" (Table 6150653)
    // NPR5.53/ALPO/20191023 CASE 373743 Removed field 21 "Sales Ticket Series": moved to "POS Audit Profile" (Table 6150650)
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.53/ALPO/20191105 CASE 376035 Save active event on Sale POS, copy event's dimensions directly to the sale instead of overwriting pos unit dimensions

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
                //-NPR4.21
                RetailTableCode.RegisterCheckNo("Register No.");
                //+NPR4.21
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
        }
        field(6; "Balanced on Sales Ticket"; Code[20])
        {
            Caption = 'Balanced on Sales Ticket';
            DataClassification = CustomerContent;
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
            TableRelation = "NPR Register Types";
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

                //-NPR5.40 [309516]
                //InitialiserKasse;
                //+NPR5.40 [309516]
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
                //-NPR5.40 [309516]
                //InitialiserKasse;
                //+NPR5.40 [309516]
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

                //-NPR5.40 [309516]
                //InitialiserKasse;
                //+NPR5.40 [309516]
            end;
        }
        field(14; "Difference Account"; Code[20])
        {
            Caption = 'Difference Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                //-NPR5.40 [309516]
                //InitialiserKasse;
                //+NPR5.40 [309516]
            end;
        }
        field(15; "Balance Account"; Code[20])
        {
            Caption = 'Balance Account';
            DataClassification = CustomerContent;
            TableRelation = IF ("Balanced Type" = CONST(Finans)) "G/L Account"
            ELSE
            IF ("Balanced Type" = CONST(Bank)) "Bank Account";

            trigger OnValidate()
            begin
                //-NPR5.40 [309516]
                //InitialiserKasse;
                //+NPR5.40 [309516]
            end;
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
        }
        field(19; "VAT Gen. Business Post.Gr"; Code[10])
        {
            Caption = 'VAT Gen. Business Posting Group (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
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
                //-NPR5.43
                if DisplaySetup.Get("Register No.") then
                    if DisplaySetup.Activate then
                        Error(TXT001, "Register No.");
                //+NPR5.43
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
        }
        field(257; Address; Text[50])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(258; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(259; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.Reset;
                PostCode.SetRange(Code, "Post Code");
                if PostCode.Find('-') then
                    City := PostCode.City;
            end;
        }
        field(260; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(261; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
            DataClassification = CustomerContent;
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
            CalcFormula = Count ("NPR Audit Roll" WHERE("Register No." = FIELD("Register No."),
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
            CalcFormula = Sum ("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
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
            CalcFormula = Sum ("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
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
            CalcFormula = Count ("NPR Audit Roll" WHERE("Register No." = FIELD("Register No."),
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
            CalcFormula = Sum ("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
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
            CalcFormula = Sum ("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Date" = FIELD("Date Filter"),
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

            trigger OnValidate()
            var
                FromDefDim: Record "Default Dimension";
                ToDefDim: Record "Default Dimension";
            begin
                //-NPR5.53 [376035]-revoked
                /*
                //-NPR5.52 [368673]
                IF "Active Event No." <> '' THEN BEGIN
                  FromDefDim.SETRANGE("Table ID",DATABASE::Job);
                  FromDefDim.SETRANGE("No.","Active Event No.");
                  FromDefDim.SETFILTER("Dimension Code",'<>%1','');
                  FromDefDim.SETFILTER("Dimension Value Code",'<>%1','');
                  IF FromDefDim.FINDSET THEN
                    REPEAT
                      ToDefDim.INIT;
                      //ToDefDim."Table ID" := DATABASE::Register;  //NPR5.53 [371956]-revoked
                      ToDefDim."Table ID" := DATABASE::"POS Unit";  //NPR5.53 [371956]
                      ToDefDim."No." := "Register No.";
                      ToDefDim."Dimension Code" := FromDefDim."Dimension Code";
                      IF NOT ToDefDim.FIND THEN
                        ToDefDim.INSERT;
                      ToDefDim."Dimension Value Code" := FromDefDim."Dimension Value Code";
                      IF ToDefDim."Value Posting" = ToDefDim."Value Posting"::"No Code" THEN
                        ToDefDim."Value Posting" := ToDefDim."Value Posting"::" ";
                      ToDefDim.MODIFY;
                    UNTIL FromDefDim.NEXT = 0;
                  //DimMgt.UpdateDefaultDim(DATABASE::Register,"Register No.","Global Dimension 1 Code","Global Dimension 2 Code");  //NPR5.53 [371956]-revoked
                  //-NPR5.53 [371956]
                  POSUnit.GET("Register No.");
                  DimMgt.UpdateDefaultDim(DATABASE::"POS Unit",POSUnit."No.",POSUnit."Global Dimension 1 Code",POSUnit."Global Dimension 2 Code");
                  POSUnit.MODIFY;
                  //+NPR5.53 [371956]
                END;
                //+NPR5.52 [368673]
                */
                //+NPR5.53 [376035]-revoked

            end;
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

            trigger OnValidate()
            begin
                //-NPR5.46 [290734]
                //-MbP1.80
                //"MobilePay PoS Unit ID" := MobilePayPoSAPIIntegration.ResolvePoSUnitId("MobilePay PoS Unit ID");
                //+MbP1.80
                //+NPR5.46 [290734]
            end;
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
        //-NPR4.21
        AuditRoll.SetRange("Register No.", "Register No.");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        if AuditRoll.FindLast then begin
            if not Confirm(StrSubstNo(Text1060008, "Register No.", AuditRoll."Sale Date"), false) then
                Error('');
        end else begin
            if not Confirm(StrSubstNo(Text1060009, "Register No."), false) then
                Error('');
        end;
        //+NPR4.21
        DimMgt.DeleteDefaultDim(DATABASE::"NPR Register", "Register No.");
    end;

    trigger OnInsert()
    var
        RetailTableCode: Codeunit "NPR Retail Table Code";
    begin
        //-NPR4.21
        RetailTableCode.RegisterCheckNo("Register No.");
        //+NPR4.21

        // ERROR(Text1060000,Kassenummer);
        //DimMgt.UpdateDefaultDim( DATABASE::Register,"Register No.", "Global Dimension 1 Code","Global Dimension 2 Code");  //NPR5.53 [371956]-revoked

        "Connected To Server" := true;

        //-NPR5.49 [335739]
        /*
        //-NPR4.12
        DetectDecimalThousandsSeparator();
        //+NPR4.12
        */
        //+NPR5.49 [335739]

    end;

    trigger OnRename()
    begin
        Error(Text1060003, xRec."Register No.");
    end;

    var
        Text1060003: Label 'Register %1 cannot be renamed!';
        RetailSetup: Record "NPR Retail Setup";
        Environment: Codeunit "NPR Environment Mgt.";
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

        //-NPR4.21
        RetailTableCode.RegisterCheckNo(RegNo);
        //+NPR4.21

        Register.Init;
        Register."Register No." := RegNo;
        Register."Closing Cash" := Primo;
        Register."Opening Cash" := Primo;
        if CompInf.Get then begin
            Register.Name := CompInf.Name;
            Register.Address := CompInf.Address;
            Register.City := CompInf.City;
            Register."Post Code" := CompInf."Post Code";
            Register."Phone No." := CompInf."Phone No.";
            Register."Fax No." := CompInf."Fax No.";
            Register."Giro No." := CompInf."Giro No.";
            Register."Bank Name" := CompInf."Bank Name";
            Register."Bank Registration No." := CompInf."Bank Branch No.";
            Register."Bank Account No." := CompInf."Bank Account No.";
            Register."Automatic Payment No." := CompInf."Payment Routing No.";
            Register."VAT No." := CompInf."VAT Registration No.";
            Register."E-mail" := CompInf."E-Mail";
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
        //-NPR5.53 [371956]
        Error(CannotChangeHereLbl);
        //+NPR5.53 [371956]
    end;
}

