table 6060091 "MM Admission Service Entry"
{
    // NPR5.31/NPKNAV/20170502  CASE 263737 Transport NPR5.31 - 2 May 2017
    // NPR5.43/CLVA  /20180627  CASE 318579 Added new fields "Ticket Type Code","Ticket Type Description","Membership Code" and "Membership Description"
    // NPR5.44/CLVA  /20180711  CASE 318579 Changed field lenght on "Ticket Type Description" from 30 to 50

    Caption = 'MM Admission Service Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "MM Admission Service Entries";
    LookupPageID = "MM Admission Service Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Blank,Ticket,Membership';
            OptionMembers = Blank,Ticket,Membership;
        }
        field(11; "Created Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(12; "Modify Date"; DateTime)
        {
            Caption = 'Modify Date';
            DataClassification = CustomerContent;
        }
        field(13; Token; Code[50])
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
        field(14; "Key"; Code[20])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(15; Arrived; Boolean)
        {
            Caption = 'Arrived';
            DataClassification = CustomerContent;
        }
        field(16; "Admission Is Valid"; Boolean)
        {
            Caption = 'Admission Is Valid';
            DataClassification = CustomerContent;
        }
        field(20; "Card Entry No."; Integer)
        {
            Caption = 'Card Entry No.';
            DataClassification = CustomerContent;
        }
        field(21; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
        }
        field(22; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
        }
        field(23; "External Card No."; Text[50])
        {
            Caption = 'External Card No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MembershipManagement: Codeunit "MM Membership Management";
                NotFoundReasonText: Text;
            begin
            end;
        }
        field(24; "External Membership No."; Code[20])
        {
            CalcFormula = Lookup ("MM Membership"."External Membership No." WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "External Member No."; Code[20])
        {
            CalcFormula = Lookup ("MM Member"."External Member No." WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Display Name"; Text[100])
        {
            Caption = 'Display Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; Message; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(28; "Scanner Station Id"; Code[10])
        {
            Caption = 'Scanner Station Id';
            DataClassification = CustomerContent;
        }
        field(29; "Ticket Entry No."; Code[20])
        {
            Caption = 'Ticket Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "TM Ticket";
        }
        field(30; "External Ticket No."; Code[30])
        {
            Caption = 'External Ticket No.';
            DataClassification = CustomerContent;
        }
        field(31; "Ticket Type Code"; Code[10])
        {
            Caption = 'Ticket Type Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(32; "Ticket Type Description"; Text[50])
        {
            Caption = 'Ticket Type Description';
            DataClassification = CustomerContent;
        }
        field(33; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
        }
        field(34; "Membership Description"; Text[50])
        {
            Caption = 'Membership Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

