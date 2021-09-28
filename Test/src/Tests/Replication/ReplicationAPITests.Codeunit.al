codeunit 85042 "NPR Replication API Tests"
{
    // [Feature] Replication API

    Subtype = Test;

    trigger OnRun()
    var

    begin
        Initialized := false;
    end;

    var
        RepSetup: Record "NPR Replication Service Setup";
        ImportType: Record "NPR Nc Import Type";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;

        Initialized: Boolean;

    [Test]
    procedure VerifyDataIsReplicatedUOM()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        UOM: Record "Unit of Measure";
        RepEndpointLocal: Record "NPR Replication Endpoint";
        ReplicationAPI: Codeunit "NPR Replication API";
        ProcessImportListLbl: Label 'process_import_list', Locked = true;
        ImportTypeParameterLbl: Label 'import_type', locked = true;
        StrSubStNoText: Label '%1=%2,%3';
        ImportListProcessingCU: Codeunit "NPR Nc Import List Processing";
        MockCU: Codeunit "Replication API Mock Handler";
        NewUOMsList: List of [Code[20]];
        i: Integer;
        RepCounter: BigInteger;
    begin
        // [SCENARIO] Verify data is replicated

        // [GIVEN] Replication Setup and Enpoint
        InitializeData();
        CreateReplicationEndpointUOM(RepEndpointLocal);

        // [GIVEN] Simulate 6 new UOMs are created
        CreateUOMs(NewUOMsList);

        // [GIVEN] Mock Codeunit is Enabled and Parameters are Set
        // this helps simulate creation of import entries based on mock data instead of calling the api web service.
        BindSubscription(MockCU);
        MockCU.SetNoOfPages(3);
        MockCU.SetCode20List(NewUOMsList);
        MockCU.SetTestFunctionName('VerifyDataIsReplicatedUOM');

        // [WHEN] Nc Import List is Updated
        TempJobQueueEntry.Init();
        TempJobQueueEntry."Record ID to Process" := RepSetup.RecordId;
        TempJobQueueEntry."Parameter String" := StrSubstNo(StrSubStNoText,
                            ImportTypeParameterLbl, RepSetup."API Version",
                            ProcessImportListLbl);
        ReplicationAPI.Update(TempJobQueueEntry, ImportType);

        // [WHEN] ProcessImportEntry is ran
        ImportListProcessingCU.ProcessImportEntries(ImportType);

        // [THEN] Verify data was imported
        For i := 1 to NewUOMsList.Count() do begin
            UOM.Get(NewUOMsList.Get(i));
        end;

        // [THEN] Verify Replication Counter on Replication Endpoint
        RepEndpointLocal.FIND();
        RepCounter := 6;
        Assert.AreEqual(RepEndpointLocal."Replication Counter", RepCounter, 'Incorrect Replication Counter in Replication Endpoint.'); // last imported rec had counter 6.

        // [CLEANUP] Unbind Event Subscriptions in Mock Helper Codeunit
        RepEndpointLocal.Delete();
        UnbindSubscription(MockCU);
    end;

    [Test]
    procedure VerifyEncouteredErrorStopsFurtherImportUOM()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        UOM: Record "Unit of Measure";
        RepEndpointLocal: Record "NPR Replication Endpoint";
        ReplicationAPI: Codeunit "NPR Replication API";
        ProcessImportListLbl: Label 'process_import_list', Locked = true;
        ImportTypeParameterLbl: Label 'import_type', locked = true;
        StrSubStNoText: Label '%1=%2,%3';
        ImportListProcessingCU: Codeunit "NPR Nc Import List Processing";
        MockCU: Codeunit "Replication API Mock Handler";
        NewUOMsList: List of [Code[20]];
        i: Integer;
        RepCounter: BigInteger;
    begin
        // [SCENARIO] Verify data import stops for all next pages if an error occurs in one page.

        // [GIVEN] Replication Setup and Endpoint
        InitializeData();
        CreateReplicationEndpointUOM(RepEndpointLocal);

        // [GIVEN] Simulate 6 new UOMs are created
        CreateUOMs(NewUOMsList);

        // [GIVEN] 3rd UOM has an error: Code exceeds 10 characters
        NewUOMsList.Set(3, LibraryUtility.GenerateRandomText(15));

        // [GIVEN] Mock Codeunit is Enabled and Parameters are Set
        // this helps simulate creation of import entries based on mock data instead of calling the api web service.
        BindSubscription(MockCU);
        MockCU.SetNoOfPages(3);
        MockCU.SetCode20List(NewUOMsList);
        MockCU.SetTestFunctionName('VerifyEncouteredErrorStopsFurtherImportUOM');

        // [WHEN] Nc Import List is Updated
        TempJobQueueEntry.Init();
        TempJobQueueEntry."Record ID to Process" := RepSetup.RecordId;
        TempJobQueueEntry."Parameter String" := StrSubstNo(StrSubStNoText,
                            ImportTypeParameterLbl, RepSetup."API Version",
                            ProcessImportListLbl);
        ReplicationAPI.Update(TempJobQueueEntry, ImportType);

        // [WHEN] ProcessImportEntry is ran
        ImportListProcessingCU.ProcessImportEntries(ImportType);

        // [THEN] Verify data was imported: 1st page
        For i := 1 to 2 do begin
            UOM.Get(NewUOMsList.Get(i));
        end;

        // [THEN] Verify import of data was stopped: 2nd and 3rd page
        For i := 3 to NewUOMsList.Count() do begin
            asserterror UOM.Get(NewUOMsList.Get(i));
        end;

        // [THEN] Verify Replication Counter on Replication Endpoint
        RepEndpointLocal.FIND();
        RepCounter := 2;
        Assert.AreEqual(RepEndpointLocal."Replication Counter", RepCounter, 'Incorrect Replication Counter in Replication Endpoint.'); // last imported rec had counter 2.

        // [CLEANUP] Unbind Event Subscriptions in Mock Helper Codeunit
        RepEndpointLocal.Delete();
        UnbindSubscription(MockCU);
    end;

    local procedure CreateUOMs(NewUOMsList: List of [Code[20]])
    var
        i: Integer;
        UOM: Record "Unit of Measure";
    begin
        For i := 1 to 6 do begin
            NewUOMsList.Add(LibraryUtility.GenerateRandomCode(UOM.FieldNo(Code), Database::"Unit of Measure"))
        end;
    end;

    procedure InitializeData()
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin

        if not Initialized then begin
            //create Setup
            CreateReplicationSetup();
            ReplicationAPI.RegisterNcImportType(RepSetup."API Version");
            ImportType.Get(RepSetup."API Version");
            Initialized := true;

            Commit();
        end;
    end;

    local procedure CreateReplicationSetup()
    begin
        RepSetup.Init();
        RepSetup."API Version" := LibraryUtility.GenerateRandomCode20(RepSetup.FieldNo("API Version"), Database::"NPR Replication Service Setup");
        RepSetup.Insert();
        RepSetup."Service URL" := 'https://localhost.dynamics-retail.com:7048/bc/api';
        RepSetup.AuthType := RepSetup.AuthType::Basic;
        RepSetup.UserName := '';
        RepSetup.SetApiPassword('');
        RepSetup.FromCompany := CompanyName;
        RepSetup."External Database" := false;
        RepSetup.Enabled := true;
        RepSetup.Modify();
    end;

    local procedure CreateReplicationEndpointUOM(var RepEndpoint: Record "NPR Replication Endpoint")
    var
    begin
        RepEndpoint.Init();
        RepEndpoint."Service Code" := RepSetup."API Version";
        RepEndpoint."EndPoint ID" := LibraryUtility.GenerateRandomText(50);
        RepEndpoint."Endpoint Method" := RepEndpoint."Endpoint Method"::"Get BC Generic Data";
        RepEndpoint."Table ID" := Database::"Unit of Measure";
        RepEndpoint.Path := '/navipartner/core/v1.0/companies(%1)/unitsOfMeasure/?$filter=replicationCounter gt %2&$orderby=replicationCounter';
        RepEndpoint."Sequence Order" := 100;
        RepEndpoint."odata.maxpagesize" := 2;
        RepEndpoint."Replication Counter" := 0;
        RepEndpoint.Enabled := TRUE;
        RepEndpoint.Insert();
    end;

}