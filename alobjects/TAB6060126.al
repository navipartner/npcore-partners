table 6060126 "MM Member"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.01/TSA/20151222  CASE 230149 NaviPartner Member Management
    // MM1.10/TSA/20160325  CASE 235634 Added Contact No. Field to member
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160523  CASE 240871 Notification Service field 60
    // MM1.15/TSA/20160611  CASE 248625 Delete the MemberCards on Member delete
    // MM1.16/TSA/20160913  CASE 252216 Signature change on search function
    // MM1.18/TSA/20170302  CASE 265340 Added Customer and Contact sync on modify ();
    // MM1.19/TSA/20170524  CASE 265379 Changed member sync to contact
    // MM1.22/TSA /20170818 CASE 279343 Cascade member block to contact
    // MM1.24/TSA /20171101 CASE 294950 Added Notification Method Manual
    // MM1.25/TSA /20180122 CASE 301124 Removed the title property
    // MM1.29/TSA /20180503 CASE 313795 Added Block Reason
    // MM1.29/TSA /20180507 CASE 313741 Update Magento Contact false when member delete
    // MM1.29/TSA /20180522 CASE 316251 Added index on "External Member No."
    // MM1.29.02/TSA /20180531 CASE 317156 Added SMS as notification method
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018
    // MM1.33/TSA /20180803 CASE 323443 Added the post code lookup and field completion
    // MM1.41/TSA /20190918 CASE 369123 Blocking a member also blocks the membership role

    Caption = 'Member';
    DataClassification = CustomerContent;
    DrillDownPageID = "MM Members";
    LookupPageID = "MM Members";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(9; "External Member No."; Code[20])
        {
            Caption = 'External Member No.';
            DataClassification = CustomerContent;
        }
        field(10; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
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

            trigger OnValidate()
            var
                MembershipRole: Record "MM Membership Role";
                Contact: Record Contact;
            begin
                "Blocked At" := CreateDateTime(0D, 0T);
                "Blocked By" := '';
                if (Blocked) then begin
                    "Blocked At" := CurrentDateTime();
                    "Blocked By" := UserId;
                end;

                //-MM1.22 [279343]
                MembershipRole.SetFilter("Member Entry No.", '=%1', "Entry No.");
                MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
                if (MembershipRole.FindSet()) then begin
                    repeat
                        // -MM1.41 [369123]
                        MembershipRole.Validate(Blocked, Blocked);
                        MembershipRole.Modify();
                        //+MM1.41 [369123]

                        if (Contact.Get(MembershipRole."Contact No.")) then begin
                            Contact.Validate("Magento Contact", not Blocked);
                            Contact.Modify();
                        end;
                    until (MembershipRole.Next() = 0);
                end;
                //+MM1.22 [279343]
            end;
        }
        field(16; "Blocked At"; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Blocked By"; Code[30])
        {
            Caption = 'Blocked By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Block Reason"; Option)
        {
            Caption = 'Block Reason';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Expired,User Request,Internal,Anonymized';
            OptionMembers = UNKNOWN,EXPIRED,USER_REQUEST,INTERNAL,ANONYMIZED;
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
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                County: Text;
                PostCode: Record "Post Code";
                CountryRegion: Record "Country/Region";
            begin
                PostCode.ValidatePostCode(City, "Post Code Code", County, "Country Code", (CurrFieldNo <> 0) and GuiAllowed);
                if (CountryRegion.Get("Country Code")) then
                    Country := CountryRegion.Name;
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
            OptionCaption = ' ,E-Mail,Manual,SMS';
            OptionMembers = "NONE",EMAIL,MANUAL,SMS;
        }
        field(60; "E-Mail News Letter"; Option)
        {
            Caption = 'E-Mail News Letter';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = NOT_SPECIFIED,YES,NO;
        }
        field(85; "Created Datetime"; DateTime)
        {
            Caption = 'Created Datetime';
            DataClassification = CustomerContent;
        }
        field(90; "Display Name"; Text[100])
        {
            Caption = 'Display Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(91; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
            Description = '## depricated';
            TableRelation = Contact;
        }
        field(199; "Document ID"; Text[100])
        {
            Caption = 'Document ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "External Member No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MembershipRole: Record "MM Membership Role";
        MemberCard: Record "MM Member Card";
        MemberNotificationEntry: Record "MM Member Notification Entry";
        Contact: Record Contact;
    begin
        MembershipRole.SetCurrentKey("Member Entry No.");
        MembershipRole.SetFilter("Member Entry No.", '=%1', "Entry No.");
        //-MM1.29 [313741]
        if (MembershipRole.FindSet()) then begin
            repeat
                if (Contact.Get(MembershipRole."Contact No.")) then begin
                    Contact."Magento Contact" := false;
                    Contact.Modify(true);
                end;
            until (MembershipRole.Next() = 0);
        end;
        //+MM1.29 [313741]

        MembershipRole.DeleteAll();

        if (MemberCard.SetCurrentKey("Member Entry No.")) then;
        MemberCard.SetFilter("Member Entry No.", '=%1', "Entry No.");
        MemberCard.DeleteAll();

        if (MemberNotificationEntry.SetCurrentKey("Member Entry No.")) then;
        MemberNotificationEntry.SetFilter("Member Entry No.", '=%1', "Entry No.");
        MemberNotificationEntry.DeleteAll();
    end;

    trigger OnInsert()
    begin
        "Display Name" := StrSubstNo('%1 %2', "First Name", "Last Name");
        "Created Datetime" := CurrentDateTime();
    end;

    trigger OnModify()
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipRole: Record "MM Membership Role";
        Member: Record "MM Member";
    begin
        "Display Name" := StrSubstNo('%1 %2', "First Name", "Last Name");

        //-MM1.18 [265340]
        MembershipRole.SetFilter("Member Entry No.", '=%1', "Entry No.");
        if (MembershipRole.FindSet()) then begin
            repeat
                //MembershipManagement.SynchronizeCustomerAndContact (MembershipRole."Membership Entry No.");
                MembershipManagement.UpdateContactFromMember(MembershipRole."Membership Entry No.", Rec);
            until (MembershipRole.Next() = 0);
        end;
        //+MM1.18 [265340]
    end;
}

