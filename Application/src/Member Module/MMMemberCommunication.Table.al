table 6151188 "NPR MM Member Communication"
{
    Access = Internal;

    Caption = 'Member Communication';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR MM Member";
        }
        field(2; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR MM Membership Role"."Membership Entry No." WHERE("Member Entry No." = FIELD("Member Entry No."));
        }
        field(3; "Message Type"; Option)
        {
            Caption = 'Message Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Welcome,Renew,Newsletter,Member Card,Tickets,Coupons';
            OptionMembers = WELCOME,RENEW,NEWSLETTER,MEMBERCARD,TICKETS,COUPONS;
        }
        field(20; "Preferred Method"; Option)
        {
            Caption = 'Preferred Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Manual,SMS,E-Mail,Wallet (SMS),Wallet (E-Mail)';
            OptionMembers = MANUAL,SMS,EMAIL,WALLET_SMS,WALLET_EMAIL;
        }
        field(30; "Accepted Communication"; Option)
        {
            Caption = 'Accepted Communication';
            DataClassification = CustomerContent;
            OptionCaption = 'Pending,Opt-In,Opt-Out';
            OptionMembers = PENDING,"OPT-IN","OPT-OUT";
        }
        field(40; "Changed At"; DateTime)
        {
            Caption = 'Changed At';
            DataClassification = CustomerContent;
        }
        field(100; "Display Name"; Text[100])
        {
            CalcFormula = Lookup("NPR MM Member"."Display Name" WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'Display Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "External Member No."; Code[20])
        {
            CalcFormula = Lookup("NPR MM Member"."External Member No." WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "External Membership No."; Code[20])
        {
            CalcFormula = Lookup("NPR MM Membership"."External Membership No." WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Membership Code"; Code[20])
        {
            CalcFormula = Lookup("NPR MM Membership"."Membership Code" WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'Membership Code';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Member Entry No.", "Membership Entry No.", "Message Type")
        {
        }
    }

    fieldgroups
    {
    }
}

