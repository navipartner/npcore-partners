table 6060132 "NPR MM Member Community"
{

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
        field(13; "External Membership No. Series"; Code[20])
        {
            Caption = 'External Membership No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(14; "External Member No. Series"; Code[20])
        {
            Caption = 'External Member No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(15; "Customer No. Series"; Code[20])
        {
            Caption = 'Customer No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; "Member Unique Identity"; Enum "NPR MM Member Unique Identity")
        {
            Caption = 'Member Unique Identity';
            DataClassification = CustomerContent;
        }
        field(21; "Create Member UI Violation"; Option)
        {
            Caption = 'Create Member UI Violation';
            DataClassification = CustomerContent;
            OptionCaption = 'Error,Confirm,Reuse,Merge';
            OptionMembers = ERROR,CONFIRM,REUSE,MERGE_MEMBER;
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
            CalcFormula = Exist("NPR MM Foreign Members. Setup" WHERE("Community Code" = FIELD(Code),
                                                                     Disabled = CONST(false)));
            Caption = 'Foreign Membership';
            FieldClass = FlowField;
        }

        field(40; MemberDefaultCountryCode; Code[10])
        {
            Caption = 'Member Default Country Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
            ValidateTableRelation = true;
        }
        field(41; MemberDefaultLanguageCode; Code[10])
        {
            Caption = 'Member Default Language Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Language";
            ValidateTableRelation = true;
        }
        field(60; "Create Renewal Notifications"; Boolean)
        {
            Caption = 'Create For Renewal Notifications';
            DataClassification = CustomerContent;
        }
        field(70; "Create Renewal Success Notif"; Boolean)
        {
            Caption = 'Create Renewal Success Notifications';
            DataClassification = CustomerContent;
        }
        field(80; "Create Renewal Failure Notif"; Boolean)
        {
            Caption = 'Create Renewal Failure Notifications';
            DataClassification = CustomerContent;
        }
        field(90; "Create AutoRenewal Enabl Notif"; Boolean)
        {
            Caption = 'Create Auto-Renewal Enabled Notifications';
            DataClassification = CustomerContent;
        }
        field(100; "Create AutoRenewal Disbl Notif"; Boolean)
        {
            Caption = 'Create Auto-Renewal Disabled Notifications';
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

