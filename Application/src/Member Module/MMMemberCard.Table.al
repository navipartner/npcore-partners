table 6060131 "NPR MM Member Card"
{

    Caption = 'Member Card';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Member Card List";
    LookupPageID = "NPR MM Member Card List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "External Card No."; Text[100])
        {
            Caption = 'External Card No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                NotFoundReasonText: Text;
            begin

                if (MembershipManagement.GetMembershipFromExtCardNo("External Card No.", Today, NotFoundReasonText) <> 0) then
                    Error(TEXT6060000, FieldCaption("External Card No."), "External Card No.");
            end;
        }
        field(11; "External Card No. Last 4"; Code[4])
        {
            Caption = 'External Card No. Last 4';
            DataClassification = CustomerContent;
        }
        field(12; "Pin Code"; Text[50])
        {
            Caption = 'Pin Code';
            DataClassification = CustomerContent;
        }
        field(13; "Valid Until"; Date)
        {
            Caption = 'Valid Until';
            DataClassification = CustomerContent;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Blocked At" := CreateDateTime(0D, 0T);
                "Blocked By" := '';
                if (Blocked) then begin
                    "Blocked At" := CurrentDateTime();
                    "Blocked By" := UserId;
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
        field(20; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
        }
        field(21; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
        }
        field(30; "Card Is Temporary"; Boolean)
        {
            Caption = 'Card Is Temporary';
            DataClassification = CustomerContent;
        }
        field(40; "Card Type"; Option)
        {
            Caption = 'Card Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Internal,External';
            OptionMembers = INTERNAL,EXTERNAL;
        }
        field(100; "External Member No."; Code[20])
        {
            CalcFormula = Lookup ("NPR MM Member"."External Member No." WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Member Blocked"; Boolean)
        {
            CalcFormula = Lookup ("NPR MM Member".Blocked WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'Member Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Display Name"; Text[100])
        {
            CalcFormula = Lookup ("NPR MM Member"."Display Name" WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'Display Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "E-Mail Address"; Text[80])
        {
            CalcFormula = Lookup ("NPR MM Member"."E-Mail Address" WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'E-Mail Address';
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
        field(111; "Membership Blocked"; Boolean)
        {
            CalcFormula = Lookup ("NPR MM Membership".Blocked WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'Membership Blocked';
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
        field(113; "Membership Code"; Code[20])
        {
            CalcFormula = Lookup ("NPR MM Membership"."Membership Code" WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'Membership Code';
            Editable = false;
            FieldClass = FlowField;
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
        key(Key2; "External Card No.")
        {
        }
        key(Key3; "Membership Entry No.", "Member Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        TEXT6060000: Label 'The %1 %2 is already in use.';
}

