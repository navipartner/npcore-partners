codeunit 85145 "NPR NationalIdentifierTests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        SE_NationalIdentifier: Codeunit "NPR NationalIdentifier_SE";
        DK_NationalIdentifier: Codeunit "NPR NationalIdentifier_DK";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SE_PNR()
    var
        Canonical: Text[30];
        ErrorMessage: Text;
    begin
        AssertOk(SE_PNR('19670608-1376', Canonical, ErrorMessage), Canonical, ErrorMessage, '196706081376', 'PNR valid: ' + ErrorMessage);
        AssertOk(SE_PNR('196706081376', Canonical, ErrorMessage), Canonical, ErrorMessage, '196706081376', 'PNR valid no dash: ' + ErrorMessage);
        AssertOk(SE_PNR(' 19670608-1376 ', Canonical, ErrorMessage), Canonical, ErrorMessage, '196706081376', 'PNR valid with spaces: ' + ErrorMessage);

        AssertFail(SE_PNR('19670608-137', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid length', 'PNR length');
        AssertFail(SE_PNR('19670608+1376', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid separator', 'PNR separator');
        AssertFail(SE_PNR('1967A608-1376', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid characters', 'PNR chars');
        AssertFail(SE_PNR('19670608-1377', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid check digit', 'PNR checksum');
        AssertFail(SE_PNR('19670231-1376', Canonical, ErrorMessage), Canonical, ErrorMessage, '', 'PNR invalid date (DMY2Date)'); // message varies by locale/runtime
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SE_CNR()
    var
        Canonical: Text[30];
        ErrorMessage: Text;
    begin
        AssertOk(SE_CNR('19670668-1373', Canonical, ErrorMessage), Canonical, ErrorMessage, '196706681373', 'CNR valid: ' + ErrorMessage);
        AssertOk(SE_CNR('196706681373', Canonical, ErrorMessage), Canonical, ErrorMessage, '196706681373', 'CNR valid: ' + ErrorMessage);

        AssertFail(SE_CNR('19670608-1376', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid day', 'CNR day must be 61+');
        AssertFail(SE_CNR('19670668+1373', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid separator', 'CNR separator');
        AssertFail(SE_CNR('19670668-1374', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid check digit', 'CNR checksum');
        AssertFail(SE_CNR('19671368-1373', Canonical, ErrorMessage), Canonical, ErrorMessage, '', 'CNR invalid date after day-60'); // message varies
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SE_ONR()
    var
        Canonical: Text[30];
        ErrorMessage: Text;
    begin
        AssertOk(SE_ONR('556703-7485', Canonical, ErrorMessage), Canonical, ErrorMessage, '5567037485', 'ONR valid 1: ' + ErrorMessage);
        AssertOk(SE_ONR('5567037485', Canonical, ErrorMessage), Canonical, ErrorMessage, '5567037485', 'ONR valid 1: ' + ErrorMessage);

        AssertOk(SE_ONR('212000-1355', Canonical, ErrorMessage), Canonical, ErrorMessage, '2120001355', 'ONR valid 2: ' + ErrorMessage);

        AssertFail(SE_ONR('556703-748', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid length', 'ONR length');
        AssertFail(SE_ONR('556703+7485', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid separator', 'ONR separator');
        AssertFail(SE_ONR('55A703-7485', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid characters', 'ONR chars');
        AssertFail(SE_ONR('556703-7486', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid check digit', 'ONR checksum');
        AssertFail(SE_ONR('550101-1234', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid month number', 'ONR month must be 20+');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SE_VAT()
    var
        Canonical: Text[30];
        ErrorMessage: Text;
    begin
        AssertOk(SE_VAT('SE556703748501', Canonical, ErrorMessage), Canonical, ErrorMessage, 'SE556703748501', 'VAT valid: ' + ErrorMessage);

        AssertFail(SE_VAT('SE5567037485', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid SE VAT number length', 'VAT length');
        AssertFail(SE_VAT('DK556703748501', Canonical, ErrorMessage), Canonical, ErrorMessage, 'SE VAT number must start with SE', 'VAT prefix');
        AssertFail(SE_VAT('SE556703748601', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid check digit', 'VAT underlying ONR checksum');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DK_CPR()
    var
        Canonical: Text[30];
        ErrorMessage: Text;
    begin
        AssertOk(DK_CPR_Mod11Check('111111-1118', Canonical, ErrorMessage), Canonical, ErrorMessage, '1111111118', 'CPR valid 1: ' + ErrorMessage);
        AssertOk(DK_CPR_Mod11Check('1111111118', Canonical, ErrorMessage), Canonical, ErrorMessage, '1111111118', 'CPR valid 1 no dash: ' + ErrorMessage);

        AssertFail(DK_CPR_Mod11Check('111111-111', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid CPR length', 'CPR length');
        AssertFail(DK_CPR_Mod11Check('111111+1118', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid separator', 'CPR separator');
        AssertFail(DK_CPR_Mod11Check('11111A-1118', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid characters', 'CPR chars');
        AssertFail(DK_CPR_Mod11Check('111111-1119', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid CPR modulus-11 checksum', 'CPR checksum');

        // Tests without Mod11 check (for post-2007 CPRs)
        AssertOk(DK_CPR('111111-1118', Canonical, ErrorMessage), Canonical, ErrorMessage, '1111111118', 'CPR valid 3: ' + ErrorMessage);
        AssertOk(DK_CPR('1111111118', Canonical, ErrorMessage), Canonical, ErrorMessage, '1111111118', 'CPR valid 3 no dash: ' + ErrorMessage);
        AssertOk(DK_CPR('111111-1119', Canonical, ErrorMessage), Canonical, ErrorMessage, '1111111119', 'CPR valid 4: ' + ErrorMessage);
        AssertOk(DK_CPR('1111111119', Canonical, ErrorMessage), Canonical, ErrorMessage, '1111111119', 'CPR valid 4 no dash: ' + ErrorMessage);

        AssertFail(DK_CPR('111111-111', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid CPR length', 'CPR length');
        AssertFail(DK_CPR('111111+1118', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid separator', 'CPR separator');
        AssertFail(DK_CPR('11111A-1118', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid characters', 'CPR chars');

        AssertFail(DK_CPR('411111-1119', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid date', 'CPR invalid date');
        AssertFail(DK_CPR('111511-1119', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid date', 'CPR invalid date');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DK_CVR()
    var
        Canonical: Text[30];
        ErrorMessage: Text;
    begin
        AssertOk(DK_CVR('21382191', Canonical, ErrorMessage), Canonical, ErrorMessage, '21382191', 'CVR valid: ' + ErrorMessage);

        AssertFail(DK_CVR('2138219', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid CVR length', 'CVR length');
        AssertFail(DK_CVR('21382A91', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid characters', 'CVR chars');
        AssertFail(DK_CVR('21382192', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid CVR check digit', 'CVR checksum');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DK_VAT()
    var
        Canonical: Text[30];
        ErrorMessage: Text;
    begin
        AssertOk(DK_VAT('DK21382191', Canonical, ErrorMessage), Canonical, ErrorMessage, 'DK21382191', 'DK VAT valid: ' + ErrorMessage);

        AssertFail(DK_VAT('21382191', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid DK VAT number format', 'DK VAT prefix');
        AssertFail(DK_VAT('DK2138219', Canonical, ErrorMessage), Canonical, ErrorMessage, 'Invalid CVR length', 'DK VAT underlying CVR length');
    end;

    local procedure AssertOk(Ok: Boolean; Canonical: Text[30]; Err: Text; ExpectedCanonical: Text; Msg: Text)
    begin
        Assert.IsTrue(Ok, Msg);
        Assert.AreEqual('', Err, Msg + ' (expected empty error)');
        Assert.AreEqual(ExpectedCanonical, Canonical, Msg + ' (canonical mismatch)');
    end;

    local procedure AssertFail(Ok: Boolean; Canonical: Text[30]; Err: Text; ExpectedErrContains: Text; Msg: Text)
    begin
        Assert.IsFalse(Ok, Msg);
        Assert.AreEqual('', Canonical, Msg + ' (canonical must be cleared)');
        Assert.IsTrue(Err <> '', Msg + ' (expected error message)');
        if (ExpectedErrContains <> '') then
            Assert.IsTrue(StrPos(Err, ExpectedErrContains) > 0, Msg + ' (unexpected error: ' + Err + ')');
    end;

    local procedure SE_PNR(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(SE_NationalIdentifier.TryParse_PNR(Input, Canonical, Err));
    end;

    local procedure SE_CNR(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(SE_NationalIdentifier.TryParse_CNR(Input, Canonical, Err));
    end;

    local procedure SE_ONR(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(SE_NationalIdentifier.TryParse_ONR(Input, Canonical, Err));
    end;

    local procedure SE_VAT(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(SE_NationalIdentifier.TryParse_VAT(Input, Canonical, Err));
    end;

    local procedure DK_CPR_Mod11Check(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(DK_NationalIdentifier.TryParse_CPR(Input, Canonical, true, Err));
    end;

    local procedure DK_CPR(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(DK_NationalIdentifier.TryParse_CPR(Input, Canonical, false, Err));
    end;

    local procedure DK_CVR(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(DK_NationalIdentifier.TryParse_CVR(Input, Canonical, Err));
    end;

    local procedure DK_VAT(Input: Text; var Canonical: Text[30]; var Err: Text): Boolean
    begin
        exit(DK_NationalIdentifier.TryParse_VAT(Input, Canonical, Err));
    end;
}
