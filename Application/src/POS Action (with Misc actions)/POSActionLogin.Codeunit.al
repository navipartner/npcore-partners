codeunit 6150721 "NPR POS Action - Login"
{
    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for completing the loign request passed on from the front end.';
        Text001: Label 'Unknown login type requested by JavaScript: %1.';
        InvalidStatus: Label 'The register status states that the register cannot be opened at this time.';
        CashRegisterOpenStatus: Option DoOpenRegister,DoNotOpenRegister,BalanceRegister,FirstOpenAfterBalancing;
        t002: Label 'Do you want to open register %1 with opening total of %2?';
        t004: Label 'The register has not been balanced since %1 and must be balanced before selling. Do you want to balance the register now?';
        t005: Label 'Register balancing';
        t006: Label 'Notice IMPORTANT, the Date "Posting Allowed to" has been crossed.\Contact your superuser who can correct this date.\If you reply OK, the date will be corrected\ so the register will open today.';
        MustBalanceRegister: Label 'The register has not been balanced since %1 and must be balanced before selling. The balancing function is available from the function menu below the pinpad.';
        IsEoD: Label 'The %1 %2 indicates that this %1 is being balanced and it can''t be opened at this time.';
        ContinueEoD: Label 'The %1 %2 is marked as being in balancing. Do you want to continue with balancing now?';
        ManagedPos: Label 'This POS is managed by POS Unit %1 [%2] and it is therefore required that %1 is opened prior to opening this POS.';

    local procedure ActionCode(): Text
    begin
        exit('LOGIN');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::BackEnd,
          Sender."Subscriber Instances Allowed"::Single);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Setup: Codeunit "NPR POS Setup";
        POSUnitIdentity: Codeunit "NPR POS Unit Identity";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSUnitIdentityRec: Record "NPR POS Unit Identity";
        Register: Record "NPR Register";
        UserSetup: Record "User Setup";
        Type: Text;
        Password: Text;
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        // TODO:
        // - Verify the login information
        // - If everything is okay, call POSSession.StartTransaction
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        Type := JSON.GetString('type', true);
        POSSession.GetSetup(Setup);

        // Fallback - when framwork is not providing the device identity
        POSSession.GetSessionId(HardwareId, SessionName, HostName);
        if (HardwareId = '') then begin
            UserSetup.Get(UserId);
            UserSetup.TestField("NPR Backoffice Register No.");
            POSUnitIdentity.ConfigureTemporaryDevice(UserSetup."NPR Backoffice Register No.", POSUnitIdentityRec);
            Setup.InitializeUsingPosUnitIdentity(POSUnitIdentityRec);
            POSSession.InitializeSessionId(POSUnitIdentityRec."Device ID", SessionName, HostName);
        end;

        Clear(SalespersonPurchaser);
        case Type of
            'SalespersonCode':
                begin
                    Password := JSON.GetString('password', true);
                    if (DelChr(Password, '<=>', ' ') = '') then
                        Error('Illegal password.');

                    SalespersonPurchaser.SetRange("NPR Register Password", Password);

                    if ((SalespersonPurchaser.FindFirst() and (Password <> ''))) then begin
                        OnAfterFindSalesperson(SalespersonPurchaser);
                        Setup.SetSalesperson(SalespersonPurchaser);

                        if (NPRetailSetup.Get()) then;
                        if (not NPRetailSetup."Advanced Posting Activated") then
                            OpenRegisterLegacy(FrontEnd, Setup, POSSession);

                        if (NPRetailSetup."Advanced Posting Activated") then
                            OpenPosUnit(FrontEnd, Setup, POSSession);
                    end else begin
                        Error('Illegal password.');
                    end;

                end;
            else
                FrontEnd.ReportBug(StrSubstNo(Text001, Type));
        end;
    end;

    local procedure OpenPosUnit(FrontEnd: Codeunit "NPR POS Front End Management"; Setup: Codeunit "NPR POS Setup"; POSSession: Codeunit "NPR POS Session")
    var
        POSUnit: Record "NPR POS Unit";
        Register: Record "NPR Register";
        BalanceAge: Integer;
        IsManagedPOS: Boolean;
        ManagedByPOSUnit: Record "NPR POS Unit";
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSPeriodRegister: Record "NPR POS Period Register";
        MissingPeriodRegister: Boolean;
    begin
        // This should be inside the START_POS workflow
        // But to save a roundtrip and becase nested workflows are not perfect yet, I have kept this part here

        Setup.GetPOSUnit(POSUnit);
        Setup.GetRegisterRecord(Register);

        POSUnit.Get(POSUnit."No.");
        Register.Get(Register."Register No.");

        BalanceAge := DaysSinceLastBalance(POSUnit."No.");

        if (POSUnit."POS End of Day Profile" <> '') then begin
            POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");
            if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
                IsManagedPOS := (POSEndofDayProfile."Master POS Unit No." <> POSUnit."No.");
            if (IsManagedPOS) then begin
                ManagedByPOSUnit.Get(POSEndofDayProfile."Master POS Unit No.");
                Register.Get(ManagedByPOSUnit."No.");
                BalanceAge := DaysSinceLastBalance(ManagedByPOSUnit."No.");
            end;
        end;

        case POSUnit.Status of

            POSUnit.Status::OPEN:
                begin
                    // This state might happen first time when attaching a POS as a slave with status open when master is state close.
                    if ((IsManagedPOS) and (ManagedByPOSUnit.Status <> ManagedByPOSUnit.Status::OPEN)) then begin
                        Message(ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);
                        StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS); // will fix status on the managed POS
                        exit;
                    end;

                    if (BalanceAge = -1) then begin  // Has never been balanced
                        StartWorkflow(FrontEnd, POSSession, 'START_POS');
                        exit;
                    end;

                    if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing
                        if (not Confirm(t004, true, (Today - BalanceAge))) then
                            Error(InvalidStatus);

                        // Z-Report or Close Worksift
                        StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                        exit;
                    end;

                    POSPeriodRegister.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
                    MissingPeriodRegister := not POSPeriodRegister.FindLast();
                    if (MissingPeriodRegister) or ((not MissingPeriodRegister) and (POSPeriodRegister.Status <> POSPeriodRegister.Status::OPEN)) then begin
                        StartWorkflow(FrontEnd, POSSession, 'START_POS');
                        exit;
                    end;

                    StartPOS(POSSession);
                end;

            POSUnit.Status::CLOSED:
                begin
                    if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing
                        if (IsManagedPOS) then
                            Error(ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);

                        if (not Confirm(t004, true, Format(Today - BalanceAge))) then
                            Error(InvalidStatus);

                        StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                        exit;
                    end;

                    StartWorkflow(FrontEnd, POSSession, 'START_POS');
                end;

            POSUnit.Status::EOD:
                begin
                    if (not Confirm(ContinueEoD, true, POSUnit.TableCaption(), POSUnit."No.")) then
                        Error(IsEoD, POSUnit.TableCaption(), POSUnit.FieldCaption(Status));

                    StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                end;
        end;
    end;

    local procedure StartPOS(POSSession: Codeunit "NPR POS Session"): Integer
    var
        SalePOS: Record "NPR Sale POS";
        POSAction: Record "NPR POS Action";
        POSViewProfile: Record "NPR POS View Profile";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSetup: Codeunit "NPR POS Setup";
        ResumeFromPOSQuoteNo: Integer;
        ResumeExistingSale: Boolean;
    begin
        ResumeExistingSale := POSResumeSale.SelectUnfinishedSaleToResume(SalePOS, POSSession, ResumeFromPOSQuoteNo);

        POSSession.GetSetup(POSSetup);
        POSCreateEntry.InsertUnitLoginEntry(POSSetup.Register, POSSetup.Salesperson);

        if ResumeExistingSale and (ResumeFromPOSQuoteNo = 0) then
            POSSession.ResumeTransaction(SalePOS)
        else
            POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
        if ResumeFromPOSQuoteNo <> 0 then
            if POSSale.ResumeFromPOSQuote(ResumeFromPOSQuoteNo) then
                POSSession.RequestRefreshData();
        POSSale.GetCurrentSale(SalePOS);

        if ResumeExistingSale then begin
            POSSession.ChangeViewSale();
        end else begin
            POSSetup.GetPOSViewProfile(POSViewProfile);
            case POSViewProfile."Initial Sales View" of
                POSViewProfile."Initial Sales View"::SALES_VIEW:
                    POSSession.ChangeViewSale();
                POSViewProfile."Initial Sales View"::RESTAURANT_VIEW:
                    POSSession.ChangeViewRestaurant();
            end;
        end;
    end;

    local procedure StartWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; ActionName: Code[20])
    var
        POSAction: Record "NPR POS Action";
    begin
        if (not POSSession.RetrieveSessionAction(ActionName, POSAction)) then
            POSAction.Get(ActionName);

        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure StartEODWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; ActionName: Code[20]; ManagedEOD: Boolean)
    var
        POSAction: Record "NPR POS Action";
    begin
        if (not POSSession.RetrieveSessionAction(ActionName, POSAction)) then
            POSAction.Get(ActionName);

        POSSession.StartTransaction();

        case ActionName of
            'BALANCE_V3':
                begin
                    if (not ManagedEOD) then POSAction.SetWorkflowInvocationParameter('Type', 1, FrontEnd);  // Z-Report, final count
                    if (ManagedEOD) then POSAction.SetWorkflowInvocationParameter('Type', 2, FrontEnd);  // Close Workshift - for managed POS
                end;
        end;

        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure DaysSinceLastBalance(PosUnitNo: Code[10]): Integer
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', PosUnitNo);
        POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);

        if (not POSWorkshiftCheckpoint.FindLast()) then
            exit(-1); // Never been balanced

        exit(Today - DT2Date(POSWorkshiftCheckpoint."Created At"));
    end;

    #region Legacy

    local procedure OpenRegisterLegacy(FrontEnd: Codeunit "NPR POS Front End Management"; Setup: Codeunit "NPR POS Setup"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR Sale POS";
        POSAction: Record "NPR POS Action";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin

        case RegisterTestOpen(Setup.Register()) of
            CashRegisterOpenStatus::DoNotOpenRegister:
                Error(InvalidStatus);

            CashRegisterOpenStatus::FirstOpenAfterBalancing: // After confirm on first open after balancing
                begin
                    POSSession.StartTransaction();
                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    if RegisterOpen(SalePOS) then begin
                        // RegisterOpen consumes the current sales ticket when opening the register on first open after balancing
                        POSSession.StartTransaction();
                        POSSale.GetCurrentSale(SalePOS);
                    end;
                    POSSession.ChangeViewSale();
                end;

            CashRegisterOpenStatus::BalanceRegister:
                begin
                    POSSession.StartTransaction();
                    if not POSSession.RetrieveSessionAction('BALANCE_V1', POSAction) then
                        POSAction.Get('BALANCE_V1');
                    FrontEnd.InvokeWorkflow(POSAction);
                end;

            CashRegisterOpenStatus::DoOpenRegister:
                begin
                    POSSession.StartTransaction();
                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    POSCreateEntry.InsertUnitLoginEntry(SalePOS."Register No.", SalePOS."Salesperson Code");
                    POSSession.ChangeViewSale();
                end;
            else
                Error('Illegal Register Cash TerminalStatus');
        end;
    end;

    procedure RegisterTestOpen(CashRegisterNo: Code[10]): Integer
    var
        CashRegister: Record "NPR Register";
        RetailSalesCode: Codeunit "NPR Retail Sales Code";
    begin
        CashRegister.Get(CashRegisterNo);

        case CashRegister.Status of
            CashRegister.Status::" ":
                ;
            CashRegister.Status::Afsluttet:
                begin
                    if (not RetailSalesCode.CheckPostingDateAllowed(WorkDate)) then
                        if (not Confirm(t006)) then
                            exit(CashRegisterOpenStatus::DoNotOpenRegister);

                    if not Confirm(StrSubstNo(t002, CashRegister."Register No.", CashRegister."Closing Cash"), true) then
                        exit(CashRegisterOpenStatus::DoNotOpenRegister);

                    exit(CashRegisterOpenStatus::FirstOpenAfterBalancing);
                end;

            CashRegister.Status::Ekspedition:
                begin
                    if CashRegister."Opened Date" = Today then
                        exit(CashRegisterOpenStatus::DoOpenRegister);

                    case CashRegister."Balancing every" of
                        CashRegister."Balancing every"::Day:
                            begin
                                if Confirm(t004, true, CashRegister."Opened Date") then
                                    exit(CashRegisterOpenStatus::BalanceRegister);
                                exit(CashRegisterOpenStatus::DoNotOpenRegister);
                            end;

                        CashRegister."Balancing every"::Manual:
                            exit(CashRegisterOpenStatus::DoOpenRegister);

                        else
                            exit(CashRegisterOpenStatus::DoNotOpenRegister);
                    end;
                end;
        end;

        exit(CashRegisterOpenStatus::DoOpenRegister);
    end;

    local procedure RegisterOpen(SalePOS: Record "NPR Sale POS"): Boolean
    var
        CashRegister: Record "NPR Register";
        RetailSalesCode: Codeunit "NPR Retail Sales Code";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
    begin
        if (not RetailSalesCode.CheckPostingDateAllowed(WorkDate)) then
            RetailSalesCode.EditPostingDateAllowed(UserId, WorkDate);

        CashRegister.LockTable;
        CashRegister.Get(SalePOS."Register No.");
        if CashRegister.Status <> CashRegister.Status::Afsluttet then
            exit(false);

        TouchScreenFunctions.RegisterOpen(SalePOS);

        exit(true);
    end;

    #endregion

    [EventSubscriber(ObjectType::Codeunit, 6014505, 'OnBeforeRegisterOpen', '', true, true)]
    local procedure OnRegisterOpen_LegacySubscriber(Register: Record "NPR Register")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        POSCreateEntry.InsertUnitOpenEntry(Register."Register No.", '');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
    end;
}