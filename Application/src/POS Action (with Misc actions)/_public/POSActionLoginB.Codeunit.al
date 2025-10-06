codeunit 6150832 "NPR POS Action - Login-B"
{
    var
        BalancingRequired: Label 'The register has not been balanced since %1 and must be balanced before selling. Do you want to balance the register now?';
        ContinueEoD: Label 'The %1 %2 is marked as being in balancing. Do you want to continue with balancing now?';
        InvalidStatus: Label 'The register status states that the register cannot be opened at this time.';
        IsEoD: Label 'The %1 %2 indicates that this %1 is being balanced and it can''t be opened at this time.';
        ManagedPos: Label 'This POS is managed by POS Unit %1 [%2] and it is therefore required that %1 is opened prior to opening this POS.';
#if not (BC17 or BC18 or BC19)
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        SalespersonBlockedErr: Label 'Salesperson %1 - %2 is blocked.', Comment = '%1 = Salesperson Code, %2 = Salesperson Name';
#endif

    procedure OpenPosUnit(FrontEnd: Codeunit "NPR POS Front End Management"; Setup: Codeunit "NPR POS Setup"; POSSession: Codeunit "NPR POS Session"; var ActionContext: JsonObject)
    var
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
        POSPeriodRegister: Record "NPR POS Period Register";
        ManagedByPOSUnit: Record "NPR POS Unit";
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        IsManagedPOS: Boolean;
        MissingPeriodRegister: Boolean;
        BalanceAge: Integer;
    begin
        // This should be inside the START_POS workflow
        // But to save a roundtrip and becase nested workflows are not perfect yet, I have kept this part here

        Setup.GetPOSUnit(POSUnit);
        POSUnit.Get(POSUnit."No.");
        if POSUnit.Status = POSUnit.Status::INACTIVE then
            POSUnit.FieldError(Status);

        Setup.GetSalespersonRecord(SalespersonPurchaser);
#if not (BC17 or BC18 or BC19)
        if FeatureFlagsManagement.IsEnabled('blocksalespersononposviabutton') then
            if SalespersonPurchaser.Blocked then
                Error(SalespersonBlockedErr, SalespersonPurchaser.Code, SalespersonPurchaser.Name);
#endif
        CheckPosUnitGroup(SalespersonPurchaser, POSUnit."No.");

        BalanceAge := DaysSinceLastBalance(POSUnit);

        POSEndofDayProfile.Init();
        if (POSUnit."POS End of Day Profile" <> '') then begin
            POSEndofDayProfile.Get(POSUnit."POS End of Day Profile");
            if (POSEndofDayProfile."End of Day Type" = POSEndofDayProfile."End of Day Type"::MASTER_SLAVE) then
                IsManagedPOS := (POSEndofDayProfile."Master POS Unit No." <> POSUnit."No.");
            if (IsManagedPOS) then begin
                ManagedByPOSUnit.Get(POSEndofDayProfile."Master POS Unit No.");
                BalanceAge := DaysSinceLastBalance(ManagedByPOSUnit);
            end;
        end;

        case POSUnit.Status of

            POSUnit.Status::OPEN:
                begin
                    // This state might happen first time when attaching a POS as a slave with status open when master is state close.
                    if ((IsManagedPOS) and (ManagedByPOSUnit.Status <> ManagedByPOSUnit.Status::OPEN)) then begin
                        Message(ManagedPos, ManagedByPOSUnit."No.", ManagedByPOSUnit.Name);
                        SetActionContent(ActionContext, Setup.ActionCode_EndOfDay(), IsManagedPOS);
                        exit;
                    end;

                    if (BalanceAge = -1) then begin  // Has never been balanced
                        SetActionContent(ActionContext, 'START_POS', false);
                        exit;
                    end;

                    if ((POSEndofDayProfile."End of Day Frequency" = POSEndofDayProfile."End of Day Frequency"::DAILY) and (BalanceAge > 0)) then begin
                        if (not Confirm(BalancingRequired, true, (Today - BalanceAge))) then
                            Error(InvalidStatus);

                        // Force a Z-Report or Close WorkShift
                        SetActionContent(ActionContext, Setup.ActionCode_EndOfDay(), IsManagedPOS);
                        exit;
                    end;

                    POSPeriodRegister.SetCurrentKey("POS Unit No.");
                    POSPeriodRegister.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
                    MissingPeriodRegister := not POSPeriodRegister.FindLast();
                    if (MissingPeriodRegister) or ((not MissingPeriodRegister) and (POSPeriodRegister.Status <> POSPeriodRegister.Status::OPEN)) then begin
                        SetActionContent(ActionContext, 'START_POS', false);
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

                        SetActionContent(ActionContext, Setup.ActionCode_EndOfDay(), IsManagedPOS);
                        exit;
                    end;

                    SetActionContent(ActionContext, 'START_POS', false);
                end;

            POSUnit.Status::EOD:
                begin
                    if (not Confirm(ContinueEoD, true, POSUnit.TableCaption(), POSUnit."No.")) then
                        Error(IsEoD, POSUnit.TableCaption(), POSUnit.FieldCaption(Status));

                    SetActionContent(ActionContext, Setup.ActionCode_EndOfDay(), IsManagedPOS);
                end;
        end;
    end;

    internal procedure StartPOS(POSSession: Codeunit "NPR POS Session"): Integer
    var
        SalePOS: Record "NPR POS Sale";
        POSViewProfile: Record "NPR POS View Profile";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        ResumeExistingSale: Boolean;
        ResumeFromPOSQuoteNo: Integer;
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
            POSSale.ResumeFromPOSQuote(ResumeFromPOSQuoteNo);
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

    local procedure DaysSinceLastBalance(POSUnit: Record "NPR POS Unit"): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.SetCurrentKey("POS Unit No.", Open, "Type");
        POSWorkshiftCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
        POSWorkshiftCheckpoint.SetFilter(Type, '=%1', POSWorkshiftCheckpoint.Type::ZREPORT);
        POSWorkshiftCheckpoint.SetFilter(Open, '=%1', false);

        if (not POSWorkshiftCheckpoint.FindLast()) then
            exit(-1); // Never been balanced

        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
        POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
        POSEntry.SetFilter("Entry No.", '>%1', POSWorkshiftCheckpoint."POS Entry No.");
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '<>%1', POSEntry."Entry Type"::"Cancelled Sale");
        POSEntry.SetLoadFields("Entry Date");
        if not POSEntry.FindFirst() then
            exit(0);

        if Today - POSEntry."Entry Date" >= 1 then
            exit(Today - DT2Date(POSWorkshiftCheckpoint."Created At"));
    end;

    internal procedure CheckPosUnitGroup(SalespersonPurchaser: Record "Salesperson/Purchaser"; POSUnitNo: Code[20])
    var
        POSUnitGroupLine: Record "NPR POS Unit Group Line";
        SalesPersonNotAllowedErr: Label 'Salesperson %1 is not allowed to access POS Unit %2', Comment = '%1 = Salesperson Name; %2 = Pos Unit No.';
    begin
        if SalespersonPurchaser."NPR POS Unit Group" = '' then
            exit;
        POSUnitGroupLine.SetRange("POS Unit", POSUnitNo);
        POSUnitGroupLine.SetRange("No.", SalespersonPurchaser."NPR POS Unit Group");
        if POSUnitGroupLine.IsEmpty() then
            Error(SalesPersonNotAllowedErr, SalespersonPurchaser.Name, POSUnitNo);
    end;

