codeunit 6014699 "NPR POS Post GL Entries JQ"
{
    Access = Internal;

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        Hashset: Codeunit "NPR HashSet of [Integer]";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        SkipPeriodRegisterGroup: Boolean;
        ErrorTextDictionary: Dictionary of [Integer, Text];
        ErrorCount: Integer;
        Period: Integer;
        ErrMessage: Label '%1 POS entries failed to post.';
        ErrorEntries: List of [Integer];
        DetailedMessage: TextBuilder;
    begin
        POSPostEntries.SetPostCompressed(true);
        POSPostEntries.SetStopOnError(false);
        POSPostEntries.SetPostPOSEntries(true);
        POSPostEntries.SetPostItemEntries(false);
        POSPostEntries.SetPostPerPeriodRegister(true);

        POSEntry.SetCurrentKey("Post Entry Status");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
        POSEntry.SetLoadFields("POS Period Register No.");
        if not POSEntry.FindSet() then
            exit;

        repeat
            if not Hashset.Contains(POSEntry."POS Period Register No.") then begin
                SkipPeriodRegisterGroup := POSPostEntries.SkipProcessing(1, POSEntry."POS Period Register No.", 0);
                if not SkipPeriodRegisterGroup then begin
                    Clear(POSEntry2);
                    POSEntry2.SetCurrentKey("POS Period Register No.");
                    POSEntry2.SetFilter("POS Period Register No.", '=%1', POSEntry."POS Period Register No.");
                    if (not POSPostEntries.Run(POSEntry2)) then
                        ErrorTextDictionary.Add(POSEntry."POS Period Register No.", GetLastErrorText());
                    Commit();

                    POSPostEntries.GetGLPostingErrorEntries(ErrorEntries);
                    ErrorCount += ErrorEntries.Count();
                end;
                Hashset.Add(POSEntry."POS Period Register No.");
            end;
        until POSEntry.Next() = 0;

        if ErrorCount > 0 then
            Message(ErrMessage, ErrorCount);

        if (ErrorTextDictionary.Count() > 0) then begin
            Commit();

            foreach Period in ErrorTextDictionary.Keys() do
                DetailedMessage.AppendLine(StrSubstNo('Period %1 - %2', Period, ErrorTextDictionary.Get(Period)));

            Error(DetailedMessage.ToText());
        end;
    end;
}
