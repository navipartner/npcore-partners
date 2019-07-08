codeunit 6060148 "MM Membership Auto Renew"
{
    // MM1.22/TSA /20170829 CASE 286922 Initial Version
    // MM1.23/TSA /20171025 CASE 286922 Minor change
    // MM1.25/TSA /20180103 CASE 299783 Support for reversing invoices
    // MM1.25/TSA /20180108 CASE 301339 Handling of different date option on the invoice creation and logging
    // MM1.25/TSA /20180109 CASE 301547 Refactoring due to handling a log
    // MM1.25/TSA /20180119 CASE 302598 Added return values for entry no to be able to do one-of auto-renew
    // MM1.26/TSA /20180120 CASE 299785 Improved error message on when auto-renew rule selection fails
    // MM1.27/TSA /20180126 CASE 303696 Improved errors handling on auto-renew
    // MM1.28/TSA /20180202 CASE 303876 Adapting for different auto-renew models
    // MM1.28/TSA /20180411 CASE 303635 External Document No.
    // MM1.39/TSA/20190529  CASE 350968 Transport MM1.38.01 - 29 May 2019


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
        MembershipAutoRenew: Record "MM Membership Auto Renew";
        Membership: Record "MM Membership";
        TmpMembershipAutoRenew: Record "MM Membership Auto Renew" temporary;
        MemberInfoCapture: Record "MM Member Info Capture";
        MemberMaxCount: Integer;
        MemberIndex: Integer;
        Window: Dialog;
        StartDate: Date;
        UntilDate: Date;
        SuggestedRenewPrice: Decimal;
    begin

        MembershipAutoRenew.Get (AutoRenewEntryNo);

        if (MembershipAutoRenew."Community Code" <> '') then
          Membership.SetFilter ("Community Code", '=%1', MembershipAutoRenew."Community Code");

        if (MembershipAutoRenew."Membership Code" <> '') then
          Membership.SetFilter ("Membership Code", '=%1', MembershipAutoRenew."Membership Code");

        //-MM1.39 [350968]
        //Membership.SETFILTER ("Auto-Renew", '=%1', TRUE);
        Membership.SetFilter ("Auto-Renew", '=%1', Membership."Auto-Renew"::YES_INTERNAL);
        //+MM1.39 [350968]

        Membership.SetFilter ("Auto-Renew Payment Method Code", '=%1', MembershipAutoRenew."Payment Method Code");
        Membership.SetFilter (Blocked, '=%1', false);

        if (Membership.FindSet ()) then begin
          MemberMaxCount := Membership.Count ();
          MemberIndex := 0;

          if (GuiAllowed) then begin
            Window.Open (ProgressWindow);
            Window.Update (1, ProgressTitle);
            Window.Update (2, ProgressBar);
            Window.Update (4, MembershipAutoRenew.FieldCaption ("Auto-Renew Fail Count"));
            Window.Update (6, MembershipAutoRenew.FieldCaption ("Invoice Create Fail Count"));
            Window.Update (8, MembershipAutoRenew.FieldCaption ("Invoice Posting Fail Count"));
          end;

          if (MembershipAutoRenew."Started At" = CreateDateTime (0D, 0T)) then
            MembershipAutoRenew."Started At" := CurrentDateTime ();

          MembershipAutoRenew."Started By" := UserId ();
          MembershipAutoRenew.Modify ();
          Commit;

          TmpMembershipAutoRenew.TransferFields (MembershipAutoRenew, true);
          TmpMembershipAutoRenew.Insert ();

          repeat

            AutoRenewOneMembership (0, Membership."Entry No.", TmpMembershipAutoRenew, StartDate, UntilDate, SuggestedRenewPrice, false);
            if (MemberIndex mod 10 = 0) then begin
              MembershipAutoRenew.Get (TmpMembershipAutoRenew."Entry No.");
              MembershipAutoRenew.TransferFields (TmpMembershipAutoRenew, false);
              MembershipAutoRenew.Modify ();
              Commit;
              if (GuiAllowed) then begin
                Window.Update (5, MembershipAutoRenew."Auto-Renew Fail Count");
                Window.Update (7, MembershipAutoRenew."Invoice Create Fail Count");
                Window.Update (9, MembershipAutoRenew."Invoice Posting Fail Count");
              end;
            end;

            if (GuiAllowed) then
              if (MemberIndex mod 10 = 0) then
                Window.Update (3, Round (MemberIndex/MemberMaxCount*10000, 1));

            MemberIndex += 1;
          until (Membership.Next () = 0);

          MembershipAutoRenew.Get (TmpMembershipAutoRenew."Entry No.");
          MembershipAutoRenew.TransferFields (TmpMembershipAutoRenew, false);
          MembershipAutoRenew.Modify ();
          Commit;

          if (TmpMembershipAutoRenew."Post Invoice") then begin
            MemberInfoCapture.SetFilter ("Auto-Renew Entry No.", '=%1', TmpMembershipAutoRenew."Entry No.");
            if (MemberInfoCapture.FindSet ()) then begin

              //-MM1.25 [301547]
              TmpMembershipAutoRenew."First Invoice No." := '';
              //+MM1.25 [301547]

              repeat
                if (not PostDocument (MemberInfoCapture)) then begin
                  TmpMembershipAutoRenew."Invoice Posting Fail Count" += 1;
                end else begin
                  MemberInfoCapture.Modify ();
                end;

                //-MM1.25 [301547]
                TmpMembershipAutoRenew."Last Invoice No." := MemberInfoCapture."Document No.";
                if (TmpMembershipAutoRenew."First Invoice No." = '') then
                  TmpMembershipAutoRenew."First Invoice No." := MemberInfoCapture."Document No.";
                //+MM1.25 [301547]

                if (GuiAllowed) then
                  if (MemberIndex mod 10 = 0) then
                    Window.Update (9, MembershipAutoRenew."Invoice Posting Fail Count");

              until (MemberInfoCapture.Next () = 0);
            end;
          end;

          TmpMembershipAutoRenew."Completed At" := CurrentDateTime ();
          MembershipAutoRenew.Get (TmpMembershipAutoRenew."Entry No.");
          MembershipAutoRenew.TransferFields (TmpMembershipAutoRenew, false);
          MembershipAutoRenew.Modify ();
          Commit;

          MemberInfoCapture.Reset ();
          MemberInfoCapture.SetFilter ("Auto-Renew Entry No.", '=%1', TmpMembershipAutoRenew."Entry No.");
          case TmpMembershipAutoRenew."Keep Auto-Renew Entries" of
            TmpMembershipAutoRenew."Keep Auto-Renew Entries"::ALL : ;// No delete, keep all entries
            TmpMembershipAutoRenew."Keep Auto-Renew Entries"::FAILED :
              begin
                MemberInfoCapture.SetFilter ("Response Status", '<>%1', MemberInfoCapture."Response Status"::FAILED);
                MemberInfoCapture.DeleteAll ();
              end;
            TmpMembershipAutoRenew."Keep Auto-Renew Entries"::NO : MemberInfoCapture.DeleteAll ();
          end;

          if (GuiAllowed) then begin
            Window.Close ();
          end;
        end;
    end;

    procedure AutoRenewOneMembership(InfoCaptureEntryNo: Integer;MembershipEntryNo: Integer;var TmpMembershipAutoRenew: Record "MM Membership Auto Renew" temporary;var StartDate: Date;var UntilDate: Date;var RenewUnitPrice: Decimal;WithPostInvoice: Boolean) MemberInfoCaptureEntryNo: Integer
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MemberInfoCapture: Record "MM Member Info Capture";
        ReasonText: Text;
    begin

        TmpMembershipAutoRenew."Selected Membership Count" += 1;

        if (InfoCaptureEntryNo <> 0) then begin
          MemberInfoCapture.Get (InfoCaptureEntryNo);
          MemberInfoCapture.Delete ();
        end;

        InfoCaptureEntryNo := MembershipManagement.CreateAutoRenewMemberInfoRequest (MembershipEntryNo, '', ReasonText);
        if (InfoCaptureEntryNo = 0) then begin
          MemberInfoCapture."Entry No." := CreateErrorLogEntry (MembershipEntryNo, TmpMembershipAutoRenew, ReasonText);
          TmpMembershipAutoRenew."Auto-Renew Fail Count" += 1;
          exit (MemberInfoCapture."Entry No.");
        end;

        MemberInfoCapture.Get (InfoCaptureEntryNo);
        MemberInfoCapture."Auto-Renew Entry No." := TmpMembershipAutoRenew."Entry No.";

        MemberInfoCapture.Amount := MemberInfoCapture."Unit Price";
        MemberInfoCapture."Amount Incl VAT" := MemberInfoCapture."Unit Price"; //***
        SetResponseOk (MemberInfoCapture);

        if (MembershipManagement.GetMembershipValidDate (MembershipEntryNo, CalcDate ('<+1D>', TmpMembershipAutoRenew."Valid Until Date"), StartDate, UntilDate)) then begin
          SetResponseError (MemberInfoCapture, StrSubstNo ('Membership is already valid on %1 and does not require auto-renew at this time.',TmpMembershipAutoRenew."Valid Until Date"));
          MemberInfoCapture.Modify ();
          exit (MemberInfoCapture."Entry No.");
        end;

        if (MembershipManagement.AutoRenewMembership (MemberInfoCapture, true, StartDate, UntilDate, RenewUnitPrice)) then begin

          TmpMembershipAutoRenew."Auto-Renew Success Count" += 1;
          TmpMembershipAutoRenew."Last Invoice No." := MemberInfoCapture."Document No.";
          if (TmpMembershipAutoRenew."First Invoice No." = '') then
            TmpMembershipAutoRenew."First Invoice No." := MemberInfoCapture."Document No.";

          if (WithPostInvoice) then begin
            if (TmpMembershipAutoRenew."Post Invoice") then begin
              if (not PostDocument (MemberInfoCapture)) then begin
                TmpMembershipAutoRenew."Invoice Posting Fail Count" += 1;
                SetResponseError (MemberInfoCapture, GetLastErrorText);
                ClearLastError ();
              end;
            end;
          end;

        end else begin
          TmpMembershipAutoRenew."Invoice Create Fail Count" +=1;
          SetResponseError (MemberInfoCapture, 'Auto Renew failed.');
        end;

        MemberInfoCapture.Modify ();
        exit (MemberInfoCapture."Entry No.");
    end;

    local procedure PostAutoRenewInvoiceBatch(var TmpMembershipAutoRenew: Record "MM Membership Auto Renew" temporary)
    var
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        MemberInfoCapture.SetFilter ("Auto-Renew Entry No.", '=%1', TmpMembershipAutoRenew."Entry No.");
        if (MemberInfoCapture.FindSet ()) then begin
          repeat
            if (not PostDocument (MemberInfoCapture)) then
              TmpMembershipAutoRenew."Invoice Posting Fail Count" += 1;
          until (MemberInfoCapture.Next () = 0);
        end;
    end;

    local procedure PostDocument(var MemberInfoCapture: Record "MM Member Info Capture"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        Posted: Boolean;
    begin

        if (not SalesHeader.Get(MemberInfoCapture."Document Type", MemberInfoCapture."Document No.")) then
          exit (false);

        SalesHeader.SetHideValidationDialog (true);
        SalesHeader.Validate (Status, SalesHeader.Status::Released);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify ();
        Commit;

        Posted := SalesPost.Run(SalesHeader);

        if (Posted) then
          if (SalesHeader."Last Posting No." <> '') then
            MemberInfoCapture."Document No." := SalesHeader."Last Posting No.";

        exit (Posted);
    end;

    procedure CreateInvoice(var MemberInfoCapture: Record "MM Member Info Capture";ValidFromDate: Date;ValidUntilDate: Date): Boolean
    var
        Membership: Record "MM Membership";
        MembershipAutoRenew: Record "MM Membership Auto Renew";
        MembershipSetup: Record "MM Membership Setup";
    begin

        if (not Membership.Get (MemberInfoCapture."Membership Entry No.")) then
          exit (false);

        //-#303876 [303876]
        MembershipSetup.Get (Membership."Membership Code");
        case MembershipSetup."Auto-Renew Model" of
          MembershipSetup."Auto-Renew Model"::INVOICE :
            begin
                if (Membership."Customer No." = '') then
                  exit (false);

                if (not MembershipAutoRenew.Get (MemberInfoCapture."Auto-Renew Entry No.")) then
                  MembershipAutoRenew.Init;
              exit (CreateDocument (MemberInfoCapture, ValidFromDate, ValidUntilDate, Membership, MembershipAutoRenew));
            end;
          MembershipSetup."Auto-Renew Model"::CUSTOMER_BALANCE :
            begin
              if (Membership."Customer No." = '') then
                 exit (false);

              exit (CreateAndPostJournal (MemberInfoCapture, ValidFromDate, ValidUntilDate, Membership));
            end;
          MembershipSetup."Auto-Renew Model"::RECURRING_PAYMENT : ; // Nothing to be done here
        end;
    end;

    local procedure CreateDocument(var MemberInfoCapture: Record "MM Member Info Capture";ValidFromDate: Date;ValidUntilDate: Date;Membership: Record "MM Membership";MembershipAutoRenew: Record "MM Membership Auto Renew"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        SalesHeader.Insert (true);

        SalesHeader.SetHideValidationDialog (true);
        SalesHeader.Validate ("Sell-to Customer No.", Membership."Customer No.");
        SalesHeader."External Order No." := Membership."External Membership No.";
        SalesHeader.Validate ("Payment Method Code", MembershipAutoRenew."Payment Method Code");
        SalesHeader.Validate ("Payment Terms Code", MembershipAutoRenew."Payment Terms Code");
        SalesHeader.Validate ("Salesperson Code", MembershipAutoRenew."Salesperson Code");

        //+#301339 [301339]
        //SalesHeader.VALIDATE ("Posting Date", MembershipAutoRenew."Posting Date");
        //SalesHeader.VALIDATE ("Document Date", MemberInfoCapture."Document Date");

        SalesHeader.Validate ("Document Date", MemberInfoCapture."Document Date");
        case MembershipAutoRenew."Due Date Calculation" of
          MembershipAutoRenew."Due Date Calculation"::MEMBERSHIP_EXPIRE : SalesHeader.Validate ("Due Date", CalcDate ('<-1D>',ValidFromDate));
          MembershipAutoRenew."Due Date Calculation"::PAYMENT_TERMS : ; // Standard behaviour
          else Error (MISSING_CASE, MembershipAutoRenew.FieldCaption ("Due Date Calculation"), MembershipAutoRenew."Due Date Calculation");
        end;

        case MembershipAutoRenew."Posting Date Calculation" of
          MembershipAutoRenew."Posting Date Calculation"::FIXED : SalesHeader.Validate ("Posting Date", MembershipAutoRenew."Posting Date");
          MembershipAutoRenew."Posting Date Calculation"::MEMBERSHIP_EXPIRE_DATE : SalesHeader.Validate ("Posting Date", ValidFromDate);
          else Error (MISSING_CASE, MembershipAutoRenew.FieldCaption ("Posting Date Calculation"), MembershipAutoRenew."Posting Date Calculation");
        end;
        //+#301339 [301339]

        SalesHeader."External Document No." := SalesHeader."No.";
        SalesHeader.Modify (true);

        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::SALESHEADER;
        MemberInfoCapture."Document Type" := SalesHeader."Document Type";
        MemberInfoCapture."Document No." := SalesHeader."No.";

        LineNo += 10000;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert (true);

        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate ("No.", MemberInfoCapture."Item No.");
        SalesLine.Validate (Quantity, 1);
        SalesLine.Validate ("Unit Price", MemberInfoCapture."Unit Price");
        SalesLine.Description := StrSubstNo (AUTORENEW_TEXT, Membership."External Membership No.", ValidFromDate, ValidUntilDate);
        SalesLine.Modify (true);

        exit (true);
    end;

    local procedure CreateAndPostJournal(var MemberInfoCapture: Record "MM Member Info Capture";ValidFromDate: Date;ValidUntilDate: Date;Membership: Record "MM Membership"): Boolean
    var
        TmpGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        MembershipSetup: Record "MM Membership Setup";
        RecurringPaymentSetup: Record "MM Recurring Payment Setup";
    begin

        if (not Membership.Get (MemberInfoCapture."Membership Entry No.")) then
          exit (false);

        MembershipSetup.Get (Membership."Membership Code");
        MembershipSetup.TestField ("Recurring Payment Code");
        RecurringPaymentSetup.Get (MembershipSetup."Recurring Payment Code");

        RecurringPaymentSetup.TestField ("Gen. Journal Template Name");
        RecurringPaymentSetup.TestField ("Gen. Journal Batch Name");
        RecurringPaymentSetup.TestField ("Revenue Account");

        with TmpGenJournalLine do begin

          Validate ("Journal Template Name", RecurringPaymentSetup."Gen. Journal Template Name");
          Validate ("Journal Batch Name", RecurringPaymentSetup."Gen. Journal Batch Name");

          "Line No." := 10000;
          Insert (true);

          Validate ("Posting Date", Today);
          Validate ("Document Date", Today);

          Validate ("Document Type", TmpGenJournalLine."Document Type"::Invoice);
          if (RecurringPaymentSetup."Document No. Series" <> '') then
            "Posting No. Series" := RecurringPaymentSetup."Document No. Series";
          "Document No." := NoSeriesManagement.GetNextNo("Posting No. Series", "Posting Date", true);

          "Account Type" := TmpGenJournalLine."Account Type"::Customer;
          Validate ("Account No.", Membership."Customer No.");

          "Bal. Account Type" := "Bal. Account Type"::"G/L Account";
          Validate ("Bal. Account No.", RecurringPaymentSetup."Revenue Account");

          if (RecurringPaymentSetup."Payment Terms Code" <> '') then
            Validate ("Payment Terms Code", RecurringPaymentSetup."Payment Terms Code");

          Validate (Amount, MemberInfoCapture."Unit Price");
          Validate (Description, StrSubstNo (AUTORENEW_TEXT, Membership."External Membership No.", ValidFromDate, ValidUntilDate));

          //-#303635 [303635]
          "External Document No." := MemberInfoCapture."Document No.";
          //+#303635 [303635]

          Modify (true);

        end;

        GenJnlPostLine.Run (TmpGenJournalLine);

        exit (true);
    end;

    procedure ReverseInvoice(PostedInvoiceNumber: Code[20]) Posted: Boolean
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesPost: Codeunit "Sales-Post";
    begin

        //-MM1.25 [299783]
        if (not SalesInvoiceHeader.Get (PostedInvoiceNumber)) then begin
          SalesInvoiceHeader.SetFilter ("Pre-Assigned No.", '=%1', PostedInvoiceNumber);
          if (not SalesInvoiceHeader.FindFirst ()) then
            exit (false);
        end;

        CopyDocumentMgt.SetPropertiesForInvoiceCorrection(true); //NAV 2017

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader."External Document No." := PostedInvoiceNumber;
        SalesHeader.Insert (true);

        PostedInvoiceNumber := SalesInvoiceHeader."No.";
        CopyDocumentMgt.CopySalesDocForInvoiceCancelling (PostedInvoiceNumber, SalesHeader);

        SalesHeader.SetHideValidationDialog (true);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify ();
        Commit;

        Posted := SalesPost.Run(SalesHeader);

        exit (Posted);
        //+MM1.25 [299783]
    end;

    local procedure "--Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060127, 'OnAfterMembershipCreateEvent', '', true, true)]
    local procedure OnAfterMembershipCreateSubscriber(Membership: Record "MM Membership")
    var
        Customer: Record Customer;
    begin

        //-MM1.39 [350968]
        //IF (NOT Membership."Auto-Renew") THEN
        //  EXIT;
        if (Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_INTERNAL) then
          exit;
        //+MM1.39 [350968]

        if (Membership."Customer No." = '') then
          exit;

        if (not Customer.Get (Membership."Customer No.")) then
          exit;

        if (not GuiAllowed) then
          exit;
    end;

    local procedure "--"()
    begin
    end;

    local procedure SetResponseOk(var MemberInfoCapture: Record "MM Member Info Capture")
    begin

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::COMPLETED;
        MemberInfoCapture."Response Message" := 'Ok';
    end;

    local procedure SetResponseError(var MemberInfoCapture: Record "MM Member Info Capture";ErrorDescription: Text)
    begin

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;
        MemberInfoCapture."Response Message" := CopyStr (ErrorDescription, 1, MaxStrLen (MemberInfoCapture."Response Message"));
    end;

    local procedure CreateErrorLogEntry(MembershipEntryNo: Integer;var TmpMembershipAutoRenew: Record "MM Membership Auto Renew" temporary;ReasonText: Text) EntryNo: Integer
    var
        Membership: Record "MM Membership";
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        MemberInfoCapture.Init ();
        SetResponseOk (MemberInfoCapture);
        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::AUTORENEW_JNL;
        MemberInfoCapture."Auto-Renew Entry No." := TmpMembershipAutoRenew."Entry No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::AUTORENEW;
        MemberInfoCapture.Insert ();

        if (Membership.Get (MembershipEntryNo)) then begin
          SetResponseError (MemberInfoCapture, ReasonText);

          MemberInfoCapture."External Membership No." := Membership."External Membership No.";
          MemberInfoCapture."Membership Code" := Membership."Membership Code";

        end else begin
          SetResponseError (MemberInfoCapture, StrSubstNo ('%1 %2 does not exist.', Membership.TableCaption, MembershipEntryNo));
        end;

        MemberInfoCapture.Modify ();
        exit (MemberInfoCapture."Entry No.");
    end;
}

