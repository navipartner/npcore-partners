report 6014438 "NPR POS Posting Action"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    Caption = 'POS Posting Action';
    UsageCategory = None;
    ProcessingOnly = true;
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field("Inventory Posting"; InventoryPosting)
                    {
                        Caption = 'Inventory Post';
                        ToolTip = 'If checked system will try to post entries in Item Ledger Entry';
                        ApplicationArea = NPRRetail;
                    }
                    field("Finance Posting"; FinancePosting)
                    {
                        Caption = 'General Ledger Post';
                        ToolTip = 'If checked system will try to post entries in G/L Entry, etc...';
                        ApplicationArea = NPRRetail;
                    }
                    field("Compress Posting"; CompressPosting)
                    {
                        Caption = 'Post Compressed';
                        ToolTip = 'If checked system will post entries compressed';
                        ApplicationArea = NPRRetail;
                        Editable = CompressPostingEditable;
                    }
                    field("Show Error During Posting"; ShowErrorDuringPosting)
                    {
                        Caption = 'Stop on Error';
                        ToolTip = 'If checked system will stop on first error';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryToPost: Record "NPR POS Entry";
    begin
        POSPostEntries.SetPostCompressed(CompressPosting);
        POSPostEntries.SetStopOnError(ShowErrorDuringPosting);
        POSPostEntries.SetPostPerPeriodRegister(PerPeriodRegisterPosting);
        POSPostEntries.SetPostItemEntries(InventoryPosting);
        POSPostEntries.SetPostPOSEntries(FinancePosting);

        POSEntry.CopyFilters(POSEntryWithFilter);
        POSEntry.SetCurrentKey("POS Period Register No.");
        if POSEntry.FindFirst() then
            repeat
                // Send entries to the posting codeunit in chunks by period register
                POSEntry.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
                POSEntry.FindLast();
                POSEntryToPost.Copy(POSEntry);
                POSPostEntries.Run(POSEntryToPost);
                POSEntryWithFilter.CopyFilter("POS Period Register No.", POSEntry."POS Period Register No.");
            until POSEntry.Next() = 0;
    end;

    internal procedure SetGlobalValues(DoInventoryPosting: Boolean; DoFinancePosting: Boolean; DoShowErrorDuringPosting: Boolean; DoCompressPosting: Boolean; IsCompressPostingEditable: Boolean; DoPerPeriodRegisterPosting: Boolean)
    begin
        InventoryPosting := DoInventoryPosting;
        FinancePosting := DoFinancePosting;
        ShowErrorDuringPosting := DoShowErrorDuringPosting;
        CompressPosting := DoCompressPosting;
        CompressPostingEditable := IsCompressPostingEditable;
        PerPeriodRegisterPosting := DoPerPeriodRegisterPosting;
    end;

    internal procedure SetPOSEntries(var POSEntryWithFilters: Record "NPR POS Entry")
    begin
        POSEntryWithFilter.Reset();
        POSEntryWithFilter.CopyFilters(POSEntryWithFilters);
    end;

    var
        POSEntryWithFilter: Record "NPR POS Entry";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        ShowErrorDuringPosting: Boolean;
        InventoryPosting: Boolean;
        FinancePosting: Boolean;
        CompressPosting: Boolean;
        CompressPostingEditable: Boolean;
        PerPeriodRegisterPosting: Boolean;
}
