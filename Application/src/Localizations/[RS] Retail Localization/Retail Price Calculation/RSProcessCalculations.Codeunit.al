codeunit 6185002 "NPR RS Process Calculations"
{
    Access = Internal;

#if not (BC17 or BC18 or BC19)
    internal procedure ProcessCalculationDocuments(RSRetailCalcDocTypeFilter: Enum "NPR RS Retail Calc. Doc. Type"; DocumentNoFilter: Text; StartDateFilter: Date; EndDateFilter: Date): Boolean
    begin
        SetFilters(DocumentNoFilter, StartDateFilter, EndDateFilter);

        // Will be updated with other Document Types
        if RSRetailCalcDocTypeFilter in [RSRetailCalcDocTypeFilter::"POS Entry"] then
            exit(ProcessCalculationsForPOSEntry());
    end;

    local procedure SetFilters(DocumentNoFilter: Text; StartDateFilter: Date; EndDateFilter: Date)
    begin
        DocumentNo := DocumentNoFilter;
        StartDate := StartDateFilter;
        EndDate := EndDateFilter;
    end;

    local procedure ProcessCalculationsForPOSEntry(): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        RSPOSGLAddition: Codeunit "NPR RS POS GL Addition";
        DialogWindow: Dialog;
        NoOfRecords: Integer;
        RecCount: Integer;
        EntryDateFilterLbl: Label '%1..%2', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        POSEntryTypeFilterLbl: Label '%1|%2', Locked = true, Comment = '%1 = Entry Type, %2 = Entry Type';
        ProcessingPOSEntriesLbl: Label 'Posting Retail Calculations. Info: #1##### of #2#####';
    begin
        POSEntry.SetCurrentKey("Entry No.");

        if DocumentNo <> '' then
            POSEntry.SetFilter("Document No.", DocumentNo);

        if (StartDate <> 0D) or (EndDate <> 0D) then
            POSEntry.SetFilter("Entry Date", StrSubstNo(EntryDateFilterLbl, StartDate, EndDate));

        POSEntry.SetFilter("Entry Type", StrSubstNo(POSEntryTypeFilterLbl, POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale"));
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);

        if POSEntry.IsEmpty() then
            exit(false);

        POSEntry.FindSet();
        repeat
            RSRetValueEntryMapp.SetRange("Document No.", POSEntry."Document No.");
            if RSRetValueEntryMapp.IsEmpty() then
                POSEntry.Mark(true);
        until POSEntry.Next() = 0;

        POSEntry.MarkedOnly(true);

        if POSEntry.IsEmpty() then
            exit(false);

        NoOfRecords := FilterOnlyPOSEntriesFromCurrentSystem(POSEntry);
        if NoOfRecords = 0 then
            exit(false);

        RecCount := 1;

        if GuiAllowed() then
            DialogWindow.Open(ProcessingPOSEntriesLbl, RecCount, NoOfRecords);

        POSEntry.FindSet();
        repeat
            RSPOSGLAddition.PostRetailCalculationEntries(POSEntry, false);
            DialogWindow.Update();
            RecCount += 1;
        until POSEntry.Next() = 0;

        DialogWindow.Close();
        Commit();
        exit(true);
    end;

    local procedure FilterOnlyPOSEntriesFromCurrentSystem(var POSEntry: Record "NPR POS Entry"): Integer
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetFilter("Return Sale Sales Ticket No.", '<>''''');

        POSEntry.SetFilter("Amount Incl. Tax", '<0');
        if POSEntry.IsEmpty() then begin
            POSENtry.SetRange("Amount Incl. Tax");
            exit(POSEntry.Count());
        end;

        POSEntry.FindSet();
        repeat
            POSEntrySalesLine.SetRange("Document No.", POSEntry."Document No.");
            if POSEntrySalesLine.IsEmpty() then
                POSEntry.Mark(false);
        until POSEntry.Next() = 0;

        POSEntry.SetRange("Amount Incl. Tax");
        exit(POSEntry.Count());
    end;

    var
        DocumentNo: Text;
        StartDate: Date;
        EndDate: Date;

#endif
}