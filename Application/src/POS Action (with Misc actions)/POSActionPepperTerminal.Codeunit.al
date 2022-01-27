codeunit 6150779 "NPR POS Action: PepperTerminal"
{
    Access = Internal;
    var
        ActionDescription: Label 'This command sends different commands to the Pin Pad. Specify command using the Parameters.';
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        CommandType: Option OPEN,ENDOFDAY,AUX,INSTALL,OTHER;
        Unsupported: Label 'The command %1 is not supported.';
        HaveSalesLines: Label 'You can not have sales lines when closing the Payment Terminal. First cancel the sale!';
        NextWorkflowStep: Option Resume,WaitForDevice,Pause,CheckResult,Done;
        EftCheckResultMessage: Label 'The action %1 failed with the following message:\\%2 - %3.';
        EftRequestNotFound: Label 'Action Code %1 tried retrieving "TransactionRequest_EntryNo" from POS Session and got %2. There is however no record in %3 to match that entry number.';
        EftRequestMissMatch: Label 'Action Code %1 has detected a EFT request identity missmatch:\\For Entry No. %2 the expected token is %3, but the record contains %4.';
        InstallOK: Label 'Installation was successful. Restart to activate new version.';
        OpenOK: Label 'The terminal is now open.';
        CLoseOK: Label 'The terminal is now closed.';
        OtherCommandStringMenu: Label 'Activate Offline Mode,Deactivate Offline Mode';
        ReadingErr: Label 'reading in %1';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            Sender.RegisterWorkflowStep('EFT_dowork', 'respond();');
            Sender.RegisterWorkflowStep('EFT_wait', 'respond();');
            Sender.RegisterWorkflowStep('EFT_checkresult', 'respond();');
            Sender.RegisterWorkflowStep('done', '');

            Sender.RegisterWorkflow(false);
            Sender.RegisterOptionParameter('commandId', 'Open,EndOfDay,Aux,Install,Other', 'Open');
            Sender.RegisterOptionParameter('otherCommand', 'StrMenu,Activate Offline Mode,Deactivate Offline Mode', 'Activate Offline Mode');
            Sender.RegisterOptionParameter('auxCommand', 'StrMenu,Abort,PAN Suppression ON,PAN Suppression OFF,Custom Menu,Ticket Reprint,Summary Report,' +
                                                    'Diagnostics,System Info,Display with Num Input,TINA Activation,TINA Query,Show Custom Menu', 'Ticket Reprint');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AuxCommand: Integer;
        OtherCommand: Integer;
        ContextId: Guid;
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        POSSession.GetSetup(Setup);
        POSUnit.Get(Setup.GetPOSUnitNo());

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        CommandType := JSON.GetIntegerOrFail('commandId', StrSubstNo(ReadingErr, ActionCode()));
        if (CommandType = -1) then
            CommandType := CommandType::OPEN;

        AuxCommand := JSON.GetInteger('auxCommand');
        if (AuxCommand = -1) then
            AuxCommand := 0; // StrMenu

        OtherCommand := JSON.GetInteger('otherCommand');
        if (OtherCommand = -1) then
            OtherCommand := 0; // StrMenu



        case WorkflowStep of
            'EFT_dowork':
                begin
                    POSSession.ClearActionState();
                    ContextId := POSSession.BeginAction(ActionCode());
                    POSSession.StoreActionState('ContextId', ContextId);

                    DoWork(POSSession, CommandType, AuxCommand, OtherCommand, SalePOS, POSUnit);

                end;

            'EFT_wait':
                begin
                    NextWorkflowStep := NextWorkflowStep::Pause;
                end;

            'EFT_checkresult':
                begin
                    GetTransactionRequest(POSSession, EFTTransactionRequest);
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
                ;
        end;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit('PEPPER_TERMINAL');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    local procedure DoWork(POSSession: Codeunit "NPR POS Session"; EftCommand: Option; AuxCommand: Integer; OtherCommand: Integer; SalePOS: Record "NPR POS Sale"; POSUnit: Record "NPR POS Unit")
    var
        SaleLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PepperLibraryTranscendence: Codeunit "NPR Pepper Library TSD";
        EFTSetup: Record "NPR EFT Setup";
    begin

        case EftCommand of
            CommandType::OPEN:
                begin
                    GetEFTSetup(POSUnit, EFTSetup);
                    EFTIntegration.CreateBeginWorkshiftRequest(EFTTransactionRequest, EFTSetup, POSUnit."No.", SalePOS."Sales Ticket No.");
                end;
            CommandType::ENDOFDAY:
                begin
                    SaleLine.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
                    if (not SaleLine.IsEmpty()) then
                        Error(HaveSalesLines);

                    GetEFTSetup(POSUnit, EFTSetup);
                    EFTIntegration.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, POSUnit."No.", SalePOS."Sales Ticket No.");
                end;

            CommandType::AUX:
                begin
                    GetEFTSetup(POSUnit, EFTSetup);
                    EFTIntegration.CreateAuxRequest(EFTTransactionRequest, EFTSetup, AuxCommand, POSUnit."No.", SalePOS."Sales Ticket No.");
                end;

            CommandType::INSTALL:
                begin
                    GetEFTSetup(POSUnit, EFTSetup);
                    EFTIntegration.CreateVerifySetupRequest(EFTTransactionRequest, EFTSetup, POSUnit."No.", SalePOS."Sales Ticket No.");
                end;
            CommandType::OTHER:
                begin
                    //SetOffline
                    if OtherCommand = 0 then
                        OtherCommand := StrMenu(OtherCommandStringMenu, 0);
                    case OtherCommand of
                        1:
                            PepperLibraryTranscendence.SetTerminalToOfflineMode(POSUnit, 0); //Activate
                        2:
                            PepperLibraryTranscendence.SetTerminalToOfflineMode(POSUnit, 1); //Deactivate
                    end;
                    NextWorkflowStep := NextWorkflowStep::Done;
                    exit;
                end;

            else
                Error(Unsupported, EftCommand);
        end;

        NextWorkflowStep := NextWorkflowStep::WaitForDevice;
        EFTIntegration.SendRequest(EFTTransactionRequest);

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
            Error(EftRequestNotFound, ActionCode(), TmpVariant, EFTTransactionRequest.TableCaption);

        if (EFTTransactionRequest.Token <> Token) then
            Error(EftRequestMissMatch, ActionCode(), EntryNo, Token, EFTTransactionRequest.Token);

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

    local procedure GetEFTSetup(POSUnit: Record "NPR POS UNit"; var EFTSetup: Record "NPR EFT Setup")
    var
        PepperLibraryTranscendence: Codeunit "NPR Pepper Library TSD";
    begin
        EFTSetup.SetRange("POS Unit No.", POSUnit."No.");
        EFTSetup.SetRange("EFT Integration Type", PepperLibraryTranscendence.GetIntegrationType());
        if EFTSetup.FindFirst() then
            exit;
        EFTSetup.SetRange("POS Unit No.", '');
        EFTSetup.FindFirst();
    end;
}

