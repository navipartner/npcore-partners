codeunit 6150860 "NPR POS Action: LoginButton"
{
    var
        ActionDescription: Label 'This is a built-in action for completing the login request passed on from the front end.';
        Text001: Label 'Unknown login type requested by JavaScript: %1.';
        InvalidStatus: Label 'The register status states that the register cannot be opened at this time.';
        t004: Label 'The register has not been balanced since %1 and must be balanced before selling. Do you want to balance the register now?';
        IsEoD: Label 'The %1 %2 indicates that this %1 is being balanced and it can''t be opened at this time.';
        ContinueEoD: Label 'The %1 %2 is marked as being in balancing. Do you want to continue with balancing now?';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('LOGIN-BUTTON');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin

        if (Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple))
        then begin
            Sender.RegisterTextParameter('SalespersonCode', 'KIOSK-01');
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Setup: Codeunit "NPR POS Setup";
        SalespersonCode: Text;
        Type: Text;
        Password: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        Type := JSON.GetString('type');

        POSSession.GetSetup(Setup);
        Setup.Initialize();

        Clear(SalespersonPurchaser);


        if (Type = '') then
            Type := 'Kiosk';

        case Type of
            'SalespersonCode':
                begin

                    Password := JSON.GetStringOrFail('password', StrSubstNo(ReadingErr, ActionCode()));
                    if (DelChr(Password, '<=>', ' ') = '') then
                        Error('Illegal password.');

                    SalespersonPurchaser.SetRange("NPR Register Password", Password);

                    if ((SalespersonPurchaser.FindFirst() and (Password <> ''))) then begin
                        Setup.SetSalesperson(SalespersonPurchaser);
                        OpenPosUnit(FrontEnd, Setup, POSSession);

                    end else begin
                        Error('Illegal password.');
                    end;

                end;

            'Kiosk':
                begin
                    SalespersonCode := JSON.GetStringParameterOrFail('SalespersonCode', ActionCode());
                    if (SalespersonCode = '') then
                        SalespersonCode := 'KIOSK-01';

                    SalespersonPurchaser.Get(SalespersonCode);
                    Setup.SetSalesperson(SalespersonPurchaser);

                    OpenPosUnit(FrontEnd, Setup, POSSession);
                end;
            else
                FrontEnd.ReportBugAndThrowError(StrSubstNo(Text001, Type));
        end;
    end;

    local procedure OpenPosUnit(FrontEnd: Codeunit "NPR POS Front End Management"; Setup: Codeunit "NPR POS Setup"; POSSession: Codeunit "NPR POS Session")
    var
        POSUnit: Record "NPR POS Unit";
        BalanceAge: Integer;
    begin
        // This should be inside the START_POS workflow
        // But to save a roundtrip and because nested workflows are not perfect yet, I have kept this part here

        Setup.GetPOSUnit(POSUnit);
        POSUnit.Get(POSUnit."No.");

        BalanceAge := DaysSinceLastBalance(POSUnit."No.");

        case POSUnit.Status of

            POSUnit.Status::OPEN:
                begin
                    if (BalanceAge = -1) then begin // Has never been balanced
                        StartWorkflow(FrontEnd, POSSession, 'START_POS');
                        exit;
                    end;

                    if BalanceAge > 0 then begin // Forced balancing
                        if (not Confirm(t004, true, (Today - BalanceAge))) then
                            Error(InvalidStatus);

                        StartWorkflow(FrontEnd, POSSession, 'BALANCE_V3');
                        exit;
                    end;

                    StartPOS(POSSession);
                end;

            POSUnit.Status::CLOSED:
                begin
                    if BalanceAge > 0 then begin // Forced balancing
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

    end;

    local procedure StartPOS(POSSession: Codeunit "NPR POS Session"): Integer
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
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
}
