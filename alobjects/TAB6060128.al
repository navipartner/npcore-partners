table 6060128 "MM Membership Role"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.10/TSA/20160321  CASE 237176 Added flowfield company name
    // MM1.18/TSA/20170302  CASE 265340 Added field contact no, the field on member shoul be deprecated
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.22/TSA /20170816 CASE 287080 Added option Anonymous and field "Member Count", "Created At"
    // MM1.22/TSA /20170818 CASE 279343 Cascade member block to contact
    // MM1.22/TSA /20170904 CASE 276832 Added option Guardian to Role Type
    // MM1.29/TSA /20180504 CASE 314131 Added fields for wallet
    // MM1.29/TSA /20180522 CASE 313795 Added option Dependent to Role Type
    // MM1.36/TSA /20181114 CASE 335667 Added function ReflectMembershipRoles()
    // MM1.38/TSA /20190517 CASE 355234 Added Notification Token fiels, renamed "Password SHA1" to "Password Hash" and extended to 80

    Caption = 'Membership Role';

    fields
    {
        field(1;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
            TableRelation = "MM Membership";
        }
        field(2;"Member Role";Option)
        {
            Caption = 'Member Role';
            OptionCaption = 'Membership Admin,Member,Anonymous,Guardian,Dependent';
            OptionMembers = ADMIN,MEMBER,ANONYMOUS,GUARDIAN,DEPENDENT;
        }
        field(3;"Member Entry No.";Integer)
        {
            Caption = 'Member Entry No.';
            TableRelation = "MM Member";
        }
        field(15;Blocked;Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            var
                Contact: Record Contact;
                MembershipRole: Record "MM Membership Role";
                MembershipManagement: Codeunit "MM Membership Management";
            begin
                "Blocked At" := CreateDateTime (0D, 0T);
                "Blocked By" := '';
                if (Blocked) then begin
                  "Blocked At" := CurrentDateTime ();
                  "Blocked By" := UserId;
                end;

                //-MM1.22 [279343]
                if (Contact.Get (MembershipRole."Contact No.")) then begin
                  Contact.Validate ("Magento Contact", not Blocked);
                  Contact.Modify();
                end;
                //+MM1.22 [279343]

                MembershipManagement.ReflectMembershipRoles (Rec."Membership Entry No.", Rec."Member Entry No.", Rec.Blocked);
            end;
        }
        field(16;"Blocked At";DateTime)
        {
            Caption = 'Blocked At';
            Editable = false;
        }
        field(17;"Blocked By";Code[30])
        {
            Caption = 'Blocked By';
            Editable = false;
        }
        field(18;"Block Reason";Option)
        {
            Caption = 'Block Reason';
            OptionCaption = ' ,Expired,User Request,Internal,Anonymized';
            OptionMembers = UNKNOWN,EXPIRED,USER_REQUEST,INTERNAL,ANONYMIZED;
        }
        field(20;"Community Code";Code[20])
        {
            Caption = 'Community Code';
            TableRelation = "MM Member Community";
        }
        field(21;"User Logon ID";Code[80])
        {
            Caption = 'User Logon ID';
        }
        field(22;"Password Hash";Text[80])
        {
            Caption = 'Password';
        }
        field(23;"Notification Token";Text[64])
        {
            Caption = 'Notification Token';
        }
        field(30;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;
        }
        field(35;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(40;"Member Count";Integer)
        {
            Caption = 'Member Count';
            InitValue = 1;
        }
        field(100;"External Member No.";Code[20])
        {
            CalcFormula = Lookup("MM Member"."External Member No." WHERE ("Entry No."=FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101;"Member Display Name";Text[100])
        {
            CalcFormula = Lookup("MM Member"."Display Name" WHERE ("Entry No."=FIELD("Member Entry No.")));
            Caption = 'Member Display Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"External Membership No.";Code[20])
        {
            CalcFormula = Lookup("MM Membership"."External Membership No." WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(111;"Membership Code";Code[20])
        {
            CalcFormula = Lookup("MM Membership"."Membership Code" WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'Membership Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(112;"Company Name";Text[50])
        {
            CalcFormula = Lookup("MM Membership"."Company Name" WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'Company Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(410;"Wallet Pass Id";Text[35])
        {
            Caption = 'Wallet Pass Id';
            Description = '//-MM1.29 [314131]';
        }
        field(500;"GDPR Agreement No.";Code[20])
        {
            Caption = 'GDPR Agreement No.';
            Description = '//-MM1.29 [313795]';
            TableRelation = "GDPR Agreement";
        }
        field(505;"GDPR Data Subject Id";Text[35])
        {
            Caption = 'GDPR Data Subject Id';
            Description = '//-MM1.29 [313795]';
        }
        field(510;"GDPR Current Entry No.";Integer)
        {
            CalcFormula = Max("GDPR Consent Log"."Entry No." WHERE ("Agreement No."=FIELD("GDPR Agreement No."),
                                                                    "Data Subject Id"=FIELD("GDPR Data Subject Id"),
                                                                    "Agreement Version"=FIELD("GDPR Version Filter"),
                                                                    "Valid From Date"=FIELD("GDPR Date Filter")));
            Caption = 'GDPR Current Entry No.';
            Description = '//-MM1.29 [313795]';
            Editable = false;
            FieldClass = FlowField;
        }
        field(520;"GDPR Approval";Option)
        {
            CalcFormula = Lookup("GDPR Consent Log"."Entry Approval State" WHERE ("Entry No."=FIELD("GDPR Current Entry No.")));
            Caption = 'GDPR Approval';
            Description = '//-MM1.29 [313795]';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Pending,Accepted,Rejected,Delegated to Guardian';
            OptionMembers = NA,PENDING,ACCEPTED,REJECTED,DELEGATED;
        }
        field(530;"GDPR Version Filter";Integer)
        {
            Caption = 'GDPR Version Filter';
            Description = '//-MM1.29 [313795]';
            FieldClass = FlowFilter;
        }
        field(540;"GDPR Date Filter";Date)
        {
            Caption = 'GDPR Date Filter';
            Description = '//-MM1.29 [313795]';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1;"Membership Entry No.","Member Entry No.")
        {
        }
        key(Key2;"Member Entry No.","Membership Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

