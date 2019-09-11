codeunit 6150849 "POS Action - End-of-Day V3"
{
    // 
    // NOTES:
    // Balancing requires a valid salesesperson and therefor must be done after a login
    // We are therefor in a current sales transaction and should not start a new one.
    // 
    // NPR5.42/TSA /20180306 CASE 307267 V3 initial version
    // NPR5.42/TSA /20180417 CASE 306858 Added dimensions to balance line
    // NPR5.42/BHR /20180214 CASE 312830 Added Security functionality
    // NPR5.45/TSA /20180809 CASE 322769 Removed obsolete code in ValidateRequirements ()
    // NPR5.46/TSA /20180913 CASE 328326 Setting Unit Status
    // NPR5.46/TSA /20180914 CASE 314603 Refactored the security functionality to use secure methods
    // NPR5.46/MMV /20180927 CASE 290734 EFT framework refactoring
    // NPR5.46/TSA /20181005 CASE 328338 Adjustments for keeping state on pos unit
    // NPR5.48/MHA /20181115 CASE 334633 Replaced reference to function CheckSavedSales() with CleanupPOSQuotes() in ValidateRequirements()
    // NPR5.48/TSA /20181127 CASE 336921 Changed POS Unit Status Management, cleaned up code
    // NPR5.49/TSA /20190311 CASE 348458 Added CloseWorkshift function, cleaned commented code
    // NPR5.51/TSA /20190622 CASE 359508 Adding support posting GL after balancing
    // 
    // TODO Units and Bins must get correct status


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is the built in function to perform balancing of the register (Version 1)';
        t001: Label 'Register already closed!';
        t002: Label 'Delete all sales lines before balancing the register';
        t003: Label 'You must close sales window on register no. %1';
        NextWorkflowStep: Option NA,JUMP_BALANCE_REGISTER,EFT_CLOSE;
        EndOfDayTypeOption: Option "X-Report","Z-Report",CloseWorkshift;
        MustBeManaged: Label 'The Close Workshift function is only intended for POS units that are managed for End-of-Day. Use X-Report or Z-Report instead.';

    local procedure ActionCode(): Text
    begin
        exit ('BALANCE_V3');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.6');
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
            RegisterWorkflowStep ('Eft_Discovery', 'respond()');
            RegisterWorkflowStep ('Eft_Close', 'respond()');
            RegisterWorkflowStep ('Eft_CloseDone', 'respond()');
            RegisterWorkflowStep ('BalanceRegister', 'respond()');
            RegisterWorkflowStep ('EndOfWorkflow', 'respond()');

            RegisterOptionParameter('Security','None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword','None');
            RegisterOptionParameter ('Type', 'X-Report (prel),Z-Report (final),Close Workshift', 'X-Report (prel)');

            RegisterWorkflow (false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
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
        POSUnit: Record "POS Unit";
        EFTTransactionRequest: Record "EFT Transaction Request";
        EftHandled: Boolean;
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EndOfDayType: Integer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSManagePOSUnit: Codeunit "POS Manage POS Unit";
        ClosingEntryNo: Integer;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        JSON.InitializeJObjectParser (Context,FrontEnd);
        EndOfDayType := JSON.GetIntegerParameter ('Type', true);
        if (EndOfDayType < 0) then
          EndOfDayType := 0;

        POSSession.GetSetup (POSSetup);
        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);

        POSSetup.GetRegisterRecord(Register);

        POSSetup.GetPOSUnit (POSUnit);
        POSSetup.GetSalespersonRecord (SalespersonPurchaser);
        SalePOS."Register No." := Register."Register No.";

        NextWorkflowStep := NextWorkflowStep::NA;
        case WorkflowStep of
          'ValidateRequirements' :
            begin
              if (not (ValidateRequirements (Register."Register No.", SalePOS."Sales Ticket No."))) then
                FrontEnd.ContinueAtStep ('EndOfWorkflow');
              POSCreateEntry.InsertUnitCloseBeginEntry (Register."Register No.", SalespersonPurchaser.Code);
            end;

          'NotifySubscribers' :
            begin
            end;

          'Eft_Discovery' :
            //-NPR5.49 [348458]
            // EftDiscovery(POSSession);
            if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
              EftDiscovery (POSSession);
            //+NPR5.49 [348458]

          'Eft_Close' :
            //-NPR5.49 [348458]
            // EftClose(POSSession, FrontEnd);
            if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
              EftClose (POSSession, FrontEnd);
            //+NPR5.49 [348458]

          'Eft_CloseDone' :
            //-NPR5.49 [348458]
            // EftCloseDone(POSSession);
            if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
              EftCloseDone (POSSession);
            //+NPR5.49 [348458]

          'BalanceRegister' :
            begin

              POSManagePOSUnit.SetEndOfDayPOSUnitNo (POSUnit."No.");

              case (EndOfDayType) of
                EndOfDayTypeOption::"Z-Report" :
                  begin
                    if (FinalEndOfDay (Register."Register No.", SalePOS."Dimension Set ID")) then begin
                      ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry (Register."Register No.", SalespersonPurchaser.Code);
                      POSManagePOSUnit.ClosePOSUnitNo (POSUnit."No.", ClosingEntryNo);
                      //-NPR5.51 [359508]
                      CheckAndPostAfterBalancing  (ClosingEntryNo);
                      //+NPR5.51 [359508]
                    end else begin
                      POSManagePOSUnit.ReOpenLastPeriodRegister (POSUnit."No.");
                    end;
                  end;

                //-NPR5.49 [348458]
                EndOfDayTypeOption::CloseWorkshift :
                  begin
                    CloseWorkshift (Register."Register No.", SalePOS."Dimension Set ID");
                    ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry (Register."Register No.", SalespersonPurchaser.Code);
                    POSManagePOSUnit.ClosePOSUnitNo (POSUnit."No.", ClosingEntryNo);

                    //-NPR5.51 [359508]
                    CheckAndPostAfterBalancing  (ClosingEntryNo);
                    //+NPR5.51 [359508]

                  end;
                //+NPR5.49 [348458]

                else begin
                  PreliminaryEndOfDay (Register."Register No.", SalePOS."Dimension Set ID");
                  POSManagePOSUnit.ReOpenLastPeriodRegister (POSUnit."No.");
                end;
              end;

            end;

          'EndOfWorkflow' :
            begin
              POSSession.ChangeViewLogin ();
            end;
        end;

        case NextWorkflowStep of
          NextWorkflowStep::JUMP_BALANCE_REGISTER : FrontEnd.ContinueAtStep ('BalanceRegister');
          NextWorkflowStep::EFT_CLOSE : FrontEnd.ContinueAtStep('Eft_Close');
        end;
    end;

    local procedure "--"()
    begin
    end;

    procedure ValidateRequirements(RegisterNo: Code[10];SalesTicketNo: Code[20]): Boolean
    var
        RetailSetup: Record "Retail Setup";
        NPRetailSetup: Record "NP Retail Setup";
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

        NPRetailSetup.Get ();
        NPRetailSetup.TestField ("Advanced Posting Activated");

        if (SalesTicketNo = '') then
          exit (true);

        // TODO - Needs to verified for UNITS / BINS
        RetailSetup.Get;
        RetailSetup.CheckOnline;

        Register.Get(RegisterNo);
        if (Register.Status = Register.Status::Afsluttet) then
          Error(t001);

        SalePOS.Get (RegisterNo, SalesTicketNo);
        if (RetailSalesLineCode.LineExists (SalePOS)) then
          Error(t002);

        //-NPR5.48 [334633]
        // IF (NOT RetailFormCode.CheckSavedSales (SalePOS)) THEN
        //  ERROR ('');
        if not POSQuoteMgt.CleanupPOSQuotesBeforeBalancing(SalePOS) then
          Error('');
        //+NPR5.48 [334633]

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          if (Register.FindSet()) then repeat
            if (Register."Register No." <> RegisterNo) then begin
              Message(t003, Register."Register No.");
              exit(false);
            end;
          until Register.Next = 0;
        end;

        exit (true);
    end;

    local procedure FinalEndOfDay(UnitNo: Code[10];DimensionSetId: Integer): Boolean
    var
        POSEntry: Record "POS Entry";
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        POSCheckpointMgr: Codeunit "POS Workshift Checkpoint";
        EntryNo: Integer;
    begin

        //-NPR5.49 [348458]
        // EntryNo := POSCheckpointMgr.CreateCheckpointWithDimension (TRUE, TRUE, UnitNo, DimensionSetId);
        EntryNo := POSCheckpointMgr.EndWorkshift (EndOfDayTypeOption::"Z-Report", UnitNo, DimensionSetId);
        //+NPR5.49 [348458]

        if (not POSEntry.Get (EntryNo)) then
          exit (false);

        PrintEndOfDayReport (UnitNo, EntryNo);

        // We dont have a SalePOS as base for sending the SMS anymore
        //IF (NOT CODEUNIT.RUN (CODEUNIT::"Send Register Balance", SalePOS)) THEN
        //  MESSAGE(txtCannotSendSMSWB);

        POSWorkshiftCheckpoint.SetFilter ("POS Entry No.", '=%1', EntryNo);
        if (POSWorkshiftCheckpoint.FindFirst ()) then
          exit (not POSWorkshiftCheckpoint.Open);

        exit (false);
    end;

    local procedure PreliminaryEndOfDay(UnitNo: Code[10];DimensionSetId: Integer): Boolean
    var
        POSEntry: Record "POS Entry";
        POSCheckpointMgr: Codeunit "POS Workshift Checkpoint";
        EntryNo: Integer;
    begin

        //-NPR5.49 [348458]
        //EntryNo := POSCheckpointMgr.CreateCheckpointWithDimension (TRUE, FALSE, UnitNo, DimensionSetId);
        EntryNo := POSCheckpointMgr.EndWorkshift (EndOfDayTypeOption::"X-Report", UnitNo, DimensionSetId);
        //+NPR5.49 [348458]

        if (not POSEntry.Get (EntryNo)) then
          exit (false);

        PrintEndOfDayReport (UnitNo, EntryNo);

        exit (true);
    end;

    local procedure CloseWorkshift(UnitNo: Code[10];DimensionSetId: Integer): Boolean
    var
        POSEntry: Record "POS Entry";
        POSUnit: Record "POS Unit";
        POSEndofDayProfile: Record "POS End of Day Profile";
        POSCheckpointMgr: Codeunit "POS Workshift Checkpoint";
        EntryNo: Integer;
        PosIsManaged: Boolean;
        WithPrint: Boolean;
    begin

        //-NPR5.49 [348458]
        PosIsManaged := false;
        WithPrint := true;
        POSUnit.Get (UnitNo);
        if (POSUnit."POS End of Day Profile" <> '') then
          if (POSEndofDayProfile.Get (POSUnit."POS End of Day Profile")) then
            if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then begin
              PosIsManaged := (POSUnit."No." <> POSEndofDayProfile."Master POS Unit No.");
              WithPrint := (POSEndofDayProfile."Close Workshift UI" <> POSEndofDayProfile."Close Workshift UI"::NO_PRINT);
            end;

        if (not PosIsManaged) then
          Error (MustBeManaged);

        EntryNo := POSCheckpointMgr.EndWorkshift (EndOfDayTypeOption::CloseWorkshift, UnitNo, DimensionSetId);

        if (not POSEntry.Get (EntryNo)) then
          exit (false);

        if (WithPrint) then
          PrintEndOfDayReport (UnitNo, EntryNo);

        exit (true);
        //+NPR5.49 [348458]
    end;

    local procedure PrintEndOfDayReport(UnitNo: Code[10];EntryNo: Integer)
    var
        POSEntry: Record "POS Entry";
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        ReportSelectionRetail: Record "Report Selection Retail";
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin

        POSEntry.Get (EntryNo);
        POSEntry.TestField ("Entry Type", POSEntry."Entry Type"::Balancing);

        POSWorkshiftCheckpoint.SetFilter ("POS Entry No.", '=%1', EntryNo);
        POSWorkshiftCheckpoint.FindFirst ();
        RecRef.GetTable (POSWorkshiftCheckpoint);

        RetailReportSelectionMgt.SetRegisterNo (UnitNo);
        RetailReportSelectionMgt.RunObjects (RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
    end;

    local procedure EftDiscovery(POSSession: Codeunit "POS Session")
    var
        EFTInterface: Codeunit "EFT Interface";
        tmpEFTSetup: Record "EFT Setup" temporary;
        EFTSetup: Record "EFT Setup";
    begin

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
        POSSession.BeginAction(ActionCode());
        POSSession.StoreActionState('eft_close_list', EFTSetup);
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
    end;

    local procedure EftCloseDone(POSSession: Codeunit "POS Session")
    var
        RecRef: RecordRef;
        EFTSetup: Record "EFT Setup";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin

        POSSession.RetrieveActionStateRecordRef('eft_close_list', RecRef);
        if RecRef.Number = 0 then
          exit;
        RecRef.SetTable(EFTSetup);
        if EFTSetup.Next = 0 then
          exit;

        POSSession.StoreActionState('eft_close_list', EFTSetup);
        NextWorkflowStep := NextWorkflowStep::EFT_CLOSE;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBalancing(SalePOS: Record "Sale POS";Register: Record Register)
    begin
    end;

    procedure CheckAndPostAfterBalancing(POSEntryno: Integer)
    var
        POSPeriodRegister: Record "POS Period Register";
        POSPeriodRegisterPostingFilter: Record "POS Period Register";
        POSEntry: Record "POS Entry";
    begin

        //-NPR5.51 [359508]
        if (not POSEntry.Get (POSEntryno)) then
          exit;

        if (not POSPeriodRegister.Get (POSEntry."POS Period Register No.")) then
          exit;

        ItemPosting (POSPeriodRegister);
        POSPosting (POSPeriodRegister);
        //+NPR5.51 [359508]
    end;

    local procedure POSPosting(POSPeriodRegister: Record "POS Period Register")
    var
        POSPeriodRegisterPostingFilter: Record "POS Period Register";
        NPRetailSetup: Record "NP Retail Setup";
    begin

        //-NPR5.51 [359508]
        if (not NPRetailSetup.Get ()) then
          exit;

        with NPRetailSetup do
          case ("Automatic POS Posting") of
            "Automatic POS Posting"::No : exit;
            "Automatic POS Posting"::AfterSale : exit;
            "Automatic POS Posting"::AfterEndOfDay :  POSPeriodRegisterPostingFilter.SetFilter ("POS Unit No.", '=%1', POSPeriodRegister."POS Unit No.");
            "Automatic POS Posting"::AfterLastEndofDayStore :
              begin
                POSPeriodRegisterPostingFilter.SetFilter ("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                POSPeriodRegisterPostingFilter.SetFilter (Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                if (POSPeriodRegisterPostingFilter.FindFirst ()) then begin
                  Message ('All periods are not closed for %1 %2 - POS Entries have not been posted.', POSPeriodRegister.FieldCaption ("POS Store Code"), POSPeriodRegister."POS Store Code");
                  exit;
                end;
                POSPeriodRegisterPostingFilter.Reset ();
                POSPeriodRegisterPostingFilter.SetFilter ("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
              end;
            "Automatic POS Posting"::AfterLastEndofDayCompany :
              begin
                POSPeriodRegisterPostingFilter.SetFilter (Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                if (POSPeriodRegisterPostingFilter.FindFirst ()) then begin
                  Message ('All periods are not closed - POS Entries have not been posted.');
                  exit;
                end;
                POSPeriodRegisterPostingFilter.Reset ();
                POSPeriodRegisterPostingFilter.SetFilter ("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
              end;
            else begin
              Message ('The settting %1 is not yet supported.', NPRetailSetup."Automatic POS Posting");
              exit;
            end;
          end;

        PostPeriodEntries (POSPeriodRegisterPostingFilter, true, false);
        //+NPR5.51 [359508]
    end;

    local procedure ItemPosting(POSPeriodRegister: Record "POS Period Register")
    var
        POSPeriodRegisterPostingFilter: Record "POS Period Register";
        NPRetailSetup: Record "NP Retail Setup";
        POSUnit: Record "POS Unit";
    begin

        //-NPR5.51 [359508]
        if (not NPRetailSetup.Get ()) then
          exit;

        with NPRetailSetup do
          case ("Automatic Item Posting") of
            "Automatic Item Posting"::No : exit;
            "Automatic Item Posting"::AfterSale : exit;
            "Automatic Item Posting"::AfterEndOfDay :
              begin
                POSPeriodRegisterPostingFilter.SetFilter ("POS Unit No.", '=%1', POSPeriodRegister."POS Unit No.");
              end;
            "Automatic Item Posting"::AfterLastEndofDayStore :
              begin
                POSPeriodRegisterPostingFilter.SetFilter ("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                POSPeriodRegisterPostingFilter.SetFilter (Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                if (POSPeriodRegisterPostingFilter.FindFirst ()) then begin
                  Message ('All periods are not closed for %1 %2 - Item Entries have not been posted.', POSPeriodRegister.FieldCaption ("POS Store Code"), POSPeriodRegister."POS Store Code");
                  exit;
                end;
                POSPeriodRegisterPostingFilter.Reset ();
                POSPeriodRegisterPostingFilter.SetFilter ("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
              end;
            "Automatic Item Posting"::AfterLastEndofDayCompany :
              begin
                POSPeriodRegisterPostingFilter.SetFilter (Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                if (POSPeriodRegisterPostingFilter.FindFirst ()) then begin
                  Message ('All periods are not closed - Item Entries have not been posted.');
                  exit;
                end;
                POSPeriodRegisterPostingFilter.Reset ();
                POSPeriodRegisterPostingFilter.SetFilter ("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
              end;
            else begin
              Message ('The settting %1 %2 is not yet supported.', FieldCaption ("Automatic Item Posting"), "Automatic Item Posting");
              exit;
            end;
          end;

        PostPeriodEntries (POSPeriodRegisterPostingFilter, false, true);
        //+NPR5.51 [359508]
    end;

    local procedure PostPeriodEntries(var POSPeriodRegisterPostingFilter: Record "POS Period Register";pPostPOSEntries: Boolean;pPostItemEntries: Boolean)
    var
        POSEntry: Record "POS Entry";
        HaveUnpostedEntries: Boolean;
        PostingError: Boolean;
    begin

        //-NPR5.51 [359508]
        POSPeriodRegisterPostingFilter.SetFilter ("Opened Date", '%1..', CreateDateTime (CalcDate ('<-7D>', Today), 0T));
        POSPeriodRegisterPostingFilter.Ascending (false);
        if (POSPeriodRegisterPostingFilter.FindSet ()) then begin
          repeat
            POSEntry.SetFilter ("POS Period Register No.", '=%1', POSPeriodRegisterPostingFilter."No.");

            if (pPostPOSEntries) then
              POSEntry.SetFilter ("Post Entry Status", '<2');

            if (pPostItemEntries) then
              POSEntry.SetFilter ("Post Item Entry Status", '<2');

            HaveUnpostedEntries :=  not POSEntry.IsEmpty ();
            PostingError := false;

            if (HaveUnpostedEntries) then begin
              PostPeriodEntriesWorker (POSPeriodRegisterPostingFilter."No.", pPostPOSEntries , pPostItemEntries);
              PostingError := not POSEntry.IsEmpty ();
            end;

            if (PostingError) then
              Error ('There was an error during posting of entries for POS Period Register %1.\\%2', POSPeriodRegisterPostingFilter."No.", GetLastErrorText);

          until ((POSPeriodRegisterPostingFilter.Next() = 0) or (PostingError));
        end;
        //+NPR5.51 [359508]
    end;

    local procedure PostPeriodEntriesWorker(PosPeriodEntryNo: Integer;pPostPOSEntries: Boolean;pPostItemEntries: Boolean)
    var
        POSPeriodRegister: Record "POS Period Register";
        POSPostEntries: Codeunit "POS Post Entries";
        POSEntry: Record "POS Entry";
    begin

        //-NPR5.51 [359508]
        if (not POSPeriodRegister.Get (PosPeriodEntryNo)) then
          exit;

        if (POSPeriodRegister.Status <> POSPeriodRegister.Status::CLOSED) then
          exit;

        if (POSPeriodRegister."End of Day Date" <> 0DT) then
          if (POSPeriodRegister."Posting Compression" = POSPeriodRegister."Posting Compression"::"Per POS Period") then
            POSPostEntries.SetPostingDate (true, false, DT2Date (POSPeriodRegister."End of Day Date"));

        POSPostEntries.SetPostCompressed (true);
        POSPostEntries.SetPostPOSEntries (pPostPOSEntries);
        POSPostEntries.SetPostItemEntries (pPostItemEntries);

        POSEntry.SetFilter ("POS Period Register No.", '=%1', POSPeriodRegister."No.");

        if (not POSEntry.IsEmpty ()) then begin
          Commit;
          POSPostEntries.Run (POSEntry);
          Commit;
        end;
        //+NPR5.51 [359508]
    end;
}

