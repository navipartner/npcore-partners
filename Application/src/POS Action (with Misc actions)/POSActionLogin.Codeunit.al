codeunit 6150721 "NPR POS Action - Login"
{
    // NPR5.32.11/TSA/20170620  CASE 279495 Invoke workflow BALANCE_V1 when register balancing is required before login
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant
    // NPR5.38/TSA /20171123 CASE 297087 InsertPOSUnitOpen entry
    // NPR5.39/TSA /20180214 CASE 305106 Disallow blank password, update current sale with new sales person
    // NPR5.40/VB  /20180307 CASE 306347 Refactored retrieval of POS Action
    // NPR5.46/TSA /20180913 CASE 328338 Handling POS Unit status when balancing V3 is used
    // NPR5.49/TSA /20190314 CASE 348458 Added state check for POS Open when end-of-day is managed by a different POS.
    // NPR5.51/TSA /20190622 CASE 359508 Adding a new pos period when the period is status closed (or missing) and the unit is open
    // NPR5.51/MMV /20190628 CASE 356076 Added system entry for login without balancing
    // NPR5.53/TJ  /20191202 CASE 379680 New publisher OnAfterFindSalesperson
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/TSA /20200505 CASE 402244 Make sure we have a active transaction when balance is performed to be able to get dimensions correct.
    // NPR5.55/TSA /20200527 CASE 406862 Added selection of initial view
    // NPR5.55/ALPO/20200528 CASE 401222 Ensure cash register is not opened multiple times


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

                    //-NPR5.39 [305106]
                    if (DelChr(Password, '<=>', ' ') = '') then
                        Error('Illegal password.');
                    //+NPR5.39 [305106]

                    SalespersonPurchaser.SetRange("NPR Register Password", Password);

                    if ((SalespersonPurchaser.FindFirst() and (Password <> ''))) then begin
                        //-NPR5.53 [379680]
                        OnAfterFindSalesperson(SalespersonPurchaser);
                        //+NPR5.53 [379680]
                        Setup.SetSalesperson(SalespersonPurchaser);

                        //-NPR5.46 [328338] - refactored
                        if (NPRetailSetup.Get()) then;
                        if (not NPRetailSetup."Advanced Posting Activated") then
                            OpenRegisterLegacy(FrontEnd, Setup, POSSession);

                        if (NPRetailSetup."Advanced Posting Activated") then
                            OpenPosUnit(FrontEnd, Setup, POSSession);
                        //+NPR5.46 [328338]

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

        //-NPR5.46 [328338]
        // This should be inside the START_POS workflow
        // But to save a roundtrip and becase nested workflows are not perfect yet, I have kept this part here

        Setup.GetPOSUnit(POSUnit);
        Setup.GetRegisterRecord(Register);

        POSUnit.Get(POSUnit."No.");
        Register.Get(Register."Register No.");

        BalanceAge := DaysSinceLastBalance(POSUnit."No.");

        //-NPR5.49 [348458]
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
        //+NPR5.49 [348458]

        case POSUnit.Status of

            POSUnit.Status::OPEN:
                begin

                    //-NPR5.49 [348458]
                    // This state might happen first time when attaching a POS as a slave with status open when master is state close.
                    if ((IsManagedPOS) and (ManagedByPOSUnit.Status <> ManagedByPOSUnit.Status::OPEN)) then begin
                        Message(ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);
                        StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS); // will fix status on the managed POS
                        exit;
                    end;
                    //+NPR5.49 [348458]

                    if (BalanceAge = -1) then begin// Has never been balanced
                        StartWorkflow(FrontEnd, POSSession, 'START_POS');
                        exit;
                    end;

                    if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing

                        if (not Confirm(t004, true, (Today - BalanceAge))) then
                            Error(InvalidStatus);

                        //-NPR5.49 [348458]
                        //StartWorkflow (FrontEnd, POSSession, 'BALANCE_V3');
                        // Z-Report or Close Worksift
                        StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                        //+NPR5.49 [348458]

                        exit;
                    end;

                    //-NPR5.51 [359508]
                    POSPeriodRegister.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
                    MissingPeriodRegister := not POSPeriodRegister.FindLast();
                    if (MissingPeriodRegister) or ((not MissingPeriodRegister) and (POSPeriodRegister.Status <> POSPeriodRegister.Status::OPEN)) then begin
                        StartWorkflow(FrontEnd, POSSession, 'START_POS');
                        exit;
                    end;
                    //+NPR5.51 [359508]

                    StartPOS(POSSession);
                end;

            POSUnit.Status::CLOSED:
                begin
                    if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing

                        //-NPR5.49 [348458]
                        if (IsManagedPOS) then
                            Error(ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);
                        //+NPR5.49 [348458]

                        if (not Confirm(t004, true, Format(Today - BalanceAge))) then
                            Error(InvalidStatus);

                        //-NPR5.49 [348458]
                        //StartWorkflow (FrontEnd, POSSession, 'BALANCE_V3');
                        StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                        //+NPR5.49 [348458]
                        exit;
                    end;

                    StartWorkflow(FrontEnd, POSSession, 'START_POS');
                end;

            POSUnit.Status::EOD:
                begin

                    if (not Confirm(ContinueEoD, true, POSUnit.TableCaption(), POSUnit."No.")) then
                        Error(IsEoD, POSUnit.TableCaption(), POSUnit.FieldCaption(Status));

                    //-NPR5.49 [348458]
                    //StartWorkflow (FrontEnd, POSSession, 'BALANCE_V3');
                    StartEODWorkflow(FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                    //+NPR5.49 [348458]

                end;
        end;

        //+NPR5.46 [328338]
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
        //-NPR5.54 [364658]
        ResumeExistingSale := POSResumeSale.SelectUnfinishedSaleToResume(SalePOS, POSSession, ResumeFromPOSQuoteNo);
        //+NPR5.54 [364658]

        //-NPR5.51 [356076]
        POSSession.GetSetup(POSSetup);
        POSCreateEntry.InsertUnitLoginEntry(POSSetup.Register, POSSetup.Salesperson);
        //+NPR5.51 [356076]

        //-NPR5.54 [364658]
        if ResumeExistingSale and (ResumeFromPOSQuoteNo = 0) then
            POSSession.ResumeTransaction(SalePOS)
        else
            //+NPR5.54 [364658]
            POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
        //-NPR5.54 [364658]
        if ResumeFromPOSQuoteNo <> 0 then
            if POSSale.ResumeFromPOSQuote(ResumeFromPOSQuoteNo) then
                POSSession.RequestRefreshData();
        //+NPR5.54 [364658]
        POSSale.GetCurrentSale(SalePOS);

        //-NPR5.55 [406862]
        // POSSession.ChangeViewSale();
        POSSetup.GetPOSViewProfile(POSViewProfile);
        case POSViewProfile."Initial Sales View" of
            POSViewProfile."Initial Sales View"::SALES_VIEW:
                POSSession.ChangeViewSale();
            POSViewProfile."Initial Sales View"::RESTAURANT_VIEW:
                POSSession.ChangeViewRestaurant();
        end;
        //+NPR5.55 [406862]
    end;

    local procedure StartWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; ActionName: Code[20])
    var
        POSAction: Record "NPR POS Action";
    begin

        if (not POSSession.RetrieveSessionAction(ActionName, POSAction)) then
            POSAction.Get(ActionName);

        //-NPR5.49 [348458]
        // CASE ActionName OF
        //  'BALANCE_V3' : POSAction.SetWorkflowInvocationParameter ('Type', 1, FrontEnd);  // Z-Report, final count
        // END;
        //+NPR5.49 [348458]

        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure StartEODWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; ActionName: Code[20]; ManagedEOD: Boolean)
    var
        POSAction: Record "NPR POS Action";
    begin

        //-NPR5.49 [348458]
        if (not POSSession.RetrieveSessionAction(ActionName, POSAction)) then
            POSAction.Get(ActionName);

        //-NPR5.55 [402244]
        POSSession.StartTransaction();
        //+NPR5.55 [402244]

        case ActionName of
            'BALANCE_V3':
                begin
                    if (not ManagedEOD) then POSAction.SetWorkflowInvocationParameter('Type', 1, FrontEnd);  // Z-Report, final count
                    if (ManagedEOD) then POSAction.SetWorkflowInvocationParameter('Type', 2, FrontEnd);  // Close Workshift - for managed POS
                end;
        end;

        FrontEnd.InvokeWorkflow(POSAction);
        //+NPR5.49 [348458]
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

    local procedure "--Legacy"()
    begin
    end;

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
                    //RegisterOpen (SalePOS);  //NPR5.55 [401222]-revoked
                    if RegisterOpen(SalePOS) then begin  //NPR5.55 [401222]
                                                         // RegisterOpen consumes the current sales ticket when opening the register on first open after balancing
                        POSSession.StartTransaction();
                        POSSale.GetCurrentSale(SalePOS);
                    end;  //NPR5.55 [401222]
                    POSSession.ChangeViewSale();
                end;

            CashRegisterOpenStatus::BalanceRegister:
                begin
                    // POSSession.ChangeViewBalancing ();
                    POSSession.StartTransaction();
                    //-NPR5.40 [306347]
                    //POSAction.GET ('BALANCE_V1');
                    if not POSSession.RetrieveSessionAction('BALANCE_V1', POSAction) then
                        POSAction.Get('BALANCE_V1');
                    //+NPR5.40 [306347]
                    FrontEnd.InvokeWorkflow(POSAction);
                end;

            CashRegisterOpenStatus::DoOpenRegister:
                begin
                    POSSession.StartTransaction();
                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    //-NPR5.38 [297087]
                    //POSCreateEntry.InsertUnitLoginEntry (SalePOS."Register No.", SalespersonPurchaser.Code);
                    //-NPR5.46 [328338]
                    POSCreateEntry.InsertUnitLoginEntry(SalePOS."Register No.", SalePOS."Salesperson Code");
                    //+NPR5.46 [328338]

                    //+NPR5.38 [297087]

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

        //-NPR5.32.11 [279495]
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

                                //MESSAGE (MustBalanceRegister, CashRegister."Opened Date");
                                //EXIT (CashRegisterOpenStatus::BalanceRegister);

                            end;

                        CashRegister."Balancing every"::Manual:
                            exit(CashRegisterOpenStatus::DoOpenRegister);

                        else
                            exit(CashRegisterOpenStatus::DoNotOpenRegister);
                    end;
                end;
        end;

        exit(CashRegisterOpenStatus::DoOpenRegister);

        //+NPR5.32.11 [279495]
    end;

    local procedure RegisterOpen(SalePOS: Record "NPR Sale POS"): Boolean
    var
        CashRegister: Record "NPR Register";
        RetailSalesCode: Codeunit "NPR Retail Sales Code";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
    begin

        //-NPR5.32.11 [279495]
        if (not RetailSalesCode.CheckPostingDateAllowed(WorkDate)) then
            RetailSalesCode.EditPostingDateAllowed(UserId, WorkDate);

        //-NPR5.38 [297087]
        // NOTE: When legacy function RegisterOpen is removed, OnOpenRegister_LegacySubscriber must also be removed and InsertUnitOpenEntry invoked directly
        // POSCreateEntry.InsertUnitOpenEntry (Register."Register No.", SalePOS."Salesperson Code");
        //+NPR5.38 [297087]

        //-NPR5.55 [401222]
        CashRegister.LockTable;
        CashRegister.Get(SalePOS."Register No.");
        if CashRegister.Status <> CashRegister.Status::Afsluttet then
            exit(false);
        //+NPR5.55 [401222]

        TouchScreenFunctions.RegisterOpen(SalePOS);

        //-NPR5.55 [401222]-revoked
        //CashRegister.GET (SalePOS."Register No.");
        //CashRegister.Status := CashRegister.Status::Ekspedition;
        //CashRegister.MODIFY;
        //+NPR5.55 [401222]-revoked
        //+NPR5.32.11 [279495]

        exit(true);  //NPR5.55 [401222]
    end;

    local procedure "--"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014505, 'OnBeforeRegisterOpen', '', true, true)]
    local procedure OnRegisterOpen_LegacySubscriber(Register: Record "NPR Register")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin

        //-NPR5.38 [297087]
        POSCreateEntry.InsertUnitOpenEntry(Register."Register No.", '');
        //+NPR5.38 [297087]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
    end;
}

