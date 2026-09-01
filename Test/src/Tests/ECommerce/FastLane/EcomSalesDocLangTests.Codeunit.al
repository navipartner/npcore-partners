#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85391 "NPR Ecom Sales Doc Lang Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EmptyTag_ReturnsBlank()
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        LanguageCode: Code[10];
    begin
        // [SCENARIO] A blank language tag resolves to a blank language code and never errors.

        // [GIVEN] A clean set of synthetic Language rows
        Initialize();

        // [WHEN] A blank language tag is resolved
        LanguageCode := EcomSalesDocUtils.LanguageTagToLanguageCode('');

        // [THEN] The result is blank
        _Assert.AreEqual('', LanguageCode, 'A blank language tag must resolve to a blank language code.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnknownWellFormedTag_ValidateLanguageTagRaisesError()
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [SCENARIO] The gate that actually rejects an unusable tag. The Ecom API calls this before creating
        // the document (EcomSalesDocApiAgentV2), so the request is refused up front.

        // [GIVEN] A clean set of synthetic Language rows
        Initialize();

        // [WHEN] A well-formed but unknown tag passes through the gate
        asserterror EcomSalesDocUtils.ValidateLanguageTag('zz-ZZ');

        // [THEN] It is rejected. Only the standard identifier is pinned: the surrounding words come from a
        // translatable Label and would break this test in a non-ENU run or on any wording tweak.
        _Assert.ExpectedError('RFC 5646');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlankTag_ValidateLanguageTagDoesNotRaiseError()
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [SCENARIO] A blank language tag is legitimate - it means the caller supplied no language - so the
        // pre-import gate must let it through. This pins that the error above is scoped to unusable tags and
        // does not turn "no language supplied" into a rejected order.

        // [GIVEN] A clean set of synthetic Language rows
        Initialize();

        // [WHEN] A blank tag passes through the gate
        // [THEN] It is accepted - any error raised here fails the test
        EcomSalesDocUtils.ValidateLanguageTag('');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AbbreviatedNameWins_OverWindowsLanguageIdMatch()
    var
        WindowsLanguage: Record "Windows Language";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        AbbreviatedLanguageCode: Code[10];
        LanguageCode: Code[10];
    begin
        // [SCENARIO] A Language whose Code equals the Windows abbreviated name wins over a
        // Language that merely carries the same Windows Language ID, even when that other code sorts first.
        // The old implementation returned 'AAA' here, so this test discriminates old behavior from new.

        // [GIVEN] The Windows language for 'sv-SE' and its abbreviated name
        Initialize();
        ResolveWindowsLanguage('sv-SE', WindowsLanguage);
        AbbreviatedLanguageCode := WindowsLanguage."Abbreviated Name";
        _Assert.AreNotEqual('', AbbreviatedLanguageCode, 'Precondition: the Windows language must have an abbreviated name.');

        // [GIVEN] Two competing Languages: 'AAA' on the tag's Windows Language ID, and one named after the
        // abbreviation that carries no Windows Language ID at all
        PurgeResolvableLanguages(WindowsLanguage);
        ForceLanguage('AAA', WindowsLanguage."Language ID");
        ForceLanguage(AbbreviatedLanguageCode, 0);

        // [WHEN] The tag is resolved
        LanguageCode := EcomSalesDocUtils.LanguageTagToLanguageCode('sv-SE');

        // [THEN] The abbreviation match wins, even though 'AAA' sorts first
        _Assert.AreEqual(AbbreviatedLanguageCode, LanguageCode, 'The Language matching the Windows abbreviated name must win.');
        _Assert.AreNotEqual('AAA', LanguageCode, 'The Windows Language ID match must not win over the abbreviated name match.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WindowsLanguageIdMatch_WhenNoAbbreviatedNameRow()
    var
        WindowsLanguage: Record "Windows Language";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [SCENARIO] Regression guard (the old implementation also passed this): with no Language
        // named after the abbreviation, the Language carrying the tag's Windows Language ID is returned.

        // [GIVEN] The Windows language for 'sv-SE', with no Language named after its abbreviation
        Initialize();
        ResolveWindowsLanguage('sv-SE', WindowsLanguage);
        PurgeResolvableLanguages(WindowsLanguage);

        // [GIVEN] A single Language carrying the tag's Windows Language ID
        ForceLanguage('ZZ1', WindowsLanguage."Language ID");

        // [WHEN] The tag is resolved
        // [THEN] That Language is returned
        _Assert.AreEqual('ZZ1', EcomSalesDocUtils.LanguageTagToLanguageCode('sv-SE'), 'The Language carrying the tag''s Windows Language ID must be returned.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SameWindowsLanguageId_LowestCodeWins()
    var
        WindowsLanguage: Record "Windows Language";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [SCENARIO] When several Languages carry the same Windows Language ID,
        // FindFirst on the clustered Code key makes the lowest Code win. This pins that documented order.

        // [GIVEN] The Windows language for 'sv-SE', with no Language named after its abbreviation
        Initialize();
        ResolveWindowsLanguage('sv-SE', WindowsLanguage);
        PurgeResolvableLanguages(WindowsLanguage);

        // [GIVEN] Two Languages sharing that Windows Language ID
        ForceLanguage('AAA', WindowsLanguage."Language ID");
        ForceLanguage('ZZZ', WindowsLanguage."Language ID");

        // [WHEN] The tag is resolved
        // [THEN] The lowest Code wins
        _Assert.AreEqual('AAA', EcomSalesDocUtils.LanguageTagToLanguageCode('sv-SE'), 'The lowest Code must win when several Languages share the Windows Language ID.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NoMatchAnywhere_FallsBackToWindowsAbbreviation()
    var
        Language: Record Language;
        WindowsLanguage: Record "Windows Language";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        AbbreviatedLanguageCode: Code[10];
        LanguageCode: Code[10];
    begin
        // [SCENARIO] With no Language reachable through any lookup step, the resolver returns the raw Windows
        // abbreviated name rather than erroring, so the document still imports.

        // [GIVEN] The Windows language for 'af-ZA' and its abbreviated name
        Initialize();
        ResolveWindowsLanguage('af-ZA', WindowsLanguage);
        AbbreviatedLanguageCode := WindowsLanguage."Abbreviated Name";
        _Assert.AreNotEqual('', AbbreviatedLanguageCode, 'Precondition: the Windows language must have an abbreviated name.');

        // [GIVEN] No Language reachable by either lookup
        PurgeResolvableLanguages(WindowsLanguage);

        // [WHEN] The tag is resolved
        LanguageCode := EcomSalesDocUtils.LanguageTagToLanguageCode('af-ZA');

        // [THEN] The raw Windows abbreviated name is returned
        _Assert.AreEqual(AbbreviatedLanguageCode, LanguageCode, 'The Windows abbreviated name must be returned when nothing matches.');

        // [THEN] ...and it is not a usable language code. This documents the consequence of the fallback
        // rather than endorsing it: "Language Code" carries TableRelation = Language.Code, so the value fails
        // validation later (EcomSalesDocUtils.ValidateLanguage / EcomSalesDocImplV2 sales header transfer).
        // If the fallback is ever replaced by an intake-time error, this assertion is the one to revisit.
        _Assert.IsFalse(Language.Get(LanguageCode), 'The abbreviated-name fallback returns a code with no Language record.');
    end;

    local procedure Initialize()
    var
        Language: Record Language;
    begin
        // The test runner rolls back per test codeunit, not per test method, so the synthetic Language rows
        // created by one test survive into the next and would make this suite order-dependent. Removing them
        // up front gives every test a deterministic starting state.
        Language.SetFilter(Code, '%1|%2|%3', 'AAA', 'ZZZ', 'ZZ1');
        Language.DeleteAll();
    end;

    local procedure ResolveWindowsLanguage(LanguageTag: Text; var WindowsLanguage: Record "Windows Language")
    var
        Language: Codeunit Language;
        LanguageId: Integer;
    begin
        LanguageId := Language.GetLanguageIdFromCultureName(LanguageTag);
        _Assert.AreNotEqual(0, LanguageId, StrSubstNo('Precondition: the language tag ''%1'' must resolve to a Windows language id.', LanguageTag));
        _Assert.IsTrue(WindowsLanguage.Get(LanguageId), StrSubstNo('Precondition: the language tag ''%1'' must exist in the Windows Language table.', LanguageTag));
    end;

    local procedure PurgeResolvableLanguages(WindowsLanguage: Record "Windows Language")
    var
        Language: Record Language;
    begin
        if Language.Get(WindowsLanguage."Abbreviated Name") then
            Language.Delete();

        Language.Reset();
        Language.SetRange("Windows Language ID", WindowsLanguage."Language ID");
        Language.DeleteAll();

        // The primary language id is deliberately NOT purged: the resolver does not consult it, so a real
        // Language sitting there cannot be found, and leaving it alone destroys one base-app row fewer.
        AssertResolvableLanguagesPurged(WindowsLanguage);
    end;

    local procedure AssertResolvableLanguagesPurged(WindowsLanguage: Record "Windows Language")
    var
        Language: Record Language;
    begin
        _Assert.IsFalse(Language.Get(WindowsLanguage."Abbreviated Name"), StrSubstNo('Arrangement: the Language ''%1'' must have been deleted.', WindowsLanguage."Abbreviated Name"));

        Language.Reset();
        Language.SetRange("Windows Language ID", WindowsLanguage."Language ID");
        _Assert.IsTrue(Language.IsEmpty(), StrSubstNo('Arrangement: no Language may be left on Windows language id %1.', WindowsLanguage."Language ID"));
    end;

    local procedure ForceLanguage(LanguageCodeParam: Code[10]; WindowsLanguageId: Integer)
    var
        Language: Record Language;
    begin
        if Language.Get(LanguageCodeParam) then begin
            Language."Windows Language ID" := WindowsLanguageId;
            Language.Modify();
        end else begin
            Language.Init();
            Language.Code := LanguageCodeParam;
            Language."Windows Language ID" := WindowsLanguageId;
            Language.Insert();
        end;
    end;
}
#endif
