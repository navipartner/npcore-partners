table 6060134 "NPR MM Member Info Capture"
{

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
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                CountyTxt: Text[30];
                CityTxt: Text[30];
                PostCode: Record "Post Code";
                CountryRegion: Record "Country/Region";
            begin
                CityTxt := CopyStr(Rec.City, 1, MaxStrLen(CityTxt));
                PostCode.ValidatePostCode(CityTxt, Rec."Post Code Code", CountyTxt, Rec."Country Code", (CurrFieldNo <> 0) and GuiAllowed);
                Rec.City := CityTxt;
                if (CountryRegion.Get(Rec."Country Code")) then
                    Rec.Country := CountryRegion.Name;
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
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                CountryRegion: Record "Country/Region";
            begin
                if (CountryRegion.Get("Country Code")) then
                    Country := CountryRegion.Name;
            end;
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(33; Image; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
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
        field(95; Description; Text[100])
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
        field(110; "External Card No."; Text[100])
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
        field(115; "Replace External Card No."; Text[100])
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
        field(200; "User Logon ID"; Code[80])
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
        field(500; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store";
            ValidateTableRelation = false;
        }
        field(1000; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
            Description = 'External Relations';
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
        field(1011; "Document Type"; Enum "NPR MM Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
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

    procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    begin
        TenantMedia.Init();
        if not Image.HasValue() then
            exit;
        if TenantMedia.Get(Image.MediaId()) then
            TenantMedia.CalcFields(Content);
    end;
}

