codeunit 85463 "NPR MMMemberCardPrintQRTests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryReportDataset: Codeunit "Library - Report Dataset";
        _CardEntryNoFilter: Text;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MemberCardPrintQRRequestPageHandler')]
    procedure GivenMemberWithoutPhotoPrintedAfterMemberWithPhoto_WhenReportRuns_ThenTheSecondCardHasNoPhoto()
    var
        FirstCardEntryNo: Integer;
        SecondCardEntryNo: Integer;
        MemberWithPhoto: Code[20];
        MemberWithoutPhoto: Code[20];
    begin
        // [GIVEN] Two member cards, the first belonging to a member who has a photo and the second to a member who has none
        MemberWithPhoto := CreateMemberCard(NewCardNo(), true, FirstCardEntryNo);
        MemberWithoutPhoto := CreateMemberCard(NewCardNo(), false, SecondCardEntryNo);

        // [WHEN] The report prints both cards in that order
        RunReportForCards(StrSubstNo('%1|%2', FirstCardEntryNo, SecondCardEntryNo));

        // [THEN] The photo appears only on the card of the member who has one
        _Assert.AreNotEqual('', ElementOfMember(MemberWithPhoto, 'MemberPicture'), 'The member who has a photo must print it.');
        _Assert.AreEqual('', ElementOfMember(MemberWithoutPhoto, 'MemberPicture'), 'A member without a photo must not inherit the previous member photo.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MemberCardPrintQRRequestPageHandler')]
    procedure GivenMemberCardWithCardNumber_WhenReportRuns_ThenAQrCodeIsProduced()
    var
        CardEntryNo: Integer;
        MemberNo: Code[20];
    begin
        // [GIVEN] A member card that has an external card number
        MemberNo := CreateMemberCard(NewCardNo(), false, CardEntryNo);

        // [WHEN] The report prints the card
        RunReportForCards(Format(CardEntryNo));

        // [THEN] The dataset carries an encoded QR code image
        _Assert.AreNotEqual('', ElementOfMember(MemberNo, 'QRBlob'), 'A card with a card number must print a QR code.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MemberCardPrintQRRequestPageHandler')]
    procedure GivenMemberCardWithoutCardNumber_WhenReportRuns_ThenItPrintsWithoutQrCodeAndWithoutError()
    var
        CardEntryNo: Integer;
        MemberNo: Code[20];
    begin
        // [GIVEN] A member card with no external card number, which the barcode provider cannot encode
        MemberNo := CreateMemberCard('', false, CardEntryNo);

        // [WHEN] The report prints the card
        RunReportForCards(Format(CardEntryNo));

        // [THEN] The card still prints, simply without a QR code, instead of aborting the whole run
        _Assert.AreEqual('', ElementOfMember(MemberNo, 'QRBlob'), 'A card without a card number must print no QR code.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MemberCardPrintQRRequestPageHandler')]
    procedure GivenUserWithoutUserSetup_WhenReportRuns_ThenTheCardStillPrints()
    var
        UserSetup: Record "User Setup";
        CardEntryNo: Integer;
        MemberNo: Code[20];
    begin
        // [GIVEN] The printing user has no User Setup record, so no POS unit can be resolved
        if UserSetup.Get(UserId()) then
            UserSetup.Delete();
        MemberNo := CreateMemberCard(NewCardNo(), false, CardEntryNo);

        // [WHEN] The report prints the card
        RunReportForCards(Format(CardEntryNo));

        // [THEN] The card prints anyway, because the POS unit only supplies an optional background image
        _Assert.AreNotEqual('', ElementOfMember(MemberNo, 'MemberCardNo'), 'A user without a User Setup record must still be able to print a member card.');
    end;

    local procedure CreateMemberCard(ExternalCardNo: Text[100]; WithPhoto: Boolean; var CardEntryNo: Integer) ExternalMemberNo: Code[20]
    var
        MMMember: Record "NPR MM Member";
        MMMemberCard: Record "NPR MM Member Card";
    begin
        ExternalMemberNo := CopyStr(Format(CreateGuid(), 0, 4), 1, 20);

        MMMember.Init();
        MMMember."External Member No." := ExternalMemberNo;
        MMMember."First Name" := 'Report';
        MMMember."Last Name" := 'Test';
        if WithPhoto then
            AddPhoto(MMMember);
        MMMember.Insert(true);

        MMMemberCard.Init();
        MMMemberCard."External Card No." := ExternalCardNo;
        MMMemberCard."Member Entry No." := MMMember."Entry No.";
        MMMemberCard.Insert(true);

        CardEntryNo := MMMemberCard."Entry No.";
    end;

    local procedure AddPhoto(var MMMember: Record "NPR MM Member")
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        OutStr: OutStream;
        OnePixelPngTok: Label 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', Locked = true;
    begin
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(OnePixelPngTok, OutStr);
        TempBlob.CreateInStream(InStr);
        MMMember.Image.ImportStream(InStr, 'Member photo');
    end;

    local procedure NewCardNo(): Text[100]
    begin
        exit(CopyStr(Format(CreateGuid(), 0, 4), 1, 20));
    end;

    local procedure RunReportForCards(CardEntryNoFilter: Text)
    begin
        _CardEntryNoFilter := CardEntryNoFilter;

        Commit();
        Report.Run(Report::"NPR MM Member Card Print QR", true, false);
        _LibraryReportDataset.LoadDataSetFile();
    end;

    local procedure ElementOfMember(ExternalMemberNo: Code[20]; ElementName: Text) Value: Text
    var
        ElementValue: Variant;
    begin
        _LibraryReportDataset.Reset();
        _LibraryReportDataset.SetRange('MemberNumber', ExternalMemberNo);
        _Assert.IsTrue(_LibraryReportDataset.GetNextRow(), StrSubstNo('The dataset has no row for member ''%1''.', ExternalMemberNo));

        if not _LibraryReportDataset.CurrentRowHasElement(ElementName) then
            exit('');

        _LibraryReportDataset.GetElementValueInCurrentRow(ElementName, ElementValue);
        Value := Format(ElementValue);
    end;

    [RequestPageHandler]
    procedure MemberCardPrintQRRequestPageHandler(var MemberCardPrintQR: TestRequestPage "NPR MM Member Card Print QR")
    begin
        MemberCardPrintQR."MM Member Card".SetFilter("Entry No.", _CardEntryNoFilter);
        MemberCardPrintQR.SaveAsXml(_LibraryReportDataset.GetParametersFileName(), _LibraryReportDataset.GetFileName());
    end;
}
