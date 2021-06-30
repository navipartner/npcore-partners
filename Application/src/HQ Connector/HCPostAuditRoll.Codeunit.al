codeunit 6150901 "NPR HC Post Audit Roll"
{
    TableNo = "NPR HC Audit Roll";

    trigger OnRun()
    begin
        RunCode(Rec);
    end;

    var
        TempRevisionsrulle: Record "NPR HC Audit Roll Posting" temporary;
        HCRetailSetup: Record "NPR HC Retail Setup";
        HCPostTempAuditRoll: Codeunit "NPR HC Post Temp Audit Roll";
        ProgressVis: Boolean;
        pRevisionsrulle: Record "NPR HC Audit Roll Posting";
        SkipPostGL: Boolean;
        SkipPostItem: Boolean;

    procedure ShowProgress(Set: Boolean)
    begin
        ProgressVis := Set;
    end;

    procedure PostPerRegisterTmp(Kasse: Record "NPR HC Register"): Boolean
    var
        TempPost: Record "NPR HC Audit Roll Posting" temporary;
    begin
        if TempRevisionsrulle.Count() > 0 then begin
            HCPostTempAuditRoll.setPostingNo(HCPostTempAuditRoll.getNewPostingNo(true));

            TempRevisionsrulle.ModifyAll("Internal Posting No.", 0);

            if TempRevisionsrulle.Find('-') then
                repeat
                    HCPostTempAuditRoll.ClearStatusWindow();
                    TempRevisionsrulle.SetRange("Sale Date", TempRevisionsrulle."Sale Date");
                    TempPost.Reset();
                    TempPost.TransferFromTemp(TempPost, TempRevisionsrulle);
                    HCPostTempAuditRoll.RunPost(TempPost);
                    TempRevisionsrulle.Find('+');
                    TempRevisionsrulle.SetRange("Sale Date");
                    TempPost.Reset();
                    HCPostTempAuditRoll.RunUpdateChanges(TempPost);
                    TempPost.DeleteAll();
                until TempRevisionsrulle.Next() = 0;
            exit(true);
        end else
            exit(false);
    end;

    procedure PostPerRegisterTmpItemLedger(Kasse: Record "NPR HC Register"): Boolean
    var
        TempPost: Record "NPR HC Audit Roll Posting" temporary;
    begin
        if TempRevisionsrulle.Count() > 0 then begin
            TempRevisionsrulle.ModifyAll("Internal Posting No.", 0);

            if TempRevisionsrulle.Find('-') then
                repeat
                    HCPostTempAuditRoll.ClearStatusWindow();
                    TempRevisionsrulle.SetRange("Sale Date", TempRevisionsrulle."Sale Date");
                    TempPost.Reset();
                    TempPost.TransferFromTemp(TempPost, TempRevisionsrulle);
                    HCPostTempAuditRoll.RunPostItemLedger(TempPost);
                    TempRevisionsrulle.Find('+');
                    TempRevisionsrulle.SetRange("Sale Date");
                    TempPost.Reset();
                    HCPostTempAuditRoll.RunUpdateChanges(TempPost);
                    TempPost.DeleteAll();

                until TempRevisionsrulle.Next() = 0;
            exit(true);
        end else
            exit(false);
    end;

    procedure RunCode(var Rec: Record "NPR HC Audit Roll")
    var
        Kasse: Record "NPR HC Register";
        TempDummy: Record "NPR HC Audit Roll" temporary;
    begin
        HCRetailSetup.Get();
        ProcessToSalesDocuments(Rec);

        TempDummy.Copy(Rec);
        Clear(TempRevisionsrulle);

        HCRetailSetup.Validate("Posting Source Code", HCRetailSetup."Posting Source Code");

        Kasse.SetFilter("Register No.", Rec.GetFilter("Register No."));

        if ProgressVis then begin
            HCPostTempAuditRoll.OpenStatusWindow();
        end;

        if not SkipPostGL then begin
            if not HCRetailSetup."Post registers compressed" then begin
                if Kasse.Find('-') then
                    repeat
                        HCPostTempAuditRoll.SetProgressVis(ProgressVis);

                        Rec.SetRange("Register No.", Kasse."Register No.");

                        HCPostTempAuditRoll.RunTransfer(TempRevisionsrulle, Rec);
                        HCPostTempAuditRoll.RemoveSuspendedPayouts(TempRevisionsrulle);

                        TempRevisionsrulle.Reset();

                        HCPostTempAuditRoll.RunTest(TempRevisionsrulle);

                        PostPerRegisterTmp(Kasse);
                        TempRevisionsrulle.DeleteAll();
                    until Kasse.Next() = 0;
            end else begin
                HCPostTempAuditRoll.SetProgressVis(ProgressVis);

                HCPostTempAuditRoll.RunTransfer(TempRevisionsrulle, Rec);
                HCPostTempAuditRoll.RemoveSuspendedPayouts(TempRevisionsrulle);

                TempRevisionsrulle.Reset();

                HCPostTempAuditRoll.RunTest(TempRevisionsrulle);

                PostPerRegisterTmp(Kasse);
                TempRevisionsrulle.DeleteAll();

            end;
        end;

        /* ITEM ENTRY POSTING */
        Clear(TempRevisionsrulle);
        TempRevisionsrulle.DeleteAll();
        Rec.CopyFilters(TempDummy);
        Kasse.Reset();
        Kasse.SetFilter("Register No.", Rec.GetFilter("Register No."));
        pRevisionsrulle.DeleteAll();

        if not SkipPostItem then begin
            Rec.SetRange(Posted);
            Rec.SetRange("Item Entry Posted", false);
            Rec.SetRange("Sale Type", Rec."Sale Type"::Sale);
            Rec.SetRange(Type, Rec.Type::Item);

            if not HCRetailSetup."Post registers compressed" then begin
                if Kasse.Find('-') then
                    repeat
                        HCPostTempAuditRoll.SetProgressVis(ProgressVis);
                        Rec.SetRange("Register No.", Kasse."Register No.");
                        HCPostTempAuditRoll.RunTransferItemLedger(TempRevisionsrulle, Rec);
                        HCPostTempAuditRoll.RunTest(TempRevisionsrulle);
                        TempRevisionsrulle.Reset();
                        PostPerRegisterTmpItemLedger(Kasse);
                        TempRevisionsrulle.DeleteAll();
                    until Kasse.Next() = 0;
            end else begin
                HCPostTempAuditRoll.SetProgressVis(ProgressVis);
                HCPostTempAuditRoll.RunTransferItemLedger(TempRevisionsrulle, Rec);
                HCPostTempAuditRoll.RunTest(TempRevisionsrulle);
                TempRevisionsrulle.Reset();
                PostPerRegisterTmpItemLedger(Kasse);
                TempRevisionsrulle.DeleteAll();
            end;
        end;

        Rec.Copy(TempDummy);

        if ProgressVis then
            HCPostTempAuditRoll.CloseStatusWindow('');

    end;

    procedure SetPostingParameters(SkipPostGLEntry: Boolean; SkipPostItemLedgerEntry: Boolean)
    begin
        SkipPostGL := SkipPostGLEntry;
        SkipPostItem := SkipPostItemLedgerEntry;
    end;

    local procedure ProcessToSalesDocuments(var HCAuditRoll: Record "NPR HC Audit Roll")
    var
        HCAuditRollToSalesDocument: Record "NPR HC Audit Roll";
        HCPaymentTypePOS: Record "NPR HC Payment Type POS";
    begin
        HCAuditRollToSalesDocument.CopyFilters(HCAuditRoll);
        HCAuditRollToSalesDocument.SetFilter("Sale Type", '=%1', HCAuditRollToSalesDocument."Sale Type"::Payment);
        HCAuditRollToSalesDocument.SetFilter("Amount Including VAT", '<>0');
        HCAuditRollToSalesDocument.SetRange(Posted, false);
        if HCAuditRollToSalesDocument.FindSet() then
            repeat
                HCPaymentTypePOS.Get(HCAuditRollToSalesDocument."No.");
                if HCPaymentTypePOS."HQ Processing" > 0 then begin
                    ProcessToSalesDocument(HCAuditRollToSalesDocument, HCPaymentTypePOS);
                    MarkAllLinesAsPosted(HCAuditRollToSalesDocument);
                end;
            until HCAuditRollToSalesDocument.Next() = 0;
    end;

    local procedure ProcessToSalesDocument(var HCAuditRoll: Record "NPR HC Audit Roll"; HCPaymentTypePOS: Record "NPR HC Payment Type POS")
    var
        HCAuditRollToSalesDocument: Record "NPR HC Audit Roll";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LocalHCPostTempAuditRoll: Codeunit "NPR HC Post Temp Audit Roll";
        LineNo: Integer;
        SuccessPosting: Boolean;
        HCAuditRollPosting: Record "NPR HC Audit Roll Posting";
        AccountType: Integer;
        AccountNo: Code[20];
        PostPayment: Boolean;
        PaymentMethod: Record "Payment Method";
        HCPostSalesHeader: Codeunit "NPR HC Post S.Header";
    begin
        HCAuditRoll.TestField("Customer No.");
        SalesHeader.Init();
        case HCPaymentTypePOS."HQ Processing" of
            HCPaymentTypePOS."HQ Processing"::SalesInvoice:
                if HCAuditRoll."Amount Including VAT" > 0 then
                    SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice)
                else
                    SalesHeader.Validate("Document Type", SalesHeader."Document Type"::"Credit Memo");
            HCPaymentTypePOS."HQ Processing"::SalesQuote:
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Quote);
            HCPaymentTypePOS."HQ Processing"::SalesOrder:
                if HCAuditRoll."Amount Including VAT" > 0 then
                    SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order)
                else
                    SalesHeader.Validate("Document Type", SalesHeader."Document Type"::"Return Order");
        end;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", HCAuditRoll."Customer No.");
        SalesHeader.Validate("Document Date", HCAuditRoll."Sale Date");
        SalesHeader.Validate("External Document No.", HCAuditRoll."Sales Ticket No.");
        SalesHeader.Validate("Your Reference", HCAuditRoll.Reference);
        SalesHeader.Validate("Location Code", HCAuditRoll.Lokationskode);
        if HCPaymentTypePOS."Payment Method Code" <> '' then
            SalesHeader.Validate("Payment Method Code", HCPaymentTypePOS."Payment Method Code");
        SalesHeader.Modify(true);

        LineNo := 0;
        HCAuditRollToSalesDocument.SetRange("Sales Ticket No.", HCAuditRoll."Sales Ticket No.");
        HCAuditRollToSalesDocument.SetRange("Register No.", HCAuditRoll."Register No.");
        if HCAuditRollToSalesDocument.FindSet() then
            repeat
                //CreateLine
                if HCAuditRollToSalesDocument."Sale Type" = HCAuditRollToSalesDocument."Sale Type"::Sale then begin
                    if HCAuditRollToSalesDocument.Type in [HCAuditRollToSalesDocument.Type::Item, HCAuditRollToSalesDocument.Type::"G/L"] then begin
                        LineNo := LineNo + 10000;
                        SalesLine.Init();
                        SalesLine.Validate("Document Type", SalesHeader."Document Type");
                        SalesLine.Validate("Document No.", SalesHeader."No.");
                        SalesLine."Line No." := LineNo;
                        SalesLine.Insert(true);
                        case HCAuditRollToSalesDocument.Type of
                            HCAuditRollToSalesDocument.Type::Item:
                                SalesLine.Validate(Type, SalesLine.Type::Item);
                            HCAuditRollToSalesDocument.Type::"G/L":
                                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                        end;
                        SalesLine.Validate("No.", HCAuditRollToSalesDocument."No.");
                        SalesLine.Validate("Location Code", HCAuditRollToSalesDocument.Lokationskode);
                        if HCAuditRollToSalesDocument.Unit <> '' then
                            SalesLine.Validate("Unit of Measure Code", HCAuditRollToSalesDocument.Unit);
                        SalesLine.Validate(Quantity, HCAuditRollToSalesDocument.Quantity);
                        SalesLine.Validate(Amount, HCAuditRoll.Amount);
                        SalesLine.Modify(true);
                    end;
                end;
            until HCAuditRollToSalesDocument.Next() = 0;

        OnAfterCreateSalesDoc(SalesHeader);

        if HCPaymentTypePOS."HQ Post Sales Document" then begin
            Commit();
            SuccessPosting := HCPostSalesHeader.Run(SalesHeader);
            OnAfterTryPostingSalesDoc(SalesHeader, SuccessPosting);
        end;

        PostPayment := HCPaymentTypePOS."HQ Post Payment";
        if (SalesHeader."Payment Method Code" <> '') and PostPayment then
            if PaymentMethod.Get(SalesHeader."Payment Method Code") then
                if PaymentMethod."Bal. Account No." <> '' then
                    PostPayment := false;

        if PostPayment then begin
            HCAuditRoll.SetRecFilter();
            LocalHCPostTempAuditRoll.RunTransfer(HCAuditRollPosting, HCAuditRoll);
            LocalHCPostTempAuditRoll.PostTransaction(
                  HCAuditRoll."Customer No.",
                  HCAuditRoll."Amount Including VAT",
                  HCAuditRoll."Register No.",
                  1, //debitor
                  HCAuditRoll."Department Code",
                  HCAuditRoll.Description,
                  HCAuditRoll."Sale Date",
                  HCAuditRollPosting);
            if HCPaymentTypePOS."HQ Post Sales Document" and SuccessPosting then
                LocalHCPostTempAuditRoll.ApplyToSalesDoc(SalesHeader);

            //Balancing entry
            case HCPaymentTypePOS."Account Type" of
                HCPaymentTypePOS."Account Type"::Bank:
                    begin
                        AccountType := 3; // Finans,Debitor,Kreditor,Bank,Anlæg
                        AccountNo := HCPaymentTypePOS."G/L Account No.";
                    end;
                HCPaymentTypePOS."Account Type"::"G/L Account":
                    begin
                        AccountType := 0; // Finans,Debitor,Kreditor,Bank,Anlæg
                        AccountNo := HCPaymentTypePOS."Bank Acc. No.";
                    end;
            end;
            LocalHCPostTempAuditRoll.PostTransaction(
             AccountNo,
              HCAuditRoll."Amount Including VAT",
              HCAuditRoll."Register No.",
              AccountType,
              HCAuditRoll."Department Code",
              HCAuditRoll.Description,
              HCAuditRoll."Sale Date",
              HCAuditRollPosting);
            if HCRetailSetup."Gen. Journal Batch" = '' then
                LocalHCPostTempAuditRoll.PostTodaysGLEntries(HCAuditRollPosting);
        end;
    end;

    local procedure MarkAllLinesAsPosted(var HCAuditRoll: Record "NPR HC Audit Roll")
    var
        HCAuditRollTomarkAsProcessed: Record "NPR HC Audit Roll";
    begin
        HCAuditRollTomarkAsProcessed.SetRange("Sales Ticket No.", HCAuditRoll."Sales Ticket No.");
        HCAuditRollTomarkAsProcessed.SetRange("Register No.", HCAuditRoll."Register No.");
        if HCAuditRollTomarkAsProcessed.FindSet() then
            repeat
                HCAuditRollTomarkAsProcessed.Posted := true;
                HCAuditRollTomarkAsProcessed.Modify();
            until HCAuditRollTomarkAsProcessed.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesDoc(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTryPostingSalesDoc(var SalesHeader: Record "Sales Header"; SuccessfulPosting: Boolean)
    begin
    end;
}

