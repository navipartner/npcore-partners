page 6060077 "NPR MM Recur. Payment Setup"
{
    Extensible = False;
    Caption = 'Recurring Payment Setup';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR MM Recur. Paym. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the recurring payment.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Service Provider Code"; Rec."Payment Service Provider Code")
                {
                    ToolTip = 'Specifies the value of the Payment Service Provider Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("PSP Recurring Plan ID"; Rec."PSP Recurring Plan ID")
                {
                    ToolTip = 'Specifies the value of the PSP Recurring Plan ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Period Alignment"; Rec."Period Alignment")
                {
                    ToolTip = 'Specifies the value of the Period Alignment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Period Size"; Rec."Period Size")
                {
                    ToolTip = 'Specifies the value of the Period Size field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Subscr. Auto-Renewal On"; Rec."Subscr. Auto-Renewal On")
                {
                    ToolTip = 'Specifies when the system should automatically renew subscriptions.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                group(RenewScheduleOpions)
                {
                    ShowCaption = false;
                    Visible = Rec."Subscr. Auto-Renewal On" = Rec."Subscr. Auto-Renewal On"::Schedule;
                    field("Subscr Auto-Renewal Sched Code"; Rec."Subscr Auto-Renewal Sched Code")
                    {
                        ToolTip = 'Specifies the renewal schedule code used when auto-renewal is set to Schedule.';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
                group(RenewWithoutScheduleOpions)
                {
                    ShowCaption = false;
                    Visible = Rec."Subscr. Auto-Renewal On" <> Rec."Subscr. Auto-Renewal On"::Schedule;
                    field("First Attempt Offset (Days)"; Rec."First Attempt Offset (Days)")
                    {
                        ToolTip = 'Specifies how many days before the auto-renewal date the system will first attempt to automatically renew the subscription. This helps to ensure continuity of service for subscribers.';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
                field("Max. Process Error Retry Count"; Rec."Max. Pay. Process Try Count")
                {
                    BlankZero = true;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the maximum number of attempts the system will make to process the recurring payment.';
                }
            }
            group(Commitment)
            {
                Caption = 'Commitment';

                field(SubscriptionCommitStartDate; Rec.SubscriptionCommitStartDate)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the base date for calculating the subscription commit when the subscription is entered.';
                }
                field(SubscriptionCommitmentPeriod; Rec.SubscriptionCommitmentPeriod)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the formula used for calculating the subscription commitment.';
                }
            }
            group(Termination)
            {
                Caption = 'Termination';

                field(TerminationPeriod; Rec.TerminationPeriod)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Termination Period field.';
                }
                field(EnforceTerminationPeriod; Rec.EnforceTerminationPeriod)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enforce Termination Period field.';
                }
            }
            group(Posting)
            {
                field("Gen. Journal Template Name"; Rec."Gen. Journal Template Name")
                {
                    ToolTip = 'Specifies the value of the Gen. Journal Template Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document No. Series"; Rec."Document No. Series")
                {
                    ToolTip = 'Specifies the value of the Document No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the source code the system uses to post subscription renewal related transactions to General Ledger.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Revenue Account"; Rec."Revenue Account")
                {
                    ToolTip = 'Specifies the value of the Revenue Account field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the default value for Global Dimension 1 on subscription posting transactions.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the default value for Global Dimension 2 on subscription posting transactions.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
#if BC17 or BC18
                RunPageLink = "Table ID" = const(6060093), "No." = field(Code);
#else   
                RunPageLink = "Table ID" = const(Database::"NPR MM Recur. Paym. Setup"), "No." = field(Code);
#endif
                ShortCutKey = 'Alt+D';
                ToolTip = 'View or edit default dimensions for subscription postings. These dimensions will be applied to all G/L entries created during subscription renewals.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }
}
