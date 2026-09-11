#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85442 "NPR APICompany Get"
{
    // [FEATURE] GET /company — returns the company name plus its ISO currency & country (null when unconfigured)

    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCompany_ReturnsDocumentedShape()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
    begin
        // [SCENARIO] GET /company returns 200 with the company name, currency and country properties.
        // Pins the 'NPR API Company' permission-set literal in the resolver and the company enum-value-to-path
        // coupling in APIModule.Enum.al - a rename of either would turn this route into a 403 or 404.

        // [GIVEN] The caller has the NPR API Company permission set assigned
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Company');
        SelectLatestVersion();

        // [WHEN] The company endpoint is called
        Response := LibraryNPRetailAPI.CallApi('GET', '/company', Body, QueryParams, Headers);

        // [THEN] The response is successful
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /company should succeed');

        // [THEN] The response body exposes the documented shape { name, currencyCode, countryCode }
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(Body.Get('name', JToken), 'Response should contain a name property');
        Assert.IsTrue(Body.Get('currencyCode', JToken), 'Response should contain a currencyCode property');
        Assert.IsTrue(Body.Get('countryCode', JToken), 'Response should contain a countryCode property');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCompany_Unconfigured_ReturnsJsonNull()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        OrigLCYCode: Code[10];
        OrigCountryCode: Code[10];
    begin
        // [SCENARIO] With no local currency and no country configured, GET /company returns those
        // properties as JSON null - present, not omitted and not an empty string - so a consumer can
        // distinguish "not configured" from a real value. This is the contract the endpoint exists for.

        // [GIVEN] The caller has the NPR API Company permission set assigned
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Company');

        // [GIVEN] The company's local currency and country are blank (direct assign to skip OnValidate)
        GeneralLedgerSetup.Get();
        OrigLCYCode := GeneralLedgerSetup."LCY Code";
        GeneralLedgerSetup."LCY Code" := '';
        GeneralLedgerSetup.Modify();
        CompanyInformation.Get();
        OrigCountryCode := CompanyInformation."Country/Region Code";
        CompanyInformation."Country/Region Code" := '';
        CompanyInformation.Modify();
        SelectLatestVersion();

        // [WHEN] The company endpoint is called
        Response := LibraryNPRetailAPI.CallApi('GET', '/company', Body, QueryParams, Headers);
        Body := LibraryNPRetailAPI.GetResponseBody(Response);

        // Restore the setup before asserting, so a failed assertion can't leave the company blanked
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."LCY Code" := OrigLCYCode;
        GeneralLedgerSetup.Modify();
        CompanyInformation.Get();
        CompanyInformation."Country/Region Code" := OrigCountryCode;
        CompanyInformation.Modify();

        // [THEN] The call still succeeds (a blank value is not an error condition here)
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /company should succeed');

        // [THEN] currencyCode is present and JSON null
        Assert.IsTrue(Body.Get('currencyCode', JToken), 'currencyCode should be present');
        Assert.IsTrue(JToken.IsValue() and JToken.AsValue().IsNull(), 'currencyCode should be JSON null when no local currency is configured');

        // [THEN] countryCode is present and JSON null
        Assert.IsTrue(Body.Get('countryCode', JToken), 'countryCode should be present');
        Assert.IsTrue(JToken.IsValue() and JToken.AsValue().IsNull(), 'countryCode should be JSON null when no country is configured');
    end;
}
#endif
