codeunit 85221 "NPR DE Submission Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Assert: Codeunit Assert;
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSubmission()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DESubmission: Record "NPR DE Submission";
        DEEstablishment: Record "NPR DE Establishment";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        SumbissionNotCreatedErr: Label 'Submission is not created.', Locked = true;
    begin
        // [SCENARIO] Checks creation of submission with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and it is created at Fiskaly
        CreateEstablishmentAtFiskaly(DEEstablishment, ConnectionParameterSet."Primary Key");

        // [WHEN] Creating submission for establishment (POS Store) at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.CreateSubmission(DEEstablishment."POS Store Code");
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Submission is created at Fiskaly
        DESubmission.FindLast();
        Assert.AreEqual(DESubmission."POS Store Code", DEEstablishment."POS Store Code", SumbissionNotCreatedErr);
        Assert.AreEqual(DESubmission."Establishment Id", DEEstablishment.SystemId, SumbissionNotCreatedErr);
        Assert.AreEqual(DESubmission.State, DESubmission.State::CREATED, SumbissionNotCreatedErr);
        Assert.AreNotEqual(DESubmission."Created At", 0DT, SumbissionNotCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetrieveSubmission()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        DESubmission: Record "NPR DE Submission";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        SubmissionNotRetrievedErr: Label 'Submission is not retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving of submisssion with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and it is created at Fiskaly
        CreateEstablishmentAtFiskaly(DEEstablishment, ConnectionParameterSet."Primary Key");

        // [GIVEN] Submisssion exists for establishment (POS Store)
        CreateSubmission(DESubmission, DEEstablishment);

        // [WHEN] Retrieving submission from Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.RetrieveSubmission(DESubmission);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Submission is retrieved from Fiskaly
        DESubmission.Get(DESubmission."Entry No.");
        Assert.AreEqual(DESubmission."Establishment Id", DEEstablishment.SystemId, SubmissionNotRetrievedErr);
        Assert.AreEqual(DESubmission.State, DESubmission.State::VALIDATION_TRIGGERED, SubmissionNotRetrievedErr);
        Assert.AreNotEqual(DESubmission."Created At", 0DT, SubmissionNotRetrievedErr);
        Assert.AreNotEqual(DESubmission."Generated At", 0DT, SubmissionNotRetrievedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TriggerSubmissionTransmission()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DESubmission: Record "NPR DE Submission";
        DEEstablishment: Record "NPR DE Establishment";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        SumbissionTransmissionNotTriggeredErr: Label 'Submission transmission is not triggered.', Locked = true;
    begin
        // [SCENARIO] Checks triggering of submission transmission with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and it is created at Fiskaly
        CreateEstablishmentAtFiskaly(DEEstablishment, ConnectionParameterSet."Primary Key");

        // [GIVEN] Submission exists for establishment (POS Store) and it is ready for tranmission
        CreateSubmission(DESubmission, DEEstablishment);
        DESubmission.Validate(State, DESubmission.State::READY_FOR_TRANSMISSION);
        DESubmission.Modify(true);

        // [WHEN] Triggering transmission of submission at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.TriggerSubmissionTransmission(DESubmission);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Transmission of submission is triggered at Fiskaly
        DESubmission.FindLast();
        Assert.AreEqual(DESubmission.State, DESubmission.State::TRANSMISSION_PENDING, SumbissionTransmissionNotTriggeredErr);
        Assert.AreNotEqual(DESubmission."Generated At", 0DT, SumbissionTransmissionNotTriggeredErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelSubmissionTransmission()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DESubmission: Record "NPR DE Submission";
        DEEstablishment: Record "NPR DE Establishment";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
        SumbissionTransmissionNotCancelledErr: Label 'Submission transmission is not cancelled.', Locked = true;
    begin
        // [SCENARIO] Checks cancelling of submission transmission with successful response from Fiskaly
        // [GIVEN] POS and DE audit setup are set
        InitializeData();

        // [GIVEN] DE Connection Parameter Set exists and Taxpayer is created for it at Fiskaly
        CreateTaxpayerAtFiskalyForConnectionParameterSet(ConnectionParameterSet);

        // [GIVEN] DE Establishment exists for POS Store and it is created at Fiskaly
        CreateEstablishmentAtFiskaly(DEEstablishment, ConnectionParameterSet."Primary Key");

        // [GIVEN] Submission exists for establishment (POS Store) and its tranmission is triggered, but not still processed
        CreateSubmission(DESubmission, DEEstablishment);
        DESubmission.Validate(State, DESubmission.State::TRANSMISSION_PENDING);
        DESubmission.Modify(true);

        // [WHEN] Cancelling transmission of submission at Fiskaly
        BindSubscription(DEFiscalLibrary);
        DEFiskalyCommunication.CancelSubmissionTransmission(DESubmission);
        UnbindSubscription(DEFiscalLibrary);

        // [THEN] Transmission of submission is cancelled at Fiskaly
        DESubmission.FindLast();
        Assert.AreEqual(DESubmission.State, DESubmission.State::TRANSMISSION_CANCELLED, SumbissionTransmissionNotCancelledErr);
        Assert.AreNotEqual(DESubmission."Generated At", 0DT, SumbissionTransmissionNotCancelledErr);
    end;

    local procedure CreateTaxpayerAtFiskalyForConnectionParameterSet(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        DEFiscalLibrary.CreateTestConnectionParameterSet(ConnectionParameterSet);
        ConnectionParameterSet.Validate("Taxpayer Created", true);
        ConnectionParameterSet.Modify(true);
    end;

    local procedure CreateEstablishmentAtFiskaly(var DEEstablishment: Record "NPR DE Establishment"; ConnectionParameterSetCode: Code[10])
    var
        POSStore: Record "NPR POS Store";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
        DEFiscalLibrary.CreateEstablishment(DEEstablishment, POSStore.Code, ConnectionParameterSetCode);
        DEEstablishment.Validate(Created, true);
        DEEstablishment.Modify(true);
    end;

    local procedure CreateSubmission(var DESubmission: Record "NPR DE Submission"; DEEstablishment: Record "NPR DE Establishment")
    begin
        DESubmission.Init();
        DESubmission."Entry No." := DESubmission.GetLastEntryNo() + 1;
        DESubmission."POS Store Code" := DEEstablishment."POS Store Code";
        DESubmission."Establishment Id" := DEEstablishment.SystemId;
        DESubmission.Insert(true);
    end;

    local procedure InitializeData()
    var
        POSSetup: Record "NPR POS Setup";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        DEFiscalLibrary: Codeunit "NPR Library DE Fiscal";
    begin
        if Initialized then
            exit;

        POSMasterDataLibrary.CreatePOSSetup(POSSetup);
        POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);

        DEFiscalLibrary.EnableFiscalization();

        Initialized := true;
        Commit();
    end;
}
