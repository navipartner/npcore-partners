page 6151103 "NPR NpRi Reimburs. Entries"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Entries';
    Editable = false;
    PageType = List;
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
                }
                field("Party No."; "Party No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Source Company Name"; "Source Company Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Table No."; "Source Table No.")
                {
                    ApplicationArea = All;
                }
                field("Source Table Name"; "Source Table Name")
                {
                    ApplicationArea = All;
                }
                field("Source Record Position"; "Source Record Position")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Entry No."; "Source Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field(Positive; Positive)
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                }
                field("Closed by Entry No."; "Closed by Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                }
                field("Reimbursement Amount"; "Reimbursement Amount")
                {
                    ApplicationArea = All;
                }
                field("Last modified by"; "Last modified by")
                {
                    ApplicationArea = All;
                }
                field("Last modified at"; "Last modified at")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
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

