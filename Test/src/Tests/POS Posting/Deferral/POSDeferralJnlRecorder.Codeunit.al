codeunit 85608 "NPR POS Deferral Jnl. Recorder"
{
    EventSubscriberInstance = Manual;

    var
        _TempRecordedLine: Record "Gen. Journal Line" temporary;
        _TempPostedLine: Record "Gen. Journal Line" temporary;
        _EventNames: List of [Text];
        _DocumentNos: List of [Code[20]];

    procedure AddDocumentNo(DocumentNo: Code[20])
    begin
        if not _DocumentNos.Contains(DocumentNo) then
            _DocumentNos.Add(DocumentNo);
    end;

    procedure ClearRecords()
    begin
        _TempRecordedLine.Reset();
        _TempRecordedLine.DeleteAll();
        Clear(_EventNames);
    end;

    procedure GetSequence() Sequence: Text
    var
        i: Integer;
        RecordLbl: Label '%1|%2|%3|%4|%5|%6|%7; ', Locked = true;
    begin
        _TempRecordedLine.Reset();
        if _TempRecordedLine.FindSet() then
            repeat
                i += 1;
                Sequence += StrSubstNo(RecordLbl, _EventNames.Get(i), _TempRecordedLine."Document No.", _TempRecordedLine."Account Type", _TempRecordedLine."Account No.", _TempRecordedLine.Amount, _TempRecordedLine."Deferral Code", _TempRecordedLine."Deferral Line No.");
            until _TempRecordedLine.Next() = 0;
    end;

    procedure GetFullSequence() Sequence: Text
    var
        i: Integer;
        Line: TextBuilder;
        FieldLbl: Label '%1=%2|', Locked = true;
    begin
        _TempRecordedLine.Reset();
        if _TempRecordedLine.FindSet() then
            repeat
                i += 1;
                Clear(Line);
                Line.Append(_EventNames.Get(i) + '|');
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Posting Date"), Format(_TempRecordedLine."Posting Date", 0, 9)));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Document Date"), Format(_TempRecordedLine."Document Date", 0, 9)));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Document Type"), _TempRecordedLine."Document Type"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Document No."), _TempRecordedLine."Document No."));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("External Document No."), _TempRecordedLine."External Document No."));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Account Type"), _TempRecordedLine."Account Type"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Account No."), _TempRecordedLine."Account No."));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption(Description), _TempRecordedLine.Description));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Gen. Posting Type"), _TempRecordedLine."Gen. Posting Type"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Gen. Bus. Posting Group"), _TempRecordedLine."Gen. Bus. Posting Group"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Gen. Prod. Posting Group"), _TempRecordedLine."Gen. Prod. Posting Group"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("VAT Bus. Posting Group"), _TempRecordedLine."VAT Bus. Posting Group"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("VAT Prod. Posting Group"), _TempRecordedLine."VAT Prod. Posting Group"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("VAT Calculation Type"), _TempRecordedLine."VAT Calculation Type"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("VAT Posting"), _TempRecordedLine."VAT Posting"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("VAT %"), Format(_TempRecordedLine."VAT %", 0, 9)));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Currency Code"), _TempRecordedLine."Currency Code"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption(Amount), Format(_TempRecordedLine.Amount, 0, 9)));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Amount (LCY)"), Format(_TempRecordedLine."Amount (LCY)", 0, 9)));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("VAT Amount"), Format(_TempRecordedLine."VAT Amount", 0, 9)));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("VAT Amount (LCY)"), Format(_TempRecordedLine."VAT Amount (LCY)", 0, 9)));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Shortcut Dimension 1 Code"), _TempRecordedLine."Shortcut Dimension 1 Code"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Shortcut Dimension 2 Code"), _TempRecordedLine."Shortcut Dimension 2 Code"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Dimension Set ID"), _TempRecordedLine."Dimension Set ID"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Salespers./Purch. Code"), _TempRecordedLine."Salespers./Purch. Code"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Reason Code"), _TempRecordedLine."Reason Code"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Source Code"), _TempRecordedLine."Source Code"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Source Type"), _TempRecordedLine."Source Type"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Bill-to/Pay-to No."), _TempRecordedLine."Bill-to/Pay-to No."));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("System-Created Entry"), _TempRecordedLine."System-Created Entry"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Deferral Code"), _TempRecordedLine."Deferral Code"));
                Line.Append(StrSubstNo(FieldLbl, _TempRecordedLine.FieldCaption("Deferral Line No."), _TempRecordedLine."Deferral Line No."));
                Sequence += Line.ToText() + '; ';
            until _TempRecordedLine.Next() = 0;
    end;

    procedure GetRecordCount(): Integer
    begin
        exit(_EventNames.Count());
    end;

    procedure GetRecord(Index: Integer; var EventName: Text; var GenJournalLine: Record "Gen. Journal Line")
    begin
        _TempRecordedLine.Reset();
        _TempRecordedLine.SetRange("Line No.", Index);
        _TempRecordedLine.FindFirst();
        _TempRecordedLine.Reset();
        GenJournalLine := _TempRecordedLine;
        EventName := _EventNames.Get(Index);
    end;

    procedure FindRecordedLine(EventName: Text; AccountNo: Code[20]; var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        i: Integer;
    begin
        _TempRecordedLine.Reset();
        if _TempRecordedLine.FindSet() then
            repeat
                i += 1;
                if (_EventNames.Get(i) = EventName) and (_TempRecordedLine."Account No." = AccountNo) then begin
                    GenJournalLine := _TempRecordedLine;
                    exit(true);
                end;
            until _TempRecordedLine.Next() = 0;
    end;

    procedure BufferLineEventName(): Text
    begin
        exit('OnAfterInsertPOSPostingBufferToGenJnl');
    end;

    procedure FindPostedLine(AccountNo: Code[20]; var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        Found: Boolean;
    begin
        _TempPostedLine.Reset();
        _TempPostedLine.SetRange("Account No.", AccountNo);
        Found := _TempPostedLine.FindFirst();
        if Found then
            GenJournalLine := _TempPostedLine;
        _TempPostedLine.Reset();
        exit(Found);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure RecordPostedLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        NextLineNo: Integer;
    begin
        if (_DocumentNos.Count() > 0) and not _DocumentNos.Contains(GenJournalLine."Document No.") then
            exit;
        _TempPostedLine.Reset();
        if _TempPostedLine.FindLast() then
            NextLineNo := _TempPostedLine."Line No.";
        _TempPostedLine := GenJournalLine;
        _TempPostedLine."Journal Template Name" := '';
        _TempPostedLine."Journal Batch Name" := '';
        _TempPostedLine."Line No." := NextLineNo + 1;
        _TempPostedLine.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Entries", 'OnAfterInsertPOSPostingBufferToGenJnl', '', false, false)]
    local procedure RecordBufferLine(var POSPostingBuffer: Record "NPR POS Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
        RecordLine(BufferLineEventName(), GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Entries", 'OnAfterInsertFromPOSPostingBufferToGenJournal', '', false, false)]
    local procedure RecordBufferLineWithBin(POSUnitNo: Code[10]; LineType: Option; POSPaymentMethodCode: Code[10]; PostingDate: Date; POSPaymentBinCode: Code[10]; POSPeriodRegister: Integer; var GenJournalLine: Record "Gen. Journal Line")
    begin
        RecordLine('OnAfterInsertFromPOSPostingBufferToGenJournal', GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Entries", 'OnBeforeCheckAndPostGenJournal', '', false, false)]
    local procedure RecordJournalBeforeCheck(var GenJournalLine: Record "Gen. Journal Line"; var POSEntry: Record "NPR POS Entry")
    begin
        GenJournalLine.Reset();
        if GenJournalLine.FindSet() then
            repeat
                RecordLine('OnBeforeCheckAndPostGenJournal', GenJournalLine);
            until GenJournalLine.Next() = 0;
        GenJournalLine.Reset();
    end;

    local procedure RecordLine(EventName: Text; GenJournalLine: Record "Gen. Journal Line")
    var
        NextLineNo: Integer;
    begin
        if (_DocumentNos.Count() > 0) and not _DocumentNos.Contains(GenJournalLine."Document No.") then
            exit;
        _TempRecordedLine.Reset();
        if _TempRecordedLine.FindLast() then
            NextLineNo := _TempRecordedLine."Line No.";
        NextLineNo += 1;
        _TempRecordedLine := GenJournalLine;
        _TempRecordedLine."Journal Template Name" := '';
        _TempRecordedLine."Journal Batch Name" := '';
        _TempRecordedLine."Line No." := NextLineNo;
        _TempRecordedLine.Insert();
        _EventNames.Add(EventName);
    end;
}
