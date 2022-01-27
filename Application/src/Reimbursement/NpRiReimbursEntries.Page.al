page 6151103 "NPR NpRi Reimburs. Entries"
{
    Extensible = False;
    Caption = 'Reimbursement Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpRi Reimbursement Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; Rec."Party Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Party Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Party No."; Rec."Party No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Party No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Code"; Rec."Template Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Company Name"; Rec."Source Company Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Table No."; Rec."Source Table No.")
                {

                    ToolTip = 'Specifies the value of the Source Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {

                    ToolTip = 'Specifies the value of the Source Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Record Position"; Rec."Source Record Position")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Record Position field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {

                    ToolTip = 'Specifies the value of the Source Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Positive; Rec.Positive)
                {

                    ToolTip = 'Specifies the value of the Positive field';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {

                    ToolTip = 'Specifies the value of the Remaining Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {

                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Account Type"; Rec."Account Type")
                {

                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Account No."; Rec."Account No.")
                {

                    ToolTip = 'Specifies the value of the Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reimbursement Amount"; Rec."Reimbursement Amount")
                {

                    ToolTip = 'Specifies the value of the Reimbursement Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Last modified by"; Rec."Last modified by")
                {

                    ToolTip = 'Specifies the value of the Last modified by field';
                    ApplicationArea = NPRRetail;
                }
                field("Last modified at"; Rec."Last modified at")
                {

                    ToolTip = 'Specifies the value of the Last modified at field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Apply Entries")
            {
                Caption = 'Apply Entries';
                Image = ApplyEntries;
                Scope = Repeater;
                ShortCutKey = 'Shift+F11';

                ToolTip = 'Executes the Apply Entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
                    NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpRiReimbursementEntry);
                    NpRiReimbursementMgt.ManualApplyEntries(NpRiReimbursementEntry);
                    CurrPage.Update();
                end;
            }
            action("Cancel Manual Application")
            {
                Caption = 'Cancel Manual Application';
                Ellipsis = true;
                Image = UnApply;
                Scope = Repeater;

                ToolTip = 'Executes the Cancel Manual Application action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
                    NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
                begin
                    NpRiReimbursementEntry.Get(Rec."Entry No.");
                    NpRiReimbursementMgt.CancelManualApplication(NpRiReimbursementEntry);
                    CurrPage.Update();
                end;
            }
        }
        area(navigation)
        {
            action("Show Source")
            {
                Caption = 'Show Source';
                Image = Item;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';

                ToolTip = 'Executes the Show Source action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRiSetupMgt: Codeunit "NPR NpRi Setup Mgt.";
                begin
                    NpRiSetupMgt.ShowEntrySource(Rec);
                end;
            }
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                ToolTip = 'Executes the &Navigate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
        }
    }
}

