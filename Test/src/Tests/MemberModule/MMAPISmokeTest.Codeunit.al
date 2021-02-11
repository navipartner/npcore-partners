codeunit 85016 "NPR MM API Smoke Test"
{
    Subtype = Test;

    var
        _LastMembership: Record "NPR MM Membership";
        _LastMember: Record "NPR MM Member";

        _LastMemberCard: Record "NPR MM Member Card";
        _IsInitialized: Boolean;


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
        ItemNo: Code[20];
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
    procedure AddMembershipMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryInventory: Codeunit "NPR Library - Inventory";
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

        _LastMemberCard.SetFilter("Membership Entry No.", '=%1', _LastMembership."Entry No.");
        _LastMemberCard.SetFilter("Member Entry No.", '=%1', _LastMember."Entry No.");
        _LastMemberCard.FindFirst();

    end;

    [Test]
    procedure ActivateMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        LibraryInventory: Codeunit "NPR Library - Inventory";
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
    procedure GetMembershipUsingMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        LibraryInventory: Codeunit "NPR Library - Inventory";
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
        AddMembershipMember();

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
    procedure GetMembershipMemberUsingMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        Assert: Codeunit Assert;
        ApiStatus: Boolean;

        ScannerStation: Code[10];
        TmpMemberInfoResponseOut: Record "NPR MM Member Info Capture" temporary;
        TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary;
        ResponseMessage: Text;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMember();

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
    procedure UpdateMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberInfoCapture: Record "NPR MM Member Info Capture";
        UpdatedMember: Record "NPR MM Member";
        ScannerStation: Code[10];
    begin

        Initialize();
        CreateMembership();
        AddMembershipMember();

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
    procedure UpdateMemberImage()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;

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
        AddMembershipMember();

        // [TEST]
        if (_LastMember.Picture.HasValue()) then
            Error('Initial member is not expected to have picture.');

        ClearLastError();
        ApiStatus := MemberApiLibrary.UpdateMemberImageAPI(_LastMember."External Member No.", SourceImageB64, ScannerStation);
        Assert.IsTrue(true, StrSubstNo('Update member API failed: %1', GetLastErrorText()));

        _LastMember.Get(_LastMember."Entry No.");
        if (not _LastMember.Picture.HasValue()) then
            Error('Member is expected to have picture after update.');

        Assert.AreEqual(1098, _LastMember.Picture.Length(), 'Incorrect length in BLOB when checking stored picture size.');

    end;

    [Test]
    procedure MemberNumberValidation()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ScannerStation: Code[10];
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMember();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberValidationAPI(_LastMember."External Member No.", ScannerStation);
        Assert.IsTrue(ApiStatus, 'Member expected to be found.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MemberValidationAPI('FOOBAR NUMBER', ScannerStation);
        Assert.IsFalse(ApiStatus, 'Member not expected to be found.');
    end;

    [Test]
    procedure MembershipNumberValidation()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ScannerStation: Code[10];
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMember();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MembershipValidationAPI(_LastMembership."External Membership No.", ScannerStation);
        Assert.IsTrue(ApiStatus, 'Membership expected to be found.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MembershipValidationAPI('FOOBAR NUMBER', ScannerStation);
        Assert.IsFalse(ApiStatus, 'Membership not expected to be found.');
    end;


    [Test]
    procedure MemberEmailExists()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ScannerStation: Code[10];
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMember();

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
    procedure MemberCardNumberValidation()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        ScannerStation: Code[10];
        ApiStatus: Boolean;
    begin
        Initialize();
        CreateMembership();
        AddMembershipMember();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberCardNumberValidationAPI(_LastMemberCard."External Card No.", ScannerStation);
        Assert.IsTrue(ApiStatus, 'Membership expected to be found.');

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MemberCardNumberValidationAPI('FOOBAR NUMBER', ScannerStation);
        Assert.IsFalse(ApiStatus, 'Membership not expected to be found.');
    end;

    [Test]
    procedure MemberRegisterArrival()
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
        AddMembershipMember();

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        Item.Get(ItemNo);
        MembershipSetup.Get(_LastMembership."Membership Code");
        MembershipSetup.Validate("Ticket Item Barcode", StrSubstNo('IXRF-%1', ItemNo)); // Ticket smoketest scenario creates item cross reference by prefixing item no.
        MembershipSetup.Modify();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberRegisterArrivalAPI(_LastMember."External Member No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Member arrival failed: %1', ResponseMessage));

        // [TEST 2]
        asserterror ApiStatus := MemberApiLibrary.MemberRegisterArrivalAPI('FOOBAR MEMBER NO', AdmissionCode, ScannerStation, ResponseMessage);

    end;

    [Test]
    procedure MemberCardRegisterArrival()
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
        AddMembershipMember();

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        MembershipSetup.Get(_LastMembership."Membership Code");
        MembershipSetup.Validate("Ticket Item Barcode", StrSubstNo('IXRF-%1', ItemNo)); // Ticket smoketest scenario creates item cross reference by prefixing item no.
        MembershipSetup.Modify();
        Commit();

        // [TEST 1]
        ApiStatus := MemberApiLibrary.MemberCardRegisterArrivalAPI(_LastMemberCard."External Card No.", AdmissionCode, ScannerStation, ResponseMessage);
        Assert.IsTrue(ApiStatus, StrSubstNo('Member arrival failed: %1', ResponseMessage));

        // [TEST 2]
        ApiStatus := MemberApiLibrary.MemberCardRegisterArrivalAPI('FOOBAR MEMBER NO', AdmissionCode, ScannerStation, ResponseMessage);
        Assert.Isfalse(ApiStatus, StrSubstNo('Member arrival must fail when providing invalid card number: %1', ResponseMessage));
    end;

    [Normal]
    local procedure SelectSmokeTestScenario() ItemNo: Code[20]
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
    begin
        ItemNo := MemberLibrary.CreateScenario_SmokeTest()
    end;


}