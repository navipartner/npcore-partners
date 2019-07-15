codeunit 6150812 "POS Action - Balance Reg V1"
{
    // 
    // NOTES:
    // Balancing requires a valid salesesperson and therefor must be done after a login
    // We are therefor in a current sales transaction and should not start a new one.
    // 
    // NPR5.32.11/TSA/20170623  CASE 279495 Issues with end-of-day balancing from the pos action - login
    // NPR5.36/MMV/20170724  CASE Signature change on PrintReceipt
    // NPR5.38/TSA /20171120 CASE 296587 Added a check of saved sales.
    // NPR5.38/TSA /20171123 CASE 297087 Added System events Unit Close
    // NPR5.46/MMV /20180927 CASE 290734 EFT framework refactoring
    // NPR5.48/MHA /20181115 CASE 334633 Replaced reference to function CheckSavedSales() with CleanupPOSQuotes() in ValidateRequirements()


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is the built in function to perform balancing of the register (Version 1)';
        t001: Label 'Register already closed!';
        t002: Label 'Delete all sales lines before balancing the register';
        t003: Label 'You must close sales window on register no. %1';
        txtCannotSendSMSWB: Label 'Could not send SMS with todays sales.';
        NextWorkflowStep: Option NA,JUMP_BALANCE_REGISTER,EFT_CLOSE;

    local procedure ActionCode(): Text
    begin
        exit ('BALANCE_V1');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1'); //-+NPR5.46 [290734]
    end;

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

        //-NPR5.46 [290734]
        //    RegisterWorkflowStep ('Eft_EndOfDayReport', 'respond()');
        //    RegisterWorkflowStep ('Eft_Print', 'respond();');
            RegisterWorkflowStep ('Eft_Discovery', 'respond()');
            RegisterWorkflowStep ('Eft_Close', 'respond()');
            RegisterWorkflowStep ('Eft_CloseDone', 'respond()');
        //+NPR5.46 [290734]

            RegisterWorkflowStep ('BalanceRegister', 'respond()');
            RegisterWorkflowStep ('EndOfWorkflow', 'respond()');

            RegisterWorkflow (false);

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        POSSetup: Codeunit "POS Setup";
        POSSale: Codeunit "POS Sale";
        POSCreateEntry: Codeunit "POS Create Entry";
        SalePOS: Record "Sale POS";
        Register: Record Register;
        EFTTransactionRequest: Record "EFT Transaction Request";
        EftHandled: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;


        POSSession.GetSetup (POSSetup);
        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);

        POSSetup.GetRegisterRecord(Register);

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

        //-NPR5.46 [290734]
        //  'Eft_EndOfDayReport' :
        //    BEGIN
        //      POSSession.ClearActionState();
        //      POSSession.StoreActionState ('ContextId', POSSession.BeginAction (ActionCode));
        //
        //      FrontEnd.PauseWorkflow ();
        //
        //      OnBalancingEft (EFTTransactionRequest, SalePOS, Register, EftHandled);
        //      IF (EftHandled) THEN BEGIN
        //        EFTTransactionRequest.SetTransactionRequest (POSSession, EFTTransactionRequest);
        //      END ELSE BEGIN
        //        // If no EFT device responed, we resume workflow without EFT Print
        //        FrontEnd.ContinueAtStep ('BalanceRegister');
        //        FrontEnd.ResumeWorkflow ();
        //      END;
        //    END;
        //
        //  'Eft_Print' :
        //    BEGIN
        //      EFTTransactionRequest.GetTransactionRequest (POSSession, ActionCode(), EFTTransactionRequest);
        //      EFTTransactionRequest.PrintReceipts(TRUE);
        //    END;
          'Eft_Discovery' :
            EftDiscovery(POSSession);

          'Eft_Close' :
            EftClose(POSSession, FrontEnd);

          'Eft_CloseDone' :
            EftCloseDone(POSSession);
        //+NPR5.46 [290734]

          'BalanceRegister' :
            begin
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

        //-NPR5.46 [290734]
        case NextWorkflowStep of
          NextWorkflowStep::JUMP_BALANCE_REGISTER : FrontEnd.ContinueAtStep ('BalanceRegister');
          NextWorkflowStep::EFT_CLOSE : FrontEnd.ContinueAtStep('Eft_Close');
        end;
        //+NPR5.46 [290734]

        Handled := true;
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
        RetailFormCode: Codeunit "Retail Form Code";
        POSQuoteMgt: Codeunit "POS Quote Mgt.";
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
        pageBalancingWeb: Page "Touch Screen - Balancing (Web)";
        "Audit Roll Check": Record "Audit Roll";
        Register: Record Register;
        "Payment Type - Detailed": Record "Payment Type - Detailed";
        SalePOS: Record "Sale POS";
        RetailFormCode: Codeunit "Retail Form Code";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        Action1: Action;
        closingType: Option Cancel,Normal,Saved;
    begin
        //BalanceRegister

        RetailSetup.Get;

        Register.Get(RegisterNo);
        SalePOS.Get (RegisterNo, SalesTicketNo);

        pageBalancingWeb.LookupMode(true);
        pageBalancingWeb.Initialize(RegisterNo, SalePOS."Salesperson Code");
        Commit;

        Action1 := pageBalancingWeb.RunModal;
        closingType := pageBalancingWeb.getClosingType;

        case closingType of
          closingType::Normal :
            begin
              pageBalancingWeb.saveBalancedRegister (SalePOS, Today, Time, true);

              "Payment Type - Detailed".SetRange ("Register No.", RegisterNo);
              "Payment Type - Detailed".DeleteAll (true);

              if (not RetailFormCode.FormBalanceRegister (SalePOS, Today)) then begin
                SalePOS."Last Sale" := false;
                SalePOS.Modify;
                exit(false);

              end else
                if (not CODEUNIT.Run (CODEUNIT::"Send Register Balance", SalePOS)) then
                  Message(txtCannotSendSMSWB);

              exit(true);

            end;

          else begin
            SalePOS."Last Sale" := false;
            SalePOS.Modify;
            exit(false);
          end;
        end;

        exit(true);
    end;

    local procedure EftDiscovery(POSSession: Codeunit "POS Session")
    var
        EFTInterface: Codeunit "EFT Interface";
        tmpEFTSetup: Record "EFT Setup" temporary;
        EFTSetup: Record "EFT Setup";
    begin
        //-NPR5.46 [290734]
        EFTInterface.OnQueueCloseBeforeRegisterBalance(POSSession, tmpEFTSetup);
        if not tmpEFTSetup.FindSet then begin
          NextWorkflowStep := NextWorkflowStep::JUMP_BALANCE_REGISTER;
          exit;
        end;

        repeat
          EFTSetup.Get(tmpEFTSetup.RecordId);
          EFTSetup.Mark(true);
        until tmpEFTSetup.Next = 0;
        EFTSetup.MarkedOnly(true);
        EFTSetup.FindSet;

        POSSession.ClearActionState();
        POSSession.BeginAction(ActionCode);
        POSSession.StoreActionState('eft_close_list', EFTSetup);
        //+NPR5.46 [290734]
    end;

    local procedure EftClose(POSSession: Codeunit "POS Session";POSFrontEnd: Codeunit "POS Front End Management")
    var
        RecRef: RecordRef;
        EFTSetup: Record "EFT Setup";
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        POSSetup: Codeunit "POS Setup";
    begin
        //-NPR5.46 [290734]
        POSSession.RetrieveActionStateRecordRef('eft_close_list', RecRef);
        if RecRef.Number = 0 then
          exit;
        RecRef.SetTable(EFTSetup);
        if not EFTSetup.Find then
          exit;

        POSSession.GetSale(POSSale);
        POSSession.GetSetup(POSSetup);
        POSSale.GetCurrentSale(SalePOS);

        EFTFrameworkMgt.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, POSSetup.Register, SalePOS."Sales Ticket No.");
        Commit;
        EFTFrameworkMgt.SendRequest(EFTTransactionRequest);

        POSFrontEnd.PauseWorkflow();
        //+NPR5.46 [290734]
    end;

    local procedure EftCloseDone(POSSession: Codeunit "POS Session")
    var
        RecRef: RecordRef;
        EFTSetup: Record "EFT Setup";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        //-NPR5.46 [290734]
        POSSession.RetrieveActionStateRecordRef('eft_close_list', RecRef);
        if RecRef.Number = 0 then
          exit;
        RecRef.SetTable(EFTSetup);
        if EFTSetup.Next = 0 then
          exit;

        POSSession.StoreActionState('eft_close_list', EFTSetup);
        NextWorkflowStep := NextWorkflowStep::EFT_CLOSE;
        //+NPR5.46 [290734]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBalancing(SalePOS: Record "Sale POS";Register: Record Register)
    begin
    end;
}

