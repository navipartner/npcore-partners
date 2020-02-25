codeunit 6014409 "Post audit roll"
{
    // --->> NPR Version 1.7
    //    Kalder codeunit 'Bogf�r revisionsrulle aktivt'
    // <<--- NPR Version 1.7 slut
    // 
    // 
    // --->> NPR Version 1.8
    //   Codeunit 'Bogf�r revisionsrulle' (6014410) fjernet!
    //   Codeunit 'Bogf�r revisionsrulle aktivt' om�bt til
    //   Codeunit 'Bogf�r revisionsrulle' (6014414)
    //   Kalder codeunit 'Bogf�r revisionsrulle' (6014414)
    // <<--- NPR version 1.8
    // 
    // --->> NPR Version 1.93
    //   Indf�rt tjek for h�ngende udbetalinger via funktionen 'FjernH�ngendeUdbetalinger'.
    // <<--- NPR Version 1.93
    // 
    // Lavet mulighed for at bruge temporer tabel til bogf�ring af revisionsrullen
    // 
    // NPR5.23/JDH /20160429  CASE 240004 Possible to initiate from Task Queue (or other places) to avoid posting of items or GL
    // NPR5.29/MHA /20170116  CASE 262116 Adjusted Filter Reset on Item Ledger Posting
    // NPR5.36/TJ  /20170920  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.53/BHR / 20191004 CASE 369361 Removed Invalid Functionalities

    TableNo = "Audit Roll";

    trigger OnRun()
    var
        Txt001: Label 'Posting of audit roll is not possible in offline mode';
    begin
        RetailSetup.Get;
        //-NPR5.53 [369361]
        //IF RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline THEN
        //  ERROR(Txt001);
        //+NPR5.53 [369361]
        RunCode(Rec);
    end;

    var
        AuditRollPosting: Record "Audit Roll Posting" temporary;
        RetailSetup: Record "Retail Setup";
        PostTempAuditRoll: Codeunit "Post Temp Audit Roll";
        ShowProgressGlobal: Boolean;
        AuditRollPosting2: Record "Audit Roll Posting";
        SkipPostGL: Boolean;
        SkipPostItem: Boolean;

    procedure RemoveSuspendedPayouts(var AuditRoll: Record "Audit Roll")
    var
        AuditRoll2: Record "Audit Roll";
        Window: Dialog;
        Counter: Integer;
        TotalCount: Integer;
        TxtDlgFin: Label 'Removing outstanding financial payments #1######### of #2########## @3@@@@@@@@@';
    begin
        //FjernH�ngendeUdbetalinger
        Clear(AuditRoll2);
        AuditRoll2.SetCurrentKey("Sale Type",Type,"No.");
        AuditRoll.SetCurrentKey("Sale Type",Type,"No.");
        AuditRoll2.CopyFilters(AuditRoll);
        AuditRoll2.SetRange("Sale Type",AuditRoll."Sale Type"::"Out payment");
        AuditRoll2.SetRange(Type,AuditRoll.Type::"G/L");
        AuditRoll2.SetRange("No.",'*');
        if ShowProgressGlobal then begin
          TotalCount := AuditRoll2.Count;
          Window.Open(TxtDlgFin);
          Window.Update(1,0);
          Window.Update(2,TotalCount);
          Window.Update(3,0);
          Counter := 0;
        end;
        if AuditRoll2.Find('-') then
          repeat
            if ShowProgressGlobal then begin
              Counter += 1;
              Window.Update(1,Counter);
              Window.Update(3,Round(Counter / TotalCount * 10000,1,'>'));
            end;
            if AuditRoll.GetFilter("Sales Ticket No.") <> '' then
              AuditRoll.SetFilter("Sales Ticket No.",AuditRoll.GetFilter("Sales Ticket No.") + '&<>' + Format(AuditRoll2."Sales Ticket No."))
            else
              AuditRoll.SetFilter("Sales Ticket No.",'<>' + Format(AuditRoll2."Sales Ticket No."));
          until AuditRoll2.Next = 0;
        AuditRoll2.SetRange("Sale Type",AuditRoll."Sale Type"::Deposit);
        AuditRoll2.SetRange(Type,AuditRoll.Type::Customer);
        if ShowProgressGlobal then begin
          Window.Close;
          Clear(Window);
          TotalCount := AuditRoll2.Count;
          Window.Open(TxtDlgFin);
          Window.Update(1,0);
          Window.Update(2,TotalCount);
          Window.Update(3,0);
          Counter := 0;
        end;
        if AuditRoll2.Find('-') then
          repeat
            if ShowProgressGlobal then begin
              Counter += 1;
              Window.Update(1,Counter);
              Window.Update(3,Round(Counter / TotalCount * 10000,1,'>'));
            end;
            if AuditRoll.GetFilter("Sales Ticket No.") <> '' then
              AuditRoll.SetFilter("Sales Ticket No.",AuditRoll.GetFilter("Sales Ticket No.") + '&<>' + Format(AuditRoll2."Sales Ticket No."))
            else
              AuditRoll.SetFilter("Sales Ticket No.",'<>' + Format(AuditRoll2."Sales Ticket No."));
          until AuditRoll2.Next = 0;
    end;

    procedure ShowProgress(ShowProgress: Boolean)
    begin
        //ShowProgress
        ShowProgressGlobal := ShowProgress;
    end;

    procedure PostPerRegisterTemp(Register: Record Register): Boolean
    var
        TempAuditRollPosting: Record "Audit Roll Posting" temporary;
    begin
        //Bogf�rperkassetemp

        if AuditRollPosting.Count > 0 then begin
          //ohm-
          //IF Kasse."Last G/L Posting No." = '' THEN
          //  Kasse."Last G/L Posting No." := '0';
          //Kasse."Last G/L Posting No." := INCSTR(Kasse."Last G/L Posting No.");
          //Kasse.MODIFY;
          PostTempAuditRoll.SetPostingNo(PostTempAuditRoll.GetNewPostingNo(true));
          //ohm+

          AuditRollPosting.ModifyAll("Internal Posting No.",0);

          if AuditRollPosting.Find('-') then
            repeat
              PostTempAuditRoll.StatusVindueClear();
              AuditRollPosting.SetRange("Sale Date",AuditRollPosting."Sale Date");
              TempAuditRollPosting.Reset;
              TempAuditRollPosting.TransferFromTemp(TempAuditRollPosting,AuditRollPosting);
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

    procedure PostPerRegisterTempItemLedger(Register: Record Register): Boolean
    var
        TempAuditRollPosting: Record "Audit Roll Posting" temporary;
    begin
        //Bogf�rperkassetempItemLedger

        if AuditRollPosting.Count > 0 then begin
          //ohm-
          //IF Kasse."Last G/L Posting No." = '' THEN
          //  Kasse."Last G/L Posting No." := '0';
          //Kasse."Last G/L Posting No." := INCSTR(Kasse."Last G/L Posting No.");
          //Kasse.MODIFY;
          //tBogf�r.setPostingNo(tBogf�r.getNewPostingNo(TRUE));
          //ohm+

          AuditRollPosting.ModifyAll("Internal Posting No.",0);

          if AuditRollPosting.Find('-') then
            repeat
              PostTempAuditRoll.StatusVindueClear();
              AuditRollPosting.SetRange("Sale Date",AuditRollPosting."Sale Date");
              TempAuditRollPosting.Reset;
              TempAuditRollPosting.TransferFromTemp(TempAuditRollPosting,AuditRollPosting);
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

    procedure RunCode(var Rec: Record "Audit Roll")
    var
        Register: Record Register;
        t001: Label 'Posting of audit roll is not possible in offline mode';
        Dummy: Record "Audit Roll" temporary;
    begin
        //RunKode()
        
        //-NPR5.29 [262116]
        //dummy.COPYFILTERS(Rec);
        Dummy.Copy(Rec);
        //+NPR5.29 [262116]
        
        RetailSetup.Get();
        Clear(AuditRollPosting);
        //-NPR5.53 [369361]
        //IF RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline THEN
        //  ERROR(t001);
        //+NPR5.53 [369361]
        RetailSetup.Validate("Posting Source Code",RetailSetup."Posting Source Code");
        
        Register.SetFilter("Register No.",Rec.GetFilter("Register No."));
        
        if ShowProgressGlobal then begin
          PostTempAuditRoll.StatusWindowOpen();
        end;
        
        /* G/L ENTRY POSTING */
        //-NPR5.23
        if not SkipPostGL then begin
        //+NPR5.23
          if not RetailSetup."Post registers compressed" then begin
            if Register.Find('-') then
              repeat
                PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);
        
                Rec.SetRange("Register No.",Register."Register No.");
                PostTempAuditRoll.RunTransfer(AuditRollPosting,Rec);
                PostTempAuditRoll.RemoveSuspendedPayouts(AuditRollPosting);
        
                AuditRollPosting.Reset;
                PostTempAuditRoll.RunTest(AuditRollPosting);
        
                PostPerRegisterTemp(Register);
                AuditRollPosting.DeleteAll;
              until Register.Next = 0;
          end else begin
            PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);
        
            PostTempAuditRoll.RunTransfer(AuditRollPosting,Rec);
            PostTempAuditRoll.RemoveSuspendedPayouts(AuditRollPosting);
        
            AuditRollPosting.Reset;
        
            PostTempAuditRoll.RunTest(AuditRollPosting);
        
            PostPerRegisterTemp(Register);
            AuditRollPosting.DeleteAll;
        
          end;
        
        //-NPR5.23
        end;
        //+NPR5.23
        
        
        /* ITEM ENTRY POSTING */
        Clear(AuditRollPosting);
        AuditRollPosting.DeleteAll;
        Rec.CopyFilters(Dummy);
        Register.Reset;
        Register.SetFilter("Register No.",Rec.GetFilter("Register No."));
        AuditRollPosting2.DeleteAll;
        
        //-NPR5.23
        if not SkipPostItem then begin
        //+NPR5.23
          //-NPR5.29 [262116]
          Rec.SetRange(Posted);
          Rec.SetRange("Item Entry Posted",false);
          Rec.SetRange("Sale Type",Rec."Sale Type"::Sale);
          Rec.SetRange(Type,Rec.Type::Item);
          //+NPR5.29 [262116]
        
          if not RetailSetup."Post registers compressed" then begin
            if Register.Find('-') then
              repeat
                PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);
                Rec.SetRange("Register No.",Register."Register No.");
                PostTempAuditRoll.RunTransferItemLedger(AuditRollPosting,Rec);
                PostTempAuditRoll.RunTest(AuditRollPosting);
                AuditRollPosting.Reset;
                PostPerRegisterTempItemLedger(Register);
                AuditRollPosting.DeleteAll;
              until Register.Next = 0;
          end else begin
            PostTempAuditRoll.SetProgressVis(ShowProgressGlobal);
            PostTempAuditRoll.RunTransferItemLedger(AuditRollPosting,Rec);
            PostTempAuditRoll.RunTest(AuditRollPosting);
            AuditRollPosting.Reset;
            PostPerRegisterTempItemLedger(Register);
            AuditRollPosting.DeleteAll;
          end;
        //-NPR5.23
        end;
        //+NPR5.23
        
        //-NPR5.29 [262116]
        //dummy.COPYFILTERS(Rec);
        Rec.Copy(Dummy);
        //+NPR5.29 [262116]
        
        if ShowProgressGlobal then
          PostTempAuditRoll.StatusVindueLuk('');

    end;

    procedure SetPostingParameters(SkipPostGLEntry: Boolean;SkipPostItemLedgerEntry: Boolean)
    begin
        //-NPR5.23
        SkipPostGL := SkipPostGLEntry;
        SkipPostItem := SkipPostItemLedgerEntry;
        //+NPR5.23
    end;
}

