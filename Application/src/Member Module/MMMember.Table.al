table 6060126 "NPR MM Member"
{

    Caption = 'Member';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Members";
    LookupPageID = "NPR MM Members";

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
                MembershipRole: Record "NPR MM Membership Role";
                Contact: Record Contact;
            begin
                "Blocked At" := CreateDateTime(0D, 0T);
                "Blocked By" := '';
                if (Blocked) then begin
                    "Blocked At" := CurrentDateTime();
                    "Blocked By" := UserId;
                end;

                MembershipRole.SetFilter("Member Entry No.", '=%1', "Entry No.");
                MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
                if (MembershipRole.FindSet()) then begin
                    repeat
                        // -MM1.41 [369123]
                        MembershipRole.Validate(Blocked, Blocked);
                        MembershipRole.Modify();

                        if (Contact.Get(MembershipRole."Contact No.")) then begin
                            Contact.Validate("NPR Magento Contact", not Blocked);
                            Contact.Modify();
                        end;
                    until (MembershipRole.Next() = 0);
                end;

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
        field(500; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store";
            ValidateTableRelation = false;
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
        MembershipRole: Record "NPR MM Membership Role";
        MemberCard: Record "NPR MM Member Card";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        Contact: Record Contact;
    begin
        MembershipRole.SetCurrentKey("Member Entry No.");
        MembershipRole.SetFilter("Member Entry No.", '=%1', "Entry No.");

        if (MembershipRole.FindSet()) then begin
            repeat
                if (Contact.Get(MembershipRole."Contact No.")) then begin
                    Contact."NPR Magento Contact" := false;
                    Contact.Modify(true);
                end;
            until (MembershipRole.Next() = 0);
        end;

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
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipRole: Record "NPR MM Membership Role";
    begin
        "Display Name" := StrSubstNo('%1 %2', "First Name", "Last Name");

        MembershipRole.SetFilter("Member Entry No.", '=%1', "Entry No.");
        if (MembershipRole.FindSet()) then begin
            repeat
                //MembershipManagement.SynchronizeCustomerAndContact (MembershipRole."Membership Entry No.");
                MembershipManagement.UpdateContactFromMember(MembershipRole."Membership Entry No.", Rec);
            until (MembershipRole.Next() = 0);
        end;

    end;
}

