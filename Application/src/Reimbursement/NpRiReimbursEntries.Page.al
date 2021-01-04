page 6151103 "NPR NpRi Reimburs. Entries"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpRi Reimbursement Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; "Party Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Party Type field';
                }
                field("Party No."; "Party No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Party No. field';
                }
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Template Code field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Source Company Name"; "Source Company Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Company Name field';
                }
                field("Source Table No."; "Source Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Table No. field';
                }
                field("Source Table Name"; "Source Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Table Name field';
                }
                field("Source Record Position"; "Source Record Position")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Record Position field';
                }
                field("Source Entry No."; "Source Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Entry No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Positive; Positive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Positive field';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                }
                field("Closed by Entry No."; "Closed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field';
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field';
                }
                field("Reimbursement Amount"; "Reimbursement Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Amount field';
                }
                field("Last modified by"; "Last modified by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last modified by field';
                }
                field("Last modified at"; "Last modified at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last modified at field';
                }
                field("Entry No."; "Entry No.")
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
                    CurrPage.Update;
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
                    NpRiReimbursementEntry.Get("Entry No.");
                    NpRiReimbursementMgt.CancelManualApplication(NpRiReimbursementEntry);
                    CurrPage.Update;
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
                PromotedCategory = Process;
                Scope = Repeater;
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }
}