#if not (BC17 or BC18 or BC19)
    internal procedure CheckSalespersonBlocked(SalespersonCode: Code[20])
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if not FeatureFlagsManagement.IsEnabled('blocksalespersononposviabutton') then
            exit;
        SalespersonPurchaser.SetLoadFields(Blocked, Code, Name);
        if not SalespersonPurchaser.Get(SalespersonCode) then
            exit;
        if SalespersonPurchaser.Blocked then
            Error(SalespersonBlockedErr, SalespersonPurchaser.Code, SalesPersonPurchaser.Name);
    end;
#endif

    local procedure SetActionContent(var ActionContext: JsonObject; ActionName: Code[20]; ManagedEOD: Boolean)
    var
        POSAction: Record "NPR POS Action";
        POSSession: Codeunit "NPR POS Session";
        Parameters: JsonObject;
    begin
        if not POSSession.RetrieveSessionAction(ActionName, POSAction) then
            POSAction.Get(ActionName);

        ActionContext.Add('name', POSAction.Code);

        case ActionName of
            'BALANCE_V4':
                begin
                    if (not ManagedEOD) then
                        Parameters.Add('Type', 1);  // Z-Report, final count
                    if (ManagedEOD) then
                        Parameters.Add('Type', 2);// Close WorkShift - for managed POS
                end;
        end;
        ActionContext.Add('parameters', Parameters);
    end;
}