codeunit 85573 "NPR Member Valid From Tests"
{
    // [FEATURE] Member email date tags: membership_valid_from_localized in the member's language, membership_valid_from_formatted unchanged
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidFromLocalized_DanishMember_UsesDanishShortDate()
    var
        Entry: Record "NPR MM Member Notific. Entry";
        TypeHelper: Codeunit "Type Helper";
        ValidFromLocalized: Text;
    begin
        // [SCENARIO] membership_valid_from_localized uses the short date of the member's preferred language
        // [GIVEN] A Danish language and a notification entry for a Danish member
        CreateLanguage('NPRTESTDA', 1030);
        InitNotificationEntry(Entry, 20270930D, 'NPRTESTDA');

        // [WHEN] The member data provider builds the content
        ValidFromLocalized := GetContentValue(Entry, 'membership_valid_from_localized');

        // [THEN] membership_valid_from_localized equals the Danish short date
        _Assert.AreEqual(TypeHelper.FormatDate(20270930D, 1030), ValidFromLocalized, 'membership_valid_from_localized must use the short date of the member''s preferred language');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidFromFormatted_DanishMember_KeepsExistingOutput()
    var
        Entry: Record "NPR MM Member Notific. Entry";
        OldLanguageId: Integer;
        ExpectedDate: Text;
        ValidFromFormatted: Text;
    begin
        // [SCENARIO] membership_valid_from_formatted keeps its existing output for a member with a language
        // [GIVEN] A Danish language and a notification entry for a Danish member
        CreateLanguage('NPRTESTDA', 1030);
        InitNotificationEntry(Entry, 20270930D, 'NPRTESTDA');
        OldLanguageId := GlobalLanguage();
        GlobalLanguage(1030);
        ExpectedDate := Format(20270930D, 0, '<Standard Format,0>');
        GlobalLanguage(OldLanguageId);

        // [WHEN] The member data provider builds the content
        ValidFromFormatted := GetContentValue(Entry, 'membership_valid_from_formatted');

        // [THEN] membership_valid_from_formatted equals the standard date format under the member's language
        _Assert.AreEqual(ExpectedDate, ValidFromFormatted, 'membership_valid_from_formatted must keep its existing output');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidFromLocalized_NoPreferredLanguage_KeepsSessionFormat()
    var
        Entry: Record "NPR MM Member Notific. Entry";
        ValidFromLocalized: Text;
    begin
        // [SCENARIO] membership_valid_from_localized falls back to the session format when the member has no language
        // [GIVEN] A notification entry without a preferred language
        InitNotificationEntry(Entry, 20270930D, '');

        // [WHEN] The member data provider builds the content
        ValidFromLocalized := GetContentValue(Entry, 'membership_valid_from_localized');

        // [THEN] membership_valid_from_localized equals the session format
        _Assert.AreEqual(Format(20270930D, 0, '<Standard Format,0>'), ValidFromLocalized, 'Without a preferred language the session format is kept');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidFromLocalized_UnknownLanguage_KeepsSessionFormat()
    var
        Entry: Record "NPR MM Member Notific. Entry";
        Language: Record Language;
        ValidFromLocalized: Text;
    begin
        // [SCENARIO] membership_valid_from_localized falls back to the session format when the language code is unknown
        // [GIVEN] A notification entry whose language code has no Language record
        if Language.Get('NPRTESTXX') then
            Language.Delete();
        InitNotificationEntry(Entry, 20270930D, 'NPRTESTXX');

        // [WHEN] The member data provider builds the content
        ValidFromLocalized := GetContentValue(Entry, 'membership_valid_from_localized');

        // [THEN] membership_valid_from_localized equals the session format
        _Assert.AreEqual(Format(20270930D, 0, '<Standard Format,0>'), ValidFromLocalized, 'A language code with no Language record keeps the session format');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidFromLocalized_NoDate_IsEmpty()
    var
        Entry: Record "NPR MM Member Notific. Entry";
        ValidFromLocalized: Text;
    begin
        // [SCENARIO] membership_valid_from_localized is empty when there is no valid from date
        // [GIVEN] A Danish language and a notification entry without a valid from date
        CreateLanguage('NPRTESTDA', 1030);
        InitNotificationEntry(Entry, 0D, 'NPRTESTDA');

        // [WHEN] The member data provider builds the content
        ValidFromLocalized := GetContentValue(Entry, 'membership_valid_from_localized');

        // [THEN] membership_valid_from_localized is empty
        _Assert.AreEqual('', ValidFromLocalized, 'An empty valid from date stays empty');
    end;

    local procedure CreateLanguage(LanguageCode: Code[10]; WindowsLanguageId: Integer)
    var
        Language: Record Language;
    begin
        if not Language.Get(LanguageCode) then begin
            Language.Init();
            Language.Code := LanguageCode;
            Language.Insert();
        end;
        Language."Windows Language ID" := WindowsLanguageId;
        Language.Modify();
    end;

    local procedure InitNotificationEntry(var Entry: Record "NPR MM Member Notific. Entry"; ValidFrom: Date; LanguageCode: Code[10])
    begin
        Entry.Init();
        Entry."Membership Valid From" := ValidFrom;
        Entry.PreferredLanguageCode := LanguageCode;
    end;

    local procedure GetContentValue(Entry: Record "NPR MM Member Notific. Entry"; KeyName: Text): Text
    var
        DataProvider: Codeunit "NPR NPEmailMemberDataProvider";
        RecRef: RecordRef;
        Content: JsonObject;
        Token: JsonToken;
    begin
        RecRef.GetTable(Entry);
        Content := DataProvider.GetContent(RecRef);
        Content.Get(KeyName, Token);
        exit(Token.AsValue().AsText());
    end;
}
