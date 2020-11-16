table 6060128 "NPR MM Membership Role"
{

    Caption = 'Membership Role';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership";
        }
        field(2; "Member Role"; Option)
        {
            Caption = 'Member Role';
            DataClassification = CustomerContent;
            OptionCaption = 'Membership Admin,Member,Anonymous,Guardian,Dependent';
            OptionMembers = ADMIN,MEMBER,ANONYMOUS,GUARDIAN,DEPENDENT;
        }
        field(3; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member";
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Contact: Record Contact;
                MembershipRole: Record "NPR MM Membership Role";
                MembershipManagement: Codeunit "NPR MM Membership Mgt.";
            begin
                "Blocked At" := CreateDateTime(0D, 0T);
                "Blocked By" := '';
                if (Blocked) then begin
                    "Blocked At" := CurrentDateTime();
                    "Blocked By" := UserId;
                end;

                if (Contact.Get(MembershipRole."Contact No.")) then begin
                    Contact.Validate("NPR Magento Contact", not Blocked);
                    Contact.Modify();
                end;

                MembershipManagement.ReflectMembershipRoles(Rec."Membership Entry No.", Rec."Member Entry No.", Rec.Blocked);
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
        field(20; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(21; "User Logon ID"; Code[80])
        {
            Caption = 'User Logon ID';
            DataClassification = CustomerContent;
        }
        field(22; "Password Hash"; Text[80])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(23; "Notification Token"; Text[64])
        {
            Caption = 'Notification Token';
            DataClassification = CustomerContent;
        }
        field(30; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;
        }
        field(35; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(40; "Member Count"; Integer)
        {
            Caption = 'Member Count';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(100; "External Member No."; Code[20])
        {
            CalcFormula = Lookup ("NPR MM Member"."External Member No." WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Member Display Name"; Text[100])
        {
            CalcFormula = Lookup ("NPR MM Member"."Display Name" WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'Member Display Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "External Membership No."; Code[20])
        {
            CalcFormula = Lookup ("NPR MM Membership"."External Membership No." WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(111; "Membership Code"; Code[20])
        {
            CalcFormula = Lookup ("NPR MM Membership"."Membership Code" WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'Membership Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(112; "Company Name"; Text[50])
        {
            CalcFormula = Lookup ("NPR MM Membership"."Company Name" WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'Company Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(410; "Wallet Pass Id"; Text[35])
        {
            Caption = 'Wallet Pass Id';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(500; "GDPR Agreement No."; Code[20])
        {
            Caption = 'GDPR Agreement No.';
            DataClassification = CustomerContent;
            Description = '';
            TableRelation = "NPR GDPR Agreement";
        }
        field(505; "GDPR Data Subject Id"; Text[35])
        {
            Caption = 'GDPR Data Subject Id';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(510; "GDPR Current Entry No."; Integer)
        {
            CalcFormula = Max ("NPR GDPR Consent Log"."Entry No." WHERE("Agreement No." = FIELD("GDPR Agreement No."),
                                                                    "Data Subject Id" = FIELD("GDPR Data Subject Id"),
                                                                    "Agreement Version" = FIELD("GDPR Version Filter"),
                                                                    "Valid From Date" = FIELD("GDPR Date Filter")));
            Caption = 'GDPR Current Entry No.';
            Description = '';
            Editable = false;
            FieldClass = FlowField;
        }
        field(520; "GDPR Approval"; Option)
        {
            CalcFormula = Lookup ("NPR GDPR Consent Log"."Entry Approval State" WHERE("Entry No." = FIELD("GDPR Current Entry No.")));
            Caption = 'GDPR Approval';
            Description = '';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Pending,Accepted,Rejected,Delegated to Guardian';
            OptionMembers = NA,PENDING,ACCEPTED,REJECTED,DELEGATED;
        }
        field(530; "GDPR Version Filter"; Integer)
        {
            Caption = 'GDPR Version Filter';
            Description = '';
            FieldClass = FlowFilter;
        }
        field(540; "GDPR Date Filter"; Date)
        {
            Caption = 'GDPR Date Filter';
            Description = '';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Membership Entry No.", "Member Entry No.")
        {
        }
        key(Key2; "Member Entry No.", "Membership Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

