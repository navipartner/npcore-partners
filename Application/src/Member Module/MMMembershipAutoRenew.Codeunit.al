﻿codeunit 6060148 "NPR MM Membership Auto Renew"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        ProgressWindow: Label '#1##################:\#2##################: @3@@@@@@@@@@@@@@@@@@\#4##################: #5##################\#6##################: #7##################\#8##################: #9##################';
        ProgressTitle: Label 'Auto-Renew';
        ProgressBar: Label 'Progress';
        AUTORENEW_TEXT: Label 'Renewal of %1 for %2 - %3.';
        MISSING_CASE: Label '%1 is missing implementation for case %2';

    procedure AutoRenewBatch(AutoRenewEntryNo: Integer)
    var
        MembershipAutoRenew: Record "NPR MM Membership Auto Renew";
        Membership: Record "NPR MM Membership";
        TempMembershipAutoRenew: Record "NPR MM Membership Auto Renew" temporary;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberMaxCount: Integer;
        MemberIndex: Integer;
        Window: Dialog;
        StartDate: Date;
        UntilDate: Date;
        SuggestedRenewPrice: Decimal;
    begin

        MembershipAutoRenew.Get(AutoRenewEntryNo);

        if (MembershipAutoRenew."Community Code" <> '') then
            Membership.SetFilter("Community Code", '=%1', MembershipAutoRenew."Community Code");

        if (MembershipAutoRenew."Membership Code" <> '') then
            Membership.SetFilter("Membership Code", '=%1', MembershipAutoRenew."Membership Code");

        //Membership.SetFilter ("Auto-Renew", '=%1', TRUE);
        Membership.SetFilter("Auto-Renew", '=%1', Membership."Auto-Renew"::YES_INTERNAL);

        Membership.SetFilter("Auto-Renew Payment Method Code", '=%1', MembershipAutoRenew."Payment Method Code");
        Membership.SetFilter(Blocked, '=%1', false);

        if (Membership.FindSet()) then begin
            MemberMaxCount := Membership.Count();
            MemberIndex := 0;

            if (GuiAllowed) then begin
                Window.Open(ProgressWindow);
                Window.Update(1, ProgressTitle);
                Window.Update(2, ProgressBar);
                Window.Update(4, MembershipAutoRenew.FieldCaption("Auto-Renew Fail Count"));
                Window.Update(6, MembershipAutoRenew.FieldCaption("Invoice Create Fail Count"));
                Window.Update(8, MembershipAutoRenew.FieldCaption("Invoice Posting Fail Count"));
            end;

            if (MembershipAutoRenew."Started At" = CreateDateTime(0D, 0T)) then
                MembershipAutoRenew."Started At" := CurrentDateTime();

            MembershipAutoRenew."Started By" := CopyStr(UserId(), 1, MaxStrLen(MembershipAutoRenew."Started By"));
            MembershipAutoRenew.Modify();
            Commit();

            TempMembershipAutoRenew.TransferFields(MembershipAutoRenew, true);
            TempMembershipAutoRenew.Insert();

            repeat

                AutoRenewOneMembership(0, Membership."Entry No.", TempMembershipAutoRenew, StartDate, UntilDate, SuggestedRenewPrice, false);
                if (MemberIndex mod 10 = 0) then begin
                    MembershipAutoRenew.Get(TempMembershipAutoRenew."Entry No.");
                    MembershipAutoRenew.TransferFields(TempMembershipAutoRenew, false);
                    MembershipAutoRenew.Modify();
                    Commit();
                    if (GuiAllowed) then begin
                        Window.Update(5, MembershipAutoRenew."Auto-Renew Fail Count");
                        Window.Update(7, MembershipAutoRenew."Invoice Create Fail Count");
                        Window.Update(9, MembershipAutoRenew."Invoice Posting Fail Count");
                    end;
                end;

                if (GuiAllowed) then
                    if (MemberIndex mod 10 = 0) then
                        Window.Update(3, Round(MemberIndex / MemberMaxCount * 10000, 1));

                MemberIndex += 1;
            until (Membership.Next() = 0);

            MembershipAutoRenew.Get(TempMembershipAutoRenew."Entry No.");
            MembershipAutoRenew.TransferFields(TempMembershipAutoRenew, false);
            MembershipAutoRenew.Modify();
            Commit();

            if (TempMembershipAutoRenew."Post Invoice") then begin
                MemberInfoCapture.SetFilter("Auto-Renew Entry No.", '=%1', TempMembershipAutoRenew."Entry No.");
                if (MemberInfoCapture.FindSet()) then begin

                    TempMembershipAutoRenew."First Invoice No." := '';

                    repeat
                        if (not PostDocument(MemberInfoCapture)) then begin
                            TempMembershipAutoRenew."Invoice Posting Fail Count" += 1;
                        end else begin
                            MemberInfoCapture.Modify();
                        end;

                        TempMembershipAutoRenew."Last Invoice No." := MemberInfoCapture."Document No.";
                        if (TempMembershipAutoRenew."First Invoice No." = '') then
                            TempMembershipAutoRenew."First Invoice No." := MemberInfoCapture."Document No.";

                        if (GuiAllowed) then
                            if (MemberIndex mod 10 = 0) then
                                Window.Update(9, MembershipAutoRenew."Invoice Posting Fail Count");

                    until (MemberInfoCapture.Next() = 0);
                end;
            end;

            TempMembershipAutoRenew."Completed At" := CurrentDateTime();
            MembershipAutoRenew.Get(TempMembershipAutoRenew."Entry No.");
            MembershipAutoRenew.TransferFields(TempMembershipAutoRenew, false);
            MembershipAutoRenew.Modify();
            Commit();

            MemberInfoCapture.Reset();
            MemberInfoCapture.SetFilter("Auto-Renew Entry No.", '=%1', TempMembershipAutoRenew."Entry No.");
            case TempMembershipAutoRenew."Keep Auto-Renew Entries" of
                TempMembershipAutoRenew."Keep Auto-Renew Entries"::ALL:
                    ;// No delete, keep all entries
                TempMembershipAutoRenew."Keep Auto-Renew Entries"::FAILED:
                    begin
                        MemberInfoCapture.SetFilter("Response Status", '<>%1', MemberInfoCapture."Response Status"::FAILED);
                        MemberInfoCapture.DeleteAll();
                    end;
                TempMembershipAutoRenew."Keep Auto-Renew Entries"::NO:
                    MemberInfoCapture.DeleteAll();
            end;

            if (GuiAllowed) then begin
                Window.Close();
            end;
        end;
    end;

    procedure AutoRenewOneMembership(InfoCaptureEntryNo: Integer; MembershipEntryNo: Integer; var TmpMembershipAutoRenew: Record "NPR MM Membership Auto Renew" temporary; var StartDate: Date; var UntilDate: Date; var RenewUnitPrice: Decimal; WithPostInvoice: Boolean) MemberInfoCaptureEntryNo: Integer
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ReasonText: Text;
        MembershipRenewNotAllowedLbl: Label 'Membership is already valid on %1 and does not require auto-renew at this time.';
    begin

        TmpMembershipAutoRenew."Selected Membership Count" += 1;

        if (InfoCaptureEntryNo <> 0) then begin
            MemberInfoCapture.Get(InfoCaptureEntryNo);
            MemberInfoCapture.Delete();
        end;

        InfoCaptureEntryNo := MembershipManagement.CreateAutoRenewMemberInfoRequest(MembershipEntryNo, '', ReasonText);
        if (InfoCaptureEntryNo = 0) then begin
            MemberInfoCapture."Entry No." := CreateErrorLogEntry(MembershipEntryNo, TmpMembershipAutoRenew, ReasonText);
            TmpMembershipAutoRenew."Auto-Renew Fail Count" += 1;
            exit(MemberInfoCapture."Entry No.");
        end;

        MemberInfoCapture.Get(InfoCaptureEntryNo);
        MemberInfoCapture."Auto-Renew Entry No." := TmpMembershipAutoRenew."Entry No.";

        MemberInfoCapture.Amount := MemberInfoCapture."Unit Price";
        MemberInfoCapture."Amount Incl VAT" := MemberInfoCapture."Unit Price"; //***
        SetResponseOk(MemberInfoCapture);

        if (MembershipManagement.GetMembershipValidDate(MembershipEntryNo, CalcDate('<+1D>', TmpMembershipAutoRenew."Valid Until Date"), StartDate, UntilDate)) then begin
            SetResponseError(MemberInfoCapture, StrSubstNo(MembershipRenewNotAllowedLbl, TmpMembershipAutoRenew."Valid Until Date"));
            MemberInfoCapture.Modify();
            exit(MemberInfoCapture."Entry No.");
        end;

        if (MembershipManagement.AutoRenewMembership(MemberInfoCapture, true, StartDate, UntilDate, RenewUnitPrice)) then begin

            TmpMembershipAutoRenew."Auto-Renew Success Count" += 1;
            TmpMembershipAutoRenew."Last Invoice No." := MemberInfoCapture."Document No.";
            if (TmpMembershipAutoRenew."First Invoice No." = '') then
                TmpMembershipAutoRenew."First Invoice No." := MemberInfoCapture."Document No.";

            if (WithPostInvoice) then begin
                if (TmpMembershipAutoRenew."Post Invoice") then begin
                    if (not PostDocument(MemberInfoCapture)) then begin
                        TmpMembershipAutoRenew."Invoice Posting Fail Count" += 1;
                        SetResponseError(MemberInfoCapture, GetLastErrorText);
                        ClearLastError();
                    end;
                end;
            end;

        end else begin
            TmpMembershipAutoRenew."Invoice Create Fail Count" += 1;
            SetResponseError(MemberInfoCapture, 'Auto Renew failed.');
        end;

        MemberInfoCapture.Modify();
        exit(MemberInfoCapture."Entry No.");
    end;

    local procedure PostDocument(var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        Posted: Boolean;
    begin

        if (not SalesHeader.Get(MemberInfoCapture."Document Type", MemberInfoCapture."Document No.")) then
            exit(false);

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate(Status, SalesHeader.Status::Released);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify();
        Commit();

        Posted := SalesPost.Run(SalesHeader);

        if (Posted) then
            if (SalesHeader."Last Posting No." <> '') then
                MemberInfoCapture."Document No." := SalesHeader."Last Posting No.";

        exit(Posted);
    end;

    procedure CreateInvoice(var SubscriptionRequest: Record "NPR MM Subscr. Request"; var MemberInfoCapture: Record "NPR MM Member Info Capture"): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipAutoRenew: Record "NPR MM Membership Auto Renew";
        MembershipSetup: Record "NPR MM Membership Setup";
        SubscrRenewPost: Codeunit "NPR MM Subscr. Renew: Post";
    begin

        if (not Membership.Get(MemberInfoCapture."Membership Entry No.")) then
            exit(false);

        if (Membership."Auto-Renew" = Membership."Auto-Renew"::YES_EXTERNAL) then begin
            if (MemberInfoCapture."Document No." = Membership."External Membership No.") then
                MemberInfoCapture."Document No." := '<EXTERNAL>';
            exit(true);
        end;

        MembershipSetup.Get(Membership."Membership Code");
        case MembershipSetup."Auto-Renew Model" of
            MembershipSetup."Auto-Renew Model"::INVOICE:
                begin
                    if (Membership."Customer No." = '') then
                        exit(false);

                    if (not MembershipAutoRenew.Get(MemberInfoCapture."Auto-Renew Entry No.")) then
                        MembershipAutoRenew.Init();
                    exit(CreateDocument(MemberInfoCapture, SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date", Membership, MembershipAutoRenew));
                end;
            MembershipSetup."Auto-Renew Model"::CUSTOMER_BALANCE:
                begin
                    if (Membership."Customer No." = '') then
                        exit(false);

                    exit(CreateAndPostJournal(MemberInfoCapture, SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date", Membership, MembershipSetup));
                end;
            MembershipSetup."Auto-Renew Model"::RECURRING_PAYMENT:
                begin
                    if SubscriptionRequest."Entry No." = 0 then
                        exit;
                    if SubscrRenewPost.PostInvoiceToGL(SubscriptionRequest, Membership, MembershipSetup) then
                        if SubscriptionRequest."Posting Document No." <> '' then
                            MemberInfoCapture."Document No." := SubscriptionRequest."Posting Document No.";
                    if SubscriptionRequest.Posted then
                        SubscrRenewPost.PostPaymentsToGL(SubscriptionRequest, '');
                    exit(SubscriptionRequest.Posted);
                end;
        end;
    end;

    local procedure CreateDocument(var MemberInfoCapture: Record "NPR MM Member Info Capture"; ValidFromDate: Date; ValidUntilDate: Date; Membership: Record "NPR MM Membership"; MembershipAutoRenew: Record "NPR MM Membership Auto Renew"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Sell-to Customer No.", Membership."Customer No.");
        SalesHeader."NPR External Order No." := Membership."External Membership No.";
        SalesHeader.Validate("Payment Method Code", MembershipAutoRenew."Payment Method Code");
        SalesHeader.Validate("Payment Terms Code", MembershipAutoRenew."Payment Terms Code");
        SalesHeader.Validate("Salesperson Code", MembershipAutoRenew."Salesperson Code");

        SalesHeader.Validate("Document Date", MemberInfoCapture."Document Date");
        case MembershipAutoRenew."Due Date Calculation" of
            MembershipAutoRenew."Due Date Calculation"::MEMBERSHIP_EXPIRE:
                SalesHeader.Validate("Due Date", CalcDate('<-1D>', ValidFromDate));
            MembershipAutoRenew."Due Date Calculation"::PAYMENT_TERMS:
                ; // Standard behavior
            else
                Error(MISSING_CASE, MembershipAutoRenew.FieldCaption("Due Date Calculation"), MembershipAutoRenew."Due Date Calculation");
        end;

        case MembershipAutoRenew."Posting Date Calculation" of
            MembershipAutoRenew."Posting Date Calculation"::FIXED:
                if (MembershipAutoRenew."Posting Date" <> 0D) then
                    SalesHeader.Validate("Posting Date", MembershipAutoRenew."Posting Date");
            MembershipAutoRenew."Posting Date Calculation"::MEMBERSHIP_EXPIRE_DATE:
                SalesHeader.Validate("Posting Date", ValidFromDate);
            else
                Error(MISSING_CASE, MembershipAutoRenew.FieldCaption("Posting Date Calculation"), MembershipAutoRenew."Posting Date Calculation");
        end;

        SalesHeader."External Document No." := SalesHeader."No.";
        SalesHeader.Modify(true);

        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::SALESHEADER;
        MemberInfoCapture."Document Type" := SalesHeader."Document Type";
        MemberInfoCapture."Document No." := SalesHeader."No.";

        LineNo += 10000;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", MemberInfoCapture."Item No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", MemberInfoCapture."Unit Price");
        SalesLine.Description := StrSubstNo(AUTORENEW_TEXT, Membership."External Membership No.", ValidFromDate, ValidUntilDate);
        SalesLine.Modify(true);

        exit(true);
    end;

    local procedure CreateAndPostJournal(var MemberInfoCapture: Record "NPR MM Member Info Capture"; ValidFromDate: Date; ValidUntilDate: Date; Membership: Record "NPR MM Membership"; MembershipSetup: Record "NPR MM Membership Setup"): Boolean
    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
        NoSeriesManagement: Codeunit NoSeriesManagement;
#else
        NoSeries: Codeunit "No. Series";
#endif
        RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        MembershipSetup.TestField("Recurring Payment Code");
        RecurringPaymentSetup.Get(MembershipSetup."Recurring Payment Code");

        RecurringPaymentSetup.TestField("Gen. Journal Template Name");
        RecurringPaymentSetup.TestField("Gen. Journal Batch Name");
        RecurringPaymentSetup.TestField("Revenue Account");

        TempGenJournalLine.Validate("Journal Template Name", RecurringPaymentSetup."Gen. Journal Template Name");
        TempGenJournalLine.Validate("Journal Batch Name", RecurringPaymentSetup."Gen. Journal Batch Name");

        TempGenJournalLine."Line No." := 10000;
        TempGenJournalLine.Insert(true);

        TempGenJournalLine.Validate("Posting Date", Today);
        TempGenJournalLine.Validate("Document Date", Today);

        TempGenJournalLine.Validate("Document Type", TempGenJournalLine."Document Type"::Invoice);
        if (RecurringPaymentSetup."Document No. Series" <> '') then
            TempGenJournalLine."Posting No. Series" := RecurringPaymentSetup."Document No. Series";
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
        TempGenJournalLine."Document No." := NoSeriesManagement.GetNextNo(TempGenJournalLine."Posting No. Series", TempGenJournalLine."Posting Date", true);
#else
        TempGenJournalLine."Document No." := NoSeries.GetNextNo(TempGenJournalLine."Posting No. Series", TempGenJournalLine."Posting Date");
#endif

        TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::Customer;
        TempGenJournalLine.Validate("Account No.", Membership."Customer No.");

        TempGenJournalLine."Bal. Account Type" := TempGenJournalLine."Bal. Account Type"::"G/L Account";
        TempGenJournalLine.Validate("Bal. Account No.", RecurringPaymentSetup."Revenue Account");

        if (RecurringPaymentSetup."Payment Terms Code" <> '') then
            TempGenJournalLine.Validate("Payment Terms Code", RecurringPaymentSetup."Payment Terms Code");

        TempGenJournalLine.Validate(Amount, MemberInfoCapture."Unit Price");
        TempGenJournalLine.Validate(Description, StrSubstNo(AUTORENEW_TEXT, Membership."External Membership No.", ValidFromDate, ValidUntilDate));

        TempGenJournalLine."External Document No." := MemberInfoCapture."Document No.";

        TempGenJournalLine.Modify(true);

        GenJnlPostLine.Run(TempGenJournalLine);

        exit(true);
    end;

    procedure ReverseInvoice(PostedInvoiceNumber: Code[20]) Posted: Boolean
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesPost: Codeunit "Sales-Post";
    begin

        if (not SalesInvoiceHeader.Get(PostedInvoiceNumber)) then begin
            SalesInvoiceHeader.SetFilter("Pre-Assigned No.", '=%1', PostedInvoiceNumber);
            if (not SalesInvoiceHeader.FindFirst()) then
                exit(false);
        end;

        CopyDocumentMgt.SetPropertiesForInvoiceCorrection(true); //NAV 2017

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader."External Document No." := PostedInvoiceNumber;
        SalesHeader.Insert(true);

        PostedInvoiceNumber := SalesInvoiceHeader."No.";
        CopyDocumentMgt.CopySalesDocForInvoiceCancelling(PostedInvoiceNumber, SalesHeader);

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify();
        Commit();

        Posted := SalesPost.Run(SalesHeader);

        exit(Posted);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterMembershipCreateEvent', '', true, true)]
    local procedure OnAfterMembershipCreateSubscriber(Membership: Record "NPR MM Membership")
    var
        Customer: Record Customer;
    begin

        //IF (NOT Membership."Auto-Renew") THEN
        //  EXIT;
        if (Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_INTERNAL) then
            exit;

        if (Membership."Customer No." = '') then
            exit;

        if (not Customer.Get(Membership."Customer No.")) then
            exit;

        if (not GuiAllowed) then
            exit;
    end;

    local procedure SetResponseOk(var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::COMPLETED;
        MemberInfoCapture."Response Message" := 'Ok';
    end;

    local procedure SetResponseError(var MemberInfoCapture: Record "NPR MM Member Info Capture"; ErrorDescription: Text)
    begin

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;
        MemberInfoCapture."Response Message" := CopyStr(ErrorDescription, 1, MaxStrLen(MemberInfoCapture."Response Message"));
    end;

    local procedure CreateErrorLogEntry(MembershipEntryNo: Integer; var TmpMembershipAutoRenew: Record "NPR MM Membership Auto Renew" temporary; ReasonText: Text): Integer
    var
        Membership: Record "NPR MM Membership";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipNotFoundLbl: Label '%1 %2 does not exist.';
    begin

        MemberInfoCapture.Init();
        SetResponseOk(MemberInfoCapture);
        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::AUTORENEW_JNL;
        MemberInfoCapture."Auto-Renew Entry No." := TmpMembershipAutoRenew."Entry No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::AUTORENEW;
        MemberInfoCapture.Insert();

        if (Membership.Get(MembershipEntryNo)) then begin
            SetResponseError(MemberInfoCapture, ReasonText);

            MemberInfoCapture."External Membership No." := Membership."External Membership No.";
            MemberInfoCapture."Membership Code" := Membership."Membership Code";

        end else begin
            SetResponseError(MemberInfoCapture, StrSubstNo(MembershipNotFoundLbl, Membership.TableCaption, MembershipEntryNo));
        end;

        MemberInfoCapture.Modify();
        exit(MemberInfoCapture."Entry No.");
    end;
}

