page 6248210 "NPR MM Subscription FactBox"
{
    Extensible = false;
    Caption = 'Subscription FactBox';
    PageType = CardPart;
    SourceTable = "NPR MM Subscription";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew"; Rec."Auto-Renew")
                {
                    ToolTip = 'Specifies the auto-renewal setting.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies whether the subscription is blocked.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(ValidityPeriod)
            {
                Caption = 'Validity Period';
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ToolTip = 'Specifies the current period start date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ToolTip = 'Specifies the current period end date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Committed Until"; Rec."Committed Until")
                {
                    ToolTip = 'Specifies the commitment end date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(MembershipDetails)
            {
                Caption = 'Membership Details';
                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(CurrentPeriodStatus)
            {
                Caption = 'Current Period Status';
                field(ShowCurrentPeriod; ShowCurrentPeriod)
                {
                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                    ToolTip = 'Specifies the current period status.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(SubscriptionRequests)
            {
                Caption = 'Subscription Requests';
                field("Subscr. Request Count"; Rec."Subscr. Request Count")
                {
                    Caption = 'No. of Subscription Requests';
                    ToolTip = 'Specifies the number of subscription requests for this subscription.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    var
        Membership: Record "NPR MM Membership";
        ShowCurrentPeriod: Text[50];
        NeedsActivation: Boolean;
        NotActivatedLbl: Label 'Not activated';
        MembershipExpiredLbl: Label 'Expired';

    trigger OnAfterGetCurrRecord()
    begin
        ClearGlobals();
        GetMembershipDetails();
    end;

    local procedure ClearGlobals()
    begin
        Clear(Membership);
        Clear(ShowCurrentPeriod);
        Clear(NeedsActivation);
    end;

    local procedure GetMembershipDetails()
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        PlaceHolder2Lbl: Label '%1 - %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 - %2 (%3)', Locked = true;
    begin
        Membership.SetLoadFields("Entry No.");
        if not Membership.Get(Rec."Membership Entry No.") then
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
