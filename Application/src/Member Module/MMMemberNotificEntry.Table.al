table 6060139 "NPR MM Member Notific. Entry"
{

    Caption = 'Member Notification Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Notification Entry No."; Integer)
        {
            Caption = 'Notification Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member";
        }
        field(8; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership";
        }
        field(10; "Notification Code"; Code[10])
        {
            Caption = 'Notification Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Notific. Setup";
        }
        field(15; "Notification Engine"; Option)
        {
            Caption = 'Notification Engine';
            DataClassification = CustomerContent;
            OptionMembers = NATIVE,M2_EMAILER;
            OptionCaption = 'Native,M2 E-Mail';
        }
        field(20; "Date To Notify"; Date)
        {
            Caption = 'Date To Notify';
            DataClassification = CustomerContent;
        }
        field(30; "Notification Send Status"; Option)
        {
            Caption = 'Notification Send Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Pending,Sent,Canceled,Failed,Not Sent';
            OptionMembers = PENDING,SENT,CANCELED,FAILED,NOT_SENT;
        }
        field(31; "Notification Sent At"; DateTime)
        {
            Caption = 'Notification Sent At';
            DataClassification = CustomerContent;
        }
        field(32; "Notification Sent By User"; Text[30])
        {
            Caption = 'Notification Sent By User';
            DataClassification = CustomerContent;
        }
        field(40; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(41; "Blocked At"; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = CustomerContent;
        }
        field(42; "Blocked By User"; Text[30])
        {
            Caption = 'Blocked By User';
            DataClassification = CustomerContent;
        }
        field(50; "Notification Trigger"; Option)
        {
            Caption = 'Notification Trigger';
            DataClassification = CustomerContent;
            OptionCaption = 'Welcome,Membership Renewal,Wallet Update,Wallet Create';
            OptionMembers = WELCOME,RENEWAL,WALLET_UPDATE,WALLET_CREATE;
        }
        field(51; "Template Filter Value"; Code[20])
        {
            Caption = 'Template Filter Value';
            DataClassification = CustomerContent;
        }
        field(80; "Target Member Role"; Option)
        {
            Caption = 'Target Member Role';
            DataClassification = CustomerContent;
            OptionCaption = 'FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS';
            OptionMembers = FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS;
        }
        field(90; "Notification Method"; Option)
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
            OptionCaption = 'None,E-Mail,Manual,Wallet,SMS';
            OptionMembers = "NONE",EMAIL,MANUAL,WALLET,SMS;
        }
        field(100; "External Member No."; Code[20])
        {
            Caption = 'External Member No.';
            DataClassification = CustomerContent;
        }
        field(105; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(106; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
        field(101; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
        }
        field(110; "E-Mail Address"; Text[80])
        {
            Caption = 'E-Mail Address';
            DataClassification = CustomerContent;
        }
        field(111; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(120; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(121; "Middle Name"; Text[50])
        {
            Caption = 'Middle Name';
            DataClassification = CustomerContent;
        }
        field(122; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(123; "Display Name"; Text[100])
        {
            Caption = 'Display Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(130; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(131; "Post Code Code"; Code[20])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(132; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(133; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(134; Country; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(140; Birthday; Date)
        {
            Caption = 'Birthday';
            DataClassification = CustomerContent;
        }
        field(150; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(151; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Members. Sales Setup"."No." WHERE(Type = CONST(ITEM));
        }
        field(152; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(153; "Membership Valid From"; Date)
        {
            Caption = 'Membership Valid From';
            DataClassification = CustomerContent;
        }
        field(154; "Membership Valid Until"; Date)
        {
            Caption = 'Membership Valid Until';
            DataClassification = CustomerContent;
        }
        field(155; "Community Description"; Text[50])
        {
            Caption = 'Community Description';
            DataClassification = CustomerContent;
        }
        field(156; "Membership Description"; Text[50])
        {
            Caption = 'Membership Description';
            DataClassification = CustomerContent;
        }
        field(157; "Membership Consecutive From"; Date)
        {
            Caption = 'Membership Consecutive From';
            DataClassification = CustomerContent;
        }
        field(158; "Membership Consecutive Until"; Date)
        {

            Caption = 'Membership Consecutive Until';
            DataClassification = CustomerContent;
        }

        field(160; "External Member Card No."; Text[100])
        {
            Caption = 'External Member Card No.';
            DataClassification = CustomerContent;
        }
        field(161; "Card Valid Until"; Date)
        {
            Caption = 'Card Valid Until';
            DataClassification = CustomerContent;
        }
        field(162; "Pin Code"; Text[50])
        {
            Caption = 'Pin Code';
            DataClassification = CustomerContent;
        }
        field(165; "Auto-Renew"; Option)
        {
            Caption = 'Auto-Renew';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes (Internal),Yes (External)';
            OptionMembers = NO,YES_INTERNAL,YES_EXTERNAL;
        }
        field(166; "Auto-Renew Payment Method Code"; Code[10])
        {
            Caption = 'Auto-Renew Payment Method Code';
            DataClassification = CustomerContent;
        }
        field(167; "Auto-Renew External Data"; Text[200])
        {
            Caption = 'Auto-Renew External Data';
            DataClassification = CustomerContent;
        }
        field(170; "Remaining Points"; Integer)
        {
            CalcFormula = Sum("NPR MM Members. Points Entry".Points WHERE("Membership Entry No." = FIELD("Membership Entry No.")));
            Caption = 'Remaining Points';
            Description = '';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180; "Notification Token"; Text[64])
        {
            Caption = 'Notification Token';
            DataClassification = CustomerContent;
        }
        field(200; "Failed With Message"; Text[250])
        {
            Caption = 'Failed With Message';
            DataClassification = CustomerContent;
        }
        field(400; "Include NP Pass"; Boolean)
        {
            Caption = 'Include NP Pass';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(410; "Wallet Pass Id"; Text[35])
        {
            Caption = 'Wallet Pass Id';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(420; "Wallet Pass Default URL"; Text[200])
        {
            Caption = 'Wallet Pass Default URL';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(421; "Wallet Pass Andriod URL"; Text[200])
        {
            Caption = 'Wallet Pass Andriod URL';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(422; "Wallet Pass Landing URL"; Text[200])
        {
            Caption = 'Wallet Pass Combine URL';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(430; "Magento Get Password URL"; Text[200])
        {
            Caption = 'Magento Get Password URL';
            DataClassification = CustomerContent;
            Description = '';
        }
    }

    keys
    {
        key(Key1; "Notification Entry No.", "Member Entry No.")
        {
        }
        key(Key2; "Notification Send Status", "Date To Notify")
        {
        }
        key(Key3; "Member Entry No.")
        {
        }
        key(Key4; "Membership Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

