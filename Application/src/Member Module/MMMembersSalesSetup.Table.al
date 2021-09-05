table 6060125 "NPR MM Members. Sales Setup"
{

    Caption = 'Membership Sales Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Membership Sales Setup";
    LookupPageID = "NPR MM Membership Sales Setup";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,G/L Account';
            OptionMembers = ITEM,ACCOUNT;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = IF (Type = CONST(ITEM)) Item WHERE(Blocked = CONST(false))
            ELSE
            IF (Type = CONST(ACCOUNT)) "G/L Account" WHERE(Blocked = CONST(false));
        }
        field(10; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(12; "Business Flow Type"; Option)
        {
            Caption = 'Business Flow Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Membership,Additional Named Member,Additional Card,Replace Card,Additional Anonymous Member(s)';
            OptionMembers = MEMBERSHIP,ADD_NAMED_MEMBER,ADD_CARD,REPLACE_CARD,ADD_ANONYMOUS_MEMBER;
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
        field(25; "Requires Guardian"; Boolean)
        {
            Caption = 'Requires Guardian';
            DataClassification = CustomerContent;
        }
        field(26; "Age Constraint Type"; Option)
        {
            Caption = 'Age Constraint Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Less Than,Less Than or Equal,Greater Than,Greater Than or Equal,Equal';
            OptionMembers = NA,LT,LTE,GT,GTE,E;
        }
        field(27; "Age Constraint (Years)"; Integer)
        {
            Caption = 'Age Constraint (Years)';
            DataClassification = CustomerContent;
        }
        field(28; "Age Constraint Applies To"; Option)
        {
            Caption = 'Age Constraint Applies To';
            DataClassification = CustomerContent;
            OptionCaption = 'All Members,Youngest Member,Oldest Member,Administrators,Dependants';
            OptionMembers = ALL,YOUNGEST,OLDEST,ADMINS,DEPENDANTS;
        }
        field(40; "Valid From Base"; Option)
        {
            Caption = 'Valid From Base';
            DataClassification = CustomerContent;
            Description = '224895';
            OptionCaption = 'Sales Date,Date Formula,Prompt,Activate On First Use';
            OptionMembers = SALESDATE,DATEFORMULA,PROMPT,FIRST_USE;
        }
        field(41; "Sales Cut-Off Date Calculation"; DateFormula)
        {
            Caption = 'Sales Cut-Off Date Calculation';
            DataClassification = CustomerContent;
            Description = '224895';
        }
        field(42; "Valid From Date Calculation"; DateFormula)
        {
            Caption = 'Valid From Date Calculation';
            DataClassification = CustomerContent;
            Description = '224895';
        }
        field(43; "Valid Until Calculation"; Option)
        {
            Caption = 'Valid Until Calculation';
            DataClassification = CustomerContent;
            OptionCaption = 'Date Formula,End of Time';
            OptionMembers = DATEFORMULA,END_OF_TIME;
        }
        field(44; "Duration Formula"; DateFormula)
        {
            Caption = 'Duration Formula';
            DataClassification = CustomerContent;
        }
        field(50; "Suggested Membercount In Sales"; Integer)
        {
            Caption = 'Suggested Member Count In Sales';
            DataClassification = CustomerContent;
        }
        field(60; "Assign Loyalty Points On Sale"; Boolean)
        {
            Caption = 'Assign Loyalty Points On Sale';
            DataClassification = CustomerContent;
        }
        field(65; "Mixed Sale Policy"; Option)
        {
            Caption = 'Mixed Sale Policy';
            DataClassification = CustomerContent;
            OptionMembers = ALLOW,MEMBERSHIP_ITEM,SAME_ITEM,DISALLOW;
            OptionCaption = 'Allow Any Item,Membership Items,Same Item,Disallowed';
        }
        field(70; "Auto-Renew To"; Code[20])
        {
            Caption = 'Auto-Renew To';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Members. Alter. Setup"."Sales Item No." WHERE("Alteration Type" = CONST(AUTORENEW));
        }
        field(80; "Auto-Admit Member On Sale"; Option)
        {
            Caption = 'Auto-Admit Member On Sale';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = NO,YES,ASK;
        }
        field(90; "Member Card Type Selection"; Option)
        {
            Caption = 'Member Card Type Selection';
            DataClassification = CustomerContent;
            OptionCaption = 'Auto,User Select';
            OptionMembers = AUTO,USER_SELECT;
        }
        field(95; "Member Card Type"; Option)
        {
            Caption = 'Member Card Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Physical Card,Wallet,Card+Wallet,None';
            OptionMembers = CARD,PASSSERVER,CARD_PASSSERVER,"NONE";
        }
        field(100; "Magento M2 Membership Sign-up"; Boolean)
        {
            Caption = 'Magento M2 Membership Sign-up';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

