codeunit 6151252 "NPR MM Member Change Log Mgt"
{
    Access = Internal;
    Permissions = TableData "NPR MM Member Change Log" = rid;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterGetDatabaseTableTriggerSetup', '', true, false)]
    local procedure SetupMemberTriggers(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
        if (TableId = Database::"NPR MM Member") then begin
            OnDatabaseModify := true;
            OnDatabaseDelete := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseModify', '', true, false)]
    local procedure LogMemberModify(RecRef: RecordRef)
    var
        Member: Record "NPR MM Member";
        xMember: Record "NPR MM Member";
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
        FieldNo: Integer;
        IsReadable: Boolean;
    begin
        if (RecRef.Number <> Database::"NPR MM Member") then
            exit;
        if (RecRef.IsTemporary) then
            exit;
        if (DatabaseTriggersDisabled()) then
            exit;

        xRecRef.Open(RecRef.Number, false, RecRef.CurrentCompany());
        xRecRef.ReadIsolation := IsolationLevel::ReadCommitted;
        xRecRef.SecurityFiltering := SecurityFilter::Filtered;
        if (xRecRef.ReadPermission()) then begin
            IsReadable := true;
            if (not xRecRef.Get(RecRef.RecordId)) then
                exit;
        end;

        RecRef.SetTable(Member);
        xRecRef.SetTable(xMember);

        foreach FieldNo in TrackedFieldNumbers() do begin
            FldRef := RecRef.Field(FieldNo);
            xFldRef := xRecRef.Field(FieldNo);
            if (IsNormalField(FldRef)) then
                if (FieldValueChanged(Member, xMember, FldRef, xFldRef)) then
                    InsertLogEntry(Member."Entry No.", FldRef, xFldRef, IsReadable);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseDelete', '', true, false)]
    local procedure DeleteMemberChangeLog(RecRef: RecordRef)
    var
        Member: Record "NPR MM Member";
        MemberChangeLog: Record "NPR MM Member Change Log";
    begin
        if (RecRef.Number <> Database::"NPR MM Member") then
            exit;
        if (RecRef.IsTemporary) then
            exit;

        RecRef.SetTable(Member);
        MemberChangeLog.SetRange("Member Entry No.", Member."Entry No.");
        if (not MemberChangeLog.IsEmpty()) then
            MemberChangeLog.DeleteAll();
    end;

    local procedure DatabaseTriggersDisabled(): Boolean
    var
        SaaSImportSetup: Record "NPR SaaS Import Setup";
    begin
        if (not SaaSImportSetup.ReadPermission()) then
            exit(false);
        if (not SaaSImportSetup.Get()) then
            exit(false);
        exit(SaaSImportSetup."Disable Database Triggers");
    end;

    local procedure FieldValueChanged(Member: Record "NPR MM Member"; xMember: Record "NPR MM Member"; FldRef: FieldRef; xFldRef: FieldRef): Boolean
    begin
        if (FldRef.Value = xFldRef.Value) then
            exit(false);

        if (FldRef.Number = Member.FieldNo(Image)) then
            exit(MemberImageChanged(Member, xMember));

        exit(true);
    end;

    local procedure MemberImageChanged(Member: Record "NPR MM Member"; xMember: Record "NPR MM Member"): Boolean
    var
        Sentry: Codeunit "NPR Sentry";
        ImagesDiffer: Boolean;
    begin
        if (Member.Image.HasValue() <> xMember.Image.HasValue()) then
            exit(true);
        if (not Member.Image.HasValue()) then
            exit(false);

        if (TryImagesDiffer(Member, xMember, ImagesDiffer)) then
            exit(ImagesDiffer);

        Sentry.AddLastErrorIfProgrammingBug();
        exit(true);
    end;

    [TryFunction]
    local procedure TryImagesDiffer(Member: Record "NPR MM Member"; xMember: Record "NPR MM Member"; var ImagesDiffer: Boolean)
    begin
        ImagesDiffer := ImageHash(Member) <> ImageHash(xMember);
    end;

    local procedure ImageHash(Member: Record "NPR MM Member"): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        TempBlob.CreateOutStream(OutStr);
        Member.Image.ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);
        exit(CryptographyManagement.GenerateHash(InStr, HashAlgorithmType::SHA256));
    end;

    local procedure InsertLogEntry(MemberEntryNo: Integer; FldRef: FieldRef; xFldRef: FieldRef; IsReadable: Boolean)
    var
        MemberChangeLog: Record "NPR MM Member Change Log";
    begin
        MemberChangeLog.Init();
        MemberChangeLog."Member Entry No." := MemberEntryNo;
        MemberChangeLog."Field No." := FldRef.Number;
        if (IsReadable) then
            MemberChangeLog."Old Value" := CopyStr(Format(xFldRef.Value, 0, 9), 1, MaxStrLen(MemberChangeLog."Old Value"));
        MemberChangeLog."New Value" := CopyStr(Format(FldRef.Value, 0, 9), 1, MaxStrLen(MemberChangeLog."New Value"));
        MemberChangeLog.Insert(true);
    end;

    local procedure IsNormalField(FldRef: FieldRef): Boolean
    begin
        exit(FldRef.Class = FieldClass::Normal);
    end;

    local procedure TrackedFieldNumbers() FieldNumbers: List of [Integer]
    var
        Member: Record "NPR MM Member";
        MemberImageMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin
        FieldNumbers.Add(Member.FieldNo("First Name"));
        FieldNumbers.Add(Member.FieldNo("Last Name"));
        FieldNumbers.Add(Member.FieldNo("E-Mail Address"));
        FieldNumbers.Add(Member.FieldNo(Birthday));

        if (not MemberImageMedia.IsFeatureEnabled()) then
            FieldNumbers.Add(Member.FieldNo(Image));
    end;
}
