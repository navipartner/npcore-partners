table 6060134 "NPR MM Member Info Capture"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.02/TSA/20151228  CASE 229684 Touch-up and enchancements
    // MM1.03/TSA/20160104  CASE 230647 - Added NewsLetter CRM option
    // MM1.08/TSA/20160223  CASE 234913 - Include company name field on membership
    // MM1.08/TSA/20160223  CASE 234592 - update of city from post code
    // MM1.09/TSA/20160229 CASE 235805 Added support for Sales Context
    // MM1.10/TSA/20160325 CASE 236532 Added the picture BLOB field
    // MM1.11/TSA/20160502  CASE 233824 Transport MM1.11 - 29 April 2016
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160523  CASE 240871 Notification Service field 40
    // MM1.15/TSA/20160615  CASE Bug fix Added field Description to capture a posting description
    // MM1.15/TSA/20160718  CASE 242519 Bug fix - checking for duplicate external member card no on manual input
    // MM1.15/TSA/20160810  CASE 248625 Added Field "imported"
    // MM1.16/TSA/20160913  CASE 252216 Signature change on search function
    // MM1.17/TSA/20161230  CASE 261216 Added field Replace External Card No.
    // MM1.19/TSA/20170421  CASE 271971 Adding Key on Receipt No.,Line No.
    // MM1.22/TSA /20170817 CASE 287080 Added field Quantity
    // MM1.22/TSA /20170829 CASE 286922 Added field "Enable Auto-Renew", added context type AUTORENEW
    // MM1.22/TSA /20170904 CASE 276832 Added Guardian External Member No.
    // MM1.22/TSA /20170911 CASE 284560 Added field Temporary Member Card, Membership, Member
    // MM1.22/TSA /20170913 CASE 286922 Added field Payment Method Code to filter out different payment methods for auto renew
    // MM1.23/TSA /20171003 CASE 257011 Added Context FOREIGN, "Initial Loyalty Point Count"
    // MM1.24/TSA /20171101 CASE 294950 Added Notification Method Manual
    // MM1.25/TSA /20171213 CASE 299783 Added a few more Source Types
    // MM1.25/TSA /20171215 CASE 299783 Added fields Response Status and Response Message to improve batch processing
    // MM1.25/TSA /20180115 CASE 299537 Added Context types for printing
    // MM1.26/TSA /20180122 CASE 301124 Removed Title Property
    // MM1.29/TSA /20180511 CASE 313795 GDPR Approval Option field
    // MM1.29.02/TSA /20180528 CASE 317156 Added SMS as notification option
    // MM1.32/TSA /20180710 CASE 318132 Added field "Member Card Type" option
    // MM1.40/TSA /20190730 CASE 360275 Added field "Auto-Admit Member"
    // MM1.42/TSA /20191205 CASE 381222 Changed InitValue for Notification Method from EMAIL to new option DEFAULT
    // MM1.43/TSA /20200130 CASE 386080 Added field Customer No and Contact No

    Caption = 'Member Info Capture';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Member Entry No"; Integer)
        {
            Caption = 'Member Entry No';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member";
        }
        field(4; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership";
        }
        field(5; "Card Entry No."; Integer)
        {
            Caption = 'Card Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
            Description = 'Member';
        }
        field(11; "Middle Name"; Text[50])
        {
            Caption = 'Middle Name';
            DataClassification = CustomerContent;
        }
        field(12; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
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
        field(20; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(21; "Social Security No."; Text[30])
        {
            Caption = 'Social Security No.';
            DataClassification = CustomerContent;
        }
        field(22; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(25; "Post Code Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                County: Text[50];
                PostCode: Record "Post Code";
            begin
                PostCode.ValidatePostCode(City, "Post Code Code", County, "Country Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(27; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(28; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(29; Country; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(30; Gender; Option)
        {
            Caption = 'Gender';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Male,Female,Other';
            OptionMembers = NOT_SPECIFIED,MALE,FEMALE,OTHER;
        }
        field(31; Birthday; Date)
        {
            Caption = 'Birthday';
            DataClassification = CustomerContent;
        }
        field(32; Picture; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(35; "E-Mail Address"; Text[80])
        {
            Caption = 'E-Mail Address';
            DataClassification = CustomerContent;
        }
        field(40; "Notification Method"; Option)
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
            InitValue = DEFAULT;
            OptionCaption = ' ,E-Mail,Manual,SMS,Default';
            OptionMembers = NO_THANKYOU,EMAIL,MANUAL,SMS,DEFAULT;
        }
        field(60; "News Letter"; Option)
        {
            Caption = 'News Letter';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = NOT_SPECIFIED,YES,NO;
        }
        field(95; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(96; "Duration Formula"; DateFormula)
        {
            Caption = 'Duration Formula';
            DataClassification = CustomerContent;
        }
        field(97; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(98; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(99; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
        }
        field(110; "External Card No."; Text[50])
        {
            Caption = 'External Card No.';
            DataClassification = CustomerContent;
            Description = 'Card';

            trigger OnValidate()
            var
                NotFoundReasonText: Text;
            begin

                if (MembershipManagement.GetMembershipFromExtCardNo("External Card No.", Today, NotFoundReasonText) <> 0) then
                    Error(TEXT6060000, FieldCaption("External Card No."), "External Card No.");
            end;
        }
        field(111; "External Card No. Last 4"; Code[4])
        {
            Caption = 'External Card No. Last 4';
            DataClassification = CustomerContent;
        }
        field(112; "Pin Code"; Text[20])
        {
            Caption = 'Pin Code';
            DataClassification = CustomerContent;
        }
        field(113; "Valid Until"; Date)
        {
            Caption = 'Valid Until';
            DataClassification = CustomerContent;
        }
        field(115; "Replace External Card No."; Text[50])
        {
            Caption = 'Replace External Card No.';
            DataClassification = CustomerContent;
        }
        field(120; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(121; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
        }
        field(200; "User Logon ID"; Code[50])
        {
            Caption = 'User Logon ID';
            DataClassification = CustomerContent;
            Description = 'Role';
        }
        field(201; "Password SHA1"; Text[50])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(210; "External Member No"; Code[20])
        {
            Caption = 'External Member No.';
            DataClassification = CustomerContent;
        }
        field(211; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
        }
        field(220; "GDPR Approval"; Option)
        {
            Caption = 'GDPR Approval';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Pending,Accepted,Rejected';
            OptionMembers = NA,PENDING,ACCEPTED,REJECTED;
        }
        field(300; "Enable Auto-Renew"; Boolean)
        {
            Caption = 'Enable Auto-Renew';
            DataClassification = CustomerContent;
        }
        field(305; "Auto-Renew Entry No."; Integer)
        {
            Caption = 'Auto-Renew Entry No.';
            DataClassification = CustomerContent;
        }
        field(310; "Auto-Renew Payment Method Code"; Code[10])
        {
            Caption = 'Auto-Renew Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(320; "Guardian External Member No."; Code[20])
        {
            Caption = 'Guardian External Member No.';
            DataClassification = CustomerContent;
        }
        field(330; "Temporary Membership"; Boolean)
        {
            Caption = 'Temporary Membership';
            DataClassification = CustomerContent;
        }
        field(332; "Temporary Member"; Boolean)
        {
            Caption = 'Temporary Member';
            DataClassification = CustomerContent;
        }
        field(334; "Temporary Member Card"; Boolean)
        {
            Caption = 'Temporary Member Card';
            DataClassification = CustomerContent;
        }
        field(340; "Member Card Type"; Option)
        {
            Caption = 'Member Card Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Physical Card,Wallet,Card+Wallet,None';
            OptionMembers = CARD,PASSSERVER,CARD_PASSSERVER,"NONE";
        }
        field(350; "Auto-Admit Member"; Boolean)
        {
            Caption = 'Auto-Admit Member';
            DataClassification = CustomerContent;
        }
        field(1000; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
            Description = 'Externa Relations';
        }
        field(1001; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(1002; "Information Context"; Option)
        {
            Caption = 'Information Context';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Regret,Renew,Upgrade,Extend,List,Cancel,Auto-Renew,Foreign Membership,Print Card,Print Member,Print Membership';
            OptionMembers = NEW,REGRET,RENEW,UPGRADE,EXTEND,LIST,CANCEL,AUTORENEW,FOREIGN,PRINT_CARD,PRINT_ACCOUNT,PRINT_MEMBERSHIP;
        }
        field(1003; "Originates From File Import"; Boolean)
        {
            Caption = 'Originates From File Import';
            DataClassification = CustomerContent;
        }
        field(1005; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(1006; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(1007; "Amount Incl VAT"; Decimal)
        {
            Caption = 'Amount Incl VAT';
            DataClassification = CustomerContent;
        }
        field(1008; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(1009; "Initial Loyalty Point Count"; Decimal)
        {
            Caption = 'Initial Loyalty Point Count';
            DataClassification = CustomerContent;
        }
        field(1010; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Sales Header,Alteration Journal,File Import,Print Journal,AutoRenew Journal';
            OptionMembers = NA,SALESHEADER,ALTERATION_JNL,FILE_IMPORT,PRINT_JNL,AUTORENEW_JNL;
        }
        field(1011; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,1,2,3,4,5';
            OptionMembers = "0","1","2","3","4","5";
        }
        field(1012; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(1013; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(1015; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(1020; "Import Entry Document ID"; Text[100])
        {
            Caption = 'Import Entry Document ID';
            DataClassification = CustomerContent;
        }
        field(1200; "Response Status"; Option)
        {
            Caption = 'Response Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Registered,Validated,Completed,Failed';
            OptionMembers = REGISTERED,READY,COMPLETED,FAILED;
        }
        field(1210; "Response Message"; Text[250])
        {
            Caption = 'Response Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Import Entry Document ID")
        {
        }
        key(Key3; "Receipt No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        TEXT6060000: Label 'The %1 %2 is already in use.';
}

