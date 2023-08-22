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
                        Editable = false;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        POSEntryToPost: Record "NPR POS Entry";
        GotErrorDuringPosting: Boolean;
    begin
        POSPostEntries.SetPostCompressed(CompressPosting);
        POSPostEntries.SetStopOnError(ShowErrorDuringPosting);
        POSPostEntries.SetPostPerPeriodRegister(PerPeriodRegisterPosting);

        if (InventoryPosting) then begin
            POSEntryToPost.Reset();
            POSEntryToPost.CopyFilters(POSEntryWithFilter);
            POSPostEntries.SetPostItemEntries(true);
            POSPostEntries.SetPostPOSEntries(false);
            repeat
                if (POSEntryToPost.FindLast()) then
                    POSEntryToPost.SetFilter("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                POSPostEntries.Run(POSEntryToPost);
                Commit();

                GotErrorDuringPosting := not POSEntryToPost.IsEmpty();
                POSEntryToPost.SetFilter("POS Period Register No.", POSEntryWithFilter.GetFilter("POS Period Register No."));
            until (GotErrorDuringPosting or POSEntryToPost.IsEmpty());
        end;

        if (FinancePosting) then begin
            POSEntryToPost.Reset();
            POSEntryToPost.CopyFilters(POSEntryWithFilter);
            POSPostEntries.SetPostItemEntries(false);
            POSPostEntries.SetPostPOSEntries(true);
            repeat
                if (POSEntryToPost.FindLast()) then
                    POSEntryToPost.SetFilter("POS Period Register No.", '=%1', POSEntryToPost."POS Period Register No.");

                POSPostEntries.Run(POSEntryToPost);
                Commit();

                GotErrorDuringPosting := not POSEntryToPost.IsEmpty();
                POSEntryToPost.SetFilter("POS Period Register No.", POSEntryWithFilter.GetFilter("POS Period Register No."));
            until (GotErrorDuringPosting or POSEntryToPost.IsEmpty());
        end;
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
