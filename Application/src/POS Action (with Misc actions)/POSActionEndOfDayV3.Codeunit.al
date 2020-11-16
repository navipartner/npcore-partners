codeunit 6150849 "NPR POS Action: EndOfDay V3"
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
    // NPR5.52/ALPO/20190923 CASE 365326 POS Posting related fields moved to POS Posting Profiles from NP Retail Setup
    // TODO Units and Bins must get correct status
    // NPR5.53/BHR / 20191004 CASE 369361 Removed online checks
    // NPR5.54/MMV /20200225 CASE 364340 Added EFT event before pause
    // NPR5.55/TSA /20200424 CASE 401799 Added CloseWorkshift on slave when closing master
    // NPR5.55/BHR /20200602 CASE 405112 Add Functionality for Auto Open Cash Register
    // NPR5.55/TSA /20200424 CASE 401799 Refactored printing to handle print failure and EOD completion


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
        exit('BALANCE_V3');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.55 [405112]
        //EXIT ('1.6');
        exit('1.8');
        //+NPR5.55 [405112]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin

                RegisterWorkflowStep('ValidateRequirements', 'respond()');
                RegisterWorkflowStep('NotifySubscribers', 'respond()');
                RegisterWorkflowStep('Eft_Discovery', 'respond()');
                RegisterWorkflowStep('Eft_Close', 'respond()');
                RegisterWorkflowStep('Eft_CloseDone', 'respond()');
                //-NPR5.55 [405112]
                RegisterWorkflowStep('OpenCashDrawer', 'respond()');
                //+NPR5.55 [405112]
                RegisterWorkflowStep('BalanceRegister', 'respond()');
                RegisterWorkflowStep('EndOfWorkflow', 'respond()');

                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                RegisterOptionParameter('Type', 'X-Report (prel),Z-Report (final),Close Workshift', 'X-Report (prel)');
                //-NPR5.55 [405112]
                RegisterBooleanParameter('Auto-Open Cash Drawer', false);
                RegisterTextParameter('Cash Drawer No.', '');
                //+NPR5.55 [405112]

                RegisterWorkflow(false);

            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        SalePOS: Record "NPR Sale POS";
        Register: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EftHandled: Boolean;
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EndOfDayType: Integer;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        ClosingEntryNo: Integer;
        CashDrawerNo: Code[10];
        RecID: RecordID;
        OpenCashRegister: Boolean;
        BalanceEntryToPrint: Integer;
        CurrentView: DotNet NPRNetView0;
        ViewType: DotNet NPRNetViewType0;
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        //-NPR5.55 [405112]
        OpenCashRegister := JSON.GetBooleanParameter('Auto-Open Cash Drawer', false);
        CashDrawerNo := JSON.GetStringParameter('Cash Drawer No.', false);
        //+NPR5.55 [405112]

        EndOfDayType := JSON.GetIntegerParameter('Type', true);
        if (EndOfDayType < 0) then
            EndOfDayType := 0;

        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSetup.GetRegisterRecord(Register);

        POSSetup.GetPOSUnit(POSUnit);
        POSSetup.GetSalespersonRecord(SalespersonPurchaser);
        SalePOS."Register No." := Register."Register No.";

        NextWorkflowStep := NextWorkflowStep::NA;
        case WorkflowStep of
            'ValidateRequirements':
                begin
                    if (not (ValidateRequirements(Register."Register No.", SalePOS."Sales Ticket No."))) then
                        FrontEnd.ContinueAtStep('EndOfWorkflow');
                    POSCreateEntry.InsertUnitCloseBeginEntry(Register."Register No.", SalespersonPurchaser.Code);
                end;

            'NotifySubscribers':
                begin
                end;

            'Eft_Discovery':
                //-NPR5.49 [348458]
                // EftDiscovery(POSSession);
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftDiscovery(POSSession);
            //+NPR5.49 [348458]

            'Eft_Close':
                //-NPR5.49 [348458]
                // EftClose(POSSession, FrontEnd);
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftClose(POSSession, FrontEnd);
            //+NPR5.49 [348458]

            'Eft_CloseDone':
                //-NPR5.49 [348458]
                // EftCloseDone(POSSession);
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftCloseDone(POSSession);
            //+NPR5.49 [348458]

            //-NPR5.55 [405112]
            'OpenCashDrawer':
                if (OpenCashRegister) then
                    OpenDrawer(CashDrawerNo, POSUnit, SalePOS);
            //-NPR5.55 [405112]

            'BalanceRegister':
                begin

                    POSManagePOSUnit.SetEndOfDayPOSUnitNo(POSUnit."No.");

                    case (EndOfDayType) of
                        EndOfDayTypeOption::"Z-Report":
                            begin
                                if (FinalEndOfDay(Register."Register No.", SalePOS."Dimension Set ID", BalanceEntryToPrint)) then begin
                                    ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(Register."Register No.", SalespersonPurchaser.Code);
                                    POSManagePOSUnit.ClosePOSUnitNo(POSUnit."No.", ClosingEntryNo);
                                    //-NPR5.51 [359508]
                                    CheckAndPostAfterBalancing(ClosingEntryNo);
                                    //+NPR5.51 [359508]

                                    //-NPR5.55 [401799]
                                    Commit;
                                    POSSession.ChangeViewLogin();
                                    PrintEndOfDayReport(POSUnit."No.", BalanceEntryToPrint);
                                    //+NPR5.55 [401799]

                                end else begin
                                    POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnit."No.");
                                end;
                            end;

                        //-NPR5.49 [348458]
                        EndOfDayTypeOption::CloseWorkshift:
                            begin
                                CloseWorkshift(Register."Register No.", SalePOS."Dimension Set ID", BalanceEntryToPrint);
                                ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(Register."Register No.", SalespersonPurchaser.Code);
                                POSManagePOSUnit.ClosePOSUnitNo(POSUnit."No.", ClosingEntryNo);

                                //-NPR5.51 [359508]
                                CheckAndPostAfterBalancing(ClosingEntryNo);
                                //+NPR5.51 [359508]

                                //-NPR5.55 [401799]
                                if (BalanceEntryToPrint <> 0) then begin
                                    Commit;
                                    POSSession.ChangeViewLogin();
                                    PrintEndOfDayReport(POSUnit."No.", BalanceEntryToPrint);
                                end;

                            end;
                        //+NPR5.49 [348458]
                        else begin
                                PreliminaryEndOfDay(Register."Register No.", SalePOS."Dimension Set ID");
                                POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnit."No.");
                            end;
                    end;

                end;

            'EndOfWorkflow':
                begin
                    //-NPR5.55 [401799]
                    // POSSession.ChangeViewLogin ();
                    POSSession.GetCurrentView(CurrentView);
                    if (not CurrentView.Type.Equals(ViewType.Login)) then
                        POSSession.ChangeViewLogin();
                    //+NPR5.55 [401799]
                end;
        end;

        case NextWorkflowStep of

            //-NPR5.55 [405112]
            //NextWorkflowStep::JUMP_BALANCE_REGISTER : FrontEnd.ContinueAtStep ('BalanceRegister');
            NextWorkflowStep::JUMP_BALANCE_REGISTER:
                FrontEnd.ContinueAtStep('OpenCashDrawer');
            //-NPR5.55 [405112]

            NextWorkflowStep::EFT_CLOSE:
                FrontEnd.ContinueAtStep('Eft_Close');
        end;
    end;

    local procedure "--"()
    begin
    end;

    procedure ValidateRequirements(RegisterNo: Code[10]; SalesTicketNo: Code[20]): Boolean
    var
        RetailSetup: Record "NPR Retail Setup";
        NPRetailSetup: Record "NPR NP Retail Setup";
        "Audit Roll Check": Record "NPR Audit Roll";
        Register: Record "NPR Register";
        "Payment Type - Detailed": Record "NPR Payment Type - Detailed";
        SalePOS: Record "NPR Sale POS";
        POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        RetailSalesLineCode: Codeunit "NPR Retail Sales Line Code";
        Action1: Action;
        closingType: Option Cancel,Normal,Saved;
    begin

        NPRetailSetup.Get();
        NPRetailSetup.TestField("Advanced Posting Activated");

        if (SalesTicketNo = '') then
            exit(true);

        // TODO - Needs to verified for UNITS / BINS
        RetailSetup.Get;
        //-NPR5.53 [369361]
        //RetailSetup.CheckOnline;
        //+NPR5.53 [369361]

        Register.Get(RegisterNo);
        if (Register.Status = Register.Status::Afsluttet) then
            Error(t001);

        SalePOS.Get(RegisterNo, SalesTicketNo);
        if (RetailSalesLineCode.LineExists(SalePOS)) then
            Error(t002);

        //-NPR5.48 [334633]
        // IF (NOT RetailFormCode.CheckSavedSales (SalePOS)) THEN
        //  ERROR ('');
        if not POSQuoteMgt.CleanupPOSQuotesBeforeBalancing(SalePOS) then
            Error('');
        //+NPR5.48 [334633]

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
            if (Register.FindSet()) then
                repeat
                    if (Register."Register No." <> RegisterNo) then begin
                        Message(t003, Register."Register No.");
                        exit(false);
                    end;
                until Register.Next = 0;
        end;

        exit(true);
    end;

    local procedure FinalEndOfDay(UnitNo: Code[10]; DimensionSetId: Integer; var EntryNo: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSUnit: Record "NPR POS Unit";
        POSUnitSlaves: Record "NPR POS Unit";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        ClosingEntryNo: Integer;
    begin

        //-NPR5.55 [401799]
        // Close workshift for the slave units.
        POSUnit.Get(UnitNo);
        if (POSUnit."POS End of Day Profile" <> '') then
            if (POSEndofDayProfile.Get(POSUnit."POS End of Day Profile")) then
                if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then begin
                    POSUnitSlaves.SetFilter("POS End of Day Profile", '=%1', POSUnit."POS End of Day Profile");
                    if (POSUnitSlaves.FindSet()) then begin
                        repeat
                            if (POSUnitSlaves."No." <> POSEndofDayProfile."Master POS Unit No.") then
                                if (POSUnitSlaves.Status = POSUnitSlaves.Status::OPEN) then begin
                                    CloseWorkshift(POSUnitSlaves."No.", DimensionSetId, EntryNo);
                                    ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnitSlaves."No.", '');
                                    POSManagePOSUnit.ClosePOSUnitNo(POSUnitSlaves."No.", ClosingEntryNo);
                                    CheckAndPostAfterBalancing(ClosingEntryNo);
                                end;
                        until (POSUnitSlaves.Next() = 0);
                    end;
                end;
        //+NPR5.55 [401799]

        //-NPR5.49 [348458]
        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::"Z-Report", UnitNo, DimensionSetId);
        //+NPR5.49 [348458]

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        //-NPR5.55 [401799]
        // PrintEndOfDayReport (UnitNo, EntryNo);
        //+NPR5.55 [401799]

        // We dont have a SalePOS as base for sending the SMS anymore
        //IF (NOT CODEUNIT.RUN (CODEUNIT::"Send Register Balance", SalePOS)) THEN
        //  MESSAGE(txtCannotSendSMSWB);

        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', EntryNo);
        if (POSWorkshiftCheckpoint.FindFirst()) then
            exit(not POSWorkshiftCheckpoint.Open);

        exit(false);
    end;

    local procedure PreliminaryEndOfDay(UnitNo: Code[10]; DimensionSetId: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        EntryNo: Integer;
    begin

        //-NPR5.49 [348458]
        //EntryNo := POSCheckpointMgr.CreateCheckpointWithDimension (TRUE, FALSE, UnitNo, DimensionSetId);
        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::"X-Report", UnitNo, DimensionSetId);
        //+NPR5.49 [348458]

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        PrintEndOfDayReport(UnitNo, EntryNo);

        exit(true);
    end;

    local procedure CloseWorkshift(UnitNo: Code[10]; DimensionSetId: Integer; var PrintEntryNo: Integer): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
        EntryNo: Integer;
        PosIsManaged: Boolean;
        WithPrint: Boolean;
    begin

        //-NPR5.49 [348458]
        PosIsManaged := false;
        WithPrint := true;
        POSUnit.Get(UnitNo);
        if (POSUnit."POS End of Day Profile" <> '') then
            if (POSEndofDayProfile.Get(POSUnit."POS End of Day Profile")) then
                if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then begin
                    PosIsManaged := (POSUnit."No." <> POSEndofDayProfile."Master POS Unit No.");
                    WithPrint := (POSEndofDayProfile."Close Workshift UI" <> POSEndofDayProfile."Close Workshift UI"::NO_PRINT);
                end;

        if (not PosIsManaged) then
            Error(MustBeManaged);

        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::CloseWorkshift, UnitNo, DimensionSetId);

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

        //-NPR5.55 [401799]
        //IF (WithPrint) THEN
        //  PrintEndOfDayReport (UnitNo, EntryNo);
        if (WithPrint) then
            PrintEntryNo := EntryNo;
        //+NPR5.55 [401799]

        exit(true);
        //+NPR5.49 [348458]
    end;

    local procedure PrintEndOfDayReport(UnitNo: Code[10]; EntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin

        POSEntry.Get(EntryNo);
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::Balancing);

        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', EntryNo);
        POSWorkshiftCheckpoint.FindFirst();
        RecRef.GetTable(POSWorkshiftCheckpoint);

        RetailReportSelectionMgt.SetRegisterNo(UnitNo);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
    end;

    local procedure EftDiscovery(POSSession: Codeunit "NPR POS Session")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        tmpEFTSetup: Record "NPR EFT Setup" temporary;
        EFTSetup: Record "NPR EFT Setup";
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

    local procedure EftClose(POSSession: Codeunit "NPR POS Session"; POSFrontEnd: Codeunit "NPR POS Front End Management")
    var
        RecRef: RecordRef;
        EFTSetup: Record "NPR EFT Setup";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSSetup: Codeunit "NPR POS Setup";
        EFTInterface: Codeunit "NPR EFT Interface";
        SkipPause: Boolean;
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
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


        //-NPR5.54 [364340]
        // EFTFrameworkMgt.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, POSSetup.Register, SalePOS."Sales Ticket No.");
        // COMMIT;
        // EFTFrameworkMgt.SendRequest(EFTTransactionRequest);
        // POSFrontEnd.PauseWorkflow();
        EFTTransactionMgt.StartEndWorkshift(EFTSetup, SalePOS);
        //+NPR5.54 [364340]
    end;

    local procedure EftCloseDone(POSSession: Codeunit "NPR POS Session")
    var
        RecRef: RecordRef;
        EFTSetup: Record "NPR EFT Setup";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
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
    local procedure OnBeforeBalancing(SalePOS: Record "NPR Sale POS"; Register: Record "NPR Register")
    begin
    end;

    procedure CheckAndPostAfterBalancing(POSEntryno: Integer)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSPeriodRegisterPostingFilter: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
    begin

        //-NPR5.51 [359508]
        if (not POSEntry.Get(POSEntryno)) then
            exit;

        if (not POSPeriodRegister.Get(POSEntry."POS Period Register No.")) then
            exit;

        ItemPosting(POSPeriodRegister);
        POSPosting(POSPeriodRegister);
        //+NPR5.51 [359508]
    end;

    local procedure POSPosting(POSPeriodRegister: Record "NPR POS Period Register")
    var
        POSPeriodRegisterPostingFilter: Record "NPR POS Period Register";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin

        //-NPR5.51 [359508]
        if (not NPRetailSetup.Get()) then
            exit;

        //WITH NPRetailSetup DO  //NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile(POSPeriodRegister."POS Unit No.", POSPostingProfile);
        with POSPostingProfile do
            //+NPR5.52 [365326]
            case ("Automatic POS Posting") of
                "Automatic POS Posting"::No:
                    exit;
                "Automatic POS Posting"::AfterSale:
                    exit;
                "Automatic POS Posting"::AfterEndOfDay:
                    POSPeriodRegisterPostingFilter.SetFilter("POS Unit No.", '=%1', POSPeriodRegister."POS Unit No.");
                "Automatic POS Posting"::AfterLastEndofDayStore:
                    begin
                        POSPeriodRegisterPostingFilter.SetFilter("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                        POSPeriodRegisterPostingFilter.SetFilter(Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                        if (POSPeriodRegisterPostingFilter.FindFirst()) then begin
                            Message('All periods are not closed for %1 %2 - POS Entries have not been posted.', POSPeriodRegister.FieldCaption("POS Store Code"), POSPeriodRegister."POS Store Code");
                            exit;
                        end;
                        POSPeriodRegisterPostingFilter.Reset();
                        POSPeriodRegisterPostingFilter.SetFilter("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                    end;
                "Automatic POS Posting"::AfterLastEndofDayCompany:
                    begin
                        POSPeriodRegisterPostingFilter.SetFilter(Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                        if (POSPeriodRegisterPostingFilter.FindFirst()) then begin
                            Message('All periods are not closed - POS Entries have not been posted.');
                            exit;
                        end;
                        POSPeriodRegisterPostingFilter.Reset();
                        POSPeriodRegisterPostingFilter.SetFilter("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                    end;
                else begin
                        //MESSAGE ('The settting %1 is not yet supported.', NPRetailSetup."Automatic POS Posting");  //NPR5.52 [365326]-revoked
                        Message('The setting %1 is not yet supported.', "Automatic POS Posting");  //NPR5.52 [365326]
                        exit;
                    end;
            end;

        PostPeriodEntries(POSPeriodRegisterPostingFilter, true, false);
        //+NPR5.51 [359508]
    end;

    local procedure ItemPosting(POSPeriodRegister: Record "NPR POS Period Register")
    var
        POSPeriodRegisterPostingFilter: Record "NPR POS Period Register";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin

        //-NPR5.51 [359508]
        if (not NPRetailSetup.Get()) then
            exit;

        //WITH NPRetailSetup DO  //NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile(POSPeriodRegister."POS Unit No.", POSPostingProfile);
        with POSPostingProfile do
            //+NPR5.52 [365326]
            case ("Automatic Item Posting") of
                "Automatic Item Posting"::No:
                    exit;
                "Automatic Item Posting"::AfterSale:
                    exit;
                "Automatic Item Posting"::AfterEndOfDay:
                    begin
                        POSPeriodRegisterPostingFilter.SetFilter("POS Unit No.", '=%1', POSPeriodRegister."POS Unit No.");
                    end;
                "Automatic Item Posting"::AfterLastEndofDayStore:
                    begin
                        POSPeriodRegisterPostingFilter.SetFilter("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                        POSPeriodRegisterPostingFilter.SetFilter(Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                        if (POSPeriodRegisterPostingFilter.FindFirst()) then begin
                            Message('All periods are not closed for %1 %2 - Item Entries have not been posted.', POSPeriodRegister.FieldCaption("POS Store Code"), POSPeriodRegister."POS Store Code");
                            exit;
                        end;
                        POSPeriodRegisterPostingFilter.Reset();
                        POSPeriodRegisterPostingFilter.SetFilter("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                    end;
                "Automatic Item Posting"::AfterLastEndofDayCompany:
                    begin
                        POSPeriodRegisterPostingFilter.SetFilter(Status, '<>%1', POSPeriodRegisterPostingFilter.Status::CLOSED);
                        if (POSPeriodRegisterPostingFilter.FindFirst()) then begin
                            Message('All periods are not closed - Item Entries have not been posted.');
                            exit;
                        end;
                        POSPeriodRegisterPostingFilter.Reset();
                        POSPeriodRegisterPostingFilter.SetFilter("POS Store Code", '=%1', POSPeriodRegister."POS Store Code");
                    end;
                else begin
                        Message('The settting %1 %2 is not yet supported.', FieldCaption("Automatic Item Posting"), "Automatic Item Posting");
                        exit;
                    end;
            end;

        PostPeriodEntries(POSPeriodRegisterPostingFilter, false, true);
        //+NPR5.51 [359508]
    end;

    local procedure PostPeriodEntries(var POSPeriodRegisterPostingFilter: Record "NPR POS Period Register"; pPostPOSEntries: Boolean; pPostItemEntries: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        HaveUnpostedEntries: Boolean;
        PostingError: Boolean;
    begin

        //-NPR5.51 [359508]
        POSPeriodRegisterPostingFilter.SetFilter("Opened Date", '%1..', CreateDateTime(CalcDate('<-7D>', Today), 0T));
        POSPeriodRegisterPostingFilter.Ascending(false);
        if (POSPeriodRegisterPostingFilter.FindSet()) then begin
            repeat
                POSEntry.SetFilter("POS Period Register No.", '=%1', POSPeriodRegisterPostingFilter."No.");

                if (pPostPOSEntries) then
                    POSEntry.SetFilter("Post Entry Status", '<2');

                if (pPostItemEntries) then
                    POSEntry.SetFilter("Post Item Entry Status", '<2');

                HaveUnpostedEntries := not POSEntry.IsEmpty();
                PostingError := false;

                if (HaveUnpostedEntries) then begin
                    PostPeriodEntriesWorker(POSPeriodRegisterPostingFilter."No.", pPostPOSEntries, pPostItemEntries);
                    PostingError := not POSEntry.IsEmpty();
                end;

                if (PostingError) then
                    Error('There was an error during posting of entries for POS Period Register %1.\\%2', POSPeriodRegisterPostingFilter."No.", GetLastErrorText);

            until ((POSPeriodRegisterPostingFilter.Next() = 0) or (PostingError));
        end;
        //+NPR5.51 [359508]
    end;

    local procedure PostPeriodEntriesWorker(PosPeriodEntryNo: Integer; pPostPOSEntries: Boolean; pPostItemEntries: Boolean)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntry: Record "NPR POS Entry";
    begin

        //-NPR5.51 [359508]
        if (not POSPeriodRegister.Get(PosPeriodEntryNo)) then
            exit;

        if (POSPeriodRegister.Status <> POSPeriodRegister.Status::CLOSED) then
            exit;

        if (POSPeriodRegister."End of Day Date" <> 0DT) then
            if (POSPeriodRegister."Posting Compression" = POSPeriodRegister."Posting Compression"::"Per POS Period") then
                POSPostEntries.SetPostingDate(true, false, DT2Date(POSPeriodRegister."End of Day Date"));

        POSPostEntries.SetPostCompressed(true);
        POSPostEntries.SetPostPOSEntries(pPostPOSEntries);
        POSPostEntries.SetPostItemEntries(pPostItemEntries);

        POSEntry.SetFilter("POS Period Register No.", '=%1', POSPeriodRegister."No.");

        if (not POSEntry.IsEmpty()) then begin
            Commit;
            POSPostEntries.Run(POSEntry);
            Commit;
        end;
        //+NPR5.51 [359508]
    end;

    local procedure OpenDrawer(CashDrawerNo: Code[10]; POSUnit: Record "NPR POS Unit"; SalePOS: Record "NPR Sale POS")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin

        //-NPR5.55 [405112]
        if (CashDrawerNo = '') then
            CashDrawerNo := POSUnit."Default POS Payment Bin";

        SalePOS."Drawer Opened" := true;
        SalePOS.Modify;

        if not POSPaymentBin.Get(CashDrawerNo) then
            POSPaymentBin."Eject Method" := 'PRINTER';

        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS);

        //+NPR5.55 [405112]
    end;
}

