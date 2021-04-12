page 6060071 "NPR MM Members. AutoRenew Card"
{

    Caption = 'Membership Auto Renew Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until Date field';
                }
                field("Keep Auto-Renew Entries"; Rec."Keep Auto-Renew Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keep Auto-Renew Entries field';
                }
            }
            group(Invoicing)
            {
                Editable = AllowEdit;
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                }
                field("Due Date Calculation"; Rec."Due Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Due Date Calculation field';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Post Invoice"; Rec."Post Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Invoice field';
                }
                field("Posting Date Calculation"; Rec."Posting Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date Calculation field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
            }
            group(Statistics)
            {
                field("Started At"; Rec."Started At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Started At field';
                }
                field("Completed At"; Rec."Completed At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Completed At field';
                }
                field("Started By"; Rec."Started By")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Started By field';
                }
                field("Selected Membership Count"; Rec."Selected Membership Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Selected Membership Count field';
                }
                field("Auto-Renew Success Count"; Rec."Auto-Renew Success Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Auto-Renew Success Count field';
                }
                field("Auto-Renew Fail Count"; Rec."Auto-Renew Fail Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Auto-Renew Fail Count field';
                }
                field("Invoice Create Fail Count"; Rec."Invoice Create Fail Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Invoice Create Fail Count field';
                }
                field("Invoice Posting Fail Count"; Rec."Invoice Posting Fail Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Invoice Posting Fail Count field';
                }
                field("First Invoice No."; Rec."First Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the First Invoice No. field';
                }
                field("Last Invoice No."; Rec."Last Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Invoice No. field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        AutoRenewCompleted := (Rec."Completed At" <> CreateDateTime(0D, 0T));
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
        AutoRenewCompleted: Boolean;
        AllowEdit: Boolean;
}

