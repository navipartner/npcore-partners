page 6150713 "POS Stargate Packages"
{
    // NPR5.32.10/MMV /20170609 CASE 280081 Added support for payload versions in manifest.

    Caption = 'POS Stargate Packages';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "POS Stargate Package";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                }
                field(Version;Version)
                {
                }
                field(Control6150619;Methods)
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import Package")
            {
                Caption = 'Import Package';
                Image = NewItem;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ImportPackage();
                end;
            }
            action("Export Managed Dependency Manifest")
            {
                Caption = 'Export Managed Dependency Manifest';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ManagedDepMgt: Codeunit "Managed Dependency Mgt.";
                    Rec2: Record "POS Stargate Package";
                    JArray: DotNet JArray;
                    StargatePackageMethods: Record "POS Stargate Package Method";
                begin
                    //-NPR5.32.10 [265454]
                    CurrPage.SetSelectionFilter(Rec2);
                    JArray := JArray.JArray();

                    if Rec2.FindSet then repeat
                      StargatePackageMethods.SetRange("Package Name", Rec2.Name);
                      ManagedDepMgt.RecordToJArray(StargatePackageMethods, JArray);
                    until Rec2.Next = 0;
                    ManagedDepMgt.RecordToJArray(Rec2, JArray);
                    ManagedDepMgt.ExportManifest(Rec2, JArray, 1);
                    //+NPR5.32.10 [265454]
                end;
            }
        }
        area(navigation)
        {
            action(Methods)
            {
                Caption = 'Methods';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Stargate Package Method";
                RunPageLink = "Package Name"=FIELD(Name);
            }
        }
    }

    var
        Text001: Label 'Select Stargate Package file';
        Text002: Label 'Package %1 is already registered with version %2. You are importing it with version %3, %4. If you continue with the import, the existing version will be overwritten.\\Are you sure you want to continue?';
        Text003: Label 'which is newer';
        Text004: Label 'which is older';
        Text005: Label 'which is exactly the same version';

    local procedure ImportPackage()
    var
        StargatePackage: Record "POS Stargate Package";
        PackageMethod: Record "POS Stargate Package Method";
        FileMgt: Codeunit "File Management";
        Package: DotNet Package;
        String: DotNet String;
        [RunOnClient]
        IOFile: DotNet File;
        FilePath: Text;
        Method: Text;
        WhichIs: Text;
        DefaultYes: Boolean;
        OutStream: OutStream;
        FileContent: Text;
    begin
        FilePath := FileMgt.OpenFileDialog(Text001,'','Stargate Package files (*.stargate)|*.stargate|JSON files(*.json)|*.json');
        if String.IsNullOrWhiteSpace(FilePath) then
          exit;

        //Package := Package.FromJsonString(IOFile.ReadAllText(FilePath));
        FileContent := IOFile.ReadAllText(FilePath);
        Package := Package.FromJsonString(FileContent);

        if StargatePackage.Get(Package.Name) then begin
          case true of
            Package.Version > StargatePackage.Version: begin
              WhichIs := Text003;
              DefaultYes := true;
            end;
            Package.Version < StargatePackage.Version: WhichIs := Text004;
            else
              WhichIs := Text005;
          end;
          if not Confirm(Text002,DefaultYes,Package.Name,StargatePackage.Version,Package.Version,WhichIs) then
            exit;

          StargatePackage.Delete(false);
        end;

        Rec.Init;
        Rec.Name := Package.Name;
        Rec.Version := Package.Version;
        //Rec.JSON.IMPORT(FilePath);
        Rec.JSON.CreateOutStream(OutStream);
        OutStream.Write(FileContent);
        Rec.Insert();

        PackageMethod.SetRange("Method Name",Package.Name);
        PackageMethod.DeleteAll(false);
        foreach Method in Package.Methods do begin
          PackageMethod."Method Name" := Method;
          PackageMethod."Package Name" := Package.Name;
          if not PackageMethod.Insert(false) then;
        end;

        CurrPage.Update(false);
    end;
}

