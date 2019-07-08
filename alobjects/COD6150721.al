codeunit 6150721 "POS Action - Login"
{
    // NPR5.32.11/TSA/20170620  CASE 279495 Invoke workflow BALANCE_V1 when register balancing is required before login
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant
    // NPR5.38/TSA /20171123 CASE 297087 InsertPOSUnitOpen entry
    // NPR5.39/TSA /20180214 CASE 305106 Disallow blank password, update current sale with new sales person
    // NPR5.40/VB  /20180307 CASE 306347 Refactored retrieval of POS Action
    // NPR5.46/TSA /20180913 CASE 328338 Handling POS Unit status when balancing V3 is used
    // NPR5.49/TSA /20190314 CASE 348458 Added state check for POS Open when end-of-day is managed by a different POS.


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
        exit ('LOGIN');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::BackEnd,
          Sender."Subscriber Instances Allowed"::Single);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Setup: Codeunit "POS Setup";
        POSUnitIdentity: Codeunit "POS Unit Identity";
        NPRetailSetup: Record "NP Retail Setup";
        POSUnitIdentityRec: Record "POS Unit Identity";
        Register: Record Register;
        UserSetup: Record "User Setup";
        ViewType: DotNet ViewType0;
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

        JSON.InitializeJObjectParser(Context,FrontEnd);
        Type := JSON.GetString('type',true);
        POSSession.GetSetup (Setup);

        // Fallback - when framwork is not providing the device identity
        POSSession.GetSessionId (HardwareId, SessionName, HostName);
        if (HardwareId = '') then begin
          UserSetup.Get (UserId);
          UserSetup.TestField ("Backoffice Register No.");
          POSUnitIdentity.ConfigureTemporaryDevice (UserSetup."Backoffice Register No.", POSUnitIdentityRec);
          Setup.InitializeUsingPosUnitIdentity (POSUnitIdentityRec);
          POSSession.InitializeSessionId (POSUnitIdentityRec."Device ID", SessionName, HostName);
        end;

        Clear(SalespersonPurchaser);
        case Type of
          'SalespersonCode':
            begin
              Password := JSON.GetString('password',true);

              //-NPR5.39 [305106]
              if (DelChr (Password, '<=>', ' ') = '') then
                Error ('Illegal password.');
              //+NPR5.39 [305106]

              SalespersonPurchaser.SetRange ("Register Password", Password);

              if ((SalespersonPurchaser.FindFirst () and (Password <> ''))) then begin
                Setup.SetSalesperson (SalespersonPurchaser);

                //-NPR5.46 [328338] - refactored
                if (NPRetailSetup.Get ()) then ;
                if (not NPRetailSetup."Advanced Posting Activated") then
                  OpenRegisterLegacy (FrontEnd, Setup, POSSession);

                if (NPRetailSetup."Advanced Posting Activated") then
                  OpenPosUnit (FrontEnd, Setup, POSSession);
                //+NPR5.46 [328338]

              end else begin
                  Error ('Illegal password.');
              end;

            end;
          else
            FrontEnd.ReportBug(StrSubstNo(Text001,Type));
        end;
    end;

    local procedure OpenPosUnit(FrontEnd: Codeunit "POS Front End Management";Setup: Codeunit "POS Setup";POSSession: Codeunit "POS Session")
    var
        POSUnit: Record "POS Unit";
        Register: Record Register;
        BalanceAge: Integer;
        IsManagedPOS: Boolean;
        ManagedByPOSUnit: Record "POS Unit";
        POSEndofDayProfile: Record "POS End of Day Profile";
    begin

        //-NPR5.46 [328338]
        // This should be inside the START_POS workflow
        // But to save a roundtrip and becase nested workflows are not perfect yet, I have kept this part here

        Setup.GetPOSUnit(POSUnit);
        Setup.GetRegisterRecord (Register);

        POSUnit.Get (POSUnit."No.");
        Register.Get (Register."Register No.");

        BalanceAge := DaysSinceLastBalance (POSUnit."No.");

        //-NPR5.49 [348458]
        if (POSUnit."POS End of Day Profile" <> '') then begin
          POSEndofDayProfile.Get (POSUnit."POS End of Day Profile");
          if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
            IsManagedPOS := (POSEndofDayProfile."Master POS Unit No." <> POSUnit."No.");
          if (IsManagedPOS) then begin
            ManagedByPOSUnit.Get (POSEndofDayProfile."Master POS Unit No.");
            Register.Get (ManagedByPOSUnit."No.");
            BalanceAge := DaysSinceLastBalance (ManagedByPOSUnit."No.");
          end;
        end;
        //+NPR5.49 [348458]

        case POSUnit.Status of

          POSUnit.Status::OPEN :
            begin

              //-NPR5.49 [348458]
              // This state might happen first time when attaching a POS as a slave with status open when master is state close.
              if ((IsManagedPOS) and (ManagedByPOSUnit.Status <> ManagedByPOSUnit.Status::OPEN)) then begin
                Message (ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);
                StartEODWorkflow (FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS); // will fix status on the managed POS
                exit;
              end;
              //+NPR5.49 [348458]

              if (BalanceAge = -1) then begin// Has never been balanced
                StartWorkflow (FrontEnd, POSSession, 'START_POS');
                exit;
              end;

              if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing

                if (not Confirm (t004, true, (Today - BalanceAge))) then
                  Error (InvalidStatus);

                //-NPR5.49 [348458]
                //StartWorkflow (FrontEnd, POSSession, 'BALANCE_V3');
                // Z-Report or Close Worksift
                StartEODWorkflow (FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                //+NPR5.49 [348458]

                exit;
              end;

              StartPOS (POSSession);
            end;

          POSUnit.Status::CLOSED :
            begin
              if ((Register."Balancing every" = Register."Balancing every"::Day) and (BalanceAge > 0)) then begin // Forced balancing

                //-NPR5.49 [348458]
                if (IsManagedPOS) then
                  Error (ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);
                //+NPR5.49 [348458]

                if (not Confirm (t004, true, Format (Today - BalanceAge))) then
                  Error (InvalidStatus);

                //-NPR5.49 [348458]
                //StartWorkflow (FrontEnd, POSSession, 'BALANCE_V3');
                StartEODWorkflow (FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
                //+NPR5.49 [348458]
                exit;
              end;

              StartWorkflow (FrontEnd, POSSession, 'START_POS');
            end;

          POSUnit.Status::EOD :
            begin

              if (not Confirm (ContinueEoD, true, POSUnit.TableCaption(), POSUnit."No.")) then
                Error (IsEoD, POSUnit.TableCaption(), POSUnit.FieldCaption (Status));

              //-NPR5.49 [348458]
              //StartWorkflow (FrontEnd, POSSession, 'BALANCE_V3');
              StartEODWorkflow (FrontEnd, POSSession, 'BALANCE_V3', IsManagedPOS);
              //+NPR5.49 [348458]

            end;
        end;

        //+NPR5.46 [328338]
    end;

    local procedure StartPOS(POSSession: Codeunit "POS Session"): Integer
    var
        SalePOS: Record "Sale POS";
        POSAction: Record "POS Action";
        POSSale: Codeunit "POS Sale";
        POSCreateEntry: Codeunit "POS Create Entry";
    begin

        POSSession.StartTransaction ();
        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);
        POSSession.ChangeViewSale();
    end;

    local procedure StartWorkflow(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";ActionName: Code[20])
    var
        POSAction: Record "POS Action";
    begin

        if (not POSSession.RetrieveSessionAction (ActionName, POSAction)) then
          POSAction.Get (ActionName);

        //-NPR5.49 [348458]
        // CASE ActionName OF
        //  'BALANCE_V3' : POSAction.SetWorkflowInvocationParameter ('Type', 1, FrontEnd);  // Z-Report, final count
        // END;
        //+NPR5.49 [348458]

        FrontEnd.InvokeWorkflow (POSAction);
    end;

    local procedure StartEODWorkflow(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";ActionName: Code[20];ManagedEOD: Boolean)
    var
        POSAction: Record "POS Action";
    begin

        //-NPR5.49 [348458]
        if (not POSSession.RetrieveSessionAction (ActionName, POSAction)) then
          POSAction.Get (ActionName);

        case ActionName of
          'BALANCE_V3' :
            begin
              if (not ManagedEOD) then POSAction.SetWorkflowInvocationParameter ('Type', 1, FrontEnd);  // Z-Report, final count
              if (ManagedEOD) then POSAction.SetWorkflowInvocationParameter ('Type', 2, FrontEnd);  // Close Workshift - for managed POS
            end;
        end;

        FrontEnd.InvokeWorkflow (POSAction);
        //+NPR5.49 [348458]
    end;

    local procedure DaysSinceLastBalance(PosUnitNo: Code[10]): Integer
    var
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.SetFilter ("POS Unit No.", '=%1', PosUnitNo);
        POSWorkshiftCheckpoint.SetFilter (Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter (Open, '=%1', false);

        if (not POSWorkshiftCheckpoint.FindLast ()) then
          exit (-1); // Never been balanced

        exit (Today - DT2Date (POSWorkshiftCheckpoint."Created At"));
    end;

    local procedure "--Legacy"()
    begin
    end;

    local procedure OpenRegisterLegacy(FrontEnd: Codeunit "POS Front End Management";Setup: Codeunit "POS Setup";POSSession: Codeunit "POS Session")
    var
        SalePOS: Record "Sale POS";
        POSAction: Record "POS Action";
        POSSale: Codeunit "POS Sale";
        POSCreateEntry: Codeunit "POS Create Entry";
    begin

        case RegisterTestOpen (Setup.Register()) of
          CashRegisterOpenStatus::DoNotOpenRegister : Error (InvalidStatus);

          CashRegisterOpenStatus::FirstOpenAfterBalancing : // After confirm on first open after balancing
            begin
              POSSession.StartTransaction ();
              POSSession.GetSale (POSSale);
              POSSale.GetCurrentSale (SalePOS);
              RegisterOpen (SalePOS);

              // RegisterOpen consumes the current sales ticket when opening the register on first open after balancing
              POSSession.StartTransaction ();

              POSSale.GetCurrentSale (SalePOS);
              POSSession.ChangeViewSale();
            end;

          CashRegisterOpenStatus::BalanceRegister :
            begin
              // POSSession.ChangeViewBalancing ();
              POSSession.StartTransaction ();
              //-NPR5.40 [306347]
              //POSAction.GET ('BALANCE_V1');
              if not POSSession.RetrieveSessionAction('BALANCE_V1',POSAction) then
                POSAction.Get ('BALANCE_V1');
              //+NPR5.40 [306347]
              FrontEnd.InvokeWorkflow(POSAction);
            end;

          CashRegisterOpenStatus::DoOpenRegister :
            begin
              POSSession.StartTransaction ();
              POSSession.GetSale (POSSale);
              POSSale.GetCurrentSale (SalePOS);
              //-NPR5.38 [297087]
              //POSCreateEntry.InsertUnitLoginEntry (SalePOS."Register No.", SalespersonPurchaser.Code);
              //-NPR5.46 [328338]
              POSCreateEntry.InsertUnitLoginEntry (SalePOS."Register No.", SalePOS."Salesperson Code");
              //+NPR5.46 [328338]

              //+NPR5.38 [297087]

              POSSession.ChangeViewSale();
            end;
        else
          Error ('Illegal Register Cash TerminalStatus');
        end;
    end;

    procedure RegisterTestOpen(CashRegisterNo: Code[10]): Integer
    var
        CashRegister: Record Register;
        RetailSalesCode: Codeunit "Retail Sales Code";
    begin

        //-NPR5.32.11 [279495]
        CashRegister.Get(CashRegisterNo);

        case CashRegister.Status of
          CashRegister.Status::" "         : ;
          CashRegister.Status::Afsluttet :
            begin

            if (not RetailSalesCode.CheckPostingDateAllowed (WorkDate)) then
              if (not Confirm(t006)) then
                exit (CashRegisterOpenStatus::DoNotOpenRegister);

            if not Confirm(StrSubstNo(t002, CashRegister."Register No.",CashRegister."Closing Cash"),true) then
              exit (CashRegisterOpenStatus::DoNotOpenRegister);

            exit (CashRegisterOpenStatus::FirstOpenAfterBalancing);

          end;

          CashRegister.Status::Ekspedition :
            begin
              if CashRegister."Opened Date" = Today then
                exit (CashRegisterOpenStatus::DoOpenRegister);

            case CashRegister."Balancing every" of
              CashRegister."Balancing every"::Day :
                begin
                  if Confirm (t004, true, CashRegister."Opened Date") then
                    exit (CashRegisterOpenStatus::BalanceRegister);
                  exit (CashRegisterOpenStatus::DoNotOpenRegister);

                  //MESSAGE (MustBalanceRegister, CashRegister."Opened Date");
                  //EXIT (CashRegisterOpenStatus::BalanceRegister);

                end;

              CashRegister."Balancing every"::Manual :
                exit (CashRegisterOpenStatus::DoOpenRegister);

              else
                exit (CashRegisterOpenStatus::DoNotOpenRegister);
            end;
          end;
        end;

        exit (CashRegisterOpenStatus::DoOpenRegister);

        //+NPR5.32.11 [279495]
    end;

    local procedure RegisterOpen(SalePOS: Record "Sale POS")
    var
        CashRegister: Record Register;
        RetailSalesCode: Codeunit "Retail Sales Code";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin

        //-NPR5.32.11 [279495]
        if (not RetailSalesCode.CheckPostingDateAllowed (WorkDate)) then
          RetailSalesCode.EditPostingDateAllowed (UserId, WorkDate);

        //-NPR5.38 [297087]
        // NOTE: When legacy function RegisterOpen is removed, OnOpenRegister_LegacySubscriber must also be removed and InsertUnitOpenEntry invoked directly
        // POSCreateEntry.InsertUnitOpenEntry (Register."Register No.", SalePOS."Salesperson Code");
        //+NPR5.38 [297087]

        TouchScreenFunctions.RegisterOpen (SalePOS);

        CashRegister.Get (SalePOS."Register No.");
        CashRegister.Status := CashRegister.Status::Ekspedition;
        CashRegister.Modify;
        //+NPR5.32.11 [279495]
    end;

    local procedure "--"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014505, 'OnBeforeRegisterOpen', '', true, true)]
    local procedure OnRegisterOpen_LegacySubscriber(Register: Record Register)
    var
        POSCreateEntry: Codeunit "POS Create Entry";
    begin

        //-NPR5.38 [297087]
        POSCreateEntry.InsertUnitOpenEntry (Register."Register No.", '');
        //+NPR5.38 [297087]
    end;
}

