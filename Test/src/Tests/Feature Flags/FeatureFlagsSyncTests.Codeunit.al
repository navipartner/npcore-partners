codeunit 85569 "NPR Feature Flags Sync Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _ChangedFlagTok: Label 'NPRTestSyncChangedFlag', Locked = true;
        _RemovedFlagTok: Label 'NPRTestSyncRemovedFlag', Locked = true;
        _NewFlagTok: Label 'NPRTestSyncNewFlag', Locked = true;
        _NotValidJsonErr: Label 'The ConfigCat response is not valid JSON. This is a programming bug.', Locked = true;
        _NoFeatureFlagsErr: Label 'The ConfigCat response contains no feature flags. This is a programming bug.', Locked = true;
        _NotFlagObjectErr: Label 'The ConfigCat response entry ''%1'' is not a feature flag object. This is a programming bug.', Locked = true, Comment = '%1 = feature flag name';
        _ResponseBody: Text;

    [Test]
    [HandlerFunctions('ReturnEvalAllResponse')]
    procedure Sync_AppliesConfigCatChangesToStoredFlags()
    var
        FeatureFlag: Record "NPR Feature Flag";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        GetFeatureFlagsJQ: Codeunit "NPR Get Feature Flags JQ";
        ResponseJson: JsonObject;
    begin
        // [Scenario] A sync applies every ConfigCat change: a switched-off flag, a removed flag and a new flag
        Initialize();

        // [Given] Two flags are stored as on
        InsertFeatureFlag(_ChangedFlagTok, 'var-on');
        InsertFeatureFlag(_RemovedFlagTok, 'var-on');

        // [Given] ConfigCat returns the first flag as off, leaves out the second and adds a new one
        AddFlagToResponse(ResponseJson, _ChangedFlagTok, false, 'var-off');
        AddFlagToResponse(ResponseJson, _NewFlagTok, true, 'var-new');
        ResponseJson.WriteTo(_ResponseBody);

        // [When] The sync job runs
        GetFeatureFlagsJQ.Run();

        // [Then] The switched-off flag is off and has the new variation
        _Assert.IsTrue(FeatureFlag.Get(_ChangedFlagTok), 'A flag that ConfigCat still returns must stay stored.');
        _Assert.IsFalse(FeatureFlagsManagement.IsEnabled(_ChangedFlagTok), 'A flag switched off in ConfigCat must be off after the sync.');
        _Assert.AreEqual('var-off', FeatureFlag."Variation ID", 'The sync must store the variation ConfigCat returned.');

        // [Then] The flag ConfigCat no longer returns is deleted
        _Assert.IsFalse(FeatureFlag.Get(_RemovedFlagTok), 'A flag removed from ConfigCat must be deleted by the sync.');

        // [Then] The new flag is stored as on
        _Assert.IsTrue(FeatureFlag.Get(_NewFlagTok), 'A flag added in ConfigCat must be stored by the sync.');
        _Assert.IsTrue(FeatureFlagsManagement.IsEnabled(_NewFlagTok), 'A new flag that is on in ConfigCat must be on after the sync.');
        _Assert.AreEqual('var-new', FeatureFlag."Variation ID", 'The sync must store the variation of a new flag.');
    end;

    [Test]
    [HandlerFunctions('ReturnEvalAllResponse')]
    procedure Sync_FailsWhenResponseIsNotJson()
    var
        GetFeatureFlagsJQ: Codeunit "NPR Get Feature Flags JQ";
    begin
        // [Scenario] A response that cannot be read makes the sync fail instead of finishing as a success
        Initialize();

        // [Given] ConfigCat returns a body that is not JSON
        _ResponseBody := 'not json';

        // [When] The sync job runs
        asserterror GetFeatureFlagsJQ.Run();

        // [Then] The job fails with the not-valid-JSON error
        _Assert.ExpectedError(_NotValidJsonErr);
    end;

    [Test]
    [HandlerFunctions('ReturnEvalAllResponse')]
    procedure Sync_FailsWhenResponseHasNoFlags()
    var
        GetFeatureFlagsJQ: Codeunit "NPR Get Feature Flags JQ";
    begin
        // [Scenario] A valid response without any flags makes the sync fail instead of finishing as a success
        Initialize();

        // [Given] ConfigCat returns an empty JSON object
        _ResponseBody := '{}';

        // [When] The sync job runs
        asserterror GetFeatureFlagsJQ.Run();

        // [Then] The job fails with the no-flags error
        _Assert.ExpectedError(_NoFeatureFlagsErr);
    end;

    [Test]
    [HandlerFunctions('ReturnEvalAllResponse')]
    procedure Sync_FailsWhenEntryIsNotFlagObject()
    var
        FeatureFlag: Record "NPR Feature Flag";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        GetFeatureFlagsJQ: Codeunit "NPR Get Feature Flags JQ";
        ResponseJson: JsonObject;
    begin
        // [Scenario] An entry that is not a flag object makes the sync fail and leaves every stored flag untouched
        Initialize();

        // [Given] A flag is stored as on
        InsertFeatureFlag(_ChangedFlagTok, 'var-on');
        Commit();

        // [Given] ConfigCat returns one proper flag and one bare value instead of a flag object for the stored flag
        AddFlagToResponse(ResponseJson, _NewFlagTok, true, 'var-new');
        ResponseJson.Add(_ChangedFlagTok, true);
        ResponseJson.WriteTo(_ResponseBody);

        // [When] The sync job runs
        asserterror GetFeatureFlagsJQ.Run();

        // [Then] The job fails naming the entry, and the stored flag is still on
        _Assert.ExpectedError(StrSubstNo(_NotFlagObjectErr, _ChangedFlagTok));
        _Assert.IsTrue(FeatureFlag.Get(_ChangedFlagTok), 'A failed sync must not delete a stored flag.');
        _Assert.IsTrue(FeatureFlagsManagement.IsEnabled(_ChangedFlagTok), 'A failed sync must not switch a stored flag off.');
        _Assert.IsFalse(FeatureFlag.Get(_NewFlagTok), 'A failed sync must not store any flag.');
    end;

    [HttpClientHandler]
    procedure ReturnEvalAllResponse(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        Response.Content.WriteFrom(_ResponseBody);
        Response.HttpStatusCode := 200;
        Response.ReasonPhrase := 'OK';
        exit(false);
    end;

    local procedure Initialize()
    var
        FeatureFlag: Record "NPR Feature Flag";
        FeatureFlagsSetup: Record "NPR Feature Flags Setup";
    begin
        _ResponseBody := '';

        if not FeatureFlagsSetup.Get() then begin
            FeatureFlagsSetup.Init();
            FeatureFlagsSetup.Insert();
        end;
        if IsNullGuid(FeatureFlagsSetup.Identifier) then begin
            FeatureFlagsSetup.Identifier := CreateGuid();
            FeatureFlagsSetup.Modify();
        end;

        FeatureFlag.SetFilter(Name, '%1|%2|%3', _ChangedFlagTok, _RemovedFlagTok, _NewFlagTok);
        FeatureFlag.DeleteAll();
    end;

    local procedure InsertFeatureFlag(FeatureFlagName: Text[50]; VariationID: Text[50])
    var
        FeatureFlag: Record "NPR Feature Flag";
    begin
        FeatureFlag.Init();
        FeatureFlag.Name := FeatureFlagName;
        FeatureFlag.Value := Format(true);
        FeatureFlag."Variation ID" := VariationID;
        FeatureFlag.Insert();
    end;

    local procedure AddFlagToResponse(var ResponseJson: JsonObject; FeatureFlagName: Text; Value: Boolean; VariationID: Text)
    var
        FlagJson: JsonObject;
    begin
        FlagJson.Add('value', Value);
        FlagJson.Add('variationId', VariationID);
        ResponseJson.Add(FeatureFlagName, FlagJson);
    end;
}
