page 6014658 "NPR MM Membership FactBox"
{
    Caption = 'Membership FactBox';
    PageType = CardPart;
    SourceTable = "NPR MM Membership";
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
                    ApplicationArea = NPRRetail;
                }
                field(ShowCurrentPeriod; ShowCurrentPeriod)
                {
                    Caption = 'Current Period';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = NeedsActivation;
                    ToolTip = 'Specifies the value of the Current Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Issued Date"; Rec."Issued Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Issued Date field';
                    ApplicationArea = NPRRetail;
                }

            }
            group(details)
            {
                Caption = 'Details';

                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Community Code"; Rec."Community Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Control6014412; Rec."Auto-Renew")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Renew Payment Method Code"; Rec."Auto-Renew Payment Method Code")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }

            }

            group("system")
            {
                Caption = 'System';
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Block Reason"; Rec."Block Reason")
                {
                    ToolTip = 'Specifies the value of the Block Reason field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked By"; Rec."Blocked By")
                {
                    ToolTip = 'Specifies the value of the Blocked By field';
                    ApplicationArea = NPRRetail;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field';
                    ApplicationArea = NPRRetail;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        ShowCurrentPeriod: Text[30];
        NeedsActivation: Boolean;
        NOT_ACTIVATED: Label 'Not activated';
        MEMBERSHIP_EXPIRED: Label 'Expired';

    trigger OnAfterGetCurrRecord()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        PlaceHolder2Lbl: Label '%1 - %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 - %2 (%3)', Locked = true;
    begin
        NeedsActivation := MembershipManagement.MembershipNeedsActivation(Rec."Entry No.");
        ShowCurrentPeriod := NOT_ACTIVATED;
        if (not NeedsActivation) then begin
            MembershipManagement.GetMembershipValidDate(Rec."Entry No.", Today, ValidFromDate, ValidUntilDate);
            ShowCurrentPeriod := StrSubstNo(PlaceHolder2Lbl, ValidFromDate, ValidUntilDate);
            if (ValidUntilDate < Today) then
                ShowCurrentPeriod := StrSubstNo(PlaceHolder3Lbl, ValidFromDate, ValidUntilDate, MEMBERSHIP_EXPIRED);
        end;
    end;
}