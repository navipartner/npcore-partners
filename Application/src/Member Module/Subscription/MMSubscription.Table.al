table 6150918 "NPR MM Subscription"
{
    Access = Internal;
    Caption = 'Subscription';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR MM Subscription Details";
    LookupPageId = "NPR MM Subscription Details";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(20; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership"."Entry No.";
        }
        field(30; "Membership Ledger Entry No."; Integer)
        {
            Caption = 'Membership Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Entry"."Entry No.";
        }
        field(40; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup".Code;
        }
        field(50; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(100; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(101; "Started At"; DateTime)
        {
            Caption = 'Started At';
            DataClassification = CustomerContent;
        }
        field(110; "Valid Until Date"; Date)
        {
            Caption = 'Valid Until Date';
            DataClassification = CustomerContent;
        }
        field(111; "Committed Until"; Date)
        {
            Caption = 'Committed Until';
            DataClassification = CustomerContent;
        }
        field(120; "Postpone Renewal Attempt Until"; Date)
        {
            Caption = 'Postpone Renewal Attempt Until';
            DataClassification = CustomerContent;
        }
        field(200; "Outst. Subscr. Requests Exist"; Boolean)
        {
            Caption = 'Outst. Subscr. Requests Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("NPR MM Subscr. Request" where("Subscription Entry No." = field("Entry No."), Type = field("Subscr. Request Type Filter"), "Processing Status" = Filter(Pending | Error), Status = filter(<> Cancelled)));
        }
        field(210; "Subscr. Request Type Filter"; Enum "NPR MM Subscr. Request Type")
        {
            Caption = 'Subscr. Request Type Filter';
            FieldClass = FlowFilter;
        }
        field(230; "Auto-Renew"; ENUM "NPR MM MembershipAutoRenew")
        {
            Caption = 'Auto-Renew';
            DataClassification = CustomerContent;
        }
        field(250; "Terminate At"; Date)
        {
            Caption = 'Terminate At';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-11-03';
            ObsoleteReason = 'Moved to NPR MM Subscr. Request table';
        }
        field(251; "Termination Reason"; Enum "NPR MM Subs Termination Reason")
        {
            Caption = 'Termination Reason';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-11-03';
            ObsoleteReason = 'Moved to NPR MM Subscr. Request table';
        }
        field(252; "Termination Requested At"; DateTime)
        {
            Caption = 'Termination Requested At';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-11-03';
            ObsoleteReason = 'Moved to NPR MM Subscr. Request table';
        }
        field(253; "Subscr Renew Sched Date Filter"; Date)
        {
            Caption = 'Subscr. Renew Schedule Date Filter';
            FieldClass = FlowFilter;
        }
        field(254; "Subscr Renew Sched Id Filter"; Guid)
        {
            Caption = 'Subscr Renew Sched Id Filter';
            FieldClass = FlowFilter;
        }
        field(255; "Subscr Renew Sched Req Exist"; Boolean)
        {
            Caption = 'Subscr. Renew Schedule Requests Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("NPR MM Subscr. Request" where("Renew Schedule Date" = field("Subscr Renew Sched Date Filter"), "Renew Schedule Id" = field("Subscr Renew Sched Id Filter"), Type = Const(Renew), Status = filter(<> Cancelled), "Subscription Entry No." = field("Entry No.")));
        }
        field(260; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR MM Membership"."External Membership No." where("Entry No." = field("Membership Entry No.")));
        }
        field(270; "Subscr. Request Count"; Integer)
        {
            Caption = 'Subscr. Request Count';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Request" where("Subscription Entry No." = field("Entry No.")));
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(FromMembership; "Membership Entry No.") { }
        key(Renewal; "Membership Code", Blocked, "Valid Until Date", "Postpone Renewal Attempt Until") { }
        key(Termination; "Terminate At", "Auto-Renew", "Valid Until Date") { }
    }

    trigger OnDelete()
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionRequest.SetRange("Subscription Entry No.", "Entry No.");
        if not SubscriptionRequest.IsEmpty() then
            SubscriptionRequest.DeleteAll(true);
    end;
}