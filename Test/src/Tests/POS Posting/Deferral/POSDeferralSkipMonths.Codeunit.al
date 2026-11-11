codeunit 85609 "NPR POS Deferral Skip Months"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Deferral Utilities", 'OnBeforeCreateDeferralSchedule', '', false, false)]
    local procedure CreateScheduleWithSkippedMonths(DeferralCode: Code[10]; DeferralDocType: Integer; GenJnlTemplateName: Code[10]; GenJnlBatchName: Code[10]; DocumentType: Integer; DocumentNo: Code[20]; LineNo: Integer; AmountToDefer: Decimal; CalcMethod: Enum "Deferral Calculation Method"; StartDate: Date; NoOfPeriods: Integer; ApplyDeferralPercentage: Boolean; DeferralDescription: Text[100]; AdjustStartDate: Boolean; CurrencyCode: Code[10]; var IsHandled: Boolean)
    var
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
        LibraryPOSDeferral: Codeunit "NPR Library POS Deferral";
        Amounts: List of [Decimal];
        Dates: List of [Date];
        i: Integer;
    begin
        if DocumentType <> Database::"NPR POS Entry Sales Line" then
            exit;
        LibraryPOSDeferral.GetS6Schedule(Dates, Amounts);

        if not DeferralHeader.Get(Enum::"Deferral Document Type".FromInteger(DeferralDocType), GenJnlTemplateName, GenJnlBatchName, DocumentType, DocumentNo, LineNo) then begin
            DeferralHeader.Init();
            DeferralHeader."Deferral Doc. Type" := Enum::"Deferral Document Type".FromInteger(DeferralDocType);
            DeferralHeader."Gen. Jnl. Template Name" := GenJnlTemplateName;
            DeferralHeader."Gen. Jnl. Batch Name" := GenJnlBatchName;
            DeferralHeader."Document Type" := DocumentType;
            DeferralHeader."Document No." := DocumentNo;
            DeferralHeader."Line No." := LineNo;
            DeferralHeader.Insert();
        end;
        DeferralHeader."Deferral Code" := DeferralCode;
        DeferralHeader."Amount to Defer" := AmountToDefer;
        DeferralHeader."Amount to Defer (LCY)" := AmountToDefer;
        DeferralHeader."Initial Amount to Defer" := AmountToDefer;
        DeferralHeader."Calc. Method" := CalcMethod;
        DeferralHeader."Start Date" := StartDate;
        DeferralHeader."No. of Periods" := Dates.Count();
        DeferralHeader."Schedule Description" := DeferralDescription;
        DeferralHeader."Currency Code" := CurrencyCode;
        DeferralHeader.Modify();

        DeferralLine.SetRange("Deferral Doc. Type", DeferralHeader."Deferral Doc. Type");
        DeferralLine.SetRange("Gen. Jnl. Template Name", GenJnlTemplateName);
        DeferralLine.SetRange("Gen. Jnl. Batch Name", GenJnlBatchName);
        DeferralLine.SetRange("Document Type", DocumentType);
        DeferralLine.SetRange("Document No.", DocumentNo);
        DeferralLine.SetRange("Line No.", LineNo);
        if not DeferralLine.IsEmpty() then
            DeferralLine.DeleteAll();
        for i := 1 to Dates.Count() do begin
            DeferralLine.Init();
            DeferralLine."Deferral Doc. Type" := DeferralHeader."Deferral Doc. Type";
            DeferralLine."Gen. Jnl. Template Name" := GenJnlTemplateName;
            DeferralLine."Gen. Jnl. Batch Name" := GenJnlBatchName;
            DeferralLine."Document Type" := DocumentType;
            DeferralLine."Document No." := DocumentNo;
            DeferralLine."Line No." := LineNo;
            DeferralLine."Posting Date" := Dates.Get(i);
            DeferralLine.Description := DeferralDescription;
            DeferralLine.Amount := Amounts.Get(i);
            DeferralLine."Amount (LCY)" := Amounts.Get(i);
            DeferralLine."Currency Code" := CurrencyCode;
            DeferralLine.Insert();
        end;
        IsHandled := true;
    end;
}
