codeunit 6248735 "NPR NPEmailUndefDocType" implements "NPR INPEmailDocType"
{
    Access = Internal;

    procedure GetDataProvider(): Enum "NPR DynTemplateDataProvider"
    begin
        exit(Enum::"NPR DynTemplateDataProvider"::UNDEFINED);
    end;

    procedure GetSourceTableId(): Integer
    begin
        exit(0);
    end;

    procedure TrySendNPEmail(RecRef: RecordRef; TemplateId: Code[20]): Boolean
    begin
        exit(false);
    end;
}
