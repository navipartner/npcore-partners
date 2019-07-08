table 6151164 "MM Membership (UPG)"
{
    // MM1.39/TSA /20190527 CASE 350968 VLOBJUPG Upgrade table for changing datatype on auto-renew from bool to option

    Caption = 'Membership';
    DrillDownPageID = "MM Memberships";
    LookupPageID = "MM Memberships";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(9;"External Membership No.";Code[20])
        {
            Caption = 'External Membership No.';
        }
        field(30;"Auto-Renew";Boolean)
        {
            Caption = 'Auto-Renew';
        }
        field(35;"Auto-Renew Payment Method Code";Code[10])
        {
            Caption = 'Auto-Renew Payment Method Code';
            TableRelation = "Payment Method";
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"External Membership No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipRole: Record "MM Membership Role";
        MembershipLedgerEntry: Record "MM Membership Entry";
        MemberCard: Record "MM Member Card";
        MembershipSetup: Record "MM Membership Setup";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin
    end;

    trigger OnModify()
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipRole: Record "MM Membership Role";
        Community: Record "MM Member Community";
    begin
    end;

    var
        RELINK_MEMBERSHIP: Label 'Are you sure you want to link %1 %2 with %3 %4?';
        DUPLICATE_CUSTOMERNO: Label 'When %1 is activated, memberships must have unique customer numbers. Membership %2 and %3 can not have the same %4 %5.';
}

