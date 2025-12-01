page 6248208 "NPR MMSubscrPmtRequest FactBox"
{
    Extensible = False;
    Caption = 'Subscription Payment Request FactBox';
    PageType = CardPart;
    SourceTable = "NPR MM Subscr. Payment Request";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(general)
            {
                Caption = 'General';
                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("PSP Reference"; Rec."PSP Reference")
                {
                    ToolTip = 'Specifies the value of the PSP Reference field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment PSP Reference"; Rec."Payment PSP Reference")
                {
                    ToolTip = 'Specifies the value of the Payment PSP Reference field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Subscription Payment Reference"; Rec."Subscription Payment Reference")
                {
                    ToolTip = 'Specifies the value of the Subscription Payment Reference field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(contactDetails)
            {
                Caption = 'Contact Details';
                field("Payment E-mail"; Rec."Payment E-mail")
                {
                    ToolTip = 'Specifies the value of the Payment E-mail field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Phone No."; Rec."Payment Phone No.")
                {
                    ToolTip = 'Specifies the value of the Payment Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(MembershipDetails)
            {
                Caption = 'Membership Details';

                field(MembershipCustomerNo; Membership."Customer No.")
                {
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(MembershipCode; Membership."Membership Code")
                {
                    Caption = 'Membership Code';
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(ShowCurrentPeriod; ShowCurrentPeriod)
                {
                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                    ToolTip = 'Specifies the value of the Current Period field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(AutoRenew; Membership."Auto-Renew")
                {
                    Caption = 'Auto-Renew';
                    ToolTip = 'Specifies whether the membership is set to auto-renew.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Membership.Blocked)
                {
                    Caption = 'Blocked';
                    ToolTip = 'Specifies whether the membership is blocked.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(SubscriptionRequestDetails)
            {
                Caption = 'Subscription Request Details';
                field("Subscr. Request Entry No."; Rec."Subscr. Request Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscr. Request Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Type; SubscriptionRequest.Type)
                {
                    ToolTip = 'Specifies the value of the Subscription Request Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(ProcessingStatus; SubscriptionRequest."Processing Status")
                {
                    ToolTip = 'Specifies the value of the Subscription Request Processing Status field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; SubscriptionRequest.Description)
                {
                    ToolTip = 'Specifies the value of the Subscription Request Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

            }
        }
    }

    var
        ShowCurrentPeriod: Text[30];
        NeedsActivation: Boolean;
        NOT_ACTIVATED: Label 'Not activated';
        MEMBERSHIP_EXPIRED: Label 'Expired';
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";

    trigger OnAfterGetCurrRecord()
    begin
        Clear(Membership);
        Clear(SubscriptionRequest);

        GetMembership();
        GetSubscrRequest();
    end;

    local procedure GetMembership()
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        PlaceHolder2Lbl: Label '%1 - %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 - %2 (%3)', Locked = true;
    begin
        Membership.SetLoadFields("Entry No.", "Customer No.", "Membership Code", "Auto-Renew", Blocked);
        Membership.SetRange("External Membership No.", Rec."External Membership No.");
        if not Membership.FindFirst() then
            exit;
        NeedsActivation := MembershipManagement.MembershipNeedsActivation(Membership."Entry No.");
        ShowCurrentPeriod := NOT_ACTIVATED;
        if (not NeedsActivation) then begin
            MembershipManagement.GetMembershipValidDate(Membership."Entry No.", Today, ValidFromDate, ValidUntilDate);
            ShowCurrentPeriod := StrSubstNo(PlaceHolder2Lbl, ValidFromDate, ValidUntilDate);
            if (ValidUntilDate < Today) then
                ShowCurrentPeriod := StrSubstNo(PlaceHolder3Lbl, ValidFromDate, ValidUntilDate, MEMBERSHIP_EXPIRED);
        end;
    end;

    local procedure GetSubscrRequest()
    begin
        SubscriptionRequest.SetLoadFields("Entry No.", Type, "Processing Status", Status, Description);
        if not SubscriptionRequest.Get(Rec."Subscr. Request Entry No.") then
            exit;
    end;
}