codeunit 6150832 "POS Action - Balance Reg V2"
{
    // 
    // NOTES:
    // Balancing requires a valid salesesperson and therefor must be done after a login
    // We are therefor in a current sales transaction and should not start a new one.
    // 
    // NPR5.32.11/TSA/20170623  CASE 279495 Issues with end-of-day balancing from the pos action - login
    // NPR5.36/MMV/20170724  CASE Signature change on PrintReceipt
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017
    // NPR5.38/TSA /20171120 CASE 296587 Added a check of saved sales.
    // NPR5.38/TSA /20171123 CASE 297087 Added System events Unit Close
    // NPR5.38/BR  /20180118 CASE 302761 Disable Audit Roll Creation for "Create POS Enties Only"
    // NPR5.38/NPKNAV/20180126  CASE 294430 Transport NPR5.38 - 26 January 2018
    // NPR5.39/BR  /20180215 CASE 305016 Added Fiscal No. support for Balancing
    // NPR5.40/MMV /20180228 CASE 308457 Moved fiscal no. pull inside pos entry create transaction.
    // NPR5.40/TS  /20180308 CASE 307432 Removed reference to MSP Dankort
    // NPR5.40/TSA /20180305 CASE 307267 Added SetCheckpoint mode
    // NPR5.40/TSA /20180305 CASE 307267 Changed Signature, added error message when advanced posting is turned on
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring
    // NPR5.48/MHA /20181115 CASE 334633 Replaced reference to function CheckSavedSales() with CleanupPOSQuotes() in ValidateRequirements()

    Permissions = TableData "Audit Roll"=rimd;

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is the built in function to perform balancing of the register (Version 1)';
        t001: Label 'Register already closed!';
        t002: Label 'Delete all sales lines before balancing the register';
        t003: Label 'You must close sales window on register no. %1';
        txtCannotSendSMSWB: Label 'Could not send SMS with todays sales.';
        NextWorkflowStep: Option NA,JUMP_BALANCE_REGISTER;
        NotCompleted: Label 'The End-of-Day did not complete since the Payment Bins has not been counted.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep ('ValidateRequirements', 'respond()');
            RegisterWorkflowStep ('NotifySubscribers', 'respond()');
            RegisterWorkflowStep ('Eft_EndOfDayReport', 'respond()');
            RegisterWorkflowStep ('Eft_Print', 'respond();');
            RegisterWorkflowStep ('BalanceRegister', 'respond()');
            RegisterWorkflowStep ('EndOfWorkflow', 'respond()');

            RegisterWorkflow (false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        POSSetup: Codeunit "POS Setup";
        POSSale: Codeunit "POS Sale";
        POSCreateEntry: Codeunit "POS Create Entry";
        SalePOS: Record "Sale POS";
        Register: Record Register;
        EFTTransactionRequest: Record "EFT Transaction Request";
        EftHandled: Boolean;
        EFTIntegration: Codeunit "EFT Framework Mgt.";
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        POSSession.GetSetup (POSSetup);
        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);

        POSSetup.GetRegisterRecord(Register);

        NextWorkflowStep := NextWorkflowStep::NA;
        case WorkflowStep of
          'ValidateRequirements' :
            begin
              if (not (ValidateRequirements (SalePOS."Register No.", SalePOS."Sales Ticket No."))) then
                FrontEnd.ContinueAtStep ('EndOfWorkflow');
              //-NPR5.38 [297087]
              POSCreateEntry.InsertUnitCloseBeginEntry (SalePOS."Register No.", SalePOS."Salesperson Code");
              //+NPR5.38 [297087]
            end;

          'NotifySubscribers' :
            OnBeforeBalancing (SalePOS, Register);

          'Eft_EndOfDayReport' :
            begin
        //-NPR5.46 [290734]
        //      POSSession.ClearActionState();
        //      POSSession.StoreActionState ('ContextId', POSSession.BeginAction (ActionCode));
        //
        //      FrontEnd.PauseWorkflow ();
        //
        //      EFTIntegration.OnBalanceEft (EFTTransactionRequest, SalePOS, Register, EftHandled);
        //      IF (EftHandled) THEN BEGIN
        //        EFTTransactionRequest.SetTransactionRequest (POSSession, EFTTransactionRequest);
        //      END ELSE BEGIN
        //
        //       // If no EFT device responed, we resume workflow without EFT Print
        //       FrontEnd.ResumeWorkflow ();
        //        NextWorkflowStep := NextWorkflowStep::JUMP_BALANCE_REGISTER;
        //
        //      END;
        //+NPR5.46 [290734]
            end;

          'Eft_Print' :
            begin
        //-NPR5.46 [290734]
        //      EFTTransactionRequest.GetTransactionRequest (POSSession, ActionCode(), EFTTransactionRequest);
        //      EFTTransactionRequest.PrintReceipts(TRUE);
        //+NPR5.46 [290734]
            end;

          'BalanceRegister' :
            begin
              //+NPR5.36 [282251]

              BalanceRegister (SalePOS."Register No.", SalePOS."Sales Ticket No.");
              //-NPR5.38 [297087]
              POSCreateEntry.InsertUnitCloseEndEntry (SalePOS."Register No.", SalePOS."Salesperson Code");
              //+NPR5.38 [297087]
            end;

          'EndOfWorkflow' :
            begin
              POSSession.ChangeViewLogin ();
            end;
        end;

        case NextWorkflowStep of
          NextWorkflowStep::JUMP_BALANCE_REGISTER : FrontEnd.ContinueAtStep ('BalanceRegister');
        end;
    end;

    local procedure ActionCode(): Text
    begin
        exit ('BALANCE_V2');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    local procedure "--"()
    begin
    end;

    procedure ValidateRequirements(RegisterNo: Code[10];SalesTicketNo: Code[20]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        pageBalancingWeb: Page "Touch Screen - Balancing (Web)";
        "Audit Roll Check": Record "Audit Roll";
        Register: Record Register;
        "Payment Type - Detailed": Record "Payment Type - Detailed";
        SalePOS: Record "Sale POS";
        POSQuoteMgt: Codeunit "POS Quote Mgt.";
        RetailFormCode: Codeunit "Retail Form Code";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Action1: Action;
        closingType: Option Cancel,Normal,Saved;
    begin

        RetailSetup.Get;
        RetailSetup.CheckOnline;

        Register.Get(RegisterNo);
        if (Register.Status = Register.Status::Afsluttet) then
          Error(t001);

        SalePOS.Get (RegisterNo, SalesTicketNo);
        if (RetailSalesLineCode.LineExists (SalePOS)) then
          Error(t002);

        //-NPR5.48 [334633]
        // //-NPR5.38 [296587]
        // IF (NOT RetailFormCode.CheckSavedSales (SalePOS)) THEN
        //  ERROR ('');
        // //+NPR5.38 [296587]
        if not POSQuoteMgt.CleanupPOSQuotes(SalePOS) then
          Error('');
        //+NPR5.48 [334633]

        "Audit Roll Check".SetRange ("Register No.", RegisterNo);
        if ("Audit Roll Check".FindLast ()) then begin
          if ("Audit Roll Check"."Sales Ticket No." > SalesTicketNo) then
            SalePOS.Rename(RegisterNo, RetailFormCode.FetchSalesTicketNumber (RegisterNo));
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          if (Register.FindSet()) then repeat
            if (Register."Register No." <> RegisterNo) then begin
              Message(t003, Register."Register No.");
              exit(false);
            end;
          until Register.Next = 0;
        end;

        SalePOS."Last Sale" := true;
        SalePOS.Modify;

        exit (true);
    end;

    procedure BalanceRegister(RegisterNo: Code[10];SalesTicketNo: Code[20]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        pagePOSWorkshiftCheckpoint: Page "POS Workshift Checkpoint Card";
        "Audit Roll Check": Record "Audit Roll";
        Register: Record Register;
        "Payment Type - Detailed": Record "Payment Type - Detailed";
        SalePOS: Record "Sale POS";
        RetailFormCode: Codeunit "Retail Form Code";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        PageAction: Action;
        closingType: Option Cancel,Normal,Saved;
        "--": Integer;
        POSCheckpointMgr: Codeunit "POS Workshift Checkpoint";
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        POSCreateEntry: Codeunit "POS Create Entry";
        CheckpointEntryNo: Integer;
        NPRetailSetup: Record "NP Retail Setup";
    begin
        //BalanceRegister

        //-NPR5.40 [307267]
        NPRetailSetup.Get ();
        if (NPRetailSetup."Advanced Posting Activated") then
          Error ('This balancing function should not be used when %1 is turned on.', NPRetailSetup."Advanced Posting Activated");
        //+NPR5.40 [307267]

        RetailSetup.Get;
        Register.Get(RegisterNo);
        SalePOS.Get (RegisterNo, SalesTicketNo);

        CheckpointEntryNo := POSCheckpointMgr.CreateEndWorkshiftCheckpoint_AuditRoll (RegisterNo);
        Commit();

        POSWorkshiftCheckpoint.Get (CheckpointEntryNo);
        pagePOSWorkshiftCheckpoint.SetRecord (POSWorkshiftCheckpoint);

        pagePOSWorkshiftCheckpoint.SetCheckpointMode (1); // Final
        //-NPR5.40 [307267]
        pagePOSWorkshiftCheckpoint.LookupMode (true);
        //+NPR5.40 [307267]
        PageAction := pagePOSWorkshiftCheckpoint.RunModal;

        case PageAction of
          ACTION::LookupOK :
            begin

              POSPaymentBinCheckpoint.Reset ();
              POSPaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
              POSPaymentBinCheckpoint.SetFilter (Status, '=%1' , POSPaymentBinCheckpoint.Status::READY);
              if (POSPaymentBinCheckpoint.FindFirst ()) then begin

                //-NPR5.40 [307267]
                //POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, CheckpointEntryNo);
                if (NPRetailSetup."Advanced POS Entries Activated") then
                  POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, false, CheckpointEntryNo);
                //+NPR5.40 [307267]

                POSCheckpointMgr.CopyCheckpointToPeriode_AR (CheckpointEntryNo, SalePOS, Today, Time, true);

                "Payment Type - Detailed".SetRange ("Register No.", RegisterNo);
                "Payment Type - Detailed".DeleteAll (true);

                if (not AdaptedFormBalanceRegister (SalePOS, Today)) then begin
                  SalePOS."Last Sale" := false;
                  SalePOS.Modify;
                  exit(false);
                end;

                if (not CODEUNIT.Run (CODEUNIT::"Send Register Balance", SalePOS)) then
                  Message(txtCannotSendSMSWB);

              end else begin
                Error (NotCompleted);

              end;

            end;

          else begin
            SalePOS."Last Sale" := false;
            SalePOS.Modify;
            exit(false);
          end;
        end;

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBalancing(SalePOS: Record "Sale POS";Register: Record Register)
    begin
    end;

    procedure AdaptedFormBalanceRegister(var SalePOS: Record "Sale POS";RegisterEndDate: Date) ret: Boolean
    var
        Register2: Record Register;
        ReportSelectionRetail: Record "Report Selection Retail";
        Register: Record Register;
        AuditRoll: Record "Audit Roll";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Period: Record Period;
        PostAuditRoll: Codeunit "Post audit roll";
        OBSOLETE_CallTerminalIntegration: Codeunit "Call Terminal Integration";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        EndSalesTicketNo: Code[10];
        PostingRegisterNo: Code[20];
        EndRegisterNo: Code[10];
        Separator: Text[1];
        RegisterFilter: Text[30];
        Text10600049: Label 'Register balanced by %1 with %2';
        Text10600050: Label 'Register %1 is balanced!';
        Text10600073: Label 'The register %1 is balanced but the posting of the audit roll failed. Try to post it by push F11 on the Audit roll';
        LukVindueFejl: Label 'You have to close the POS window on Register %1';
        t002: Label 'An error occurred printing the register report. Do it manually from the Audit roll form!';
        t003: Label 'Error occured! \The receipt number on the balancing [%1] is not the same as on the current sale [%2]. \The balancing is saved for a retry.';
        RetailSetup: Record "Retail Setup";
        "---Adapted": Integer;
        RetailSetupGlobal: Record "Retail Setup";
        RetailFormCodeCu: Codeunit "Retail Form Code";
        POSSale: Codeunit "POS Sale";
    begin
        
        //**
        // This is a mildly refactored version of the CU6014435.FormBalanceRegister
        
        
        //FormAfslutKasse()
        
        with SalePOS do begin
          "Last Sale" := true;
          Modify;
        
          /* Clear Terminal Comm File */
          // ** OBSOLETE CallTerminalIntegration.FlushFile("Register No.");
          ret := true;
        
          Period.Reset;
          Period.SetRange("Register No.","Register No.");
          Period.SetRange("Sales Ticket No.","Sales Ticket No.");
          Period.Find('+');
        
          /* Check if the right closing data */
          if Period."Sales Ticket No." <> SalePOS."Sales Ticket No." then begin
            Message(t003,Period."Sales Ticket No.",SalePOS."Sales Ticket No.");
            exit(false);
          end;
        
          /* ** Opretter filter p� kasse ** */
          Clear(RegisterFilter);
          RetailSetupGlobal.Get();
          case RetailSetupGlobal."Balancing Posting Type" of
            RetailSetupGlobal."Balancing Posting Type"::TOTAL:
              begin
                if Register.Find('-') then
                  repeat
                    RegisterFilter += Separator + Format(Register."Register No.");
                    if (Register."Register No." <> RetailFormCodeCu.FetchRegisterNumber) then
                      Error(LukVindueFejl,Register."Register No.");
                    Separator := '|';
                  until Register.Next = 0;
              end;
            RetailSetupGlobal."Balancing Posting Type"::"PER REGISTER":
              begin
                RegisterFilter := Format("Register No.");
              end;
          end;
        
          /* ** Finder f�rste kasse (Har kun betydning ved samlet kasseafslutning) ** */
          Register.Find('-');
          PostingRegisterNo := Register."Register No.";
        
          /* ** Skriver i revisionsrullen ** */
          Clear(AuditRoll);
        
          Register.SetFilter("Register No.",RegisterFilter);
          if Register.Find('-') then
            repeat
              Register.Validate(Status,Register.Status::Afsluttet);
              Register."Status Set By Sales Ticket" := "Sales Ticket No.";
              Register.Balanced := Today;
              Register."Closing Cash" := Period."Closing Cash";
              Register."Change Register" := Period."Change Register";
              Register.TestField(Account);
              Register.TestField("Gift Voucher Account");
              Register.TestField("Credit Voucher Account");
              Register.TestField("Difference Account");
              Register.TestField("Difference Account - Neg.");
              Register.TestField("Balance Account");
        
              AuditRoll.Init;
              AuditRoll."Register No." := Register."Register No.";
              AuditRoll."No." := Register."Register No.";
              AuditRoll.Lokationskode := Register."Location Code";
              AuditRoll."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
              AuditRoll."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
              AuditRoll."Dimension Set ID" := "Dimension Set ID";
              AuditRoll."Salesperson Code" := "Salesperson Code";
              AuditRoll.Type := AuditRoll.Type::"Open/Close";
              AuditRoll."Sale Type" := AuditRoll."Sale Type"::Comment;
              AuditRoll."Starting Time" := "Start Time";
              AuditRoll."Closing Time" := Time;
              AuditRoll."Sale Date" := Today;
        
              AuditRoll.Balancing := true;
              AuditRoll.Offline := not Register."Connected To Server";
              AuditRoll."Sales Ticket No." := "Sales Ticket No.";
        
            //  MoveEkspDim2Revrulle( Eksp, Revisionsrulle );
        
            //++0027 MG 8/5-02 S�lgernavn med i afslutningstekst
              if SalespersonPurchaser.Get("Salesperson Code") then
                AuditRoll.Description := CopyStr(StrSubstNo(Text10600049,SalespersonPurchaser.Name,Register."Closing Cash"),1,MaxStrLen(AuditRoll.Description));
            //--0027 MG 8/5-02   ��
              AuditRoll."Closing Cash" := Period."Closing Cash";
              AuditRoll."Transferred to Balance Account" := Period."Deposit in Bank";
              AuditRoll.Difference := Period.Difference;
              AuditRoll.EuroDifference := Period."Euro Difference";
              AuditRoll."Balance Amount" := Period."Balance Per Denomination";
              AuditRoll."Balance Sundries" := Period."Balanced Sec. Currency";
              AuditRoll."Balance amount euro" := Period."Balanced Euro";
              AuditRoll."Change Register" := Period."Change Register";
        
            // 0016 - start
              if (RetailSetupGlobal."Balancing Posting Type" = RetailSetupGlobal."Balancing Posting Type"::TOTAL) and (PostingRegisterNo = Register."Register No.") then begin
                EndSalesTicketNo := AuditRoll."Sales Ticket No.";
                EndRegisterNo := AuditRoll."Register No.";
                AuditRoll."Balanced on Sales Ticket No." := EndSalesTicketNo;
                AuditRoll."On Register No." := EndRegisterNo;
              end;
            // 0016 + slut
        
              if (RetailSetupGlobal."Balancing Posting Type" = RetailSetupGlobal."Balancing Posting Type"::TOTAL) and (PostingRegisterNo <> Register."Register No.") then begin
                AuditRoll."Closing Cash" := 0;
                AuditRoll."Transferred to Balance Account" := 0;
                AuditRoll.Difference := 0;
                AuditRoll."Balance Amount" := '';
                AuditRoll."Balance Sundries" := '';
            // 0016 - start
                AuditRoll."Balanced on Sales Ticket No." := EndSalesTicketNo;
                AuditRoll."On Register No." := EndRegisterNo;
            // 0016 + slut
        
              end;
              AuditRoll."Offline receipt no." := SalePOS."Sales Ticket No.";
              AuditRoll."Money bag no." := Period."Money bag no.";
              AuditRoll.Balancing := true; //ohm
              //-NPR5.38 [302761]
              if not RetailSetupGlobal."Create POS Entries Only" then begin
              //+NPR5.38 [302761]
                AuditRoll.Insert(true);                          //formAfslutKasse
                RetailFormCodeCu.MoveSaleDim2AuditRoll(SalePOS,AuditRoll);
              end;
              //+NPR5.38 [302761]
              Register."Opened Date" := 0D;
              Register."Balanced on Sales Ticket" := AuditRoll."Sales Ticket No.";
              Register.Modify;
        
              //Sender SMS med bruttooms�tning
              //  Flyttet til efter commit af opg�relsen.
            until Register.Next = 0;
        
        /* *************************************************************************************** */
          Commit;
        /* *************************************************************************************** */
        
        //-NPR5.40 [308457]
          //-NPR5.39 [305016]
        //  POSSale.FillFiscalNoOnPOSEntry(SalePOS);
        //  COMMIT;
          //+NPR5.39 [305016]
        //+NPR5.40 [308457]
        
          if not RetailSalesLineCode.Run(SalePOS) then
            Message(t002);
        
        /* Code for running Credit Card dataport and delete file */
        
        /* *************************************************************************************** */
          Commit;
        /* *************************************************************************************** */
        
          Message(Text10600050,ConvertStr(RegisterFilter,'|','+'));
        
          if RetailSetupGlobal."Posting Audit Roll" = RetailSetupGlobal."Posting Audit Roll"::Automatic then begin
        
            //-NPR5.38 [294430]
            // PostAuditRoll.ShowProgress(TRUE);
            PostAuditRoll.ShowProgress(CurrentClientType = CLIENTTYPE::Windows);
            //+NPR5.38 [294430]
        
            case RetailSetupGlobal."Posting When Balancing" of
              RetailSetupGlobal."Posting When Balancing"::"Per Register":
                begin
                  AuditRoll.Reset;
                  AuditRoll.SetRange("Register No.","Register No.");
                  if not PostAuditRoll.Run(AuditRoll) then
                    Message(Text10600073,Register."Register No.",AuditRoll.TableCaption,AuditRoll.TableCaption);
                end;
              RetailSetupGlobal."Posting When Balancing"::Total:
                begin
                  Register2.Reset;
                  Register2.SetCurrentKey(Status);
                  Register2.SetFilter(Status,'<>%1',Register2.Status::Afsluttet);
                  Clear(AuditRoll);
                  if not Register2.Find('-' ) then
                    if not PostAuditRoll.Run(AuditRoll) then
                      Message(Text10600073,Register."Register No.",AuditRoll.TableCaption,AuditRoll.TableCaption);
                end;
            end;
          end;
        
          Commit;
        
        // ** OBSOLETE
        //  IF Register."Import credit card transact." THEN BEGIN
        //    MSPDankort.LoadJournal;
        //    COMMIT;
        //  END;
        
          Clear(AuditRoll);
          Clear(ReportSelectionRetail);
          Commit;
        
        end;
        
        
        // ** OBSOLETE
        // //-NPR-PrintRetailDoc1.0
        // CLEAR(Register2);
        // Register2.GET(SalePOS."Register No.");
        // IF Register2."Credit Card Solution" = Register2."Credit Card Solution"::POINT THEN BEGIN
        //  RetailSetup.GET();
        // END;
        
        // ** OBSOLETE
        // IF Register."Auto Open/Close Terminal" THEN
        //  MSPDankort.CloseTerminal;
        
        // ** OBSOLETE
        //-NPR3.12i
        // RetailSetup.GET();
        //
        // IF RetailSetup."Automatic inventory posting" THEN
        // //  REPORT.RUNMODAL(6014530,FALSE,FALSE);
        // //+NPR3.12i
        //
        // //-NPR3.12j
        // IF RetailSetup."Automatic Cost Adjustment" THEN
        // // REPORT.RUNMODAL(6059769,FALSE,FALSE);
        // //+NPR3.12j
        //
        
        exit(true);

    end;
}

