codeunit 85352 "NPR DE ZRep Blocking Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;
        _EodWorkshiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ZReportCompletesWhenDSFINVKWriteIsBlocked()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        BlockingHandler: Codeunit "NPR DE ZRep Blocking Handler";
        CheckpointMgt: Codeunit "NPR POS Workshift Checkpoint";
        PosEntryNo: Integer;
    begin
        // [Scenario] A DE fiscalized POS unit runs a Z-report while the DSFinV-K closing row
        //            cannot be written. The Z-report must still complete: both
        //            "NPR POS Workshift Checkpoint".EndWorkshift and
        //            "NPR End Of Day UI Handler".FinalizeZReport commit and then raise their
        //            after-event, so an error thrown by the DE audit subscriber aborts
        //            everything that follows - including PrintEndOfDayReport.

        // [GIVEN] a DE fiscalized POS unit with one sale ready to be balanced.
        //         "DSFINVK Api URL" is left blank by the test library, exactly as the DE
        //         setup wizard leaves it, so SendRequest_DSFinV_K fails on its TestField
        //         without any HTTP call and the flow lands in SetDSFINVKErrorMsg.
        Initialize();
        DoItemSale();

        // [GIVEN] every write to the closing row loses a rowversion race - what a 30 second
        //         SQL lock timeout against the DSFINVK job degrades into.
        BlockingHandler.SetInjectWriteConflict(true);
        BindSubscription(BlockingHandler);

        // [WHEN] the Z-report is run
        PosEntryNo := CheckpointMgt.EndWorkshift(_EodWorkshiftMode::ZREPORT, _POSUnit."No.", 0);
        UnbindSubscription(BlockingHandler);

        // [THEN] the closing write really was attempted and really did fail. Without this the
        //        test would silently pass if the DE flow ever stopped reaching the write at all.
        _Assert.IsTrue(BlockingHandler.GetInjectionCount() > 0, 'The DSFinV-K closing write was never attempted, so this test proves nothing.');

        // [THEN] the Z-report completed rather than being aborted by the DE audit subscriber
        POSWorkshiftCheckpoint.SetRange("POS Entry No.", PosEntryNo);
        _Assert.IsTrue(POSWorkshiftCheckpoint.FindLast(), 'Z-report workshift checkpoint must exist.');
        _Assert.AreEqual(POSWorkshiftCheckpoint.Type::ZREPORT, POSWorkshiftCheckpoint.Type, 'Checkpoint must be a Z-report.');
        _Assert.IsFalse(POSWorkshiftCheckpoint.Open, 'Z-report checkpoint must be closed.');

        // [THEN] the DSFinV-K closing is still on file, so the retry job can submit it later
        //        and the fiscal obligation is not silently dropped.
        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        DSFINVKClosing.SetRange("Closing Date", WorkDate());
        _Assert.IsFalse(DSFINVKClosing.IsEmpty(), 'DSFinV-K closing must be kept on file for retry.');
    end;

    [ModalPageHandler]
    procedure PageHandler_POSPaymentBinCheckpoint_LookupOK(var UIEndOfDay: Page "NPR POS Payment Bin Checkpoint"; var ActionResponse: Action)
    begin
        UIEndOfDay.DoOnOpenPageProcessing();
        UIEndOfDay.DoOnClosePageProcessing();
        ActionResponse := Action::LookupOK;
    end;

    local procedure DoItemSale()
    var
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedErr: Label 'Sale did not end as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSMockLibrary.CreateItemLine(_POSSession, _Item."No.", 1);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '') then
            Error(SaleNotEndedErr);

        // The POS session is deliberately left open: the balancing entry created by
        // EndWorkshift takes its salesperson from the active session, and the FR audit
        // subscriber hard-requires it via SalespersonPurchaser.Get.
    end;

    local procedure Initialize()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);
        WorkDate(Today());

        if not _Initialized then begin
            LibraryDEFiscal.CreatePOSUnit(_POSUnit, _POSStore, POSPostingProfile);
            LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            LibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);
            _Item."Unit Price" := 10;
            _Item.Modify();
            LibraryDEFiscal.CreateVATPostingSetup(POSPostingProfile."VAT Bus. Posting Group", _Item."VAT Prod. Posting Group");
            LibraryDEFiscal.CreatePOSPaymentMethod(_POSPaymentMethod, Enum::"NPR Payment Processing Type"::CASH);
            _POSPaymentMethod."Rounding Precision" := 0.01;
            _POSPaymentMethod."Rounding Type" := _POSPaymentMethod."Rounding Type"::Nearest;
            _POSPaymentMethod.Modify();

            if not POSEndOfDayProfile.Get('DE-EOD-TEST') then begin
                POSEndOfDayProfile.Code := 'DE-EOD-TEST';
                POSEndOfDayProfile.Insert();
            end;
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile."End of Day Type" := POSEndOfDayProfile."End of Day Type"::INDIVIDUAL;
            POSEndOfDayProfile.Modify();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryDEFiscal.CreateAuditProfileSetup(POSAuditProfile, _POSUnit);

            _Initialized := true;
        end;

        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        DSFINVKClosing.DeleteAll();
        LibraryPOSMasterData.ItemReferenceCleanup();
        Commit();
    end;
}
