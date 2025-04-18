﻿page 6060071 "NPR MM Members. AutoRenew Card"
{
    Extensible = False;
    Caption = 'Membership Auto Renew Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Auto Renew";

    layout
    {
        area(content)
        {
            group(Selection)
            {
                Editable = AllowEdit;
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {

                    ToolTip = 'Specifies the value of the Valid Until Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Keep Auto-Renew Entries"; Rec."Keep Auto-Renew Entries")
                {

                    ToolTip = 'Specifies the value of the Keep Auto-Renew Entries field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(Invoicing)
            {
                Editable = AllowEdit;
                field("Document Date"; Rec."Document Date")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Document Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Due Date Calculation"; Rec."Due Date Calculation")
                {

                    ToolTip = 'Specifies the value of the Due Date Calculation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Post Invoice"; Rec."Post Invoice")
                {

                    ToolTip = 'Specifies the value of the Post Invoice field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Date Calculation"; Rec."Posting Date Calculation")
                {

                    ToolTip = 'Specifies the value of the Posting Date Calculation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(Statistics)
            {
                field("Started At"; Rec."Started At")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Started At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Completed At"; Rec."Completed At")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Completed At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Started By"; Rec."Started By")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Started By field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Selected Membership Count"; Rec."Selected Membership Count")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Selected Membership Count field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew Success Count"; Rec."Auto-Renew Success Count")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Auto-Renew Success Count field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew Fail Count"; Rec."Auto-Renew Fail Count")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Auto-Renew Fail Count field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Invoice Create Fail Count"; Rec."Invoice Create Fail Count")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Invoice Create Fail Count field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Invoice Posting Fail Count"; Rec."Invoice Posting Fail Count")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Invoice Posting Fail Count field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("First Invoice No."; Rec."First Invoice No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the First Invoice No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Invoice No."; Rec."Last Invoice No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Invoice No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        AllowEdit := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Date" := CalcDate('<CM+1D>', Today);
        Rec."Post Invoice" := true;
        Rec."Posting Date" := CalcDate('<CM+1D>', Today);
        Rec."Valid Until Date" := CalcDate('<CM>', Rec."Document Date");
        AllowEdit := true;
    end;

    var
        AllowEdit: Boolean;
}

