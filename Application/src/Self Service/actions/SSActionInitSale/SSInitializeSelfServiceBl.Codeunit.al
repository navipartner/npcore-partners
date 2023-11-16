codeunit 6184576 "NPR SS InitializeSelfServiceBl"
{
    Access = Internal;
    internal procedure Initialize(CurrentSalesId: Guid; SalesPersonCode: Code[20]; LanguageCode: Code[10]) Response: JsonObject
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        StartSelfService(SalesPersonCode, LanguageCode);
        CleanupStaleSelfServiceSales(CurrentSalesId);
        POSSession.StartTransaction(CurrentSalesId);

        Response.ReadFrom('{}');
        exit(Response);
    end;

    local procedure CleanupStaleSelfServiceSales(CurrentSalesId: Guid)
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionCancelSaleB: Codeunit "NPR POSAction: Cancel Sale B";
        POSActionSavePOSSvSlB: Codeunit "NPR POS Action: SavePOSSvSl B";
        POSSaleRec: Record "NPR POS Sale";
        POSSaleLineRec: Record "NPR POS Sale Line";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
    begin
        if (IsNullGuid(CurrentSalesId)) then
            exit;

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(POSSaleRec);

        if (POSSaleRec."Register No." = '') then
            exit;

        POSSaleRec.SetFilter("Register No.", '=%1', POSSaleRec."Register No.");
        POSSaleRec.SetFilter(SystemId, '<>%1', CurrentSalesId);
        if (not POSSaleRec.FindSet()) then
            exit;

        repeat
            POSSaleLineRec.SetFilter("Register No.", '=%1', POSSaleRec."Register No.");
            POSSaleLineRec.SetFilter("Sales Ticket No.", '=%1', POSSaleRec."Sales Ticket No.");
            if (POSSaleLineRec.IsEmpty()) then begin
                POSSaleRec.Delete();
            end else begin
                POSSession.ConstructFromWebserviceSession(false, POSSaleRec."Register No.", POSSaleRec."Sales Ticket No.");
                if (HasPayment(POSSaleRec)) then begin
                    POSActionSavePOSSvSlB.SaveSale(POSSavedSaleEntry);
                end else begin
                    POSActionCancelSaleB.CancelSale();
                end;
            end;
        until (POSSaleRec.Next() = 0);

    end;

    local procedure HasPayment(POSSaleRec: Record "NPR POS Sale"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetFilter("Sales Ticket No.", '=%1', POSSaleRec."Sales Ticket No.");
        exit(not (EFTTransactionRequest.IsEmpty()));
    end;

    procedure StartSelfService(SalesPersonCode: Code[20]; LanguageCode: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        UserSetup: Record "User Setup";
        Language: Record Language;
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSession: Codeunit "NPR POS Session";
        PosUiManagement: Codeunit "NPR POS UI Management";
        Setup: codeunit "NPR POS Setup";
        OpeningEntryNo: Integer;
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        POSUnit.Get(POSUnit."No.");

        if (UserSetup.Get(UserId())) then
            if (UserSetup."Salespers./Purch. Code" <> '') then
                SalesPersonCode := UserSetup."Salespers./Purch. Code";

        SalespersonPurchaser.Get(SalespersonCode);
        Setup.SetSalesperson(SalespersonPurchaser);

        CreateFirstTimeCheckpoint(POSUnit."No.");

        POSUnit.Get(POSUnit."No.");
        if (POSUnit.Status <> POSUnit.Status::OPEN) then begin
            POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No."); // make sure pos period register is correct
            POSOpenPOSUnit.OpenPOSUnit(POSUnit);
            OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", Setup.Salesperson());
            POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
        end;

        if (Language.Get(LanguageCode)) then begin
            if (Language."Windows Language ID" > 0) then
                GlobalLanguage(Language."Windows Language ID");
            PosUiManagement.InitializeCaptions();
        end;
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