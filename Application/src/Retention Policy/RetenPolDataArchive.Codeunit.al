#if not (BC17 or BC18)
codeunit 6059927 "NPR Reten. Pol. Data Archive"
{
    Access = Internal;

    var
        DataArchive: Codeunit "Data Archive";
        UseDataArchive: Boolean;

    internal procedure CreateDataArchive(var RecRef: RecordRef)
    var
        RetentionPolicyDeletionDataArchiveDescriptionTxt: Label 'Retention Policy Deletion - %1 - %2', Comment = '%1 - table caption, %2 - today date';
    begin
#if (BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        if not IsDataArchiveEnabled(RecRef) then
            exit;
#endif

        UseDataArchive := DataArchive.DataArchiveProviderExists();
        if not UseDataArchive then
            exit;

        DataArchive.Create(StrSubstNo(RetentionPolicyDeletionDataArchiveDescriptionTxt, RecRef.Caption, Today));
        DataArchive.SaveRecords(RecRef);
    end;

    internal procedure SaveDataArchive()
    var
    begin
        if not UseDataArchive then
            exit;

        DataArchive.Save();
        UseDataArchive := false;
    end;

#if (BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
    local procedure IsDataArchiveEnabled(RecRef: RecordRef): Boolean
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RetenPolDeleting: Enum "Reten. Pol. Deleting";
    begin
        RetenPolDeleting := RetenPolAllowedTables.GetRetenPolDeleting(RecRef.Number);
        exit(RetenPolDeleting = RetenPolDeleting::"NPR Data Archive");
    end;
#endif
}
#endif