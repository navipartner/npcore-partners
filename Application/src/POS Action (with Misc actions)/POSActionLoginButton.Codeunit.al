codeunit 6150860 "NPR POS Action: LoginButton"
{
    // NPR5.32.11/TSA/20170620  CASE 279495 Invoke workflow BALANCE_V1 when register balancing is required before login
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant
    // NPR5.38/TSA /20171123 CASE 297087 InsertPOSUnitOpen entry
    // NPR5.39/TSA /20180214 CASE 305106 Disallow blank password, update current sale with new sales person
    // NPR5.40/VB  /20180307 CASE 306347 Refactored retrieval of POS Action
    // NPR5.48/TSA /20180913 CASE 328338 Handling POS Unit status when balancing V3 is used


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

    local procedure ActionCode(): Text
    begin
        exit('LOGIN-BUTTON');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        with Sender do begin
            if (DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple))
            then begin
                RegisterTextParameter('SalespersonCode', 'KIOSK-01');
                RegisterWorkflow(false);
            end;

        end;
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
        SalespersonCode: Text;
        Type: Text;
        Password: Text;
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        //IF (USERID = 'TSA') THEN MESSAGE ('%1', JSON.ToString ());

        Type := JSON.GetString('type', false);

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


        if (Type = '') then
            Type := 'Kiosk';

        case Type of
            'SalespersonCode':
                begin

                    Password := JSON.GetString('password', true);
                    if (DelChr(Password, '<=>', ' ') = '') then
                        Error('Illegal password.');

                    SalespersonPurchaser.SetRange("NPR Register Password", Password);

                    if ((SalespersonPurchaser.FindFirst() and (Password <> ''))) then begin
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

            'Kiosk':
                begin
                    SalespersonCode := JSON.GetStringParameter('SalespersonCode', true);
                    if (SalespersonCode = '') then
                        SalespersonCode := 'KIOSK-01';

                    SalespersonPurchaser.Get(SalespersonCode);
                    Setup.SetSalesperson(SalespersonPurchaser);

                    if (NPRetailSetup.Get()) then;
                    if (not NPRetailSetup."Advanced Posting Activated") then
                        OpenRegisterLegacy(FrontEnd, Setup, POSSession);

                    if (NPRetailSetup."Advanced Posting Activated") then
                        OpenPosUnit(FrontEnd, Setup, POSSession);
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
    begin

        //-NPR5.46 [328338]
        // This should be inside the START_POS workflow
        // But to save a roundtrip and becase nested workflows are not perfect yet, I have kept this part here

        Setup.GetPOSUnit(POSUnit);
        Setup.GetRegisterRecord(Register);

        POSUnit.Get(POSUnit."No.");
        Register.Get(Register."Register No.");

        BalanceAge := DaysSinceLastBalance(POSUnit."No.");

        case POSUnit.Status of

            POSUnit.Status::OPEN:
                begin
                    if (BalanceAge = -1) then begin// Has never been balanced
                        StartWorkflow(FrontEnd, POSSession, 'START_POS');
                        exit;
                    end;

                    if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing
                        if (not Confirm(t004, true, (Today - BalanceAge))) then
                            Error(InvalidStatus);

                        StartWorkflow(FrontEnd, POSSession, 'BALANCE_V3');
                        exit;
                    end;

                    StartPOS(POSSession);
                end;

            POSUnit.Status::CLOSED:
                begin
                    if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing
                        if (not Confirm(t004, true, Format(Today - BalanceAge))) then
                            Error(InvalidStatus);

                        StartWorkflow(FrontEnd, POSSession, 'BALANCE_V3');
                        exit;
                    end;

                    StartWorkflow(FrontEnd, POSSession, 'START_POS');
                end;

            POSUnit.Status::EOD:
                begin
                    if (not Confirm(ContinueEoD, true, POSUnit.TableCaption(), POSUnit."No.")) then
                        Error(IsEoD, POSUnit.TableCaption(), POSUnit.FieldCaption(Status));

                    StartWorkflow(FrontEnd, POSSession, 'BALANCE_V3');
                end;
        end;

        //+NPR5.46 [328338]
    end;

    local procedure StartPOS(POSSession: Codeunit "NPR POS Session"): Integer
    var
        SalePOS: Record "NPR Sale POS";
        POSAction: Record "NPR POS Action";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin

        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.ChangeViewSale();
    end;

    local procedure StartWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; ActionName: Code[20])
    var
        POSAction: Record "NPR POS Action";
    begin

        if (not POSSession.RetrieveSessionAction(ActionName, POSAction)) then
            POSAction.Get(ActionName);

        case ActionName of
            'BALANCE_V3':
                POSAction.SetWorkflowInvocationParameter('Type', 1, FrontEnd);  // Z-Report, final count
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
                    RegisterOpen(SalePOS);

                    // RegisterOpen consumes the current sales ticket when opening the register on first open after balancing
                    POSSession.StartTransaction();

                    POSSale.GetCurrentSale(SalePOS);
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

    local procedure RegisterOpen(SalePOS: Record "NPR Sale POS")
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

        TouchScreenFunctions.RegisterOpen(SalePOS);

        CashRegister.Get(SalePOS."Register No.");
        CashRegister.Status := CashRegister.Status::Ekspedition;
        CashRegister.Modify;
        //+NPR5.32.11 [279495]
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
}

