table 6060125 "MM Membership Sales Setup"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.17/TSA/20161208  CASE 259671 Extended options on field 40 with Prompt, Activate on first use
    // MM1.17/TSA/20161227  CASE 262040 Added field 50 - Suggested Membercount In Sales
    // MM1.17/TSA/20161227  CASE 262040 Added field 12 - Business Flow Type
    // MM1.22/TSA /20170808 CASE 285403 New Field - "Assign Loyalty Points On Sale"
    // MM1.22/TSA /20170816 CASE 287080 Added option business flow type: ADD_ANONYMOUS_MEMBER
    // MM1.22/TSA /20170829 CASE 286922 Added field Auto-Renew To
    // MM1.29.02/TSA /20180530 CASE 316450 Added field Auto-Admitt Member On Sale
    // MM1.32/TSA /20180711 CASE 318132 Added Member Card Type and Member Card Type Selection
    // MM1.40/TSA /20190726 CASE 356090 New field "Magento M2 Membership Sign-up"
    // MM1.40/TSA /20190730 CASE 360275 Corrected spelling on field and caption for field 80

    Caption = 'Membership Sales Setup';
    DrillDownPageID = "MM Membership Sales Setup";
    LookupPageID = "MM Membership Sales Setup";

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,G/L Account';
            OptionMembers = ITEM,ACCOUNT;
        }
        field(2;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = IF (Type=CONST(ITEM)) Item WHERE (Blocked=CONST(false))
                            ELSE IF (Type=CONST(ACCOUNT)) "G/L Account" WHERE (Blocked=CONST(false));
        }
        field(10;"Membership Code";Code[20])
        {
            Caption = 'Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(12;"Business Flow Type";Option)
        {
            Caption = 'Business Flow Type';
            OptionCaption = 'Membership,Additional Named Member,Additional Card,Replace Card,Additional Anonymous Member(s)';
            OptionMembers = MEMBERSHIP,ADD_NAMED_MEMBER,ADD_CARD,REPLACE_CARD,ADD_ANONYMOUS_MEMBER;
        }
        field(15;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(16;"Blocked At";DateTime)
        {
            Caption = 'Blocked At';
        }
        field(40;"Valid From Base";Option)
        {
            Caption = 'Valid From Base';
            Description = '224895';
            OptionCaption = 'Sales Date,Date Formula,Prompt,Activate On First Use';
            OptionMembers = SALESDATE,DATEFORMULA,PROMPT,FIRST_USE;
        }
        field(41;"Sales Cut-Off Date Calculation";DateFormula)
        {
            Caption = 'Sales Cut-Off Date Calculation';
            Description = '224895';
        }
        field(42;"Valid From Date Calculation";DateFormula)
        {
            Caption = 'Valid From Date Calculation';
            Description = '224895';
        }
        field(43;"Valid Until Calculation";Option)
        {
            Caption = 'Valid Until Calculation';
            OptionCaption = 'Date Formula,End of Time';
            OptionMembers = DATEFORMULA,END_OF_TIME;
        }
        field(44;"Duration Formula";DateFormula)
        {
            Caption = 'Duration Formula';
        }
        field(50;"Suggested Membercount In Sales";Integer)
        {
            Caption = 'Suggested Membercount In Sales';
        }
        field(60;"Assign Loyalty Points On Sale";Boolean)
        {
            Caption = 'Assign Loyalty Points On Sale';
        }
        field(70;"Auto-Renew To";Code[20])
        {
            Caption = 'Auto-Renew To';
            TableRelation = "MM Membership Alteration Setup"."Sales Item No." WHERE ("Alteration Type"=CONST(AUTORENEW));
        }
        field(80;"Auto-Admit Member On Sale";Option)
        {
            Caption = 'Auto-Admit Member On Sale';
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = NO,YES,ASK;
        }
        field(90;"Member Card Type Selection";Option)
        {
            Caption = 'Member Card Type Selection';
            OptionCaption = 'Auto,User Select';
            OptionMembers = AUTO,USER_SELECT;
        }
        field(95;"Member Card Type";Option)
        {
            Caption = 'Member Card Type';
            OptionCaption = 'Physical Card,Wallet,Card+Wallet,None';
            OptionMembers = CARD,PASSSERVER,CARD_PASSSERVER,"NONE";
        }
        field(100;"Magento M2 Membership Sign-up";Boolean)
        {
            Caption = 'Magento M2 Membership Sign-up';
        }
    }

    keys
    {
        key(Key1;Type,"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

