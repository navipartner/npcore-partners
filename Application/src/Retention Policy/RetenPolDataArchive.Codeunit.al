#IF NOT BC17 AND NOT BC18
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
        if not IsDataArchiveEnabled(RecRef) then
            exit;

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

    local procedure IsDataArchiveEnabled(RecRef: RecordRef): Boolean
    var
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RetenPolDeleting: Enum "Reten. Pol. Deleting";
    begin
        RetenPolDeleting := RetenPolAllowedTables.GetRetenPolDeleting(RecRef.Number);
        exit(RetenPolDeleting = RetenPolDeleting::"NPR Data Archive");
    end;
}
#ENDIF