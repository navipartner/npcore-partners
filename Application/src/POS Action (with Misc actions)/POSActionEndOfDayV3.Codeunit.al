codeunit 6150849 "NPR POS Action: EndOfDay V3"
{
    var
        ActionDescription: Label 'This is the built in function to perform balancing of the register (Version 1)';
        t001: Label 'Register already closed!';
        t002: Label 'Delete all sales lines before balancing the register';
        t003: Label 'You must close sales window on register no. %1';
        NextWorkflowStep: Option NA,JUMP_BALANCE_REGISTER,EFT_CLOSE;
        EndOfDayTypeOption: Option "X-Report","Z-Report",CloseWorkshift;
        MustBeManaged: Label 'The Close Workshift function is only intended for POS units that are managed for End-of-Day. Use X-Report or Z-Report instead.';
        POSEntryPostIssue: Label 'There was an issue during posting of entries for POS Period Register %1.';

    local procedure ActionCode(): Text
    begin
        exit('BALANCE_V3');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.9');
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
                RegisterWorkflowStep('OpenCashDrawer', 'respond()');
                RegisterWorkflowStep('BalanceRegister', 'respond()');
                RegisterWorkflowStep('EndOfWorkflow', 'respond()');

                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                RegisterOptionParameter('Type', 'X-Report (prel),Z-Report (final),Close Workshift', 'X-Report (prel)');
                RegisterBooleanParameter('Auto-Open Cash Drawer', false);
                RegisterTextParameter('Cash Drawer No.', '');

                RegisterWorkflow(false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        SalePOS: Record "NPR Sale POS";
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
        OpenUnit: Boolean;
        BalanceEntryToPrint: Integer;
        CurrentView: Codeunit "NPR POS View";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        OpenUnit := JSON.GetBooleanParameter('Auto-Open Cash Drawer', false);
        CashDrawerNo := JSON.GetStringParameter('Cash Drawer No.', false);

        EndOfDayType := JSON.GetIntegerParameter('Type', true);
        if (EndOfDayType < 0) then
            EndOfDayType := 0;

        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSetup.GetPOSUnit(POSUnit);
        POSSetup.GetSalespersonRecord(SalespersonPurchaser);
        SalePOS."Register No." := POSUnit."No.";

        NextWorkflowStep := NextWorkflowStep::NA;
        case WorkflowStep of
            'ValidateRequirements':
                begin
                    if (not (ValidateRequirements(POSUnit."No.", SalePOS."Sales Ticket No."))) then
                        FrontEnd.ContinueAtStep('EndOfWorkflow');
                    POSCreateEntry.InsertUnitCloseBeginEntry(POSUnit."No.", SalespersonPurchaser.Code);
                end;

            'NotifySubscribers':
                begin
                end;

            'Eft_Discovery':
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftDiscovery(POSSession);

            'Eft_Close':
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftClose(POSSession, FrontEnd);

            'Eft_CloseDone':
                if (EndOfDayType = EndOfDayTypeOption::"Z-Report") then
                    EftCloseDone(POSSession);

            'OpenCashDrawer':
                if (OpenUnit) then
                    OpenDrawer(CashDrawerNo, POSUnit, SalePOS);

            'BalanceRegister':
                begin

                    POSManagePOSUnit.SetEndOfDayPOSUnitNo(POSUnit."No.");

                    case (EndOfDayType) of
                        EndOfDayTypeOption::"Z-Report":
                            begin
                                if (FinalEndOfDay(POSUnit."No.", SalePOS."Dimension Set ID", BalanceEntryToPrint)) then begin
                                    ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnit."No.", SalespersonPurchaser.Code);
                                    POSManagePOSUnit.ClosePOSUnitNo(POSUnit."No.", ClosingEntryNo);
                                    CheckAndPostAfterBalancing(ClosingEntryNo);

                                    Commit;
                                    POSSession.ChangeViewLogin();
                                    PrintEndOfDayReport(POSUnit."No.", BalanceEntryToPrint);
                                end else begin
                                    POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnit."No.");
                                end;
                            end;

                        EndOfDayTypeOption::CloseWorkshift:
                            begin
                                CloseWorkshift(POSUnit."No.", SalePOS."Dimension Set ID", BalanceEntryToPrint);
                                ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(POSUnit."No.", SalespersonPurchaser.Code);
                                POSManagePOSUnit.ClosePOSUnitNo(POSUnit."No.", ClosingEntryNo);

                                CheckAndPostAfterBalancing(ClosingEntryNo);

                                if (BalanceEntryToPrint <> 0) then begin
                                    Commit;
                                    POSSession.ChangeViewLogin();
                                    PrintEndOfDayReport(POSUnit."No.", BalanceEntryToPrint);
                                end;

                            end;
                        else begin
                                PreliminaryEndOfDay(POSUnit."No.", SalePOS."Dimension Set ID");
                                POSManagePOSUnit.ReOpenLastPeriodRegister(POSUnit."No.");
                            end;
                    end;
                end;

            'EndOfWorkflow':
                begin
                    POSSession.GetCurrentView(CurrentView);
                    if (CurrentView.Type <> CurrentView.Type::Login) then
                        POSSession.ChangeViewLogin();
                end;
        end;

        case NextWorkflowStep of
            NextWorkflowStep::JUMP_BALANCE_REGISTER:
                FrontEnd.ContinueAtStep('OpenCashDrawer');
            NextWorkflowStep::EFT_CLOSE:
                FrontEnd.ContinueAtStep('Eft_Close');
        end;
    end;

    local procedure "--"()
    begin
    end;

    procedure ValidateRequirements(POSUnitCode: Code[10]; SalesTicketNo: Code[20]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR Sale POS";
        POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
    begin

        if (SalesTicketNo = '') then
            exit(true);

        // TODO - Needs to verified for UNITS / BINS
        POSUnit.Get(POSUnitCode);

        SalePOS.Get(POSUnitCode, SalesTicketNo);
        if (LineExists(SalePOS)) then
            Error(t002);

        if not POSQuoteMgt.CleanupPOSQuotesBeforeBalancing(SalePOS) then
            Error('');

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

        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::"Z-Report", UnitNo, DimensionSetId);

        if (not POSEntry.Get(EntryNo)) then
            exit(false);

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
        EntryNo := POSCheckpointMgr.EndWorkshift(EndOfDayTypeOption::"X-Report", UnitNo, DimensionSetId);
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

        if (WithPrint) then
            PrintEntryNo := EntryNo;

        exit(true);
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

        EFTTransactionMgt.StartEndWorkshift(EFTSetup, SalePOS);
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

    procedure CheckAndPostAfterBalancing(POSEntryno: Integer)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSPeriodRegisterPostingFilter: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
    begin
        if (not POSEntry.Get(POSEntryno)) then
            exit;

        if (not POSPeriodRegister.Get(POSEntry."POS Period Register No.")) then
            exit;

        ItemPosting(POSPeriodRegister);
        POSPosting(POSPeriodRegister);
    end;

    local procedure POSPosting(POSPeriodRegister: Record "NPR POS Period Register")
    var
        POSPeriodRegisterPostingFilter: Record "NPR POS Period Register";
        NPRPOSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        NPRPOSUnit.GetPostingProfile(POSPeriodRegister."POS Unit No.", POSPostingProfile);
        with POSPostingProfile do
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
                        Message('The setting %1 is not yet supported.', "Automatic POS Posting");
                        exit;
                    end;
            end;

        PostPeriodEntries(POSPeriodRegisterPostingFilter, true, false);
    end;

    local procedure ItemPosting(POSPeriodRegister: Record "NPR POS Period Register")
    var
        POSPeriodRegisterPostingFilter: Record "NPR POS Period Register";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSUnit.GetPostingProfile(POSPeriodRegister."POS Unit No.", POSPostingProfile);
        with POSPostingProfile do
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
    end;

    local procedure PostPeriodEntries(var POSPeriodRegisterPostingFilter: Record "NPR POS Period Register"; pPostPOSEntries: Boolean; pPostItemEntries: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        HaveUnpostedEntries: Boolean;
        PostingError: Boolean;
    begin
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
                    Message(POSEntryPostIssue, POSPeriodRegisterPostingFilter."No.");

            until ((POSPeriodRegisterPostingFilter.Next() = 0) or (PostingError));
        end;
    end;

    local procedure PostPeriodEntriesWorker(PosPeriodEntryNo: Integer; pPostPOSEntries: Boolean; pPostItemEntries: Boolean)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntry: Record "NPR POS Entry";
    begin
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
    end;

    local procedure OpenDrawer(CashDrawerNo: Code[10]; POSUnit: Record "NPR POS Unit"; SalePOS: Record "NPR Sale POS")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        if (CashDrawerNo = '') then begin
            POSUnit.GetProfile(POSPostingProfile);
            CashDrawerNo := POSPostingProfile."POS Payment Bin";
        end;

        if not POSPaymentBin.Get(CashDrawerNo) then
            exit;

        SalePOS."Drawer Opened" := true;
        SalePOS.Modify;

        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS);
    end;


    procedure LineExists(var SalePOS: Record "NPR Sale POS"): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        exit(not SaleLinePOS.IsEmpty);
    end;
}
