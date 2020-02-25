table 6150676 "Upgrade Register"
{
    // [VLOBJUPG] Object may be deleted after upgrade
    // NPR5.53/ALPO/20191017 CASE 371955 Rounding related fields moved to POS Posting Profiles
    // NPR5.53/ALPO/20191022 CASE 373743 Field 21 "Sales Ticket Series" moved to "POS Audit Profile"

    Caption = 'Cash Register';
    LookupPageID = "Register List";
    Permissions = ;

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Status;Option)
        {
            Caption = 'Status';
            FieldClass = Normal;
            InitValue = " ";
            OptionCaption = ' ,Sale,Balanced,Doing Balancing';
            OptionMembers = " ",Ekspedition,Afsluttet,"Under afslutning";
        }
        field(3;"Opening Cash";Decimal)
        {
            Caption = 'Opening Cash';
        }
        field(4;"Closing Cash";Decimal)
        {
            Caption = 'Closing Cash';
        }
        field(5;Balanced;Date)
        {
            Caption = 'Balanced';
        }
        field(6;"Balanced on Sales Ticket";Code[20])
        {
            Caption = 'Balanced on Sales Ticket';
        }
        field(7;"Opened Date";Date)
        {
            Caption = 'Opened Date';
        }
        field(8;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(9;"Register Type";Code[10])
        {
            Caption = 'Register Type';
            TableRelation = "Register Types";
        }
        field(11;Account;Code[20])
        {
            Caption = 'Account';
            NotBlank = true;
            TableRelation = "G/L Account"."No.";
        }
        field(12;"Gift Voucher Account";Code[20])
        {
            Caption = 'Gift Voucher Account';
            NotBlank = true;
            TableRelation = "G/L Account"."No.";
        }
        field(13;"Credit Voucher Account";Code[20])
        {
            Caption = 'Credit Voucher Account';
            TableRelation = "G/L Account";
        }
        field(14;"Difference Account";Code[20])
        {
            Caption = 'Difference Account';
            TableRelation = "G/L Account";
        }
        field(15;"Balance Account";Code[20])
        {
            Caption = 'Balance Account';
            TableRelation = IF ("Balanced Type"=CONST(Finans)) "G/L Account"
                            ELSE IF ("Balanced Type"=CONST(Bank)) "Bank Account";
        }
        field(16;"Difference Account - Neg.";Code[20])
        {
            Caption = 'Difference Account - Neg.';
            TableRelation = "G/L Account";
        }
        field(17;"Gift Voucher Discount Account";Code[20])
        {
            Caption = 'Gift Voucher Discount Account';
            NotBlank = true;
            TableRelation = "G/L Account"."No.";
        }
        field(18;"Gen. Business Posting Group";Code[10])
        {
            Caption = 'Gen. Business Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(19;"VAT Gen. Business Post.Gr";Code[10])
        {
            Caption = 'VAT Gen. Business Posting Group (Price)';
            TableRelation = "VAT Business Posting Group";
        }
        field(21;"Sales Ticket Series";Code[10])
        {
            Caption = 'Sales Ticket Series';
            TableRelation = "No. Series";
        }
        field(22;"Status Set By Sales Ticket";Code[20])
        {
            Caption = 'Status set by Sales Ticket';
        }
        field(23;"Name 2";Text[50])
        {
            Caption = 'Name 2';
        }
        field(25;Rounding;Code[20])
        {
            Caption = 'Rounding';
            Description = 'Kontonummer til �reafrunding.';
            TableRelation = "G/L Account"."No." WHERE (Blocked=CONST(false));
        }
        field(26;"Register Change Account";Code[20])
        {
            Caption = 'Register Change Account';
            TableRelation = "G/L Account"."No.";
        }
        field(27;"City Gift Voucher Account";Code[20])
        {
            Caption = 'City gift voucher account';
            TableRelation = "G/L Account";
        }
        field(28;"City Gift Voucher Discount";Code[20])
        {
            Caption = 'City Gift Voucher Discount';
            TableRelation = "G/L Account";
        }
        field(47;"Change Register";Decimal)
        {
            Caption = 'Change Register';
        }
        field(79;"Opened By Salesperson";Code[20])
        {
            Caption = 'Opened By Salesperson';
        }
        field(80;"Opened on Sales Ticket";Code[20])
        {
            Caption = 'Opened on Sales Ticket';
        }
        field(81;"Use Sales Statistics";Boolean)
        {
            Caption = 'Use Sales Statistics';
        }
        field(90;"Date Filter";Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(91;"Global Dimension 1 Filter";Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(92;"Global Dimension 2 Filter";Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(100;"Customer Display";Boolean)
        {
            Caption = 'Customer Display';
        }
        field(101;"Credit Card";Boolean)
        {
            Caption = 'Credit Card';
        }
        field(103;"Credit Card Solution";Option)
        {
            Caption = 'Credit Card Solution';
            OptionCaption = ' ,01,02,03,04,05,06 - POINT,07,08,Steria,10 - SAGEM Flexiterm .NET,SAGEM Flexiterm JavaScript,Pepper';
            OptionMembers = " ","MSP DOS","MSP Navision",OCC,"SAGEM Flexiterminal","SAGEM Flexiterm via console",POINT,TPOS3,"SAGEM Flexitermina from server",Steria,"SAGEM Flexiterm .NET","SAGEM Flexiterm JavaScript",Pepper;
        }
        field(150;"Primary Payment Type";Code[10])
        {
            Caption = 'Primary Payment Type';
            TableRelation = "Payment Type POS"."No." WHERE (Status=CONST(Active));
        }
        field(160;"Return Payment Type";Code[10])
        {
            Caption = 'Return Payment Type';
            TableRelation = "Payment Type POS"."No." WHERE (Status=CONST(Active));
        }
        field(250;"Display 1";Text[20])
        {
            Caption = 'Display 1';
        }
        field(251;"Display 2";Text[20])
        {
            Caption = 'Display 2';
        }
        field(252;Touchscreen;Boolean)
        {
            Caption = 'Touch Screen';
        }
        field(255;"Connected To Server";Boolean)
        {
            Caption = 'Connected to Server';
        }
        field(256;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(257;Address;Text[50])
        {
            Caption = 'Address';
        }
        field(258;City;Text[50])
        {
            Caption = 'City';
        }
        field(259;"Post Code";Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(260;"Phone No.";Text[30])
        {
            Caption = 'Phone No.';
        }
        field(261;"Fax No.";Text[30])
        {
            Caption = 'Fax No.';
        }
        field(262;"Giro No.";Text[20])
        {
            Caption = 'Giro No.';
        }
        field(263;"Bank Name";Text[50])
        {
            Caption = 'Bank Name';
        }
        field(264;"Bank Registration No.";Text[20])
        {
            Caption = 'Bank Registration No.';
        }
        field(265;"Bank Account No.";Text[30])
        {
            Caption = 'Bank Account No.';
        }
        field(266;"Automatic Payment No.";Text[20])
        {
            Caption = 'Automatic Payment No.';
        }
        field(267;"VAT No.";Text[20])
        {
            Caption = 'VAT No.';
        }
        field(268;"E-mail";Text[80])
        {
            Caption = 'E-mail';
        }
        field(270;"Logon-User Name";Code[20])
        {
            Caption = 'Logon-User Name';
        }
        field(271;"Sales Ticket Print Output";Option)
        {
            Caption = 'Sales Ticket Print-Out';
            OptionCaption = 'STANDARD,ASK LARGE,NEVER,CUSTOMER,DEVELOPMENT';
            OptionMembers = STANDARD,"ASK LARGE",NEVER,CUSTOMER,DEVELOPMENT;
        }
        field(273;"Sales Ticket Email Output";Option)
        {
            Caption = 'Sales Ticket Email Output';
            OptionCaption = 'None,Auto,Prompt,Prompt With Print Overrule';
            OptionMembers = "None",Auto,Prompt,"Prompt With Print Overrule";
        }
        field(274;Website;Text[50])
        {
            Caption = 'Website';
        }
        field(277;CloseOnRegBal;Boolean)
        {
            Caption = 'Close Terminal at Register Balance';
        }
        field(300;"Sales Ticket Line Text off";Option)
        {
            Caption = 'Sales Ticket Line Text off';
            OptionCaption = 'NP Config,Register,Comment Line';
            OptionMembers = "NP Config",Register,Comment;
        }
        field(301;"Sales Ticket Line Text1";Code[50])
        {
            Caption = 'Sales Ticket Line Text1';
        }
        field(302;"Sales Ticket Line Text2";Code[50])
        {
            Caption = 'Sales Ticket Line Text2';
        }
        field(303;"Sales Ticket Line Text3";Code[50])
        {
            Caption = 'Sales Ticket Line Text3';
        }
        field(304;"Sales Ticket Line Text4";Code[50])
        {
            Caption = 'Sales Ticket Line Text 4';
        }
        field(305;"Sales Ticket Line Text5";Code[50])
        {
            Caption = 'Sales Ticket Line Text 5';
        }
        field(306;"Sales Ticket Line Text6";Code[50])
        {
            Caption = 'Sales Ticket Line Text6';
        }
        field(307;"Sales Ticket Line Text7";Code[50])
        {
            Caption = 'Sales Ticket Line Text7';
        }
        field(308;"Sales Ticket Line Text8";Code[50])
        {
            Caption = 'Sales Ticket Line Text8';
        }
        field(309;"Sales Ticket Line Text9";Code[50])
        {
            Caption = 'Sales Ticket Line Text9';
        }
        field(316;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(317;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(325;"Customer Disc. Group";Code[20])
        {
            Caption = 'Customer Disc. Group';
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
        }
        field(328;"Customer Price Group";Code[10])
        {
            Caption = 'Item price group';
            TableRelation = "Customer Price Group";
        }
        field(329;"Balanced Type";Option)
        {
            Caption = 'Balanced Type';
            OptionCaption = 'Finance,Bank';
            OptionMembers = Finans,Bank;
        }
        field(330;"Receipt Printer Type";Option)
        {
            Caption = 'Receipt Printer Type';
            OptionCaption = 'TM-T88,Samsung,Star';
            OptionMembers = "TM-T88",Samsung,Star;
        }
        field(340;"Send Receipt Logo from NAV";Boolean)
        {
            Caption = 'Send Receipt Logo from NAV';
        }
        field(402;"Attendance Count in Audit Roll";Integer)
        {
            CalcFormula = Count("Audit Roll" WHERE ("Register No."=FIELD("Register No."),
                                                    "Sales Ticket No."=FIELD("Sales Ticket Filter"),
                                                    "Sale Type"=CONST(Sale),
                                                    "Line No."=CONST(1),
                                                    "Sale Date"=FIELD("Date Filter"),
                                                    "Salesperson Code"=FIELD("Sales Person Filter"),
                                                    "Shortcut Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                    "Shortcut Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Attendance Count in Audit Roll';
            FieldClass = FlowField;
        }
        field(403;"Normal Sales in Audit Roll";Decimal)
        {
            CalcFormula = Sum("Audit Roll"."Amount Including VAT" WHERE ("Sale Date"=FIELD("Date Filter"),
                                                                         "Register No."=FIELD("Register No."),
                                                                         "Sale Type"=CONST(Sale),
                                                                         Type=CONST(Item),
                                                                         "Salesperson Code"=FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Normal Sales in Audit Roll';
            FieldClass = FlowField;
        }
        field(404;"Debit Sales in Audit Roll";Decimal)
        {
            CalcFormula = Sum("Audit Roll"."Amount Including VAT" WHERE ("Sale Date"=FIELD("Date Filter"),
                                                                         "Register No."=FIELD("Register No."),
                                                                         "Sale Type"=CONST("Debit Sale"),
                                                                         "Gift voucher ref."=FILTER(=''),
                                                                         "Salesperson Code"=FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Dabit Sales in Audit Roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(410;"Item Count in Audit Roll Debit";Integer)
        {
            CalcFormula = Count("Audit Roll" WHERE ("Register No."=FIELD("Register No."),
                                                    "Sales Ticket No."=FIELD("Sales Ticket Filter"),
                                                    Type=CONST("Debit Sale"),
                                                    "Line No."=CONST(2),
                                                    "Gift voucher ref."=FILTER(=''),
                                                    "No."=FIELD("Sales Ticket Filter"),
                                                    "Sale Date"=FIELD("Date Filter"),
                                                    "Salesperson Code"=FIELD("Sales Person Filter"),
                                                    "Shortcut Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                    "Shortcut Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Item Count in Audit Debit Roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(411;"Sales Ticket Filter";Code[20])
        {
            Caption = 'Sales Ticket Filter';
            FieldClass = FlowFilter;
        }
        field(412;"Sales Person Filter";Code[20])
        {
            Caption = 'Sales Person Filter';
            FieldClass = FlowFilter;
        }
        field(414;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(417;"Balancing every";Option)
        {
            Caption = 'Registerstatement';
            OptionCaption = 'Day before 00:00pm,Manual';
            OptionMembers = Day,Manual;
        }
        field(503;"All Normal Sales in Audit Roll";Decimal)
        {
            CalcFormula = Sum("Audit Roll"."Amount Including VAT" WHERE ("Sale Date"=FIELD("Date Filter"),
                                                                         "Sale Type"=CONST(Sale),
                                                                         Type=CONST(Item),
                                                                         "Salesperson Code"=FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Normal Sales in Audit Roll';
            FieldClass = FlowField;
        }
        field(504;"All Debit Sales in Audit Roll";Decimal)
        {
            CalcFormula = Sum("Audit Roll"."Amount Including VAT" WHERE ("Sale Date"=FIELD("Date Filter"),
                                                                         "Sale Type"=CONST("Debit Sale"),
                                                                         Type=CONST(Item),
                                                                         "Gift voucher ref."=FILTER(=''),
                                                                         "Salesperson Code"=FIELD("Sales Person Filter"),
                                                                         "Shortcut Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                         "Shortcut Dimension 2 Code"=FIELD("Global Dimension 2 Filter")));
            Caption = 'Dabit Sales in Audit Roll';
            Description = 'Calcformula rettet';
            FieldClass = FlowField;
        }
        field(512;"End of day - Exchange Amount";Boolean)
        {
            Caption = 'Exchange Amount';
        }
        field(513;"Customer No. auto debit sale";Option)
        {
            Caption = 'Ask for customer';
            OptionCaption = ' ,Auto,Ask payment,Ask debit';
            OptionMembers = " ",Auto,AskPayment,AskDebit;
        }
        field(515;"Money drawer attached";Boolean)
        {
            Caption = 'Money drawer attached';
            InitValue = true;
        }
        field(520;"Lock Register To Salesperson";Boolean)
        {
            Caption = 'Lock Register To Salesperson';
        }
        field(604;"Use Fee";Boolean)
        {
            Caption = 'Use fee';
        }
        field(605;"Confirm Fee";Boolean)
        {
            Caption = 'Confirm Fee';
        }
        field(609;"Gen. Business Posting Override";Option)
        {
            Caption = 'Gen. Business Posting Override';
            OptionCaption = 'Customer,Register';
            OptionMembers = Register,Customer;
        }
        field(610;"Terminal Auto Print";Boolean)
        {
            Caption = 'Terminal Auto Print';
        }
        field(611;"Money drawer - open on special";Boolean)
        {
            Caption = 'Money drawer at debit/credit card';
        }
        field(620;"Exchange Label Exchange Period";DateFormula)
        {
            Caption = 'Exchange Label Exchange Period';
        }
        field(630;"Enable Contactless";Boolean)
        {
            Caption = 'Enable Contactless';
        }
        field(700;"Tax Free Enabled";Boolean)
        {
            Caption = 'Tax Free Enabled';
        }
        field(701;"Tax Free Merchant ID";Text[20])
        {
            Caption = 'Tax Free Merchant ID';
        }
        field(702;"Tax Free VAT Number";Text[20])
        {
            Caption = 'Tax Free VAT Number';
        }
        field(703;"Tax Free Country Code";Text[3])
        {
            Caption = 'Tax Free Country Code';
        }
        field(704;"Tax Free Amount Threshold";Decimal)
        {
            Caption = 'Tax Free Amount Threshold';
        }
        field(705;"Tax Free Check Terminal Prefix";Boolean)
        {
            Caption = 'Tax Free Check Terminal Prefix';
        }
        field(790;"Register Layout";Code[20])
        {
            Caption = 'Register Layout';
            TableRelation = "Touch Screen - Layout";
        }
        field(830;"Encrypt Protocol Data";Boolean)
        {
            Caption = 'Encrypt Protocol Data';
            Description = 'CASE 226832';
        }
        field(831;"Secure Protocol Data";Boolean)
        {
            Caption = 'Secure Protocol Data';
            Description = 'CASE 226832';
        }
        field(832;"Install Client-side Assemblies";Boolean)
        {
            Caption = 'Install Client-side Assemblies';
            Description = 'CASE 226832';
        }
        field(834;"Skip Infobox Update in Sale";Boolean)
        {
            Caption = 'Skip Infobox Update in Sale';
            Description = 'NPR5.28';
        }
        field(850;"VAT Customer No.";Code[20])
        {
            Caption = 'VAT Customer No.';
            Description = 'NPR5.36';
            TableRelation = Customer;
        }
        field(855;"Touch Screen Login Type";Option)
        {
            BlankNumbers = DontBlank;
            Caption = 'Login Type';
            OptionCaption = 'Automatic,Quick Buttons,Normal Numeric,Never';
            OptionMembers = Automatic,Quick,"Normal Numeric",Never;
        }
        field(860;"Touch Screen Customerclub";Option)
        {
            Caption = 'Touch Screen Customerclub';
            OptionCaption = 'Functions,Invoice Customer,Contact';
            OptionMembers = Functions,"Invoice Customer",Contact;
        }
        field(865;"Touch Screen Connected";Boolean)
        {
            Caption = 'Touch screen connection';
        }
        field(870;"Touch Screen Credit Card";Code[10])
        {
            Caption = 'Credit card button';
            TableRelation = "Payment Type POS";
        }
        field(875;"Touch Screen Extended info";Boolean)
        {
            Caption = 'Touch Screen Auto Unwrap If Single';
        }
        field(880;"Touch Screen Login autopopup";Boolean)
        {
            Caption = 'Login - Auto popup';
        }
        field(885;"Touch Screen Terminal Offline";Code[10])
        {
            Caption = 'Credit card offline';
            TableRelation = "Payment Type POS";
        }
        field(890;"Shop id";Code[20])
        {
            Caption = 'Shop id';
        }
        field(900;"Active Event No.";Code[20])
        {
            Caption = 'Active Event No.';
            Description = 'NPR5.52 [368673]';
            TableRelation = Job WHERE (Event=CONST(true));
        }
        field(6184471;"MobilePay Payment Type";Code[10])
        {
            Caption = 'MobilePay Payment Type';
            Description = 'MbP1.80';
            TableRelation = "Payment Type POS";
        }
        field(6184472;"MobilePay Location ID";Code[20])
        {
            Caption = 'MobilePay Location ID';
            Description = 'MbP1.80';
        }
        field(6184473;"MobilePay PoS ID";Text[50])
        {
            Caption = 'MobilePay PoS ID';
            Description = 'MbP1.80';
        }
        field(6184474;"MobilePay PoS Unit ID";Code[20])
        {
            Caption = 'MobilePay PoS Unit ID';
            Description = 'MbP1.80';
        }
        field(6184475;"MobilePay PoS Registered";Boolean)
        {
            Caption = 'MobilePay PoS Registered';
            Description = 'MbP1.80';
        }
        field(6184476;"MobilePay PoS Unit Assigned";Boolean)
        {
            Caption = 'MobilePay PoS Unit Assigned';
            Description = 'MbP1.80';
        }
        field(6184491;"mPos Payment Type";Code[10])
        {
            Caption = 'mPos Payment Type';
            Description = 'NPR5.29';
            TableRelation = "Payment Type POS";
        }
    }

    keys
    {
        key(Key1;"Register No.")
        {
            SumIndexFields = "Opening Cash";
        }
        key(Key2;"Logon-User Name")
        {
        }
        key(Key3;Status)
        {
        }
    }

    fieldgroups
    {
    }
}

