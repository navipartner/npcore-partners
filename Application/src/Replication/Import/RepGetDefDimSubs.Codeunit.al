codeunit 6014672 "NPR Rep. Get Def. Dim. Subs."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Rep. Get BC Generic Data", 'OnAfterRecordIsModified', '', false, false)]
    local procedure UpdateReferenceIDFields(var RecRef: RecordRef; ReplicationEndpoint: Record "NPR Replication Endpoint")
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if RecRef.Number <> Database::"Default Dimension" then
            exit;

        if ReplicationEndpoint."Table ID" <> Database::"Default Dimension" then
            exit;

        if DefaultDimension.UpdateReferencedIdFields() then
            DefaultDimension.Modify();
    end;

}