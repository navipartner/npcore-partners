table 6060139 "MM Member Notification Entry"
{
    // MM1.14/TSA/20160603  CASE 240871 Transport MM1.13 - 1 June 2016
    // MM1.24/TSA /20171101 CASE 294950 Added "Notification Method" Manual
    // MM1.25/TSA /20180122 CASE 301124 Removed Title Property
    // MM1.29/TSA /20180504 CASE 314131 Added fields for wallet
    // MM1.29.02/TSA /20180529 CASE 317156 Added Notification Method option SMS
    // MM1.29.02/TSA /20180529 CASE 317156 Added the field "Wallet Pass Landing URL" that will be a landing page
    // MM1.32/TSA /20180710 CASE 318132 Added option Wallet_Create to the Notification Trigger
    // MM1.38/TSA /20190517 CASE 355234 Added field Notification Token
    // MM1.39/TSA /20190529 CASE 350968 Added Auto-Renew fields
    // MM1.44/TSA /20200416 CASE 400601 Magento Get Password URL

    Caption = 'Member Notification Entry';

    fields
    {
        field(1;"Notification Entry No.";Integer)
        {
            Caption = 'Notification Entry No.';
        }
        field(2;"Member Entry No.";Integer)
        {
            Caption = 'Member Entry No.';
            TableRelation = "MM Member";
        }
        field(8;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
            TableRelation = "MM Membership";
        }
        field(10;"Notification Code";Code[10])
        {
            Caption = 'Notification Code';
            TableRelation = "MM Member Notification Setup";
        }
        field(20;"Date To Notify";Date)
        {
            Caption = 'Date To Notify';
        }
        field(30;"Notification Send Status";Option)
        {
            Caption = 'Notification Send Status';
            OptionCaption = 'Pending,Sent,Canceled,Failed,Not Sent';
            OptionMembers = PENDING,SENT,CANCELED,FAILED,NOT_SENT;
        }
        field(31;"Notification Sent At";DateTime)
        {
            Caption = 'Notification Sent At';
        }
        field(32;"Notification Sent By User";Text[30])
        {
            Caption = 'Notification Sent By User';
        }
        field(40;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(41;"Blocked At";DateTime)
        {
            Caption = 'Blocked At';
        }
        field(42;"Blocked By User";Text[30])
        {
            Caption = 'Blocked By User';
        }
        field(50;"Notification Trigger";Option)
        {
            Caption = 'Notification Trigger';
            OptionCaption = 'Welcome,Membership Renewal,Wallet Update,Wallet Create';
            OptionMembers = WELCOME,RENEWAL,WALLET_UPDATE,WALLET_CREATE;
        }
        field(51;"Template Filter Value";Code[20])
        {
            Caption = 'Template Filter Value';
        }
        field(80;"Target Member Role";Option)
        {
            Caption = 'Target Member Role';
            OptionCaption = 'FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS';
            OptionMembers = FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS;
        }
        field(90;"Notification Method";Option)
        {
            Caption = 'Notification Method';
            OptionCaption = 'None,E-Mail,Manual,Wallet,SMS';
            OptionMembers = "NONE",EMAIL,MANUAL,WALLET,SMS;
        }
        field(100;"External Member No.";Code[20])
        {
            Caption = 'External Member No.';
        }
        field(101;"External Membership No.";Code[20])
        {
            Caption = 'External Membership No.';
        }
        field(110;"E-Mail Address";Text[80])
        {
            Caption = 'E-Mail Address';
        }
        field(111;"Phone No.";Text[30])
        {
            Caption = 'Phone No.';
        }
        field(120;"First Name";Text[50])
        {
            Caption = 'First Name';
        }
        field(121;"Middle Name";Text[50])
        {
            Caption = 'Middle Name';
        }
        field(122;"Last Name";Text[50])
        {
            Caption = 'Last Name';
        }
        field(123;"Display Name";Text[100])
        {
            Caption = 'Display Name';
            Editable = false;
        }
        field(130;Address;Text[100])
        {
            Caption = 'Address';
        }
        field(131;"Post Code Code";Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(132;City;Text[50])
        {
            Caption = 'City';
        }
        field(133;"Country Code";Code[10])
        {
            Caption = 'Country Code';
        }
        field(134;Country;Text[50])
        {
            Caption = 'Country';
        }
        field(140;Birthday;Date)
        {
            Caption = 'Birthday';
        }
        field(150;"Community Code";Code[20])
        {
            Caption = 'Community Code';
            TableRelation = "MM Member Community";
        }
        field(151;"Membership Code";Code[20])
        {
            Caption = 'Membership Code';
            TableRelation = "MM Membership Sales Setup"."No." WHERE (Type=CONST(ITEM));
        }
        field(152;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(153;"Membership Valid From";Date)
        {
            Caption = 'Membership Valid From';
        }
        field(154;"Membership Valid Until";Date)
        {
            Caption = 'Membership Valid Until';
        }
        field(155;"Community Description";Text[50])
        {
            Caption = 'Community Description';
        }
        field(156;"Membership Description";Text[50])
        {
            Caption = 'Membership Description';
        }
        field(160;"External Member Card No.";Text[50])
        {
            Caption = 'External Member Card No.';
        }
        field(161;"Card Valid Until";Date)
        {
            Caption = 'Card Valid Until';
        }
        field(162;"Pin Code";Text[50])
        {
            Caption = 'Pin Code';
        }
        field(165;"Auto-Renew";Option)
        {
            Caption = 'Auto-Renew';
            OptionCaption = 'No,Yes (Internal),Yes (External)';
            OptionMembers = NO,YES_INTERNAL,YES_EXTERNAL;
        }
        field(166;"Auto-Renew Payment Method Code";Code[10])
        {
            Caption = 'Auto-Renew Payment Method Code';
        }
        field(167;"Auto-Renew External Data";Text[200])
        {
            Caption = 'Auto-Renew External Data';
        }
        field(170;"Remaining Points";Integer)
        {
            CalcFormula = Sum("MM Membership Points Entry".Points WHERE ("Membership Entry No."=FIELD("Membership Entry No.")));
            Caption = 'Remaining Points';
            Description = '//-MM1.29 [314131]';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180;"Notification Token";Text[64])
        {
            Caption = 'Notification Token';
        }
        field(200;"Failed With Message";Text[250])
        {
            Caption = 'Failed With Message';
        }
        field(400;"Include NP Pass";Boolean)
        {
            Caption = 'Include NP Pass';
            Description = '//-MM1.29 [314131]';
        }
        field(410;"Wallet Pass Id";Text[35])
        {
            Caption = 'Wallet Pass Id';
            Description = '//-MM1.29 [314131]';
        }
        field(420;"Wallet Pass Default URL";Text[200])
        {
            Caption = 'Wallet Pass Default URL';
            Description = '//-MM1.29 [314131]';
        }
        field(421;"Wallet Pass Andriod URL";Text[200])
        {
            Caption = 'Wallet Pass Andriod URL';
            Description = '//-MM1.29 [314131]';
        }
        field(422;"Wallet Pass Landing URL";Text[200])
        {
            Caption = 'Wallet Pass Combine URL';
            Description = '//-MM1.29.02 [317156]';
        }
        field(430;"Magento Get Password URL";Text[200])
        {
            Caption = 'Magento Get Password URL';
            Description = '//-MM1.44 [400601]';
        }
    }

    keys
    {
        key(Key1;"Notification Entry No.","Member Entry No.")
        {
        }
        key(Key2;"Notification Send Status","Date To Notify")
        {
        }
        key(Key3;"Member Entry No.")
        {
        }
        key(Key4;"Membership Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

