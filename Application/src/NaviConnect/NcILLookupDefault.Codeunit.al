codeunit 6184572 "NPR Nc IL Lookup Default" implements "NPR Nc Import List ILookup"
{

    Access = Internal;

    var
        NoDocsMsg: Label 'No Documents';

    internal procedure RunLookupImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.Get(ImportEntry."Import Type");
        ImportType.TestField("Lookup Codeunit ID");
        if not (CODEUNIT.Run(ImportType."Lookup Codeunit ID", ImportEntry)) then
            Message(NoDocsMsg);
    end;

}
