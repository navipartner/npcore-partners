codeunit 6151370 "NPR SS Action: Start SelfServB"
{
    procedure StartSelfService(POSSession: Codeunit "NPR POS Session"; SalespersonCode: Code[20]; LanguageCode: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Language: Record Language;
        POSSetup: Codeunit "NPR POS Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSUIManagement: Codeunit "NPR POS UI Management";
        OpeningEntryNo: Integer;
        InactivePosUnitLbl: Label 'POS Unit %1 is inactive. It can not be used to complete the action', Comment = '%1-POS Unit code';
        BusyPOSUnitLbl: Label 'This unit is busy with another process right now. Please try again later. <br>Thank-you for your patience.';
    begin
        DATABASE.SelectLatestVersion();
        POSSession.GetSetup(POSSetup);

        POSSetup.Initialize();

        SalespersonPurchaser.Get(SalespersonCode);
        POSSetup.SetSalesperson(SalespersonPurchaser);

        POSSetup.GetPOSUnit(POSUnit);

        // possetup might have a stale version
        POSUnit.Get(POSUnit."No.");
        POSSetup.SetPOSUnit(POSUnit);

        case POSUnit.Status of
            POSUnit.Status::OPEN:
                ; // Default

            POSUnit.Status::CLOSED:
                begin
                    CreateFirstTimeCheckpoint(POSUnit."No.");
                    POSManagePOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No."); // make sure pos period register is correct
                    POSManagePOSUnit.OpenPOSUnit(POSUnit);
                    OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", POSSetup.Salesperson());
                    POSManagePOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
                    POSSetup.SetPOSUnit(POSUnit);
                end;

            POSUnit.Status::EOD:
                Error(BusyPOSUnitLbl);

            POSUnit.Status::INACTIVE:
                Error(InactivePosUnitLbl, POSUnit."No.");
        end;

        POSCreateEntry.InsertUnitLoginEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

        if (Language.Get(LanguageCode)) then begin
            if (Language."Windows Language ID" > 0) then
                GlobalLanguage(Language."Windows Language ID");
            POSUIManagement.InitializeCaptions();
        end;

        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.ChangeViewSale();
    end;

    local procedure CreateFirstTimeCheckpoint(UnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin

        POSWorkshiftCheckpoint.SetRange("POS Unit No.", UnitNo);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);

        if (POSWorkshiftCheckpoint.IsEmpty()) then begin
            POSWorkshiftCheckpoint."Entry No." := 0;
            POSWorkshiftCheckpoint."POS Unit No." := UnitNo;
            POSWorkshiftCheckpoint.Open := false;
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
            POSWorkshiftCheckpoint."Created At" := CurrentDateTime();
            POSWorkshiftCheckpoint.Insert();
        end;
    end;
}