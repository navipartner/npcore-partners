page 6151103 "NPR NpRi Reimburs. Entries"
{
    Caption = 'Reimbursement Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpRi Reimbursement Entry";
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; Rec."Party Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Party Type field';
                }
                field("Party No."; Rec."Party No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Party No. field';
                }
                field("Template Code"; Rec."Template Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Template Code field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Source Company Name"; Rec."Source Company Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Company Name field';
                }
                field("Source Table No."; Rec."Source Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Table No. field';
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Table Name field';
                }
                field("Source Record Position"; Rec."Source Record Position")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Record Position field';
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Entry No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Positive field';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field';
                }
                field("Reimbursement Amount"; Rec."Reimbursement Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Amount field';
                }
                field("Last modified by"; Rec."Last modified by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last modified by field';
                }
                field("Last modified at"; Rec."Last modified at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last modified at field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Apply Entries action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Cancel Manual Application action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Source action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

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

