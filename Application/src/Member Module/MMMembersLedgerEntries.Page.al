page 6060129 "NPR MM Members. Ledger Entries"
{
    Extensible = False;
    Caption = 'Membership Ledger Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Activate On First Use"; Rec."Activate On First Use")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Activate On First Use field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {

                    ToolTip = 'Specifies the value of the Valid From Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    Style = Strong;
                    StyleExpr = _Cancelled;
                    ToolTip = 'Specifies the value of the Valid Until Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Created At"; Rec."Created At")
                {

                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Context; Rec.Context)
                {

                    ToolTip = 'Specifies the value of the Context field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Receipt No."; Rec."Receipt No.")
                {

                    ToolTip = 'Specifies the value of the Receipt No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew Entry No."; Rec."Auto-Renew Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Auto-Renew Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(RemainingAmountLCY; RemainingAmountLCY)
                {

                    Caption = 'Remaining Amount (LCY)';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = AccentuateAmount;
                    ToolTip = 'Specifies the value of the Remaining Amount (LCY) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked By"; Rec."Blocked By")
                {

                    ToolTip = 'Specifies the value of the Blocked By field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(InitialValidUntilDate; _InitialValidUntilDate)
                {
                    Caption = 'Initial Valid Until Date';
                    Editable = false;
                    ToolTip = 'Calculates the Initial Valid Until Date using Valid From Date and Duration Dateformula fields';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Entries)
            {
                Caption = 'Membership Ledger Entries';
                ToolTip = 'Opens a list for the entries.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = EditLines;
                RunObject = Page "NPR MM Edit Membership Entries";
                RunPageMode = Edit;
                RunPageLink = "Membership Entry No." = field("Membership Entry No.");
                RunPageView = sorting("Membership Entry No.") order(ascending);
            }
            action("&Navigate")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                ToolTip = 'Executes the Find entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    if (Rec."Document No." <> '') then
                        Navigate.SetDoc(DT2Date(Rec."Created At"), Rec."Document No.");
                    if (Rec."Receipt No." <> '') then
                        Navigate.SetDoc(DT2Date(Rec."Created At"), Rec."Receipt No.");
                    Navigate.Run();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        AccentuateAmount := false;
        if (Rec.CalculateRemainingAmount(OriginalAmountLCY, RemainingAmountLCY, DueDate)) then
            AccentuateAmount := ((RemainingAmountLCY > 0) and (DueDate < Today));

        _InitialValidUntilDate := 0D;
        _Cancelled := false;
        if (Rec."Valid From Date" <> 0D) and (Format(Rec."Duration Dateformula") <> '') then begin
            _InitialValidUntilDate := CalcDate(Rec."Duration Dateformula", Rec."Valid From Date");
            _Cancelled := (Rec."Valid Until Date" <> 0D) and (Rec."Valid Until Date" <> _InitialValidUntilDate);
        end;
    end;

    var
        RemainingAmountLCY: Decimal;
        OriginalAmountLCY: Decimal;
        DueDate: Date;
        AccentuateAmount: Boolean;
        _InitialValidUntilDate: Date;
        _Cancelled: Boolean;
}

