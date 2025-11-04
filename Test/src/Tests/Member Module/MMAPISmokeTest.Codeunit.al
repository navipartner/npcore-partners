codeunit 85016 "NPR MM API Smoke Test"
{
    Subtype = Test;

    var
        _LastMembership: Record "NPR MM Membership";
        _LastMember: Record "NPR MM Member";

        _LastMemberCard: Record "NPR MM Member Card";
        _IsInitialized: Boolean;
        _AddMemberWithFirstName: Text[50];

    local procedure Initialize()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
    begin
        if (_IsInitialized) then
            exit;

        MemberLibrary.Initialize();
        _IsInitialized := true;

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberItem: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        MembershipEntryNo: Integer;
        MembershipCode: Code[20];
        LoyaltyProgramCode: Code[20];
        Description: Text[50];
    begin

        Initialize();
        LibraryInventory.CreateItem(MemberItem);
        MembershipCode := MemberLibrary.GenerateCode20();

        MemberCommunity.Get(MemberLibrary.SetupCommunity_Simple());
        MembershipSetup.Get(MemberLibrary.SetupMembership_Simple(MemberCommunity.Code, MembershipCode, LoyaltyProgramCode, Description));
        MemberLibrary.SetupSimpleMembershipSalesItem(MemberItem."No.", MembershipCode);

        // [Test 1]
        MembershipSetup.Blocked := true;
        MembershipSetup.Modify();
        ApiStatus := MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);
        Assert.IsFalse(ApiStatus, StrSubstNo('It should not be possible to create a membership from a blocked membership setup: %1', ResponseMessage));

        // [Test 2]
        MembershipSetup.Blocked := false;
        MembershipSetup.Modify();
        ApiStatus := MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        _LastMembership := Membership;

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddMembershipMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberEntryNo: Integer;
    begin

        Initialize();
        CreateMembership();
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);

        // [TEST]
        ApiStatus := MemberApiLibrary.AddMembershipMember(_LastMembership, MemberInfoCapture, MemberEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        _LastMember.Get(MemberEntryNo);
        Assert.AreEqual(MemberInfoCapture.PreferredLanguageCode, _LastMember.PreferredLanguageCode, 'The preferred language code is not set to ENU.');
        Assert.AreEqual(MemberInfoCapture."First Name", _LastMember."First Name", 'The first name is not set correctly.');
        Assert.AreEqual(MemberInfoCapture."Middle Name", _LastMember."Middle Name", 'The middle name is not set correctly.');
        Assert.AreEqual(MemberInfoCapture."Last Name", _LastMember."Last Name", 'The last name is not set correctly.');
        Assert.AreEqual(LowerCase(MemberInfoCapture."E-Mail Address"), _LastMember."E-Mail Address", 'The email address is not set correctly.');
        Assert.AreEqual(MemberInfoCapture."Phone No.", _LastMember."Phone No.", 'The phone number is not set correctly.');
        Assert.AreEqual(MemberInfoCapture.Birthday, _LastMember.Birthday, 'The birth date is not set correctly.');
        Assert.AreEqual(MemberInfoCapture.City, _LastMember.City, 'The city is not set correctly.');
        Assert.AreEqual(MemberInfoCapture.Country, _LastMember.Country, 'The country is not set correctly.');
        Assert.AreEqual(MemberInfoCapture."Post Code Code", _LastMember."Post Code Code", 'The postal code is not set correctly.');
        Assert.AreEqual(MemberInfoCapture.PreferredLanguageCode, _LastMember.PreferredLanguageCode, 'The preferred language code is not set correctly.');
        Assert.AreEqual(MemberInfoCapture.Gender, _LastMember.Gender, 'The gender is not set correctly.');

        _LastMemberCard.SetFilter("Membership Entry No.", '=%1', _LastMembership."Entry No.");
        _LastMemberCard.SetFilter("Member Entry No.", '=%1', _LastMember."Entry No.");
        _LastMemberCard.FindFirst();

    end;

    procedure AddMembershipMemberWorker()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberEntryNo: Integer;
    begin

        Initialize();
        CreateMembership();
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);

        if (_AddMemberWithFirstName <> '') then
            MemberInfoCapture."First Name" := _AddMemberWithFirstName;

        // [TEST]
        ApiStatus := MemberApiLibrary.AddMembershipMember(_LastMembership, MemberInfoCapture, MemberEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        _LastMember.Get(MemberEntryNo);

        _LastMemberCard.SetFilter("Membership Entry No.", '=%1', _LastMembership."Entry No.");
        _LastMemberCard.SetFilter("Member Entry No.", '=%1', _LastMember."Entry No.");
        _LastMemberCard.FindFirst();

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddMemberCard()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberCardEntryNo: Integer;
        CardNumber: Text[100];
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        CardNumber := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

        // Pre-assigned by invoker
        ApiStatus := MemberApiLibrary.AddMemberCard(_LastMembership."External Membership No.", _LastMember."External Member No.", CardNumber, MemberCardEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        // new card
        _LastMemberCard.Get(MemberCardEntryNo);
        _LastMemberCard.TestField(Blocked, false);
        Assert.AreEqual(CardNumber, _LastMemberCard."External Card No.", 'The created card number does not match the card number provided to the API.');


        // Assign card number by setup
        ApiStatus := MemberApiLibrary.AddMemberCard(_LastMembership."External Membership No.", _LastMember."External Member No.", MemberCardEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        // new card
        _LastMemberCard.Get(MemberCardEntryNo);
        _LastMemberCard.TestField(Blocked, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReplaceMemberCard()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberCardEntryNo: Integer;
        CardNumber: Text[100];
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        CardNumber := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

        // Pre-assigned by invoker
        ApiStatus := MemberApiLibrary.ReplaceMemberCard(_LastMemberCard."External Card No.", CardNumber, MemberCardEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        // original card 
        _LastMemberCard.Get(_LastMemberCard."Entry No.");
        _LastMemberCard.TestField(Blocked, true);

        // new card
        _LastMemberCard.Get(MemberCardEntryNo);
        _LastMemberCard.TestField(Blocked, false);
        Assert.AreEqual(CardNumber, _LastMemberCard."External Card No.", 'The created card number does not match the card number provided to the API.');


        // Assign card number by setup
        ApiStatus := MemberApiLibrary.ReplaceMemberCard(_LastMemberCard."External Card No.", '', MemberCardEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        // original card 
        _LastMemberCard.Get(_LastMemberCard."Entry No.");
        _LastMemberCard.TestField(Blocked, true);

        // new card
        _LastMemberCard.Get(MemberCardEntryNo);
        _LastMemberCard.TestField(Blocked, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ActivateMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ApiStatus: Boolean;

        ScannerStation: Code[10];
    begin
        Initialize();
        CreateMembership();

        // [TEST]
        ClearLastError();
        ApiStatus := MemberApiLibrary.ActivateMembership(_LastMembership, ScannerStation);
        Assert.IsTrue(ApiStatus, StrSubstNo('Membership activation failed. Last errormessage was: %1', GetLastErrorText()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetMembershipUsingMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ApiStatus: Boolean;

        ScannerStation: Code[10];
        TmpMembershipOut: Record "NPR MM Membership" temporary;
        TmpMembershipEntryOut: Record "NPR MM Membership Entry" temporary;
        TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary;
        ResponseMessage: Text;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        // [TEST 1]
        ClearLastError();
        ApiStatus := MemberApiLibrary.GetMembershipUsingMemberNumber(_LastMember."External Member No.", ScannerStation, TmpMembershipOut, TmpMembershipEntryOut, TmpAttributeValueSetOut, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Get membership failed. Last errormessage was: %1', GetLastErrorText));

        TmpMembershipOut.FindFirst();
        Assert.AreEqual(_LastMembership."External Membership No.", TmpMembershipOut."External Membership No.", 'The incorrect membership was returned.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.GetMembershipUsingMemberNumber('FOOBAR-MEMBER-NO', ScannerStation, TmpMembershipOut, TmpMembershipEntryOut, TmpAttributeValueSetOut, ResponseMessage);
        Assert.IsFalse(ApiStatus, 'Get membership returned an invalid membership.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetMembershipMemberUsingMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ApiStatus: Boolean;

        ScannerStation: Code[10];
        TmpMemberInfoResponseOut: Record "NPR MM Member Info Capture" temporary;
        TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary;
        ResponseMessage: Text;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        // [TEST 1]
        ClearLastError();
        ApiStatus := MemberApiLibrary.GetMembershipMemberUsingMembership(_LastMembership."External Membership No.", ScannerStation, TmpMemberInfoResponseOut, TmpAttributeValueSetOut, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Get membership member failed. Last errormessage was: %1', GetLastErrorText()));

        TmpMemberInfoResponseOut.FindFirst();
        Assert.AreEqual(_LastMember."External Member No.", TmpMemberInfoResponseOut."External Member No", 'The incorrect member was returned.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.GetMembershipMemberUsingMembership('FOOBAR-MEMBER-NO', ScannerStation, TmpMemberInfoResponseOut, TmpAttributeValueSetOut, ResponseMessage);
        Assert.IsFalse(ApiStatus, 'Get membership member returned an invalid member.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberInfoCapture: Record "NPR MM Member Info Capture";
        UpdatedMember: Record "NPR MM Member";
        ScannerStation: Code[10];
    begin

        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        MemberInfoCapture."External Member No" := _LastMember."External Member No.";

        // [TEST]      
        ApiStatus := MemberApiLibrary.UpdateMember(MemberInfoCapture, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        UpdatedMember.Get(_LastMember."Entry No.");
        Assert.AreEqual(MemberInfoCapture."First Name", UpdatedMember."First Name", 'Member was not updated.');

        _LastMember := UpdatedMember;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateMemberImage()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";

        Assert: Codeunit Assert;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        ScannerStation: Code[10];
        SourceImageB64: Text;
        ApiStatus: Boolean;
    begin
        SourceImageB64 :=
            'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAA' +
            'B3RJTUUH3wwcCikwn4sr7QAAA85JREFUWMO9lk1sG0UUx/9vZndtr6lDlZJGpAGaIj5ECSAOoYIWu1kBrdQLObXlABIFCQhCHECU' +
            'jwupUKHQCxJSEJEQBypEOaA2UlDi1EFVURTTQyNy4EDEAQniJnHJhze7O49Dd82mdbJJHHska7x/j+f39uk/7w1ZVlri+mB/FqHn' +
            'ZZrneTw8/LNnxoztruN2AbibmQHgd8Mwfpi37b/379+nCSF4LfsB8CgUAPmf8MKyZts2JsYnEsXZ4ndE9AwA+HAQEZgZRNSfTKUO' +
            '7959/0IsHsNq+wWa8L9EwvOj+R3F2eLVSvBQEAfnisXC5bHLOxzHiYQDIBH6ccXFjY2N7Cw540SkV4LfoOm2bY8buhEJDzIgVoP3' +
            'ft2r+n/sP01EyTXAgzmZy+ZO9Xzao6KyK24w4E2L21ruYQDda4UHGjO//thDT3BUdkVUmkzDaF8v3NcoGYs9GOEDijShp1TLBuAA' +
            'ANd1W6s3IfPCRuD+w1zVJtzSkMojNNaTjYatW/NVm7AwPTNHRL9uwAf5f6am5qs2YSazV5dSvrZeH2ia1p3J7NWrNqGUkhcd5xII' +
            'H6/DBx8tOs4lKeXmVELLSktH8dsA3ouCCyHeWVLquGWltU2phEdfOKrGRvO3GkKcbtvVdkrTtTsA9BHRtF9wwMwzRPRVPB5vbWpu' +
            '+twQ4rOx0bEt6c50ZJ+hlSJVSiGbHXENId4F0OO/pUtE7ydvSX45c+3fq+HTkTLN20ul0ssAPihnSNBbS576pLPzSY2IKr2gqtiO' +
            'Q/BhAOkV0r7AzH/6/9lJREaldcz8k8P8tH9PQGQ7ZmbOZkdcXYhfVoGDmU0A9xHRvSvB/fGUTpTLZkfcNZlwaCjnGUJ8Q0DHBntA' +
            'JW2fIUTv4OAFZ1UTSikRk/JZAM9tIjyQjhlSHPD1ypVQKUXMfKYG8OunRfHZwcELXsVKeKjrEOeGcicB6LWA+1oirmkn2h9p926q' +
            'hH1f9OkA3qwhHH6Wjx8+0rXchLF4DBPjE921hgfj8Uczr0gp/zfh+XMDLjO/Wmt4oAF4aWBgyC2bMGWaTQDuqgfcv763tzRvT5ZN' +
            'WCqVDtQLHsyFqYIVNuGd9YIHmmL1QNmEesw4W084AGhSu1g24dzC4m8AjtQLToLeWHSc3LJ2vO22bTjz7fdeXNcs5alOZt4D4GEi' +
            'aqgWzsxXiOgiEZ2zPe/8i8eel5N/TFLQjsnPRLADd+zpUCc+PFk+Mwld3+l5XiuAZiJqZOYGBifA0IiIiUgxs83M8wBmSVBBCPFX' +
            'wjQnZ4rXpv0gyLLS0g+qfCf8D8L6EhAUv5Y3AAAAAElFTkSuQmCC';

        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        // [TEST]
        if (_LastMember.Image.HasValue()) then
            Error('Initial member is not expected to have picture.');

        ClearLastError();
        ApiStatus := MemberApiLibrary.UpdateMemberImageAPI(_LastMember."External Member No.", SourceImageB64, ScannerStation);
        Assert.IsTrue(true, StrSubstNo('Update member API failed: %1', GetLastErrorText()));

        _LastMember.Get(_LastMember."Entry No.");

        if (MemberMedia.IsFeatureEnabled()) then begin
            Assert.IsTrue(MemberMedia.HaveMemberImage(_LastMember.SystemId), 'Member image is expected to be stored in Cloudflare R2 storage.');

        end else begin
            if (not _LastMember.Image.HasValue()) then
                Error('Member is expected to have picture after update.');

            TempBlob.CreateOutStream(OutStr);
            _LastMember.Image.ExportStream(OutStr);
            Assert.AreEqual(1002, TempBlob.Length(), 'Incorrect length in BLOB when checking stored picture size.');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberNumberValidation()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ScannerStation: Code[10];
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberValidationAPI(_LastMember."External Member No.", ScannerStation);
        Assert.IsTrue(ApiStatus, 'Member expected to be found.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MemberValidationAPI('FOOBAR NUMBER', ScannerStation);
        Assert.IsFalse(ApiStatus, 'Member not expected to be found.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MembershipNumberValidation()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ScannerStation: Code[10];
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MembershipValidationAPI(_LastMembership."External Membership No.", ScannerStation);
        Assert.IsTrue(ApiStatus, 'Membership expected to be found.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MembershipValidationAPI('FOOBAR NUMBER', ScannerStation);
        Assert.IsFalse(ApiStatus, 'Membership not expected to be found.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberEmailExists()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberEmailExistsAPI(_LastMember."E-Mail Address");
        Assert.IsTrue(ApiStatus, 'Member expected to be found.');

        // [TEST 2]
        _LastMember.Blocked := true;
        _LastMember.Modify();
        ApiStatus := MemberApiLibrary.MemberEmailExistsAPI(_LastMember."E-Mail Address");
        Assert.IsFalse(ApiStatus, 'Member not expected to be found.');

        // [TEST 3]
        ApiStatus := MemberApiLibrary.MemberEmailExistsAPI('FOOBAR@FOO.BAR');
        Assert.IsFalse(ApiStatus, 'Member not expected to be found.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberCardNumberValidation()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ScannerStation: Code[10];
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberCardNumberValidationAPI(_LastMemberCard."External Card No.", ScannerStation);
        Assert.IsTrue(ApiStatus, 'Membership expected to be found.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MemberCardNumberValidationAPI('FOOBAR NUMBER', ScannerStation);
        Assert.IsFalse(ApiStatus, 'Membership not expected to be found.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberRegisterArrival_ItemRef()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Item: Record Item;
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Assert: Codeunit Assert;
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
        ResponseMessage: Text;
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        Item.Get(ItemNo);
        MembershipSetup.Get(_LastMembership."Membership Code");
        MembershipSetup."Ticket Item Type" := MembershipSetup."Ticket Item Type"::REFERENCE;
        MembershipSetup.Validate("Ticket Item Barcode", StrSubstNo('IXRF-%1', ItemNo)); // Ticket smoketest scenario creates item cross reference by prefixing item no.
        MembershipSetup.Modify();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberRegisterArrivalAPI(_LastMember."External Member No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Member arrival failed: %1', ResponseMessage));

        // [TEST 2]
        asserterror ApiStatus := MemberApiLibrary.MemberRegisterArrivalAPI('FOOBAR MEMBER NO', AdmissionCode, ScannerStation, ResponseMessage);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberRegisterArrival_Item()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Item: Record Item;
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Assert: Codeunit Assert;
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
        ResponseMessage: Text;
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        Item.Get(ItemNo);
        MembershipSetup.Get(_LastMembership."Membership Code");
        MembershipSetup."Ticket Item Type" := MembershipSetup."Ticket Item Type"::ITEM;
        MembershipSetup.Validate("Ticket Item Barcode", ItemNo);
        MembershipSetup.Modify();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberRegisterArrivalAPI(_LastMember."External Member No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Member arrival failed: %1', ResponseMessage));

        // [TEST 2]
        asserterror ApiStatus := MemberApiLibrary.MemberRegisterArrivalAPI('FOOBAR MEMBER NO', AdmissionCode, ScannerStation, ResponseMessage);

    end;



    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberCardRegisterArrival_ItemRef()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Assert: Codeunit Assert;
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
        ResponseMessage: Text;
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        MembershipSetup.Get(_LastMembership."Membership Code");
        MembershipSetup."Ticket Item Type" := MembershipSetup."Ticket Item Type"::REFERENCE;
        MembershipSetup.Validate("Ticket Item Barcode", StrSubstNo('IXRF-%1', ItemNo)); // Ticket smoketest scenario creates item cross reference by prefixing item no.
        MembershipSetup.Modify();
        Commit();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberCardRegisterArrivalAPI(_LastMemberCard."External Card No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Member arrival failed: %1', ResponseMessage));

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MemberCardRegisterArrivalAPI('FOOBAR MEMBER NO', AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiStatus, StrSubstNo('Member arrival must fail when providing invalid card number: %1', ResponseMessage));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberCardRegisterArrival_Item()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Assert: Codeunit Assert;
        ItemNo: Code[20];
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
        ResponseMessage: Text;
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMemberWorker();

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        MembershipSetup.Get(_LastMembership."Membership Code");
        MembershipSetup."Ticket Item Type" := MembershipSetup."Ticket Item Type"::ITEM;
        MembershipSetup.Validate("Ticket Item Barcode", ItemNo);
        MembershipSetup.Modify();
        Commit();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberCardRegisterArrivalAPI(_LastMemberCard."External Card No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Member arrival failed: %1', ResponseMessage));

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MemberCardRegisterArrivalAPI('FOOBAR MEMBER NO', AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsFalse(ApiStatus, StrSubstNo('Member arrival must fail when providing invalid card number: %1', ResponseMessage));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SearchMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        TempMemberInfoCaptureSearchResult: Record "NPR MM Member Info Capture" temporary;
        LimitResultTo, i : Integer;
        MemberCardEntryNo: Integer;
    begin

        Initialize();
        MemberLibrary.GenerateText(_AddMemberWithFirstName, 15);

        // Create X membership with 1 member and 1 additional card
        for i := 1 to 10 do begin
            CreateMembership();
            AddMembershipMemberWorker();
            ApiStatus := MemberApiLibrary.AddMemberCard(_LastMembership."External Membership No.", _LastMember."External Member No.", MemberCardEntryNo, ResponseMessage);
            Assert.IsTrue(ApiStatus, ResponseMessage);
        end;

        LimitResultTo := 5;

        // [TEST]
        ApiStatus := MemberApiLibrary.SearchMember(_AddMemberWithFirstName, '', '', '', LimitResultTo, TempMemberInfoCaptureSearchResult, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        TempMemberInfoCaptureSearchResult.Reset();
        TempMemberInfoCaptureSearchResult.SetFilter("First Name", '=%1', _AddMemberWithFirstName);
        Assert.AreEqual(5 * 2, TempMemberInfoCaptureSearchResult.Count, 'Expected number of members in result is incorrect. Each member should have 2 cards each.');

        // [TEST]
        Clear(TempMemberInfoCaptureSearchResult);
        ApiStatus := MemberApiLibrary.SearchMember('', _LastMember."Last Name", '', '', LimitResultTo, TempMemberInfoCaptureSearchResult, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);

        TempMemberInfoCaptureSearchResult.Reset();
        TempMemberInfoCaptureSearchResult.SetFilter("Last Name", '=%1', _LastMember."Last Name");
        Assert.AreEqual(1 * 2, TempMemberInfoCaptureSearchResult.Count, 'Expected number of members in result is incorrect. Each member should have 2 cards each.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockAndUnblockMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        MemberManagementInternal: Codeunit "NPR MM MembershipMgtInternal";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberItem: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MemberInfoCapture: Record "NPR MM Member Info Capture";

        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
        MemberCardEntryNo: Integer;
        CardNumber: Text[100];

        MembershipCode: Code[20];
        LoyaltyProgramCode: Code[20];
        Description: Text[50];
    begin

        Initialize();
        LibraryInventory.CreateItem(MemberItem);
        MembershipCode := MemberLibrary.GenerateCode20();

        MemberCommunity.Get(MemberLibrary.SetupCommunity_Simple());
        MembershipSetup.Get(MemberLibrary.SetupMembership_Simple(MemberCommunity.Code, MembershipCode, LoyaltyProgramCode, Description));
        MemberLibrary.SetupSimpleMembershipSalesItem(MemberItem."No.", MembershipCode);

        ApiStatus := MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Membership.Get(MembershipEntryNo);
        _LastMembership := Membership;

        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        ApiStatus := MemberApiLibrary.AddMembershipMember(_LastMembership, MemberInfoCapture, MemberEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Member.Get(MemberEntryNo);
        _LastMember := Member;

        CardNumber := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        ApiStatus := MemberApiLibrary.AddMemberCard(_LastMembership."External Membership No.", _LastMember."External Member No.", CardNumber, MemberCardEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        _LastMemberCard.Get(MemberCardEntryNo);


        // [TEST]
        MemberManagementInternal.BlockMembership(Membership."Entry No.", true);
        Membership.Get(Membership."Entry No.");
        Assert.IsTrue(Membership.Blocked, 'Membership is expected to be blocked.');

        Member.Get(MemberEntryNo);
        Assert.IsTrue(Member.Blocked, 'Member is expected to be blocked.');

        MemberCard.Get(MemberCardEntryNo);
        Assert.IsTrue(MemberCard.Blocked, 'Member card is expected to be blocked.');


        MemberManagementInternal.BlockMembership(Membership."Entry No.", false);
        Membership.Get(Membership."Entry No.");
        Assert.IsFalse(Membership.Blocked, 'Membership is expected to be unblocked.');

        Member.Get(MemberEntryNo);
        Assert.IsFalse(Member.Blocked, 'Member is expected to be unblocked.');

        MemberCard.Get(MemberCardEntryNo);
        Assert.IsFalse(MemberCard.Blocked, 'Member card is expected to be unblocked.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        MemberManagementInternal: Codeunit "NPR MM MembershipMgtInternal";
        MembershipFacade: Codeunit "NPR MM Membership Mgt.";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberItem: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership1, Membership2 : Record "NPR MM Membership";
        Member1, Member2 : Record "NPR MM Member";
        Card1, Card2 : Record "NPR MM Member Card";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipRole: Record "NPR MM Membership Role";

        MembershipEntryNo, MemberShipEntryNo2 : Integer;
        MemberEntryNo: Integer;
        MemberCardEntryNo: Integer;
        CardNumber: Text[100];

        MembershipCode: Code[20];
        LoyaltyProgramCode: Code[20];
        Description: Text[50];

        Name: Text[50];
        Email: Text[80];
        ConflictsExist, MembersMerged : Boolean;
    begin

        Name := DelChr(Format(CreateGuid()), '=', '{}-').ToLower();
        Email := StrSubstNo('%1@%2.navipartner.dk', Name, Name);

        Initialize();
        LibraryInventory.CreateItem(MemberItem);
        MembershipCode := MemberLibrary.GenerateCode20();

        MemberCommunity.Get(MemberLibrary.SetupCommunity_Simple());
        MembershipSetup.Get(MemberLibrary.SetupMembership_Simple(MemberCommunity.Code, MembershipCode, LoyaltyProgramCode, Description));
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::EMAIL_AND_FIRST_NAME;
        MemberCommunity."Create Member UI Violation" := MemberCommunity."Create Member UI Violation"::MERGE_MEMBER;
        MemberCommunity."Member Logon Credentials" := MemberCommunity."Member Logon Credentials"::NA;
        MemberCommunity.Modify();

        MemberLibrary.SetupSimpleMembershipSalesItem(MemberItem."No.", MembershipCode);

        // first memberships
        ApiStatus := MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Membership1.Get(MembershipEntryNo);

        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        MemberInfoCapture."First Name" := Name;
        MemberInfoCapture."E-Mail Address" := Email;
        ApiStatus := MemberApiLibrary.AddMembershipMember(Membership1, MemberInfoCapture, MemberEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Member1.Get(MemberEntryNo);

        CardNumber := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        ApiStatus := MemberApiLibrary.AddMemberCard(Membership1."External Membership No.", Member1."External Member No.", CardNumber, MemberCardEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Card1.Get(MemberCardEntryNo);

        // second memberships
        ApiStatus := MemberApiLibrary.CreateMembership(MemberItem."No.", MemberShipEntryNo2, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Membership2.Get(MemberShipEntryNo2);

        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        MemberInfoCapture."First Name" := Name;
        MemberInfoCapture."E-Mail Address" := Email;

        // Add member with merge not allowed on conflict -> should fail
        MemberInfoCapture.AllowMergeOnConflict := false;

        // [TEST]
        ApiStatus := MemberApiLibrary.AddMembershipMember(Membership2, MemberInfoCapture, MemberEntryNo, ResponseMessage);

        // We are mixing GUI and API here which is not ideal but for the sake of this test we need to verify both paths
        if (GuiAllowed) then begin
            // In GUI mode, user will be prompted to reuse the existing member (updated with new data)
            Assert.IsTrue(ApiStatus, ResponseMessage);
            Member2.Get(MemberEntryNo);
            Assert.AreEqual(Member1."Entry No.", Member2."Entry No.", 'Expected same member to be returned due to unique identity conflict.');
        end;

        if (not GuiAllowed) then begin
            // In API mode, merge is only allowed when AllowMergeOnConflict is true
            Assert.IsFalse(ApiStatus, 'Expected add member to fail due to duplicate unique identity.');

            MemberInfoCapture.AllowMergeOnConflict := true;
            ApiStatus := MemberApiLibrary.AddMembershipMember(Membership2, MemberInfoCapture, MemberEntryNo, ResponseMessage);
            Assert.IsTrue(ApiStatus, ResponseMessage);

            Member2.Get(MemberEntryNo);

            // Member 1 should not exist anymore
            asserterror Member1.Get(Member1."Entry No.");
        end;

        // verify that both memberships are linking the same member
        MembershipRole.Get(Membership1."Entry No.", Member2."Entry No.");
        MembershipRole.Get(Membership2."Entry No.", Member2."Entry No.");

        CardNumber := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        ApiStatus := MemberApiLibrary.AddMemberCard(Membership2."External Membership No.", Member2."External Member No.", CardNumber, MemberCardEntryNo, ResponseMessage);
        Assert.IsTrue(ApiStatus, ResponseMessage);
        Card2.Get(MemberCardEntryNo);

        _LastMembership := Membership2;
        _LastMember := Member2;
        _LastMemberCard := Card2;

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockAndUnblockMembershipsWithSharedMember()
    var
        MemberManagementInternal: Codeunit "NPR MM MembershipMgtInternal";
        Assert: Codeunit Assert;
        Membership1: Record "NPR MM Membership";
        Card1: Record "NPR MM Member Card";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipRole1: Record "NPR MM Membership Role";
    begin
        // ------------------------------------------------------------
        // Precondition: member is in two memberships with two cards:
        //   _LastMembership + _LastMemberCard
        //   Membership1     + Card1
        // and everything is unblocked.
        // ------------------------------------------------------------
        MergeMembership();

        // Refresh data
        _LastMembership.Get(_LastMembership."Entry No.");
        _LastMember.Get(_LastMember."Entry No.");
        _LastMemberCard.Get(_LastMemberCard."Entry No.");
        MembershipRole.Get(_LastMembership."Entry No.", _LastMember."Entry No.");

        Assert.IsFalse(_LastMembership.Blocked, 'Precondition failed: Membership is expected to be unblocked.');
        Assert.IsFalse(_LastMember.Blocked, 'Precondition failed: Member is expected to be unblocked.');
        Assert.IsFalse(_LastMemberCard.Blocked, 'Precondition failed: Member card is expected to be unblocked.');
        Assert.IsFalse(MembershipRole.Blocked, 'Precondition failed: Membership role is expected to be unblocked.');

        // ------------------------------------------------------------
        // 1) BLOCK _LastMembership (other membership stays active)
        // ------------------------------------------------------------
        MemberManagementInternal.BlockMembership(_LastMembership."Entry No.", true);

        _LastMembership.Get(_LastMembership."Entry No.");
        _LastMember.Get(_LastMember."Entry No.");
        _LastMemberCard.Get(_LastMemberCard."Entry No.");
        MembershipRole.Get(_LastMembership."Entry No.", _LastMember."Entry No.");

        Assert.IsTrue(_LastMembership.Blocked, 'Membership is expected to be blocked.');
        Assert.IsFalse(_LastMember.Blocked, 'Member is expected to be NOT blocked since it is also valid in membership 1.');
        Assert.IsTrue(_LastMemberCard.Blocked, 'Member card is expected to be blocked since it is only valid in the blocked membership.');
        Assert.IsTrue(MembershipRole.Blocked, 'Membership role is expected to be blocked.');

        // Find the other membership - must be unblocked
        MembershipRole.Reset();
        MembershipRole.SetFilter("Member Entry No.", '%1', _LastMember."Entry No.");
        MembershipRole.SetFilter("Membership Entry No.", '<>%1', _LastMembership."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);

        Assert.IsTrue(MembershipRole.FindFirst(), 'Expected another membership role for this member.');

        Membership1.Get(MembershipRole."Membership Entry No.");
        Assert.IsFalse(Membership1.Blocked, 'Other membership is expected to be unblocked.');

        Card1.Reset();
        Card1.SetFilter("Membership Entry No.", '%1', Membership1."Entry No.");
        Card1.SetFilter("Member Entry No.", '%1', _LastMember."Entry No.");
        Card1.SetFilter(Blocked, '=%1', false);
        Assert.IsTrue(Card1.FindFirst(), 'Expected an active card in the other membership.');

        // ------------------------------------------------------------
        // 2) BLOCK the remaining membership (Membership1)
        //    -> now ALL memberships for the member are blocked
        //    -> member must become blocked
        // ------------------------------------------------------------
        MemberManagementInternal.BlockMembership(Membership1."Entry No.", true);

        // Refresh all
        _LastMembership.Get(_LastMembership."Entry No.");
        Membership1.Get(Membership1."Entry No.");
        _LastMember.Get(_LastMember."Entry No.");
        _LastMemberCard.Get(_LastMemberCard."Entry No.");
        Card1.Get(Card1."Entry No.");

        MembershipRole.Get(_LastMembership."Entry No.", _LastMember."Entry No.");
        MembershipRole1.Get(Membership1."Entry No.", _LastMember."Entry No.");

        Assert.IsTrue(_LastMembership.Blocked, 'Membership 2 is expected to be blocked.');
        Assert.IsTrue(Membership1.Blocked, 'Membership 1 is expected to be blocked.');
        Assert.IsTrue(_LastMember.Blocked, 'Member is expected to be blocked when all memberships are blocked.');
        Assert.IsTrue(_LastMemberCard.Blocked, 'Member card in membership 2 is expected to be blocked.');
        Assert.IsTrue(Card1.Blocked, 'Member card in membership 1 is expected to be blocked.');
        Assert.IsTrue(MembershipRole.Blocked, 'Membership role in membership 2 is expected to be blocked.');
        Assert.IsTrue(MembershipRole1.Blocked, 'Membership role in membership 1 is expected to be blocked.');

        // ------------------------------------------------------------
        // 3) UNBLOCK one membership (unblock _LastMembership)
        //    -> member still has another blocked membership
        //    -> member must remain blocked
        // ------------------------------------------------------------
        MemberManagementInternal.BlockMembership(_LastMembership."Entry No.", false);

        _LastMembership.Get(_LastMembership."Entry No.");
        Membership1.Get(Membership1."Entry No.");
        _LastMember.Get(_LastMember."Entry No.");
        _LastMemberCard.Get(_LastMemberCard."Entry No.");
        Card1.Get(Card1."Entry No.");

        MembershipRole.Get(_LastMembership."Entry No.", _LastMember."Entry No.");
        MembershipRole1.Get(Membership1."Entry No.", _LastMember."Entry No.");

        Assert.IsFalse(_LastMembership.Blocked, 'Membership 2 is expected to be unblocked.');
        Assert.IsTrue(Membership1.Blocked, 'Membership 1 is expected to remain blocked.');
        Assert.IsTrue(_LastMember.Blocked, 'Member is expected to remain blocked while another membership is blocked.');
        Assert.IsFalse(_LastMemberCard.Blocked, 'Card in unblocked membership 2 is expected to be unblocked.');
        Assert.IsTrue(Card1.Blocked, 'Card in still-blocked membership 1 is expected to stay blocked.');
        Assert.IsFalse(MembershipRole.Blocked, 'Role in unblocked membership 2 is expected to be unblocked.');
        Assert.IsTrue(MembershipRole1.Blocked, 'Role in membership 1 is expected to stay blocked.');

        // ------------------------------------------------------------
        // 4) UNBLOCK the final membership (Membership1)
        //    -> no blocked memberships left
        //    -> member must become unblocked
        // ------------------------------------------------------------
        MemberManagementInternal.BlockMembership(Membership1."Entry No.", false);

        _LastMembership.Get(_LastMembership."Entry No.");
        Membership1.Get(Membership1."Entry No.");
        _LastMember.Get(_LastMember."Entry No.");
        _LastMemberCard.Get(_LastMemberCard."Entry No.");
        Card1.Get(Card1."Entry No.");

        MembershipRole.Get(_LastMembership."Entry No.", _LastMember."Entry No.");
        MembershipRole1.Get(Membership1."Entry No.", _LastMember."Entry No.");

        Assert.IsFalse(_LastMembership.Blocked, 'Membership 2 is expected to be unblocked in the end.');
        Assert.IsFalse(Membership1.Blocked, 'Membership 1 is expected to be unblocked in the end.');
        Assert.IsFalse(_LastMember.Blocked, 'Member is expected to be unblocked when all memberships are unblocked.');
        Assert.IsFalse(_LastMemberCard.Blocked, 'Card in membership 2 is expected to be unblocked in the end.');
        Assert.IsFalse(Card1.Blocked, 'Card in membership 1 is expected to be unblocked in the end.');
        Assert.IsFalse(MembershipRole.Blocked, 'Role in membership 2 is expected to be unblocked in the end.');
        Assert.IsFalse(MembershipRole1.Blocked, 'Role in membership 1 is expected to be unblocked in the end.');
    end;
}