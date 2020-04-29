page 6151103 "NpRi Reimbursement Entries"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NpRi Reimbursement Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type";"Party Type")
                {
                    Visible = false;
                }
                field("Party No.";"Party No.")
                {
                    Visible = false;
                }
                field("Template Code";"Template Code")
                {
                    Visible = false;
                }
                field("Posting Date";"Posting Date")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Source Company Name";"Source Company Name")
                {
                    Visible = false;
                }
                field("Source Table No.";"Source Table No.")
                {
                }
                field("Source Table Name";"Source Table Name")
                {
                }
                field("Source Record Position";"Source Record Position")
                {
                    Visible = false;
                }
                field("Source Entry No.";"Source Entry No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Amount;Amount)
                {
                }
                field(Positive;Positive)
                {
                }
                field(Open;Open)
                {
                }
                field("Remaining Amount";"Remaining Amount")
                {
                }
                field("Closed by Entry No.";"Closed by Entry No.")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Account Type";"Account Type")
                {
                }
                field("Account No.";"Account No.")
                {
                }
                field("Reimbursement Amount";"Reimbursement Amount")
                {
                }
                field("Last modified by";"Last modified by")
                {
                }
                field("Last modified at";"Last modified at")
                {
                }
                field("Entry No.";"Entry No.")
                {
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

                trigger OnAction()
                var
                    NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
                    NpRiReimbursementMgt: Codeunit "NpRi Reimbursement Mgt.";
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

                trigger OnAction()
                var
                    NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
                    NpRiReimbursementMgt: Codeunit "NpRi Reimbursement Mgt.";
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

                trigger OnAction()
                var
                    NpRiSetupMgt: Codeunit "NpRi Setup Mgt.";
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

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date","Document No.");
                    Navigate.Run;
                end;
            }
        }
    }
}

