codeunit 6150900 "NPR POS Package Handler"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    var
        FileNameLbl: Label '%1 - %2', Locked = true;

    procedure ExportPOSMenuPackageToFile(var POSMenu: Record "NPR POS Menu")
    var
        ManagedPackageBuilder: Codeunit "NPR Managed Package Builder";
        POSMenuButton: Record "NPR POS Menu Button";
        POSMenu2: Record "NPR POS Menu";
        i: Integer;
        FileName: Text;
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        if not POSMenu.FindSet() then
            exit;

        repeat
            POSMenu2 := POSMenu;
            POSMenu2.SetRecFilter();
            POSMenuButton.SetRange("Menu Code", POSMenu2.Code);
            POSParameterValue.SetRange("Table No.", DATABASE::"NPR POS Menu Button");
            POSParameterValue.SetRange(Code, POSMenu2.Code);

            ManagedPackageBuilder.AddRecord(POSMenu2);
            ManagedPackageBuilder.AddRecord(POSMenuButton);
            ManagedPackageBuilder.AddRecord(POSParameterValue);
            i += 1;
        until POSMenu.Next() = 0;

        if i = 1 then
            FileName := StrSubstNo(FileNameLbl, 'POS Menu', POSMenu2.Code)
        else
            FileName := 'POS Menus';

        ManagedPackageBuilder.ExportToFile(FileName, '1.0', 'POS Menu Setup', DATABASE::"NPR POS Menu");
    end;

    procedure ImportPOSMenuPackageFromFile()
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Menu");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Menu Button");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"NPR POS Parameter Value");
        ManagedPackageMgt.ImportFromFile();
    end;

    procedure ExportPOSLayoutsToFile(var POSLayout: Record "NPR POS Layout"; Encoding: TextEncoding)
    var
        ManagedPackageBuilder: Codeunit "NPR Managed Package Builder";
        POSLayouts: Page "NPR POS Layouts";
        FileName: Text;
    begin
        ManagedPackageBuilder.AddRecord(POSLayout, Encoding);

        if POSLayout.Count() = 1 then
            FileName := StrSubstNo(FileNameLbl, POSLayout.TableCaption(), POSLayout.Code)
        else
            FileName := POSLayouts.Caption();
        ManagedPackageBuilder.ExportToFile(FileName, '1.0', FileName, Database::"NPR POS Layout", Encoding);
    end;

    procedure ImportPOSLayoutsFromFile(Encoding: TextEncoding)
    var
        ManagedPackageMgt: Codeunit "NPR Managed Package Mgt.";
        LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst;
    begin
        ManagedPackageMgt.AddExpectedTableID(Database::"NPR POS Layout");
        ManagedPackageMgt.SetLoadMethod(LoadMethod::InsertOrModify);
        ManagedPackageMgt.ImportFromFile(Encoding);
    end;
}
