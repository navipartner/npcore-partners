page 6150713 "NPR POS Stargate Packages"
{
    Caption = 'POS Stargate Packages';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Stargate Package";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field(Control6150619; Rec.Methods)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Methods field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import Package action';

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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Export Managed Dependency Manifest action';

                trigger OnAction()
                var
                    Rec2: Record "NPR POS Stargate Package";
                    StargatePackageMethods: Record "NPR POS Stargate Pckg. Method";
                    ManagedDepMgt: Codeunit "NPR Managed Dependency Mgt.";
                    JArray: JsonArray;
                begin
                    CurrPage.SetSelectionFilter(Rec2);

                    if Rec2.FindSet() then
                        repeat
                            StargatePackageMethods.SetRange("Package Name", Rec2.Name);
                            ManagedDepMgt.RecordToJArray(StargatePackageMethods, JArray);
                        until Rec2.Next() = 0;
                    ManagedDepMgt.RecordToJArray(Rec2, JArray);
                    ManagedDepMgt.ExportManifest(Rec2, JArray, 1);
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Stargate Pckg Method";
                RunPageLink = "Package Name" = FIELD(Name);
                ApplicationArea = All;
                ToolTip = 'Executes the Methods action';
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
        StargatePackage: Record "NPR POS Stargate Package";
        PackageMethod: Record "NPR POS Stargate Pckg. Method";
        FileMgt: Codeunit "File Management";
        Package: DotNet NPRNetPackage;
        String: DotNet NPRNetString;
        [RunOnClient]
        IOFile: DotNet NPRNetFile;
        FilePath: Text;
        Method: Text;
        WhichIs: Text;
        DefaultYes: Boolean;
        OutStr: OutStream;
        FileContent: Text;
    begin
        FilePath := FileMgt.OpenFileDialog(Text001, '', 'Stargate Package files (*.stargate)|*.stargate|JSON files(*.json)|*.json');
        if String.IsNullOrWhiteSpace(FilePath) then
            exit;

        FileContent := IOFile.ReadAllText(FilePath);
        Package := Package.FromJsonString(FileContent);

        if StargatePackage.Get(Package.Name) then begin
            case true of
                Package.Version > StargatePackage.Version:
                    begin
                        WhichIs := Text003;
                        DefaultYes := true;
                    end;
                Package.Version < StargatePackage.Version:
                    WhichIs := Text004;
                else
                    WhichIs := Text005;
            end;
            if not Confirm(Text002, DefaultYes, Package.Name, StargatePackage.Version, Package.Version, WhichIs) then
                exit;

            StargatePackage.Delete(false);
        end;

        Rec.Init;
        Rec.Name := Package.Name;
        Rec.Version := Package.Version;
        Rec.JSON.CreateOutStream(OutStr);
        OutStr.Write(FileContent);
        Rec.Insert();

        PackageMethod.SetRange("Method Name", Package.Name);
        PackageMethod.DeleteAll(false);
        foreach Method in Package.Methods do begin
            PackageMethod."Method Name" := Method;
            PackageMethod."Package Name" := Package.Name;
            if not PackageMethod.Insert(false) then;
        end;

        CurrPage.Update(false);
    end;
}

