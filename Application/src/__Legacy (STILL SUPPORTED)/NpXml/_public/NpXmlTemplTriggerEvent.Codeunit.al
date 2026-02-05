codeunit 6151516 "NPR NpXml Templ. Trigger Event"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    [IntegrationEvent(false, false)]
    internal procedure OnSetupGenericParentTable("Generic Parent Codeunit ID": Integer; "Generic Parent Function": Text[250]; ChildLinkRecRef: RecordRef; var ParentRecRef: RecordRef; var Handled: Boolean)
    begin
    end;

}
