codeunit 85062 "NPR Library - NaviConnect"
{
    procedure CreateImportType(): Code[20]
    var
        ImportType: Record "NPR Nc Import Type";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ImportType.Init();
        ImportType.Code := LibraryUtility.GenerateRandomCode(ImportType.FieldNo(Code), Database::"NPR Nc Import Type");
        ImportType.Insert();

        exit(ImportType.Code);
    end;
}