page 6150940 "NPR MM Subscr. Request FactBox"
{
    Extensible = false;
    Caption = 'Subscription Request FactBox';
    PageType = CardPart;
    SourceTable = "NPR MM Subscr. Request";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("External Membership No."; Membership."External Membership No.")
                {
                    Caption = 'External Membership No.';
                    ToolTip = 'Specifies the value of the External Membership No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Subscription Entry No."; Rec."Subscription Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(MembershipDetails)
            {
                Caption = 'Membership Details';
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(ShowCurrentPeriod; ShowCurrentPeriod)
                {
                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                    ToolTip = 'Specifies the current period status.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(AutoRenew; Subscription."Auto-Renew")
                {
                    Caption = 'Auto-Renew';
                    ToolTip = 'Specifies the auto-renewal setting.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Subscription.Blocked)
                {
                    Caption = 'Blocked';
                    ToolTip = 'Specifies whether the subscription is blocked.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(SubscriptionDetails)
            {
                Caption = 'Subscription Details';
                field("Valid From Date"; Subscription."Valid From Date")
                {
                    Caption = 'Valid From Date';
                    ToolTip = 'Specifies the subscription valid from date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until Date"; Subscription."Valid Until Date")
                {
                    Caption = 'Valid Until Date';
                    ToolTip = 'Specifies the subscription valid until date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(RequestDetails)
            {
                Caption = 'Request Details';
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the value of the Processing Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(PaymentRequests)
            {
                Caption = 'Payment Requests';
                field("Payment Request Count"; Rec."Subs. Payment Request Count")
                {
                    Caption = 'No. of Payment Requests';
                    ToolTip = 'Specifies the number of payment requests for this subscription request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    var
        Subscription: Record "NPR MM Subscription";
        Membership: Record "NPR MM Membership";
        ShowCurrentPeriod: Text[50];
        NeedsActivation: Boolean;
        NotActivatedLbl: Label 'Not activated';
        MembershipExpiredLbl: Label 'Expired';

    trigger OnAfterGetCurrRecord()
    begin
        ClearGlobals();
        GetSubscriptionDetails();
    end;

    local procedure ClearGlobals()
    begin
        Clear(Subscription);
        Clear(Membership);
        Clear(ShowCurrentPeriod);
        Clear(NeedsActivation);
    end;

    local procedure GetSubscriptionDetails()
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        PlaceHolder2Lbl: Label '%1 - %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 - %2 (%3)', Locked = true;
    begin
        Subscription.SetLoadFields("Membership Entry No.", "Auto-Renew", Blocked, "Valid From Date", "Valid Until Date");
        if not Subscription.Get(Rec."Subscription Entry No.") then
            exit;

        Membership.SetLoadFields("Entry No.", "External Membership No.");
        if not Membership.Get(Subscription."Membership Entry No.") then
            exit;

        NeedsActivation := MembershipManagement.MembershipNeedsActivation(Membership."Entry No.");
        ShowCurrentPeriod := NotActivatedLbl;
        if not NeedsActivation then begin
            MembershipManagement.GetMembershipValidDate(Membership."Entry No.", Today, ValidFromDate, ValidUntilDate);
            ShowCurrentPeriod := StrSubstNo(PlaceHolder2Lbl, ValidFromDate, ValidUntilDate);
            if ValidUntilDate < Today then
                ShowCurrentPeriod := StrSubstNo(PlaceHolder3Lbl, ValidFromDate, ValidUntilDate, MembershipExpiredLbl);
        end;
    end;
}
