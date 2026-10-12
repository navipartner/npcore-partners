codeunit 85522 "NPR POS Layout Arch xRec Tests"
{
    // [FEATURE] POS layout archiving on modify: the previous version is archived, and the subscriber leaves xRec to later subscribers
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure ModifyingAPOSLayoutArchivesThePreviousVersion()
    var
        POSLayout: Record "NPR POS Layout";
        POSLayoutArchive: Record "NPR POS Layout Archive";
    begin
        // [SCENARIO] Changing a POS layout from code archives the version that was on disk before the change.
        // [GIVEN] A POS layout
        CreateLayout(POSLayout, 'Before');

        // [WHEN] The description is changed from code
        POSLayout.Description := 'After';
        POSLayout.Modify(true);

        // [THEN] An archived version carries the previous description
        POSLayoutArchive.SetRange(Code, POSLayout.Code);
        _Assert.AreEqual(1, POSLayoutArchive.Count(), 'Exactly one archived version must exist');
        POSLayoutArchive.FindFirst();
        _Assert.AreEqual('Before', POSLayoutArchive.Description, 'The archive must hold the version before the change');
    end;

    [Test]
    procedure CodeDrivenPOSLayoutModifyLeavesXRecUntouchedForLaterSubscribers()
    var
        POSLayout: Record "NPR POS Layout";
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] A code-driven modify of a POS layout reaches later subscribers with the xRec the platform supplied, which carries the description being written rather than the one on disk.
        // [GIVEN] A POS layout
        CreateLayout(POSLayout, 'Before');

        // [GIVEN] A probe subscriber observing the modify event
        BindSubscription(TestXRecProbe);

        // [WHEN] The description is changed from code
        POSLayout.Description := 'After';
        POSLayout.Modify(true);

        // [THEN] The probe saw the modify with xRec still carrying the new description
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::"NPR POS Layout"), 'The probe must observe the layout modify');
        _Assert.IsTrue(TestXRecProbe.XRecCarriesRecValue(Database::"NPR POS Layout"), 'The archive subscriber must not replace xRec');
    end;

    [Test]
    procedure ChangingOnlyTheLayoutArchivesThePreviousLayout()
    var
        POSLayout: Record "NPR POS Layout";
        POSLayoutArchive: Record "NPR POS Layout Archive";
        ArchivedBefore: Integer;
    begin
        // [SCENARIO] Changing only the layout content of a POS layout from code archives the layout that was on disk before the change.
        // [GIVEN] A POS layout whose layout content is the old one, and the archived versions it has so far
        CreateLayout(POSLayout, 'Unchanged');
        POSLayout.SetLayout('{"layout":"old"}');
        POSLayout.Modify(false);
        POSLayoutArchive.SetRange(Code, POSLayout.Code);
        ArchivedBefore := POSLayoutArchive.Count();

        // [WHEN] Only the layout content is changed from code
        POSLayout.SetLayout('{"layout":"new"}');
        POSLayout.Modify(true);

        // [THEN] One more version is archived, and it carries the old layout content
        _Assert.AreEqual(ArchivedBefore + 1, POSLayoutArchive.Count(), 'Changing only the layout must archive one version');
        POSLayoutArchive.FindLast();
        _Assert.AreEqual('{"layout":"old"}', POSLayoutArchive.GetLayout(), 'The archive must hold the layout before the change');
    end;

    [Test]
    procedure ChangingOnlyTheDescriptionArchivesTheLayoutContent()
    var
        POSLayout: Record "NPR POS Layout";
        POSLayoutArchive: Record "NPR POS Layout Archive";
    begin
        // [SCENARIO] Changing only the description of a POS layout from code archives a version that still carries the layout content.
        // [GIVEN] A POS layout with layout content, read back without its layout content calculated
        CreateLayout(POSLayout, 'Before');
        POSLayout.SetLayout('{"layout":"kept"}');
        POSLayout.Modify(false);
        POSLayout.Get(POSLayout.Code);

        // [WHEN] Only the description is changed from code
        POSLayout.Description := 'After';
        POSLayout.Modify(true);

        // [THEN] The archived version carries the layout content
        POSLayoutArchive.SetRange(Code, POSLayout.Code);
        POSLayoutArchive.FindLast();
        _Assert.AreEqual('{"layout":"kept"}', POSLayoutArchive.GetLayout(), 'The archive must hold the layout content as well as the old description');
    end;

    [Test]
    procedure DeletingAPOSLayoutArchivesItsLayoutContent()
    var
        POSLayout: Record "NPR POS Layout";
        POSLayoutArchive: Record "NPR POS Layout Archive";
    begin
        // [SCENARIO] Deleting a POS layout archives a version that carries its layout content.
        // [GIVEN] A POS layout with layout content, read back without its layout content calculated
        CreateLayout(POSLayout, 'Doomed');
        POSLayout.SetLayout('{"layout":"last"}');
        POSLayout.Modify(false);
        POSLayout.Get(POSLayout.Code);

        // [WHEN] The layout is deleted
        POSLayout.Delete(true);

        // [THEN] The archived version carries the layout content
        POSLayoutArchive.SetRange(Code, POSLayout.Code);
        POSLayoutArchive.FindLast();
        _Assert.AreEqual('{"layout":"last"}', POSLayoutArchive.GetLayout(), 'The archive of a deleted layout must hold its layout content');
    end;

    local procedure CreateLayout(var POSLayout: Record "NPR POS Layout"; Description: Text[100])
    begin
        POSLayout.Init();
        POSLayout.Code := CopyStr('L' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(POSLayout.Code));
        POSLayout.Description := Description;
        POSLayout.Insert(true);
    end;
}
