table 6060132 "NPR MM Member Community"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.09/TSA/20160226  case 235634 Membership connection to Customer & Contacts
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service, field 60
    // MM1.17/TSA/20161214  CASE 243075 Member Point System added field Activate Loyality Program
    // MM1.30/TSA /20180614 CASE 319296 Added field Customer No. Series
    // MM1.40/TSA /20190604 CASE 357360 Added "Foreign Membership" flowfield looking down into table 6060143

    Caption = 'Member Community';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Member Community";
    LookupPageID = "NPR MM Member Community";

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
        field(12; "External No. Search Order"; Option)
        {
            Caption = 'External No. Search Order';
            DataClassification = CustomerContent;
            OptionCaption = 'Card,Member,Membership,All';
            OptionMembers = CARDNO,MEMBERNO,MEMBERSHIPNO,ALL;
        }
        field(13; "External Membership No. Series"; Code[10])
        {
            Caption = 'External Membership No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(14; "External Member No. Series"; Code[10])
        {
            Caption = 'External Member No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(15; "Customer No. Series"; Code[10])
        {
            Caption = 'Customer No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; "Member Unique Identity"; Option)
        {
            Caption = 'Member Unique Identity';
            DataClassification = CustomerContent;
            OptionCaption = ' ,E-Mail,Phone No.,Social Security No.';
            OptionMembers = "NONE",EMAIL,PHONENO,SSN;
        }
        field(21; "Create Member UI Violation"; Option)
        {
            Caption = 'Create Member UI Violation';
            DataClassification = CustomerContent;
            OptionCaption = 'Error,Confirm,Reuse (Silent)';
            OptionMembers = ERROR,CONFIRM,REUSE;
        }
        field(22; "Member Logon Credentials"; Option)
        {
            Caption = 'Member Logon Credentials';
            DataClassification = CustomerContent;
            OptionCaption = 'Not Applicable,Member Unique Identity,External Member ID,Member Selected';
            OptionMembers = NA,MEMBER_UNIQUE_ID,MEMBER_NUMBER,CUSTOM;
        }
        field(23; "Membership to Cust. Rel."; Boolean)
        {
            Caption = 'Membership to Cust. Rel.';
            DataClassification = CustomerContent;
        }
        field(24; "Activate Loyalty Program"; Boolean)
        {
            Caption = 'Activate Loyalty Program';
            DataClassification = CustomerContent;
        }
        field(30; "Foreign Membership"; Boolean)
        {
            CalcFormula = Exist ("NPR MM Foreign Members. Setup" WHERE("Community Code" = FIELD(Code),
                                                                     Disabled = CONST(false)));
            Caption = 'Foreign Membership';
            FieldClass = FlowField;
        }
        field(60; "Create Renewal Notifications"; Boolean)
        {
            Caption = 'Create Renewal Notifications';
            DataClassification = CustomerContent;
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
}

