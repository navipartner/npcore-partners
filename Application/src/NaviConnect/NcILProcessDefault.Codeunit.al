codeunit 6184570 "NPR Nc IL Process Default" implements "NPR Nc Import List IProcess"
{
    Access = Internal;
    internal procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.Get(ImportEntry."Import Type");
        ImportType.TestField("Import Codeunit ID");
        CODEUNIT.Run(ImportType."Import Codeunit ID", ImportEntry);
    end;
}
