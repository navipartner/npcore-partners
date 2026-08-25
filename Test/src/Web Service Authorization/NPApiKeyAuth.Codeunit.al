codeunit 85354 "NPR NP API Key Auth Test"
{
    // [FEATURE] NP API Key authorization — enum dispatch, CheckMandatoryValues guard ladder, x-np-api-key
    //           header handling, key rotation / long-key storage, the key-secret hint boundary, and the
    //           remove/enable invariants on the setup table.

    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _SetupCodeLbl: Label 'APIKEYTEST', Locked = true;
        _ApiKeyLbl: Label 'my-secret-api-key-1234', Locked = true;
        _RotatedApiKeyLbl: Label 'rotated-api-key-9999', Locked = true;

    #region Enum dispatch
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EnumDispatch_SetsHeaderViaInterface()
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        IAuth: Interface "NPR API IAuthorization";
        AuthType: Enum "NPR API Auth. Type";
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
        HeaderValues: List of [Text];
    begin
        // [SCENARIO] Dispatching through the enum (as every consumer does via `iAuth := Rec.AuthType`)
        //            resolves to the NP API Key implementation and sets the x-np-api-key header.
        //            This guards the Implementation wiring in APIAuthType.Enum.al.
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, true);
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff(_SetupCodeLbl, AuthParamsBuff);
        RequestMessage.GetHeaders(Headers);

        IAuth := AuthType::"NP API Key";
        IAuth.CheckMandatoryValues(AuthParamsBuff);
        IAuth.SetAuthorizationValue(Headers, AuthParamsBuff);

        Headers.GetValues('x-np-api-key', HeaderValues);
        _Assert.AreEqual(1, HeaderValues.Count(), 'Interface dispatch should set exactly one x-np-api-key header.');
        _Assert.AreEqual(_ApiKeyLbl, HeaderValues.Get(1), 'Interface dispatch should carry the configured key.');
    end;
    #endregion

    #region CheckMandatoryValues error ladder
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckMandatory_BlankSetupCode_Throws()
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NPApiKeyAuth: Codeunit "NPR API NP API Key Auth";
    begin
        // [SCENARIO] A buffer with a blank setup code is rejected before any lookup happens.
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff('', AuthParamsBuff);

        asserterror NPApiKeyAuth.CheckMandatoryValues(AuthParamsBuff);
        _Assert.ExpectedError('Setting ''NPApiKeySetupCode'' is missing.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckMandatory_MissingSetup_Throws()
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NPApiKeyAuth: Codeunit "NPR API NP API Key Auth";
    begin
        // [SCENARIO] A referenced-but-missing setup gives our curated error (not BC's generic record-not-found,
        //            which also contains "does not exist"), so assert the full message including the code.
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff('DOESNOTEXIST', AuthParamsBuff);

        asserterror NPApiKeyAuth.CheckMandatoryValues(AuthParamsBuff);
        _Assert.ExpectedError('The API Key Authorization Setup ''DOESNOTEXIST'' does not exist.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckMandatory_DisabledSetup_Throws()
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NPApiKeyAuth: Codeunit "NPR API NP API Key Auth";
    begin
        // [SCENARIO] A configured but disabled setup cannot authorize outbound calls.
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, false);
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff(_SetupCodeLbl, AuthParamsBuff);

        asserterror NPApiKeyAuth.CheckMandatoryValues(AuthParamsBuff);
        _Assert.ExpectedError('is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckMandatory_EnabledNoKey_Throws()
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NPApiKeyAuth: Codeunit "NPR API NP API Key Auth";
    begin
        // [SCENARIO] An enabled setup with no stored key is rejected on the key rung, and the error names the setup.
        //            Enabled is set directly (bypassing the table's enable-requires-key guard) to reach this state.
        CreateEnabledSetupWithoutKey(_SetupCodeLbl);
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff(_SetupCodeLbl, AuthParamsBuff);

        asserterror NPApiKeyAuth.CheckMandatoryValues(AuthParamsBuff);
        _Assert.ExpectedError('has no API Key configured');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckMandatory_ValidSetup_Passes()
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NPApiKeyAuth: Codeunit "NPR API NP API Key Auth";
    begin
        // [SCENARIO] A configured, enabled setup with a stored key passes validation (no error).
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, true);
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff(_SetupCodeLbl, AuthParamsBuff);

        NPApiKeyAuth.CheckMandatoryValues(AuthParamsBuff);
    end;
    #endregion

    #region x-np-api-key header handling
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetAuthorization_CalledTwice_SingleHeaderWithCurrentKey()
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NPApiKeyAuth: Codeunit "NPR API NP API Key Auth";
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
        HeaderValues: List of [Text];
    begin
        // [SCENARIO] SetAuthorizationValue removes any existing x-np-api-key before adding. Rotating the stored
        //            key between two calls must leave exactly one header carrying the NEW key - this pins the
        //            remove-then-add behavior (an add-if-absent regression would keep the stale first key).
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, true);
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff(_SetupCodeLbl, AuthParamsBuff);
        RequestMessage.GetHeaders(Headers);

        NPApiKeyAuth.SetAuthorizationValue(Headers, AuthParamsBuff); // adds the first key

        NPApiKeySetup.Get(_SetupCodeLbl);
        NPApiKeySetup.SetApiKey(_RotatedApiKeyLbl);
        NPApiKeySetup.Modify();

        NPApiKeyAuth.SetAuthorizationValue(Headers, AuthParamsBuff); // must remove the first key and add the rotated one

        Headers.GetValues('x-np-api-key', HeaderValues);
        _Assert.AreEqual(1, HeaderValues.Count(), 'Repeated calls must not stack duplicate x-np-api-key headers.');
        _Assert.AreEqual(_RotatedApiKeyLbl, HeaderValues.Get(1), 'The x-np-api-key header must carry the current (rotated) key.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetAuthorization_ReturnsStoredKey()
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NPApiKeyAuth: Codeunit "NPR API NP API Key Auth";
    begin
        // [SCENARIO] The authorization value round-trips the stored key (what ends up in the x-np-api-key header).
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, true);
        WebServiceAuthHelper.GetNPApiKeyAuthorizationParamsBuff(_SetupCodeLbl, AuthParamsBuff);

        _Assert.AreEqual(_ApiKeyLbl, NPApiKeyAuth.GetAuthorizationValue(AuthParamsBuff), 'GetAuthorizationValue should return the stored key.');
    end;
    #endregion

    #region Key rotation / long-key storage
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Rotate_LongJwtKey_RoundTripsAndKeepsGuid()
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
        FirstKeyGuid: Guid;
        LongJwtKey: Text;
    begin
        // [SCENARIO] Rotating (the PR's whole purpose) to a >150-char JWT-shaped key round-trips via GetApiKey
        //            and reuses the same "API Key" GUID — guards SetLongApiPassword's GUID reuse (a regression
        //            to always-CreateGuid would orphan the old secret) and the long-value storage path.
        LongJwtKey := MakeLongKey();
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, true); // initial (short) key
        NPApiKeySetup.Get(_SetupCodeLbl);
        FirstKeyGuid := NPApiKeySetup."API Key";

        NPApiKeySetup.SetApiKey(LongJwtKey); // rotate
        NPApiKeySetup.Modify();

        _Assert.AreEqual(LongJwtKey, NPApiKeySetup.GetApiKey(), 'A rotated >150-char key must round-trip intact.');
        _Assert.AreEqual(FirstKeyGuid, NPApiKeySetup."API Key", 'Rotation must reuse the existing API Key GUID, not orphan it.');
    end;
    #endregion

    #region Key secret hint boundary
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BuildHint_ShortKey_MaskOnly()
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        // [SCENARIO] A key shorter than 12 chars reveals nothing — only the mask is stored as the hint.
        CreateSetup(_SetupCodeLbl, '12345678901', false); // 11 chars
        NPApiKeySetup.Get(_SetupCodeLbl);

        _Assert.AreEqual('******', NPApiKeySetup."Key Secret Hint", 'An 11-char key must leave only the mask.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BuildHint_TwelveCharKey_ShowsEnds()
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        // [SCENARIO] 12 chars is the shortest length where revealing first/last 4 still leaves at least 4
        //            characters masked, so both ends are shown.
        CreateSetup(_SetupCodeLbl, '123456789012', false); // 12 chars
        NPApiKeySetup.Get(_SetupCodeLbl);

        _Assert.AreEqual('1234******9012', NPApiKeySetup."Key Secret Hint", 'A 12-char key must reveal the first and last 4 characters.');
    end;
    #endregion

    #region Setup table invariants
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Enable_WithoutKey_Throws()
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        // [SCENARIO] The table forbids enabling a setup that has no stored key.
        if NPApiKeySetup.Get(_SetupCodeLbl) then
            NPApiKeySetup.Delete(true);
        NPApiKeySetup.Init();
        NPApiKeySetup.Code := _SetupCodeLbl;
        NPApiKeySetup.Insert();

        asserterror NPApiKeySetup.Validate(Enabled, true);
        _Assert.ExpectedError('The API Key must be set before enabling this setup.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RemoveApiKey_DisablesAndClearsHint()
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        // [SCENARIO] Removing the key also disables the setup and clears the hint, so no enabled/keyless state persists.
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, true);
        NPApiKeySetup.Get(_SetupCodeLbl);

        NPApiKeySetup.RemoveApiKey();
        NPApiKeySetup.Modify(); // RemoveApiKey mutates Rec in memory only - persist and re-read the row.
        NPApiKeySetup.Get(_SetupCodeLbl);

        _Assert.IsFalse(NPApiKeySetup.HasApiKey(), 'Key should be gone after RemoveApiKey.');
        _Assert.IsFalse(NPApiKeySetup.Enabled, 'Setup should be auto-disabled after the key is removed.');
        _Assert.AreEqual('', NPApiKeySetup."Key Secret Hint", 'Hint should be cleared after the key is removed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetApiKey_Empty_RemovesKey()
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        // [SCENARIO] SetApiKey('') is treated as a removal, so a keyless setup never keeps a hint that claims a key.
        CreateSetup(_SetupCodeLbl, _ApiKeyLbl, true);
        NPApiKeySetup.Get(_SetupCodeLbl);

        NPApiKeySetup.SetApiKey('');
        NPApiKeySetup.Modify(); // SetApiKey mutates Rec in memory only - persist and re-read the row.
        NPApiKeySetup.Get(_SetupCodeLbl);

        _Assert.IsFalse(NPApiKeySetup.HasApiKey(), 'SetApiKey('''') must leave no stored key.');
        _Assert.AreEqual('', NPApiKeySetup."Key Secret Hint", 'SetApiKey('''') must clear the hint.');
        _Assert.IsFalse(NPApiKeySetup.Enabled, 'SetApiKey('''') must not leave an enabled, keyless setup.');
    end;
    #endregion

    local procedure CreateSetup(SetupCode: Code[20]; ApiKeyValue: Text; MakeEnabled: Boolean)
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        if NPApiKeySetup.Get(SetupCode) then
            NPApiKeySetup.Delete(true);

        NPApiKeySetup.Init();
        NPApiKeySetup.Code := SetupCode;
        NPApiKeySetup.Insert();
        if ApiKeyValue <> '' then
            NPApiKeySetup.SetApiKey(ApiKeyValue);
        NPApiKeySetup.Enabled := MakeEnabled;
        NPApiKeySetup.Modify();
    end;

    local procedure CreateEnabledSetupWithoutKey(SetupCode: Code[20])
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        if NPApiKeySetup.Get(SetupCode) then
            NPApiKeySetup.Delete(true);

        NPApiKeySetup.Init();
        NPApiKeySetup.Code := SetupCode;
        NPApiKeySetup.Enabled := true; // direct assignment bypasses the enable-requires-key guard
        NPApiKeySetup.Insert();
    end;

    local procedure MakeLongKey() LongKey: Text
    var
        Builder: TextBuilder;
        i: Integer;
    begin
        // A >150-char, JWT-shaped value to exercise the long-key (unencrypted) storage path.
        Builder.Append('eyJ');
        for i := 1 to 200 do
            Builder.Append('a');
        LongKey := Builder.ToText();
    end;
}
