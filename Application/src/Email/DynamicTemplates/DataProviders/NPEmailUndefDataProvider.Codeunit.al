#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248375 "NPR NPEmailUndefDataProvider" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    begin
        ErrorNotDefined();
    end;

    procedure GenerateContentExample(): JsonObject
    begin
        ErrorNotDefined();
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
        ErrorNotDefined();
    end;

    local procedure ErrorNotDefined()
    var
        DataProviderNotDefinedErr: Label 'Data provider has not been defined';
    begin
        Error(DataProviderNotDefinedErr);
    end;
}
#endif