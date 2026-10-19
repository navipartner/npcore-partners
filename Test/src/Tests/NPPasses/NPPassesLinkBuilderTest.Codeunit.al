codeunit 85371 "NPR NP Passes LinkBuilder Test"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HappyPath_BuildsSignedLinkInExpectedFormat()
    var
        Facade: Codeunit "NPR NP Passes Facade";
        Link: Text;
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);

        Link := Facade.BuildLandingLink('9e99360037c446e6836a3c933c721e56', FixedCardSystemId());

        _Assert.AreEqual(ExpectedFixedLink('https://np-passes-generator.example.dev'), Link,
            'Link must be {Base URL}/l/{handle}/{serial}?signature={lowercase hex hmac-sha256 of handle/serial}');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TrailingSlashOnBaseUrl_IsNormalised()
    var
        Setup: Record "NPR NP Passes Setup";
        Facade: Codeunit "NPR NP Passes Facade";
        Link: Text;
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        // Bypasses OnValidate so the builder itself must strip the slash
        Setup.Get();
        Setup."Base URL" := 'https://np-passes-generator.example.dev/';
        Setup.Modify();

        Link := Facade.BuildLandingLink('9e99360037c446e6836a3c933c721e56', FixedCardSystemId());

        _Assert.AreEqual(ExpectedFixedLink('https://np-passes-generator.example.dev'), Link,
            'Trailing slash on base URL must be stripped');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledSetup_ReturnsEmptyString()
    var
        Facade: Codeunit "NPR NP Passes Facade";
        Link: Text;
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);

        Link := Facade.BuildLandingLink('9e99360037c446e6836a3c933c721e56', CreateGuid());

        _Assert.AreEqual('', Link, 'Link should be empty when setup is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WithoutSigningSecret_NoLinkIsBuilt()
    var
        Setup: Record "NPR NP Passes Setup";
        Facade: Codeunit "NPR NP Passes Facade";
        Link: Text;
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.DeleteSigningSecret();
        Setup.Enabled := true; // bypasses the validate on purpose: the runtime guard must hold on its own
        Setup.Modify();

        Link := Facade.BuildLandingLink('9e99360037c446e6836a3c933c721e56', CreateGuid());

        _Assert.IsFalse(Setup.HasSigningSecret(), 'Deleting the secret must leave no secret behind');
        _Assert.AreEqual('', Link, 'Links are always signed, so without a secret none is built');
        _Assert.IsTrue(Facade.IsConfigured(), 'Routing still points at NP Passes; the missing secret must fail the link, not fall back to legacy');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteSecretWhileEnabled_IsRejected()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', true);
        Setup.Get();

        asserterror Setup.DeleteSigningSecret();

        // No assert on the stored secret: the error rolls the transaction back, which also wipes the Isolated Storage write from Arrange.
        _Assert.ExpectedError(Setup.FieldCaption("Signing Secret Key"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EnableWithoutBaseUrl_IsRejected()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('', false);
        Setup.Get();

        asserterror Setup.Validate(Enabled, true);

        _Assert.ExpectedError(Setup.FieldCaption("Base URL"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EnableWithoutSigningSecret_IsRejected()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.DeleteSigningSecret();
        Setup.Modify();

        asserterror Setup.Validate(Enabled, true);

        _Assert.ExpectedError(Setup.FieldCaption("Signing Secret Key"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DesignListURL_ProdUrl_Accepted()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.Validate("Design List URL", 'https://bc-designer-api.npretail.app');
        Setup.Modify();

        _Assert.AreEqual('https://bc-designer-api.npretail.app', Setup."Design List URL", 'Production URL must be accepted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DesignListURL_PreliveUrl_Accepted()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.Validate("Design List URL", 'https://bc-designer-api.npretail-prelive.app');
        Setup.Modify();

        _Assert.AreEqual('https://bc-designer-api.npretail-prelive.app', Setup."Design List URL", 'Prelive URL must be accepted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DesignListURL_InvalidUrl_Rejected()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();

        asserterror Setup.Validate("Design List URL", 'https://evil.example.com');

        _Assert.ExpectedError(Setup.FieldCaption("Design List URL"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DesignListURL_TrailingSlash_StrippedBeforeValidation()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.Validate("Design List URL", 'https://bc-designer-api.npretail.app/');

        _Assert.AreEqual('https://bc-designer-api.npretail.app', Setup."Design List URL", 'Trailing slash must be stripped');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DesignListURL_Empty_ClearsField()
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.Validate("Design List URL", 'https://bc-designer-api.npretail.app');
        Setup.Modify();

        Setup.Validate("Design List URL", '');

        _Assert.AreEqual('', Setup."Design List URL", 'Clearing the field must be allowed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DesignLookup_WithoutSigningSecret_IsRejected()
    var
        Setup: Record "NPR NP Passes Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipCode: Code[20];
    begin
        ConfigureSetup('https://np-passes-generator.example.dev', false);
        Setup.Get();
        Setup.Enabled := false;
        Setup.DeleteSigningSecret();
        Setup.Modify();

        MembershipCode := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(MembershipCode));
        MembershipSetup.Init();
        MembershipSetup.Code := MembershipCode;
        MembershipSetup."NP Passes Layout Label" := 'Test Design';
        MembershipSetup.Insert();

        asserterror MembershipSetup.Validate("NP Passes Layout Label", 'Test Design');

        _Assert.ExpectedError(Setup.FieldCaption("Signing Secret Key"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DesignValidate_ClearLabel_ClearsHandle()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipCode: Code[20];
    begin
        MembershipCode := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(MembershipCode));
        MembershipSetup.Init();
        MembershipSetup.Code := MembershipCode;
        MembershipSetup."NP Passes Layout Handle" := '9e99360037c446e6836a3c933c721e56';
        MembershipSetup."NP Passes Layout Label" := 'Some Design';
        MembershipSetup.Insert();

        MembershipSetup.Validate("NP Passes Layout Label", '');

        _Assert.AreEqual('', MembershipSetup."NP Passes Layout Handle", 'Clearing the label must also clear the handle');
    end;

    local procedure ConfigureSetup(BaseUrl: Text[250]; Enabled: Boolean)
    var
        Setup: Record "NPR NP Passes Setup";
    begin
        if (not Setup.Get()) then begin
            Setup.Init();
            Setup.Insert();
        end;
        if (BaseUrl <> '') then
            Setup.Validate("Base URL", BaseUrl)
        else
            Setup."Base URL" := '';
        Setup.Enabled := Enabled;
        Setup.SetSigningSecret(SecretStrSubstNo(TestSecret()));
        Setup.Modify();
    end;

    local procedure FixedCardSystemId() Id: Guid
    begin
        Evaluate(Id, '{12345678-90AB-CDEF-1234-567890ABCDEF}');
    end;

    // Known-answer vector, computed outside BC:
    //   printf '%s' '9e99360037c446e6836a3c933c721e56/1234567890abcdef1234567890abcdef' | openssl dgst -sha256 -hmac 'test-secret-do-not-use'
    // The same vector is documented in np-passes (shared-files/link-signature.ts) for its verifier.
    local procedure ExpectedFixedLink(BaseUrl: Text): Text
    begin
        exit(BaseUrl + '/l/9e99360037c446e6836a3c933c721e56/1234567890abcdef1234567890abcdef?signature=db2be04dd58861009adf92c7df7cdea88bd1d20eaf3364d52657ac4e3a6d155a');
    end;

    local procedure TestSecret(): Text
    begin
        exit('test-secret-do-not-use');
    end;

}
