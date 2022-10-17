codeunit 6014460 "NPR Aux. Tables Event Subs."
{
    Access = Internal;

    #region G/L Account

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterDeleteEvent', '', false, false)]
    local procedure GLAccountOnAfterOnDelete(var Rec: Record "G/L Account")
    begin
        if Rec.IsTemporary() then
            exit;

        Rec.NPRDeleteGLAccAdditionalFields();
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterRenameEvent', '', false, false)]
    local procedure GLAccountOnAfterRename(var Rec: Record "G/L Account"; var xRec: Record "G/L Account")
    var
        AuxGLAccount: Record "NPR Aux. G/L Account";
    begin
        if Rec.IsTemporary() then
            exit;

        if AuxGLAccount.Get(xRec."No.") then
            AuxGLAccount.Rename(Rec."No.");
    end;
    #endregion
}
