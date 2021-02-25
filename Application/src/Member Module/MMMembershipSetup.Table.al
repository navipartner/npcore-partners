table 6060124 "NPR MM Membership Setup"
{

    Caption = 'Membership Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Membership Setup";
    LookupPageID = "NPR MM Membership Setup";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Membership Type"; Option)
        {
            Caption = 'Membership Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Community,Group,Individual';
            OptionMembers = COMMUNITY,GROUP,INDIVIDUAL;
        }
        field(12; "Loyalty Card"; Option)
        {
            Caption = 'Loyalty Card';
            DataClassification = CustomerContent;
            OptionCaption = 'Yes,No';
            OptionMembers = YES,NO;
        }
        field(13; "Customer Config. Template Code"; Code[10])
        {
            Caption = 'Customer Config. Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.33';
            TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(18));
        }
        field(14; "Member Information"; Option)
        {
            Caption = 'Member Information';
            DataClassification = CustomerContent;
            OptionCaption = 'Named,Anonymous';
            OptionMembers = NAMED,ANONYMOUS;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(16; "Blocked At"; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = CustomerContent;
        }
        field(17; Perpetual; Boolean)
        {
            Caption = 'Perpetual';
            DataClassification = CustomerContent;
        }
        field(18; "Member Role Assignment"; Option)
        {
            Caption = 'Member Role Assignment';
            DataClassification = CustomerContent;
            OptionCaption = 'Members Only,First Member is Admin,Admins Only';
            OptionMembers = MEMBERS_ONLY,FIRST_IS_ADMIN,ALL_ADMINS;
        }
        field(19; "Membership Member Cardinality"; Integer)
        {
            Caption = 'Membership Member Cardinality';
            DataClassification = CustomerContent;
        }
        field(20; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(21; "Create Welcome Notification"; Boolean)
        {
            Caption = 'Create Welcome Notification';
            DataClassification = CustomerContent;
        }
        field(22; "Receipt Print Object Type"; Option)
        {
            Caption = 'Receipt Print Object Type';
            DataClassification = CustomerContent;
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(23; "Receipt Print Object ID"; Integer)
        {
            Caption = 'Receipt Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF ("Receipt Print Object Type" = CONST(CODEUNIT)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("Receipt Print Object Type" = CONST(REPORT)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(25; "Allow Membership Delete"; Boolean)
        {
            Caption = 'Allow Membership Delete';
            DataClassification = CustomerContent;
        }
        field(26; "Confirm Member On Card Scan"; Boolean)
        {
            Caption = 'Confirm Member On Card Scan';
            DataClassification = CustomerContent;
        }
        field(27; "Loyalty Code"; Code[20])
        {
            Caption = 'Loyalty Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Setup";
        }
        field(28; "Enable Age Verification"; Boolean)
        {
            Caption = 'Enable Age Verification';
            DataClassification = CustomerContent;
        }
        field(29; "Validate Age Against"; Option)
        {
            Caption = 'Validate Age Against';
            DataClassification = CustomerContent;
            OptionCaption = 'Sales Date (Year),Period Begin (Year),Period End (Year),Sales Date (Year+Month),Period Begin (Year+Month),Period End (Year+Month),Sales Date (Year+Month+Day),Period Begin (Year+Month+Day),Period End (Year+Month+Day)';
            OptionMembers = SALESDATE_Y,PERIODBEGIN_Y,PERIODEND_Y,SALESDATE_YM,PERIODBEGIN_YM,PERIODEND_YM,SALESDATE_YMD,PERIODBEGIN_YMD,PERIODEND_YMD;
        }
        field(30; "Card Number Scheme"; Option)
        {
            Caption = 'Card Number Scheme';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Generated,External';
            OptionMembers = NA,GENERATED,EXTERNAL;
        }
        field(31; "Card Number Prefix"; Code[10])
        {
            Caption = 'Card Number Prefix';
            DataClassification = CustomerContent;
        }
        field(32; "Card Number Length"; Integer)
        {
            Caption = 'Card Number Length';
            DataClassification = CustomerContent;
        }
        field(33; "Card Number Validation"; Option)
        {
            Caption = 'Card Number Validation';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Check Digit';
            OptionMembers = "NONE",CHECKDIGIT;
        }
        field(34; "Card Number No. Series"; Code[20])
        {
            Caption = 'Card Number No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(35; "Card Number Valid Until"; DateFormula)
        {
            Caption = 'Card Number Valid Until';
            DataClassification = CustomerContent;
        }
        field(37; "Card Number Pattern"; Code[30])
        {
            Caption = 'Card Number Pattern';
            DataClassification = CustomerContent;
        }
        field(38; "Card Print Object Type"; Option)
        {
            Caption = 'Card Print Object Type';
            DataClassification = CustomerContent;
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(39; "Card Print Object ID"; Integer)
        {
            Caption = 'Card Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF ("Card Print Object Type" = CONST(CODEUNIT)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("Card Print Object Type" = CONST(REPORT)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(40; "Ticket Item Barcode"; Code[50])
        {
            Caption = 'Ticket Item Barcode';
            DataClassification = CustomerContent;
            TableRelation = "Item Reference"."Reference No." WHERE("Reference Type" = CONST("Bar Code"));
        }
        field(41; "Ticket Print Model"; Option)
        {
            Caption = 'Ticket Print Model';
            DataClassification = CustomerContent;
            OptionCaption = 'Individual,Condensed';
            OptionMembers = INDIVIDUAL,CONDENSED;
        }
        field(42; "Ticket Print Object Type"; Option)
        {
            Caption = 'Ticket Print Object Type';
            DataClassification = CustomerContent;
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(43; "Ticket Print Object ID"; Integer)
        {
            Caption = 'Ticket Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF ("Card Print Object Type" = CONST(CODEUNIT)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("Card Print Object Type" = CONST(REPORT)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(44; "Ticket Print Template Code"; Code[20])
        {
            Caption = 'Ticket Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header";
        }
        field(50; "Account Print Object Type"; Option)
        {
            Caption = 'Account Print Object Type';
            DataClassification = CustomerContent;
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(51; "Account Print Object ID"; Integer)
        {
            Caption = 'Account Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF ("Account Print Object Type" = CONST(CODEUNIT)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("Account Print Object Type" = CONST(REPORT)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(60; "Create Renewal Notifications"; Boolean)
        {
            Caption = 'Create Renewal Notifications';
            DataClassification = CustomerContent;
        }
        field(70; "Membership Customer No."; Code[20])
        {
            Caption = 'Membership Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(75; "Community Membership Entry No."; Integer)
        {
            Caption = 'Community Membership Entry No.';
            DataClassification = CustomerContent;
        }
        field(80; "Contact Config. Template Code"; Code[10])
        {
            Caption = 'Contact Config. Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.33';
            TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(5050));
        }
        field(90; "Anonymous Member Cardinality"; Option)
        {
            Caption = 'Anonymous Member Cardinality';
            DataClassification = CustomerContent;
            OptionCaption = 'Unlimited,Limited';
            OptionMembers = UNLIMITED,LIMITED;
        }
        field(100; "Card Print Template Code"; Code[20])
        {
            Caption = 'Card Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header";
        }
        field(101; "Receipt Print Template Code"; Code[20])
        {
            Caption = 'Receipt Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header";
        }
        field(102; "Account Print Template Code"; Code[20])
        {
            Caption = 'Account Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header";
        }
        field(120; "Web Service Print Action"; Option)
        {
            Caption = 'Web Service Print Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Off,Direct,Offline';
            OptionMembers = NA,DIRECT,OFFLINE;
        }
        field(125; "POS Print Action"; Option)
        {
            Caption = 'POS Print Action';
            DataClassification = CustomerContent;
            InitValue = DIRECT;
            OptionCaption = 'Direct,Offline,Off';
            OptionMembers = DIRECT,OFFLINE,NA;
        }
        field(130; "Card Expire Date Calculation"; Option)
        {
            Caption = 'Card Expire Date Calculation';
            DataClassification = CustomerContent;
            OptionCaption = 'Date Formula,Synchronized,Not Applicable';
            OptionMembers = DATEFORMULA,SYNCHRONIZED,NA;
            InitValue = NA;
        }
        field(140; "Auto-Renew Model"; Option)
        {
            Caption = 'Auto-Renew Model';
            DataClassification = CustomerContent;
            OptionCaption = 'Invoice,Recurring Payment,Customer Balance';
            OptionMembers = INVOICE,RECURRING_PAYMENT,CUSTOMER_BALANCE;
        }
        field(142; "Credit Limit Check"; Option)
        {
            Caption = 'Credit Limit Check';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Balance Amount,Overdue Amount';
            OptionMembers = "NONE",BALANCE,OVERDUE;
        }
        field(144; "Credit Limit (LCY)"; Decimal)
        {
            Caption = 'Credit Limit (LCY)';
            DataClassification = CustomerContent;
        }
        field(145; "Overdue Credit Limit (LCY)"; Decimal)
        {
            Caption = 'Overdue Credit Limit (LCY)';
            DataClassification = CustomerContent;
        }
        field(150; "Recurring Payment Code"; Code[10])
        {
            Caption = 'Recurring Payment Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Recur. Paym. Setup";
        }
        field(400; "Enable NP Pass Integration"; Boolean)
        {
            Caption = 'Enable NP Pass Integration';
            DataClassification = CustomerContent;
        }
        field(500; "GDPR Mode"; Option)
        {
            Caption = 'GDPR Mode';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Implied,Required,Consent';
            OptionMembers = NA,IMPLIED,REQUIRED,CONSENT;

            trigger OnValidate()
            var
                GDPRManagement: Codeunit "NPR MM GDPR Management";
            begin

                if (not Confirm(UPDATE_GDPR, false)) then
                    Error('');

                GDPRManagement.OnMembershipGDPRModeChangeWorker(Code, xRec."GDPR Mode", Rec."GDPR Mode");

            end;
        }
        field(510; "GDPR Agreement No."; Code[20])
        {
            Caption = 'GDPR Agreement No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR GDPR Agreement";

            trigger OnValidate()
            var
                GDPRManagement: Codeunit "NPR MM GDPR Management";
            begin

                if (not Confirm(UPDATE_GDPR, false)) then
                    Error('');

                GDPRManagement.OnMembershipGDPRAgreementChangeWorker(Code, xRec."GDPR Agreement No.", Rec."GDPR Agreement No.");

            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MMMembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
    begin
        MMMembershipAdmissionSetup.SetFilter("Membership  Code", '=%1', Code);
        if (MMMembershipAdmissionSetup.FindSet()) then
            MMMembershipAdmissionSetup.DeleteAll(true);
    end;

    var
        UPDATE_GDPR: Label 'Changing the GDPR conditions for the membership setup will forcefully update all membership. Do you want to continue?';
}

