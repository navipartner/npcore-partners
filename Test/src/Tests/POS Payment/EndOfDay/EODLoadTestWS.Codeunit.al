codeunit 85146 "NPR EODLoadTestWS"
{

    SingleInstance = true;

    var
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _POSSession: Codeunit "NPR POS Session";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _PrimeNumbers: array[10] of Integer;
        _EodWorkshiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;

    procedure PreparePosUnit(PosUnitNo: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnit.Get(PosUnitNo)) then
            exit;

        InitializeSetup(PosUnitNo, _POSUnit."POS Store Code");
    end;

    procedure CreateSales(PosUnitNo: Code[10]; NumberOfSales: Integer)
    var

        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        VATPostingSetup: Record "VAT Posting Setup";

        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";

        SalesOffset: Integer;
        TotalAmount: Decimal;
        TotalNetAmount: Decimal;
        LineAmount: Decimal;
        LineQty: Decimal;
        TotalQty: Decimal;
        SaleEnded: Boolean;
    begin
        _POSUnit.Get(PosUnitNo);
        _POSStore.Get(_POSUnit."POS Store Code");

        InitializeSale(POSSale);
        Randomize(1);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
        Commit();

        for SalesOffset := 1 to NumberOfSales do begin

            POSSale.GetCurrentSale(SalePOS);

            POSEntry.LockTable(true);
            POSEntry.FindFirst();

            Item.Get(Item."No.");
            Item."Unit Price" := _PrimeNumbers[SalesOffset];
            Item.Modify();

            LineQty := 1 + _PrimeNumbers[SalesOffset] / 100; // will be 2 decimals
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", LineQty);

            LineAmount := Round(_PrimeNumbers[SalesOffset] * LineQty, _POSPaymentMethod."Rounding Precision", _POSPaymentMethod.GetRoundingType());
            TotalAmount += LineAmount * 2;
            TotalNetAmount += LineAmount * 2 / (100 + VATPostingSetup."VAT %") * 100;
            TotalQty += LineQty * 2;

            SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, LineAmount * 2, '');
            Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');
            Commit();

            Sleep(200 + Random(100)); // allow concurrent threads to create orders
        end;

    end;

    procedure EndOfDay(PosUnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        POSEntry: Record "NPR POS Entry";

        PosEntryNo: Integer;
        DimensionSetId: Integer;
    begin
        PosEntryNo := POSWorkshiftCheckpoint.EndWorkshift(_EodWorkshiftMode::ZREPORT, PosUnitNo, DimensionSetId);
        POSEntry.Get(PosEntryNo);
    end;

    procedure DataCleanUp() UnitCount: Integer;
    var
        PosUnit: Record "NPR POS Unit";
        PosStore: Record "NPR POS Store";
        PosPostingSetup: Record "NPR POS Posting Setup";
        PosPaymentMethod: Record "NPR POS Payment Method";
        PosBin: Record "NPR POS Payment Bin";
    begin
        PosUnit.SetFilter("No.", '%1', 'GU*');
        if (PosUnit.FindSet()) then
            repeat
                PosPostingSetup.SetFilter("POS Store Code", '=%1', PosUnit."POS Store Code");
                PosPostingSetup.FindSet();
                repeat
                    if (PosPaymentMethod.Get(PosPostingSetup."POS Payment Method Code")) then
                        PosPaymentMethod.Delete();
                    PosPostingSetup.Delete();
                until (PosPostingSetup.Next() = 0);

                if (PosBin.Get(PosUnit."Default POS Payment Bin")) then
                    PosBin.Delete();

                if (PosStore.Get(PosUnit."POS Store Code")) then
                    PosStore.Delete();

                PosUnit.Delete();
                UnitCount += 1;

            until (PosUnit.Next() = 0);
    end;

    local procedure InitializeSale(var POSSale: Codeunit "NPR POS Sale")
    var
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        _POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager";
    begin
        POSBackgroundTaskAPI.Initialize(_POSBackgroundTaskManager);
        _POSSession.Constructor(POSBackgroundTaskAPI);
        _POSSession.StartTransaction();
        _POSSession.GetSale(POSSale);

        _POSPaymentMethod.SetFilter("Rounding Precision", '=%1', 0.01);
        _POSPaymentMethod.SetFilter("Processing Type", '=%1', _POSPaymentMethod."Processing Type"::CASH);
        _POSPaymentMethod.FindFirst();

        _PrimeNumbers[1] := 19;
        _PrimeNumbers[2] := 23;
        _PrimeNumbers[3] := 29;
        _PrimeNumbers[4] := 31;
        _PrimeNumbers[5] := 37;
        _PrimeNumbers[6] := 41;
        _PrimeNumbers[7] := 43;
        _PrimeNumbers[8] := 47;
        _PrimeNumbers[9] := 53;
        _PrimeNumbers[10] := 59;
    end;


    local procedure InitializeSetup(POSUnitNo: Code[10]; POSStoreCode: Code[10])
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin

        WorkDate(Today);

        NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);

        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        NPRLibraryPOSMasterData.CreatePOSStore(POSStoreCode, _POSStore, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSUnit(PosUnitNo, _POSUnit, _POSStore.Code, POSPostingProfile.Code);

        if (not POSEndOfDayProfile.Get('EOD-TEST')) then begin
            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();
        end;

        _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
        _POSUnit.Modify();

        _POSPaymentMethod.SetFilter("Rounding Precision", '=%1', 0.01);
        _POSPaymentMethod.SetFilter("Processing Type", '=%1', _POSPaymentMethod."Processing Type"::CASH);
        if (not _POSPaymentMethod.FindFirst()) then begin
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            _POSPaymentMethod."Rounding Precision" := 0.01;
            _POSPaymentMethod."Rounding Type" := _POSPaymentMethod."Rounding Type"::Nearest;
            _POSPaymentMethod.Modify();
        end;

        NPRLibraryPOSMasterData.ItemReferenceCleanup();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Setup", 'OnBeforeSetPOSUnitOnInitalize', '', false, false)]
    local procedure OnBeforeSetPOSUnitOnInitialize(var UserSetup: Record "User Setup"; var POSUnitRec: Record "NPR POS Unit"; var Handled: Boolean)
    begin
        Handled := POSUnitRec.Get(_PosUnit."No.");
    end;
}