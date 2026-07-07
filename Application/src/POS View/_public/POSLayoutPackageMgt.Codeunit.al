codeunit 6248495 "NPR POS Layout Package Mgt."
{
    // This codeunit is intentionally Public. It is the supported surface used by PTEs to copy POS Layouts between companies and environments.

    procedure ExportAllPOSLayoutsToText() PackageAsJson: Text
    var
        POSLayout: Record "NPR POS Layout";
        ManagedPackageBuilder: Codeunit "NPR Managed Package Builder";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
    begin
        if POSLayout.IsEmpty() then
            exit('');

        ManagedPackageBuilder.AddRecord(POSLayout, TextEncoding::UTF8);
        ManagedPackageBuilder.ExportToBlob('POS Layouts', '1.0', 'POS Layouts', Database::"NPR POS Layout", TempBlob);

        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        InStr.Read(PackageAsJson);
    end;

    procedure ImportPOSLayoutsFromText(PackageAsJson: Text) LayoutCount: Integer
    var
        POSLayout: Record "NPR POS Layout";
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst;
    begin
        ManagedPackageMgt.AddExpectedTableID(Database::"NPR POS Layout");
        ManagedPackageMgt.SetLoadMethod(LoadMethod::InsertOrModify);
        ManagedPackageMgt.ImportFromText(PackageAsJson, TextEncoding::UTF8);
        LayoutCount := POSLayout.Count();
    end;
}
