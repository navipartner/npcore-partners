codeunit 6150721 "NPR POS Action - Login"
{
    var
        ActionDescription: Label 'This is a built-in action for completing the login request passed on from the front end.';
        Text001: Label 'Unknown login type requested by JavaScript: %1.';
        InvalidStatus: Label 'The register status states that the register cannot be opened at this time.';
        BalancingRequired: Label 'The register has not been balanced since %1 and must be balanced before selling. Do you want to balance the register now?';
        IsEoD: Label 'The %1 %2 indicates that this %1 is being balanced and it can''t be opened at this time.';
        ContinueEoD: Label 'The %1 %2 is marked as being in balancing. Do you want to continue with balancing now?';
        ManagedPos: Label 'This POS is managed by POS Unit %1 [%2] and it is therefore required that %1 is opened prior to opening this POS.';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('LOGIN');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::BackEnd,
          Sender."Subscriber Instances Allowed"::Single);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Setup: Codeunit "NPR POS Setup";
        Type: Text;
        Password: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        Type := JSON.GetStringOrFail('type', StrSubstNo(ReadingErr, ActionCode()));
        POSSession.GetSetup(Setup);
        Setup.Initialize();

        Clear(SalespersonPurchaser);
        case Type of
            'SalespersonCode':
                begin
                    Password := JSON.GetStringOrFail('password', StrSubstNo(ReadingErr, ActionCode()));
                    if (DelChr(Password, '<=>', ' ') = '') then
                        Error('Illegal password.');

                    SalespersonPurchaser.SetRange("NPR Register Password", Password);

                    if ((SalespersonPurchaser.FindFirst() and (Password <> ''))) then begin
                        OnAfterFindSalesperson(SalespersonPurchaser);
                        Setup.SetSalesperson(SalespersonPurchaser);

                        OpenPosUnit(FrontEnd, Setup, POSSession);
                    end else begin
                        Error('Illegal password.');
                    end;

                end;
            else
                FrontEnd.ReportBugAndThrowError(StrSubstNo(Text001, Type));
        end;
    end;

    local procedure OpenPosUnit(FrontEnd: Codeunit "NPR POS Front End Management"; Setup: Codeunit "NPR POS Setup"; POSSession: Codeunit "NPR POS Session")
    var
        POSUnit: Record "NPR POS Unit";
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
        POSUnit.Get(POSUnit."No.");

        BalanceAge := DaysSinceLastBalance(POSUnit."No.");

        POSEndofDayProfile.Init();
        if (POSUnit."POS End of Day Profile" <> '') then begin
            POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");
            if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
                IsManagedPOS := (POSEndofDayProfile."Master POS Unit No." <> POSUnit."No.");
            if (IsManagedPOS) then begin
                ManagedByPOSUnit.Get(POSEndofDayProfile."Master POS Unit No.");
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

                    if ((POSEndofDayProfile."End of Day Frequency" = POSEndofDayProfile."End of Day Frequency"::DAILY) and (BalanceAge > 0)) then begin
                        if (not Confirm(BalancingRequired, true, (Today - BalanceAge))) then
                            Error(InvalidStatus);

                        // Force a Z-Report or Close WorkShift
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
                    if ((POSEndofDayProfile."End of Day Frequency" = POSEndofDayProfile."End of Day Frequency"::DAILY) and (BalanceAge > 0)) then begin
                        if (IsManagedPOS) then
                            Error(ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);

                        if (not Confirm(BalancingRequired, true, Format(Today - BalanceAge))) then
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

    procedure StartPOS(POSSession: Codeunit "NPR POS Session"): Integer
    var
        SalePOS: Record "NPR POS Sale";
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
        POSCreateEntry.InsertUnitLoginEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

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
                    if (ManagedEOD) then POSAction.SetWorkflowInvocationParameter('Type', 2, FrontEnd);  // Close WorkShift - for managed POS
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

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
    end;
}
