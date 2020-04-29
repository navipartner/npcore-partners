codeunit 6150900 "POS Package Handler"
{
    // NPR5.40/MMV /20180309 CASE 307453 Handle new parameter table.


    trigger OnRun()
    begin
    end;

    local procedure "// Export"()
    begin
    end;

    procedure ExportPOSMenuPackageToFile(var POSMenu: Record "POS Menu")
    var
        ManagedPackageBuilder: Codeunit "Managed Package Builder";
        POSMenuButton: Record "POS Menu Button";
        POSMenu2: Record "POS Menu";
        i: Integer;
        FileName: Text;
        POSParameterValue: Record "POS Parameter Value";
    begin
        if not POSMenu.FindSet then
          exit;

        repeat
          POSMenu2 := POSMenu;
          POSMenu2.SetRecFilter;
          POSMenuButton.SetRange("Menu Code", POSMenu2.Code);
          //-NPR5.40 [307453]
          POSParameterValue.SetRange("Table No.", DATABASE::"POS Menu Button");
          POSParameterValue.SetRange(Code, POSMenu2.Code);
          //+NPR5.40 [307453]

          ManagedPackageBuilder.AddRecord(POSMenu2);
          ManagedPackageBuilder.AddRecord(POSMenuButton);
          //-NPR5.40 [307453]
          ManagedPackageBuilder.AddRecord(POSParameterValue);
          //+NPR5.40 [307453]
          i += 1;
        until POSMenu.Next = 0;

        if i = 1 then
          FileName := StrSubstNo('%1 - %2','POS Menu', POSMenu2.Code)
        else
          FileName := 'POS Menus';

        ManagedPackageBuilder.ExportToFile(FileName, '1.0', 'POS Menu Setup', DATABASE::"POS Menu");
    end;

    local procedure "// Import"()
    begin
    end;

    procedure ImportPOSMenuPackageFromFile()
    var
        ManagedPackageMgt: Codeunit "Managed Package Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"POS Menu");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"POS Menu Button");
        //-NPR5.40 [307453]
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"POS Parameter Value");
        //+NPR5.40 [307453]
        ManagedPackageMgt.ImportFromFile();
    end;

    procedure DeployPOSMenuPackageFromGroundControl()
    var
        ManagedPackageMgt: Codeunit "Managed Package Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"POS Menu");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"POS Menu Button");
        //-NPR5.40 [307453]
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"POS Parameter Value");
        //+NPR5.40 [307453]
        ManagedPackageMgt.DeployPackageFromGroundControl(DATABASE::"POS Menu");
    end;
}

