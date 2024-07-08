codeunit 6151381 "NPR POS Post Sales Doc.Entries"
{
    Access = Internal;
    TableNo = "NPR POS Entry";
    Permissions = tabledata "NPR POS Entry" = rm,
                  tabledata "NPR POS Entry Sales Doc. Link" = rm,
                  tabledata "NPR POS Entry Sales Line" = rm;

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        POSPostSalesDocEntry: Codeunit "NPR POS Post Sales Doc.Entry";
    begin
        OnBeforePostPOSEntry(Rec);

        POSEntry := Rec;
        UpdateDates(POSEntry);

        if GenJnlCheckLine.DateNotAllowed(POSEntry."Posting Date") then
            POSEntry.FieldError("Posting Date", TextDateNotAllowed);

        CheckPostingrestrictions(POSEntry);

        POSEntrySalesDocLink.Reset();
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::Unposted, POSEntrySalesDocLink."Post Sales Document Status"::"Error while Posting");
        if POSEntrySalesDocLink.FindSet() then
            repeat
                Clear(POSPostSalesDocEntry);
                if _ReplaceDates then
                    POSPostSalesDocEntry.SetPostingDate(_ReplacePostingDate, _ReplaceDocumentDate, _PostingDate);
                if POSPostSalesDocEntry.Run(POSEntrySalesDocLink) then begin
                    if _PosEntryDescription = '' then
                        _PosEntryDescription := POSPostSalesDocEntry.GetPosEntryDescription();
                end else begin
                    POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::"Error while Posting";
                    POSEntrySalesDocLink.Modify();
                end;
                Commit();
            until POSEntrySalesDocLink.Next() = 0;

        OnAfterPostPOSEntry(Rec);
    end;

    local procedure CheckPostingrestrictions(POSEntryToCheck: Record "NPR POS Entry")
    var
        Customer: Record Customer;
    begin
        OnCheckPostingRestrictions(POSEntryToCheck);
        if POSEntryToCheck."Customer No." <> '' then begin
            Customer.Get(POSEntryToCheck."Customer No.");
            if Customer.Blocked = Customer.Blocked::All then
                Error(TextCustomerBlocked);
        end;
    end;

    internal procedure GetPosEntryDescription(): Text
    begin
        exit(_PosEntryDescription);
    end;

    internal procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        _ReplaceDates := true;
        _ReplacePostingDate := NewReplacePostingDate;
        _ReplaceDocumentDate := NewReplaceDocumentDate;
        _PostingDate := NewPostingDate;
    end;

    local procedure UpdateDates(var POSEntry: Record "NPR POS Entry")
    begin
        if not _ReplaceDates or (_PostingDate = 0D) then
            exit;
        if _ReplacePostingDate or (POSEntry."Posting Date" = 0D) then begin
            POSEntry."Posting Date" := _PostingDate;
            POSEntry.Validate("Currency Code");
        end;
        if _ReplaceDocumentDate or (POSEntry."Document Date" = 0D) then
            POSEntry.Validate("Document Date", _PostingDate);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingRestrictions(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    var
        _PosEntryDescription: Text;
        _PostingDate: Date;
        _ReplaceDates: Boolean;
        _ReplaceDocumentDate: Boolean;
        _ReplacePostingDate: Boolean;
        TextCustomerBlocked: Label 'Customer is blocked.';
        TextDateNotAllowed: Label 'is not within your range of allowed posting dates.';
}
