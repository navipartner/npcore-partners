codeunit 6150779 "NPR POS Action: PepperTerminal"
{
    // NPR5.36/TSA/20170724  CASE Signature change on PrintReceipt
    // NPR5.46/MMV /20180924 CASE 290734 EFT framework refactored


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This command sends different commands to the Pin Pad. Specify command using the Parameters.';
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        CommandType: Option OPEN,ENDOFDAY,AUX,INSTALL,OTHER;
        Unsupported: Label 'The command %1 is not supported.';
        HaveSalesLines: Label 'You can not have sales lines when closing the Payment Terminal. First cancel the sale!';
        NextWorkflowStep: Option Resume,WaitForDevice,Pause,CheckResult,Done;
        EftCheckResultMessage: Label 'The action %1 failed with the following message:\\%2 - %3.';
        EftNoRequestHandler: Label 'No event subscriber acknowledged the request for EFT Command %1 for register %2.';
        EftNoDeviceHandler: Label 'No event subscriber acknowledged a device for handing request %1 for register %2.';
        EftRequestNotFound: Label 'Action Code %1 tried retrieving "TransactionRequest_EntryNo" from POS Session and got %2. There is however no record in %3 to match that entry number.';
        EftRequestMissMatch: Label 'Action Code %1 has detected a EFT request identity missmatch:\\For Entry No. %2 the expected token is %3, but the record contains %4.';
        InstallOK: Label 'Installation was successful. Restart to activate new version.';
        OpenOK: Label 'The terminal is now open.';
        CLoseOK: Label 'The terminal is now closed.';
        OtherCommandStringMenu: Label 'Activate Offline Mode,Deactivate Offline Mode';

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

                RegisterWorkflowStep('EFT_dowork', 'respond();');
                RegisterWorkflowStep('EFT_wait', 'respond();');
                RegisterWorkflowStep('EFT_checkresult', 'respond();');
                RegisterWorkflowStep('done', '');

                RegisterWorkflow(false);
                RegisterOptionParameter('commandId', 'Open,EndOfDay,Aux,Install,Other', 'Open');
                RegisterOptionParameter('otherCommand', 'StrMenu,Activate Offline Mode,Deactivate Offline Mode', 'Activate Offline Mode');
                RegisterOptionParameter('auxCommand', 'StrMenu,Abort,PAN Suppression ON,PAN Suppression OFF,Custom Menu,Ticket Reprint,Summary Report,' +
                                                      'Diagnostics,System Info,Display with Num Input,TINA Activation,TINA Query,Show Custom Menu', 'Ticket Reprint');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        Setup: Codeunit "NPR POS Setup";
        Register: Record "NPR Register";
        SalePOS: Record "NPR Sale POS";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AuxCommand: Integer;
        OtherCommand: Integer;
        ContextId: Guid;
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        POSSession.GetSetup(Setup);
        Register.Get(Setup.Register());
        //-NPR5.46 [290734]
        //Register.TESTFIELD ("Credit Card Solution", Register."Credit Card Solution"::Pepper);
        //+NPR5.46 [290734]

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        CommandType := JSON.GetInteger('commandId', true);
        if (CommandType = -1) then
            CommandType := CommandType::OPEN;

        AuxCommand := JSON.GetInteger('auxCommand', false);
        if (AuxCommand = -1) then
            AuxCommand := 0; // StrMenu

        OtherCommand := JSON.GetInteger('otherCommand', false);
        if (OtherCommand = -1) then
            OtherCommand := 0; // StrMenu



        case WorkflowStep of
            'EFT_dowork':
                begin
                    POSSession.ClearActionState();
                    ContextId := POSSession.BeginAction(ActionCode);
                    POSSession.StoreActionState('ContextId', ContextId);

                    DoWork(POSSession, CommandType, AuxCommand, OtherCommand, SalePOS, Register);

                end;

            'EFT_wait':
                begin
                    NextWorkflowStep := NextWorkflowStep::Pause;
                end;

            'EFT_checkresult':
                begin
                    GetTransactionRequest(POSSession, EFTTransactionRequest);
                    //-NPR5.46 [290734]
                    //      EFTTransactionRequest.PrintReceipts (TRUE);
                    //+NPR5.46 [290734]
                    if (not EFTTransactionRequest.Successful) then
                        Message(EftCheckResultMessage, CommandType, EFTTransactionRequest."Result Code", EFTTransactionRequest."Result Description");

                    if (EFTTransactionRequest.Successful) then
                        case CommandType of
                            CommandType::INSTALL:
                                Message(InstallOK);
                            CommandType::OPEN:
                                Message(OpenOK);
                            CommandType::ENDOFDAY:
                                Message(CLoseOK);
                        end
                end;
        end;

        Handled := true;
        //MESSAGE ('%1: current step %2 (next step %3)', CURRENTDATETIME, WorkflowStep, NextWorkflowStep);

        case NextWorkflowStep of
            NextWorkflowStep::Pause:
                FrontEnd.PauseWorkflow();
            NextWorkflowStep::WaitForDevice:
                FrontEnd.ContinueAtStep('EFT_wait');
            NextWorkflowStep::CheckResult:
                FrontEnd.ContinueAtStep('EFT_checkresult');
            NextWorkflowStep::Done:
                FrontEnd.ContinueAtStep('done');
            else
                ; //FrontEnd.ResumeWorkflow ();
        end;
    end;

    local procedure ActionCode(): Text
    begin
        exit('PEPPER_TERMINAL');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    local procedure DoWork(POSSession: Codeunit "NPR POS Session"; EftCommand: Option; AuxCommand: Integer; OtherCommand: Integer; SalePOS: Record "NPR Sale POS"; Register: Record "NPR Register")
    var
        SaleLine: Record "NPR Sale Line POS";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Handled: Boolean;
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        PepperLibraryTranscendence: Codeunit "NPR Pepper Library TSD";
        EFTSetup: Record "NPR EFT Setup";
    begin

        case EftCommand of
            CommandType::OPEN:
                begin
                    //-NPR5.46 [290734]
                    //      EFTIntegration.OnCreateBeginWorkshiftRequest (EFTTransactionRequest, Handled, Register);
                    //      IF (NOT Handled) THEN
                    //        ERROR (EftNoRequestHandler, CommandType, Register."Register No.");
                    GetEFTSetup(Register, EFTSetup);
                    EFTIntegration.CreateBeginWorkshiftRequest(EFTTransactionRequest, EFTSetup, Register."Register No.", SalePOS."Sales Ticket No.");
                    //+NPR5.46 [290734]
                end;

            CommandType::ENDOFDAY:
                begin
                    SaleLine.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
                    if (not SaleLine.IsEmpty()) then
                        Error(HaveSalesLines);

                    //-NPR5.46 [290734]
                    //      EFTIntegration.OnCreateEndWorkshiftRequest (EFTTransactionRequest, Handled, Register, SalePOS."Sales Ticket No.");
                    //      IF (NOT Handled) THEN
                    //        ERROR (EftNoRequestHandler, CommandType, Register."Register No.");
                    GetEFTSetup(Register, EFTSetup);
                    EFTIntegration.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, Register."Register No.", SalePOS."Sales Ticket No.");
                    //+NPR5.46 [290734]
                end;

            CommandType::AUX:
                begin
                    //-NPR5.46 [290734]
                    //      EFTIntegration.OnCreateAuxRequest (EFTTransactionRequest, Handled, Register, AuxCommand);
                    //      IF (NOT Handled) THEN
                    //        ERROR (EftNoRequestHandler, CommandType, Register."Register No.");
                    GetEFTSetup(Register, EFTSetup);
                    EFTIntegration.CreateAuxRequest(EFTTransactionRequest, EFTSetup, AuxCommand, Register."Register No.", SalePOS."Sales Ticket No.");
                    //+NPR5.46 [290734]
                end;

            CommandType::INSTALL:
                begin
                    //-NPR5.46 [290734]
                    //      EFTIntegration.OnCreateInstallRequest (EFTTransactionRequest, Handled, Register);
                    //      IF (NOT Handled) THEN
                    //        ERROR (EftNoRequestHandler, CommandType, Register."Register No.");
                    GetEFTSetup(Register, EFTSetup);
                    EFTIntegration.CreateVerifySetupRequest(EFTTransactionRequest, EFTSetup, Register."Register No.", SalePOS."Sales Ticket No.");
                    //+NPR5.46 [290734]
                end;
            CommandType::OTHER:
                begin
                    //SetOffline
                    if OtherCommand = 0 then
                        OtherCommand := StrMenu(OtherCommandStringMenu, 0);
                    case OtherCommand of
                        1:
                            PepperLibraryTranscendence.SetTerminalToOfflineMode(Register, 0); //Activate
                        2:
                            PepperLibraryTranscendence.SetTerminalToOfflineMode(Register, 1); //Deactivate
                    end;
                    NextWorkflowStep := NextWorkflowStep::Done;
                    exit;
                end;

            else
                Error(Unsupported, EftCommand);
        end;

        NextWorkflowStep := NextWorkflowStep::WaitForDevice;
        //-NPR5.46 [290734]
        // EFTIntegration.OnEftDeviceRequestAsync (EFTTransactionRequest, Handled);
        // IF (NOT Handled) THEN
        //  ERROR (EftNoDeviceHandler, EFTTransactionRequest."Entry No.", Register."Register No.");
        EFTIntegration.SendRequest(EFTTransactionRequest);
        //+NPR5.46 [290734]

        if (EFTTransactionRequest.Mode = EFTTransactionRequest.Mode::"TEST Local") then
            NextWorkflowStep := NextWorkflowStep::CheckResult;

        SetTransactionRequest(POSSession, EFTTransactionRequest);
    end;

    local procedure SetTransactionRequest(POSSession: Codeunit "NPR POS Session"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        POSSession.StoreActionState('TransactionRequest_EntryNo', EFTTransactionRequest."Entry No.");
        POSSession.StoreActionState('TransactionRequest_Token', EFTTransactionRequest.Token);
    end;

    local procedure GetTransactionRequest(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EntryNo: Integer;
        Token: Guid;
        TmpVariant: Variant;
        AlternativTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        POSSession.RetrieveActionState('TransactionRequest_EntryNo', TmpVariant);
        EntryNo := TmpVariant;

        POSSession.RetrieveActionState('TransactionRequest_Token', TmpVariant);
        Token := TmpVariant;

        if (not EFTTransactionRequest.Get(EntryNo)) then
            Error(EftRequestNotFound, ActionCode, TmpVariant, EFTTransactionRequest.TableCaption);

        if (EFTTransactionRequest.Token <> Token) then
            Error(EftRequestMissMatch, ActionCode, EntryNo, Token, EFTTransactionRequest.Token);

        // EFT Integration might have worked some magic to get the job done
        if (not EFTTransactionRequest.Successful) then begin
            AlternativTransactionRequest.SetFilter("Initiated from Entry No.", '=%1', EFTTransactionRequest."Entry No.");
            if (not AlternativTransactionRequest.FindLast()) then
                exit;

            if ((AlternativTransactionRequest."Pepper Transaction Type Code" = EFTTransactionRequest."Pepper Transaction Type Code") and
              (AlternativTransactionRequest."Pepper Trans. Subtype Code" = EFTTransactionRequest."Pepper Trans. Subtype Code") and
              (AlternativTransactionRequest."Amount Input" = EFTTransactionRequest."Amount Input")) then begin
                SetTransactionRequest(POSSession, AlternativTransactionRequest);
                EFTTransactionRequest.Get(AlternativTransactionRequest."Entry No.");
            end;

        end;
    end;

    local procedure GetEFTSetup(Register: Record "NPR Register"; var EFTSetup: Record "NPR EFT Setup")
    var
        PepperLibraryTranscendence: Codeunit "NPR Pepper Library TSD";
    begin
        //-NPR5.46 [290734]
        EFTSetup.SetRange("POS Unit No.", Register."Register No.");
        EFTSetup.SetRange("EFT Integration Type", PepperLibraryTranscendence.GetIntegrationType());
        if EFTSetup.FindFirst then
            exit;
        EFTSetup.SetRange("POS Unit No.", '');
        EFTSetup.FindFirst;
        //+NPR5.46 [290734]
    end;
}

