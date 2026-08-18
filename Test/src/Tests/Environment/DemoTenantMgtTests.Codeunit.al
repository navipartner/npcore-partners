// Pins the MDX (formerly CDX) demo-tenant domain matrix of "NPR Demo Tenant Mgt.".
// Pure string matching: IsMdxEnvironment() does the Azure AD lookup, this covers only the pattern it feeds.
codeunit 85341 "NPR Demo Tenant Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MdxDomain_MicrosoftDemoShapes_Classified()
    var
        DemoTenantMgt: Codeunit "NPR Demo Tenant Mgt.";
    begin
        // [SCENARIO] Every empirically measured MDX tenant shape is recognised as a demo tenant.
        _Assert.IsTrue(DemoTenantMgt.IsMdxTenantDomain('m365x214355.onmicrosoft.com'), 'm365x + 6 digits');
        _Assert.IsTrue(DemoTenantMgt.IsMdxTenantDomain('m365x12345678.onmicrosoft.com'), 'm365x + 8 digits');
        _Assert.IsTrue(DemoTenantMgt.IsMdxTenantDomain('crmbc123456.onmicrosoft.com'), 'crmbc + 6 digits');
        _Assert.IsTrue(DemoTenantMgt.IsMdxTenantDomain('m365b123456.onmicrosoft.com'), 'm365b + 6 digits');
        _Assert.IsTrue(DemoTenantMgt.IsMdxTenantDomain('m365edu123456.onmicrosoft.com'), 'm365edu + 6 digits');
        _Assert.IsTrue(DemoTenantMgt.IsMdxTenantDomain('msdx123456.onmicrosoft.com'), 'msdx + 6 digits');
        _Assert.IsTrue(DemoTenantMgt.IsMdxTenantDomain('M365X214355.OnMicrosoft.Com'), 'classification is case-insensitive');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MdxDomain_CustomerAndNearMissShapes_NotClassified()
    var
        DemoTenantMgt: Codeunit "NPR Demo Tenant Mgt.";
    begin
        // [SCENARIO] Customer tenants, and anything only shaped like a demo tenant, are not - both the exact-length
        // and the all-digits guard are load-bearing.
        _Assert.IsFalse(DemoTenantMgt.IsMdxTenantDomain('contoso.onmicrosoft.com'), 'named customer tenant');
        _Assert.IsFalse(DemoTenantMgt.IsMdxTenantDomain('m365x12345.onmicrosoft.com'), '5 digits is too short');
        _Assert.IsFalse(DemoTenantMgt.IsMdxTenantDomain('m365x1234567.onmicrosoft.com'), '7 digits is neither 6 nor 8');
        _Assert.IsFalse(DemoTenantMgt.IsMdxTenantDomain('m365x12345a.onmicrosoft.com'), 'trailing non-digit');
        _Assert.IsFalse(DemoTenantMgt.IsMdxTenantDomain('m365x12a456.onmicrosoft.com'), 'non-digit inside the number');
        _Assert.IsFalse(DemoTenantMgt.IsMdxTenantDomain('m365x123456.contoso.com'), 'vanity domain, not .onmicrosoft.com');
        _Assert.IsFalse(DemoTenantMgt.IsMdxTenantDomain(''), 'empty domain (e.g. an unset value)');
    end;
}
