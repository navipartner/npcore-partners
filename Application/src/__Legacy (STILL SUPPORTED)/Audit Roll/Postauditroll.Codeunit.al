codeunit 6014409 "NPR Post audit roll"
{
    TableNo = "NPR Audit Roll";

    trigger OnRun()
    var
        Txt001: Label 'Posting of audit roll is not possible in offline mode';
    begin
        RetailSetup.Get;
        RunCode(Rec);
    end;

    var
        AuditRollPosting: Record "NPR Audit Roll Posting" temporary;
        RetailSetup: Record "NPR Retail Setup";
        PostTempAuditRoll: Codeunit "NPR Post Temp Audit Roll";
        ShowProgressGlobal: Boolean;
        AuditRollPosting2: Record "NPR Audit Roll Posting";
        SkipPostGL: Boolean;
        SkipPostItem: Boolean;

    procedure RemoveSuspendedPayouts(var AuditRoll: Record "NPR Audit Roll")
    var
        AuditRoll2: Record "NPR Audit Roll";
        Window: Dialog;
        Counter: Integer;
        TotalCount: Integer;
        TxtDlgFin: Label 'Removing outstanding financial payments #1######### of #2########## @3@@@@@@@@@';
    begin
        Clear(AuditRoll2);
        AuditRoll2.SetCurrentKey("Sale Type", Type, "No.");
        AuditRoll.SetCurrentKey("Sale Type", Type, "No.");
        AuditRoll2.CopyFilters(AuditRoll);
        AuditRoll2.SetRange("Sale Type", AuditRoll."Sale Type"::"Out payment");
        AuditRoll2.SetRange(Type, AuditRoll.Type::"G/L");
        AuditRoll2.SetRange("No.", '*');
        if ShowProgressGlobal then begin
            TotalCount := AuditRoll2.Count;
            Window.Open(TxtDlgFin);
            Window.Update(1, 0);
            Window.Update(2, TotalCount);
            Window.Update(3, 0);
            Counter := 0;
        end;
        if AuditRoll2.Find('-') then
            repeat
                if ShowProgressGlobal then begin
                    Counter += 1;
                    Window.Update(1, Counter);
                    Window.Update(3, Round(Counter / TotalCount * 10000, 1, '>'));
                end;
                if AuditRoll.GetFilter("Sales Ticket No.") <> '' then
                    AuditRoll.SetFilter("Sales Ticket No.", AuditRoll.GetFilter("Sales Ticket No.") + '&<>' + Format(AuditRoll2."Sales Ticket No."))
                else
                    AuditRoll.SetFilter("Sales Ticket No.", '<>' + Format(AuditRoll2."Sales Ticket No."));
            until AuditRoll2.Next = 0;
        AuditRoll2.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
        AuditRoll2.SetRange(Type, AuditRoll.Type::Customer);
        if ShowProgressGlobal then begin
            Window.Close;
            Clear(Window);
            TotalCount := AuditRoll2.Count;
            Window.Open(TxtDlgFin);
            Window.Update(1, 0);
            Window.Update(2, TotalCount);
            Window.Update(3, 0);
            Counter := 0;
        end;
        if AuditRoll2.Find('-') then
            repeat
                if ShowProgressGlobal then begin
                    Counter += 1;
                    Window.Update(1, Counter);
                    Window.Update(3, Round(Counter / TotalCount * 10000, 1, '>'));
                end;
                if AuditRoll.GetFilter("Sales Ticket No.") <> '' then
                    AuditRoll.SetFilter("Sales Ticket No.", AuditRoll.GetFilter("Sales Ticket No.") + '&<>' + Format(AuditRoll2."Sales Ticket No."))
                else
                    AuditRoll.SetFilter("Sales Ticket No.", '<>' + Format(AuditRoll2."Sales Ticket No."));
            until AuditRoll2.Next = 0;
    end;

    procedure ShowProgress(ShowProgress: Boolean)
    begin
        ShowProgressGlobal := ShowProgress;
    end;

    procedure PostPerRegisterTemp(Register: Record "NPR Register"): Boolean
    var
        TempAuditRollPosting: Record "NPR Audit Roll Posting" temporary;
    begin
        if AuditRollPosting.Count > 0 then begin
            PostTempAuditRoll.SetPostingNo(PostTempAuditRoll.GetNewPostingNo(true));

            AuditRollPosting.ModifyAll("Internal Posting No.", 0);

            if AuditRollPosting.Find('-') then
                repeat
                    PostTempAuditRoll.StatusVindueClear();
                    AuditRollPosting.SetRange("Sale Date", AuditRollPosting."Sale Date");
                    TempAuditRollPosting.Reset;
                    TempAuditRollPosting.TransferFromTemp(TempAuditRollPosting, AuditRollPosting);
                    PostTempAuditRoll.RunPost(TempAuditRollPosting);
                    AuditRollPosting.Find('+');
                    AuditRollPosting.SetRange("Sale Date");
                    TempAuditRollPosting.Reset;
                    PostTempAuditRoll.RunUpdateChanges(TempAuditRollPosting);
                    TempAuditRollPosting.DeleteAll;
                until AuditRollPosting.Next = 0;
            exit(true);
        end else
            exit(false);
    end;

    procedure PostPerRegisterTempItemLedger(Register: Record "NPR Register"): Boolean
    var
        TempAuditRollPosting: Record "NPR Audit Roll Posting" temporary;
    begin
        if AuditRollPosting.Count > 0 then begin
            AuditRollPosting.ModifyAll("Internal Posting No.", 0);

            if AuditRollPosting.Find('-') then
                repeat
                    PostTempAuditRoll.StatusVindueClear();
                    AuditRollPosting.SetRange("Sale Date", AuditRollPosting."Sale Date");
                    TempAuditRollPosting.Reset;
                    TempAuditRollPosting.TransferFromTemp(TempAuditRollPosting, AuditRollPosting);
                    PostTempAuditRoll.RunPostItemLedger(TempAuditRollPosting);
                    AuditRollPosting.Find('+');
                    AuditRollPosting.SetRange("Sale Date");
                    TempAuditRollPosting.Reset;
                    PostTempAuditRoll.RunUpdateChanges(TempAuditRollPosting);
                    TempAuditRollPosting.DeleteAll;
                until AuditRollPosting.Next = 0;
            exit(true);
        end else
            exit(false);
    end;

    procedure RunCode(var Rec: Record "NPR Audit Roll")
    var
        Register: Record "NPR Register";
        t001: Label 'Posting of audit roll is not possible in offline mode';
        Dummy: Record "NPR Audit Roll" temporary;
    begin
        Dummy.Copy(Rec);

        RetailSetup.Get();
        Clear(AuditRollPosting);
        RetailSetup.Validate("Posting Source Code", RetailSetup."Posting Source Code");

        Register.SetFilter("Register No.", Rec.GetFilter("Register No."));

        if ShowProgressGlobal then begin
            PostTempAuditRoll.StatusWindowOpen();
        end;

        if not SkipPostGL then begin
            if not RetailSetup."Post registers compressed" then begin
                if Register.Find('-') then
                    repeat
                        PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);

                        Rec.SetRange("Register No.", Register."Register No.");
                        PostTempAuditRoll.RunTransfer(AuditRollPosting, Rec);
                        PostTempAuditRoll.RemoveSuspendedPayouts(AuditRollPosting);

                        AuditRollPosting.Reset;
                        PostTempAuditRoll.RunTest(AuditRollPosting);

                        PostPerRegisterTemp(Register);
                        AuditRollPosting.DeleteAll;
                    until Register.Next = 0;
            end else begin
                PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);

                PostTempAuditRoll.RunTransfer(AuditRollPosting, Rec);
                PostTempAuditRoll.RemoveSuspendedPayouts(AuditRollPosting);

                AuditRollPosting.Reset;

                PostTempAuditRoll.RunTest(AuditRollPosting);

                PostPerRegisterTemp(Register);
                AuditRollPosting.DeleteAll;
            end;
        end;

        Clear(AuditRollPosting);
        AuditRollPosting.DeleteAll;
        Rec.CopyFilters(Dummy);
        Register.Reset;
        Register.SetFilter("Register No.", Rec.GetFilter("Register No."));
        AuditRollPosting2.DeleteAll;

        if not SkipPostItem then begin
            Rec.SetRange(Posted);
            Rec.SetRange("Item Entry Posted", false);
            Rec.SetRange("Sale Type", Rec."Sale Type"::Sale);
            Rec.SetRange(Type, Rec.Type::Item);

            if not RetailSetup."Post registers compressed" then begin
                if Register.Find('-') then
                    repeat
                        PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);
                        Rec.SetRange("Register No.", Register."Register No.");
                        PostTempAuditRoll.RunTransferItemLedger(AuditRollPosting, Rec);
                        PostTempAuditRoll.RunTest(AuditRollPosting);
                        AuditRollPosting.Reset;
                        PostPerRegisterTempItemLedger(Register);
                        AuditRollPosting.DeleteAll;
                    until Register.Next = 0;
            end else begin
                PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);
                PostTempAuditRoll.RunTransferItemLedger(AuditRollPosting, Rec);
                PostTempAuditRoll.RunTest(AuditRollPosting);
                AuditRollPosting.Reset;
                PostPerRegisterTempItemLedger(Register);
                AuditRollPosting.DeleteAll;
            end;
        end;

        Rec.Copy(Dummy);

        if ShowProgressGlobal then
            PostTempAuditRoll.StatusVindueLuk('');

    end;

    procedure SetPostingParameters(SkipPostGLEntry: Boolean; SkipPostItemLedgerEntry: Boolean)
    begin
        SkipPostGL := SkipPostGLEntry;
        SkipPostItem := SkipPostItemLedgerEntry;
    end;
}

