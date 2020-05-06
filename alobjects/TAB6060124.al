table 6060124 "MM Membership Setup"
{
    // MM80.1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM80.1.00/TSA/20151222  CASE 230109 Added "Ticket Item Barcode"
    // MM80.1.01/TSA/20151222  CASE 230149 NaviPartner Member Management
    // MM80.1.02/TSA/20151228  CASE 229980 Print Membercard
    // MM1.09/TSA/20160226  CASE 235634 Membership connection to Customer & Contacts, renamed "template customer no." to "Customer Template Code"
    // MM1.09/TSA/20160229  CASE 235812 Member Receipt Printing
    // MM1.10/TSA/20160321 CASE 234209 Show member details on membercard scan
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160523  CASE 240871 Notification Service field 60
    // MM1.17/TSA/20161214  CASE 243075 Member Point System added field "Loyalty Program" and "membership customer no." to be the price group customer when no crm
    // MM1.19/TSA/20170315  CASE 264882 Config Template instead of Customer Template
    // NPR5.33/MHA /20170608  CASE 279229 Added field 80 "Contact Config. Template Code"
    // MM1.21/TSA /20170719 CASE 276840 Add lookup field on member ticket reference
    // MM1.22/TSA /20170821 CASE 287080 Added option field "Anonymous Members"
    // MM1.25/TSA /20180115 CASE 299537 Added fields for template print and options
    // MM1.25/TSA /20180115 CASE 299537 Added different print alternatives for POS and WS
    // MM1.25/TSA /20180122 CASE 300256 Card Expire Date calculation selection
    // MM1.26/TSA /20180202 CASE 303876 Added Auto-Renew model and settings for Credit Limit checks
    // MM1.27/TSA /20180322 CASE 307113 Added field Community Membership Entry No. - when in community mode there can only be one membership actually...
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR related fields
    // #314131/TSA /20180517 CASE 314131 Added field "Activate NP Pass Integration"
    // MM1.32/TSA/20180725  CASE 318132 Transport MM1.32 - 25 July 2018
    // MM1.36/TSA /20181126 CASE 337110 Added Ticket Print option on member card swipe
    // MM1.43/TSA /20200317 CASE 337112 Changed spelling, "Ticket Print Model"::CONDENSED

    Caption = 'Membership Setup';
    DrillDownPageID = "MM Membership Setup";
    LookupPageID = "MM Membership Setup";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(11;"Membership Type";Option)
        {
            Caption = 'Membership Type';
            OptionCaption = 'Community,Group,Individual';
            OptionMembers = COMMUNITY,GROUP,INDIVIDUAL;
        }
        field(12;"Loyalty Card";Option)
        {
            Caption = 'Loyalty Card';
            OptionCaption = 'Yes,No';
            OptionMembers = YES,NO;
        }
        field(13;"Customer Config. Template Code";Code[10])
        {
            Caption = 'Customer Config. Template Code';
            Description = 'NPR5.33';
            TableRelation = "Config. Template Header" WHERE ("Table ID"=CONST(18));
        }
        field(14;"Member Information";Option)
        {
            Caption = 'Member Information';
            OptionCaption = 'Named,Anonymous';
            OptionMembers = NAMED,ANONYMOUS;
        }
        field(15;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(16;"Blocked At";DateTime)
        {
            Caption = 'Blocked At';
        }
        field(17;Perpetual;Boolean)
        {
            Caption = 'Perpetual';
        }
        field(18;"Member Role Assignment";Option)
        {
            Caption = 'Member Role Assignment';
            OptionCaption = 'Members Only,First Member is Admin,Admins Only';
            OptionMembers = MEMBERS_ONLY,FIRST_IS_ADMIN,ALL_ADMINS;
        }
        field(19;"Membership Member Cardinality";Integer)
        {
            Caption = 'Membership Member Cardinality';
        }
        field(20;"Community Code";Code[20])
        {
            Caption = 'Community Code';
            TableRelation = "MM Member Community";
        }
        field(21;"Create Welcome Notification";Boolean)
        {
            Caption = 'Create Welcome Notification';
        }
        field(22;"Receipt Print Object Type";Option)
        {
            Caption = 'Receipt Print Object Type';
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(23;"Receipt Print Object ID";Integer)
        {
            Caption = 'Receipt Print Object ID';
            TableRelation = IF ("Receipt Print Object Type"=CONST(CODEUNIT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Receipt Print Object Type"=CONST(REPORT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(25;"Allow Membership Delete";Boolean)
        {
            Caption = 'Allow Membership Delete';
        }
        field(26;"Confirm Member On Card Scan";Boolean)
        {
            Caption = 'Confirm Member On Card Scan';
        }
        field(27;"Loyalty Code";Code[20])
        {
            Caption = 'Loyalty Code';
            TableRelation = "MM Loyalty Setup";
        }
        field(30;"Card Number Scheme";Option)
        {
            Caption = 'Card Number Scheme';
            OptionCaption = ' ,Generated,External';
            OptionMembers = NA,GENERATED,EXTERNAL;
        }
        field(31;"Card Number Prefix";Code[10])
        {
            Caption = 'Card Number Prefix';
        }
        field(32;"Card Number Length";Integer)
        {
            Caption = 'Card Number Length';
        }
        field(33;"Card Number Validation";Option)
        {
            Caption = 'Card Number Validation';
            OptionCaption = ' ,Check Digit';
            OptionMembers = "NONE",CHECKDIGIT;
        }
        field(34;"Card Number No. Series";Code[10])
        {
            Caption = 'Card Number No. Series';
            TableRelation = "No. Series";
        }
        field(35;"Card Number Valid Until";DateFormula)
        {
            Caption = 'Card Number Valid Until';
        }
        field(37;"Card Number Pattern";Code[30])
        {
            Caption = 'Card Number Pattern';
        }
        field(38;"Card Print Object Type";Option)
        {
            Caption = 'Card Print Object Type';
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(39;"Card Print Object ID";Integer)
        {
            Caption = 'Card Print Object ID';
            TableRelation = IF ("Card Print Object Type"=CONST(CODEUNIT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Card Print Object Type"=CONST(REPORT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(40;"Ticket Item Barcode";Code[20])
        {
            Caption = 'Ticket Item Barcode';
            TableRelation = "Item Cross Reference"."Cross-Reference No." WHERE ("Cross-Reference Type"=CONST("Bar Code"));
        }
        field(41;"Ticket Print Model";Option)
        {
            Caption = 'Ticket Print Model';
            OptionCaption = 'Individual,Condensed';
            OptionMembers = INDIVIDUAL,CONDENSED;
        }
        field(42;"Ticket Print Object Type";Option)
        {
            Caption = 'Ticket Print Object Type';
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(43;"Ticket Print Object ID";Integer)
        {
            Caption = 'Ticket Print Object ID';
            TableRelation = IF ("Card Print Object Type"=CONST(CODEUNIT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Card Print Object Type"=CONST(REPORT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(44;"Ticket Print Template Code";Code[20])
        {
            Caption = 'Ticket Print Template Code';
            TableRelation = "RP Template Header";
        }
        field(50;"Account Print Object Type";Option)
        {
            Caption = 'Account Print Object Type';
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(51;"Account Print Object ID";Integer)
        {
            Caption = 'Account Print Object ID';
            TableRelation = IF ("Account Print Object Type"=CONST(CODEUNIT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Account Print Object Type"=CONST(REPORT)) AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(60;"Create Renewal Notifications";Boolean)
        {
            Caption = 'Create Renewal Notifications';
        }
        field(70;"Membership Customer No.";Code[20])
        {
            Caption = 'Membership Customer No.';
            TableRelation = Customer;
        }
        field(75;"Community Membership Entry No.";Integer)
        {
            Caption = 'Community Membership Entry No.';
        }
        field(80;"Contact Config. Template Code";Code[10])
        {
            Caption = 'Contact Config. Template Code';
            Description = 'NPR5.33';
            TableRelation = "Config. Template Header" WHERE ("Table ID"=CONST(5050));
        }
        field(90;"Anonymous Member Cardinality";Option)
        {
            Caption = 'Anonymous Member Cardinality';
            OptionCaption = 'Unlimited,Limited';
            OptionMembers = UNLIMITED,LIMITED;
        }
        field(100;"Card Print Template Code";Code[20])
        {
            Caption = 'Card Print Template Code';
            TableRelation = "RP Template Header";
        }
        field(101;"Receipt Print Template Code";Code[20])
        {
            Caption = 'Receipt Print Template Code';
            TableRelation = "RP Template Header";
        }
        field(102;"Account Print Template Code";Code[20])
        {
            Caption = 'Account Print Template Code';
            TableRelation = "RP Template Header";
        }
        field(120;"Web Service Print Action";Option)
        {
            Caption = 'Web Service Print Action';
            OptionCaption = 'Off,Direct,Offline';
            OptionMembers = NA,DIRECT,OFFLINE;
        }
        field(125;"POS Print Action";Option)
        {
            Caption = 'POS Print Action';
            InitValue = DIRECT;
            OptionCaption = 'Direct,Offline,Off';
            OptionMembers = DIRECT,OFFLINE,NA;
        }
        field(130;"Card Expire Date Calculation";Option)
        {
            Caption = 'Card Expire Date Calculation';
            OptionCaption = 'Date Formula,Synchronized,Not Applicable';
            OptionMembers = DATEFORMULA,SYNCHRONIZED,NA;
        }
        field(140;"Auto-Renew Model";Option)
        {
            Caption = 'Auto-Renew Model';
            OptionCaption = 'Invoice,Recurring Payment,Customer Balance';
            OptionMembers = INVOICE,RECURRING_PAYMENT,CUSTOMER_BALANCE;
        }
        field(142;"Credit Limit Check";Option)
        {
            Caption = 'Credit Limit Check';
            OptionCaption = 'None,Balance Amount,Overdue Amount';
            OptionMembers = "NONE",BALANCE,OVERDUE;
        }
        field(144;"Credit Limit (LCY)";Decimal)
        {
            Caption = 'Credit Limit (LCY)';
        }
        field(145;"Overdue Credit Limit (LCY)";Decimal)
        {
            Caption = 'Overdue Credit Limit (LCY)';
        }
        field(150;"Recurring Payment Code";Code[10])
        {
            Caption = 'Recurring Payment Code';
            TableRelation = "MM Recurring Payment Setup";
        }
        field(400;"Enable NP Pass Integration";Boolean)
        {
            Caption = 'Enable NP Pass Integration';
        }
        field(500;"GDPR Mode";Option)
        {
            Caption = 'GDPR Mode';
            OptionCaption = ' ,Implied,Required,Consent';
            OptionMembers = NA,IMPLIED,REQUIRED,CONSENT;

            trigger OnValidate()
            var
                GDPRManagement: Codeunit "MM GDPR Management";
            begin

                //-MM1.29 [313795]
                if (not Confirm (UPDATE_GDPR, false)) then
                  Error ('');

                GDPRManagement.OnMembershipGDPRModeChangeWorker (Code, xRec."GDPR Mode", Rec."GDPR Mode");
                //+MM1.29 [313795]
            end;
        }
        field(510;"GDPR Agreement No.";Code[20])
        {
            Caption = 'GDPR Agreement No.';
            TableRelation = "GDPR Agreement";

            trigger OnValidate()
            var
                GDPRManagement: Codeunit "MM GDPR Management";
            begin

                //-MM1.29 [313795]
                if (not Confirm (UPDATE_GDPR, false)) then
                  Error ('');

                GDPRManagement.OnMembershipGDPRAgreementChangeWorker (Code, xRec."GDPR Agreement No.", Rec."GDPR Agreement No.");
                //+MM1.29 [313795]
            end;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MMMembershipAdmissionSetup: Record "MM Membership Admission Setup";
    begin
        MMMembershipAdmissionSetup.SetFilter ("Membership  Code", '=%1', Code);
        if (MMMembershipAdmissionSetup.FindSet ()) then
          MMMembershipAdmissionSetup.DeleteAll (true);
    end;

    var
        UPDATE_GDPR: Label 'Changing the GDPR conditions for the membership setup will forcefully update all membership. Do you want to continue?';
}

