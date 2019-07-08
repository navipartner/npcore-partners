page 6150720 "POS Stargate Package Creator"
{
    Caption = 'POS Stargate Package Creator';
    DataCaptionExpression = AssemblyName;
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "POS Stargate Assembly Map";
    SourceTableTemporary = true;
    SourceTableView = SORTING(Status);

    layout
    {
        area(content)
        {
            group("Assembly Selection")
            {
                Caption = 'Assembly Selection';
                group(Control6150626)
                {
                    ShowCaption = false;
                    field(AssemblyPath;AssemblyPath)
                    {
                        AssistEdit = true;
                        Caption = 'Select Assembly';
                        Editable = false;

                        trigger OnAssistEdit()
                        begin
                            LoadAssembly();
                        end;
                    }
                    field(Control6150627;'')
                    {
                        ShowCaption = false;
                    }
                    field(PackageName;PackageName)
                    {
                        Caption = 'Package Name';
                    }
                    field(PackageVersion;PackageVersion)
                    {
                        Caption = 'Package Version';
                    }
                }
            }
            repeater(Dependencies)
            {
                Caption = 'Dependencies';
                Editable = false;
                field("Assembly Name";"Assembly Name")
                {
                    StyleExpr = Style;
                }
                field(Path;Path)
                {
                    AssistEdit = true;
                    Editable = false;
                    StyleExpr = Style;

                    trigger OnAssistEdit()
                    begin
                        MapAssembly();
                    end;
                }
                field(Status;Status)
                {
                    StyleExpr = Style;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Map Assembly")
            {
                Caption = '&Map Assembly';
                Ellipsis = true;
                Image = ViewDocumentLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    MapAssembly();
                end;
            }
            action("&Add Assembly")
            {
                Caption = '&Add Assembly';
                Ellipsis = true;
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AddAssembly();
                end;
            }
            action("Create &Package")
            {
                Caption = 'Create &Package';
                Ellipsis = true;
                Image = NewItem;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CreatePackage();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetStyle();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        exit(Confirm(Text004));
    end;

    var
        [RunOnClient]
        Package: DotNet Package;
        AssemblyPath: Text;
        Text001: Label 'Select an assembly file';
        AssemblyName: Text;
        PackageName: Text;
        PackageVersion: Text;
        Style: Text;
        Text002: Label 'The assembly you selected has a different assembly name.\\Expected: %1\Actual: %2';
        Text003: Label 'Assembly you selected does not seem to be a valid match for %1.';
        Text004: Label 'Deleting this assembly will exclude it from the Stargate Package, and this may prevent the entier package from working correctly on the client.\\Are you sure you want to do this?';
        Text005: Label 'Specify destination';
        Text006: Label 'The assembly you selected does not contain any Stargate methods.';

    local procedure LoadAssembly()
    var
        FileMgt: Codeunit "File Management";
        String: DotNet String;
        [RunOnClient]
        Assembly: DotNet Assembly;
        FilePath: Text;
    begin
        FilePath := FileMgt.OpenFileDialog(Text001,AssemblyPath,'Assembly files (*.dll)|*.dll');
        if String.IsNullOrWhiteSpace(FilePath) then
          exit;

        Package := Package.Package(FilePath);
        if Package.Methods.Length = 0 then
          Error(Text006);

        AssemblyPath := FilePath;

        PackageName := Package.AssemblyShortName;
        PackageVersion := Package.Version;

        Assembly := Assembly.ReflectionOnlyLoadFrom(AssemblyPath);
        AssemblyName := Assembly.FullName;

        DetectDependencies(AssemblyPath);
    end;

    local procedure DetectDependencies(Path: Text)
    var
        [RunOnClient]
        Detector: DotNet AssemblyDetector;
        Dependency: Text;
    begin
        Rec.DeleteAll();
        Detector := Detector.AssemblyDetector();
        Detector.DetectDependencies(Path);

        PopulateAssemblies(Detector.Resolved,Rec.Status::Mapped);
        PopulateAssemblies(Detector.Unknown,Rec.Status::Unknown);

        if Rec.FindFirst() then
          CurrPage.Update(false);
    end;

    local procedure IsKnownAssembly(Name: Text): Boolean
    begin
        exit(Name in
          [
            'Newtonsoft.Json, Version=7.0.0.0, Culture=neutral, PublicKeyToken=30ad4fe6b2a6aeed',
            'NaviPartner.Retail.Stargate, Version=5.3.745.0, Culture=neutral, PublicKeyToken=909fa1bba7619e33'
          ]);
    end;

    local procedure PopulateAssemblies(Dependencies: DotNet IEnumerable_Of_T;Status: Option)
    var
        [RunOnClient]
        Dependency: DotNet DetectionResult;
    begin
        foreach Dependency in Dependencies do begin
          Rec.Init;
          Rec."Assembly Name" := Dependency.AssemblyName;
          Rec.Status := Status;
          if Status = Rec.Status::Mapped then
            Rec.Path := Dependency.ResolvedPath;
          if IsKnownAssembly(Dependency.AssemblyName) then begin
            Rec.Status := Rec.Status::Known;
            Rec.Path := '';
          end;
          Rec.Insert;
        end;
    end;

    local procedure GetStyle()
    begin
        case Rec.Status of
          Rec.Status::Known: Style := 'Subordinate';
          Rec.Status::Mapped: Style := 'Favorable';
          Rec.Status::Unknown: Style := 'Unfavorable';
          Rec.Status::Additional: Style := 'StandardAccent';
        end;
    end;

    local procedure MapAssembly()
    var
        FileMgt: Codeunit "File Management";
        String: DotNet String;
        [RunOnClient]
        Assembly: DotNet Assembly;
        [RunOnClient]
        Detector: DotNet AssemblyDetector;
        FilePath: Text;
    begin
        FilePath := FileMgt.OpenFileDialog(Text001,AssemblyPath,'Assembly files (*.dll)|*.dll');
        if String.IsNullOrWhiteSpace(FilePath) then
          exit;

        Assembly := Assembly.ReflectionOnlyLoadFrom(FilePath);
        if Assembly.FullName <> "Assembly Name" then
          Error(Text002,"Assembly Name",Assembly.FullName);

        Detector := Detector.AssemblyDetector();
        if not Detector.IsSameAssembly("Assembly Name",FilePath) then
          Error(Text003,"Assembly Name");

        Rec.Path := FilePath;
        Rec.Status := Rec.Status::Mapped;
        CurrPage.Update(true);
    end;

    local procedure AddAssembly()
    var
        FileMgt: Codeunit "File Management";
        String: DotNet String;
        [RunOnClient]
        Assembly: DotNet Assembly;
        [RunOnClient]
        Detector: DotNet AssemblyDetector;
        FilePath: Text;
    begin
        FilePath := FileMgt.OpenFileDialog(Text001,AssemblyPath,'Assembly files (*.dll)|*.dll');
        if String.IsNullOrWhiteSpace(FilePath) then
          exit;

        Assembly := Assembly.ReflectionOnlyLoadFrom(FilePath);
        Rec.Init;
        Rec."Assembly Name" := Assembly.FullName;
        Rec.Status := Rec.Status::Additional;
        Rec.Path := FilePath;
        Rec.Insert(false);

        CurrPage.Update(false);
    end;

    local procedure CreatePackage()
    var
        Rec2: Record "POS Stargate Assembly Map";
        FileMgt: Codeunit "File Management";
        [RunOnClient]
        AssemblyContent: DotNet AssemblyPackageContent;
        String: DotNet String;
        [RunOnClient]
        IOFile: DotNet File;
        FilePath: Text;
    begin
        // TODO: if there are Unknown, then warn and ask for confirmation!
        Rec2 := Rec;

        Package.Name := PackageName;
        Package.Version := PackageVersion;

        if Rec.FindSet then
          repeat
            if Rec.Status in [Rec.Status::Mapped,Rec.Status::Additional] then begin
              AssemblyContent := AssemblyContent.AssemblyPackageContent(Rec.Path);
              Package.AddContent(AssemblyContent);
            end;
          until Rec.Next = 0;

        Rec := Rec2;

        FilePath := FileMgt.SaveFileDialog(Text005,PackageName + '.' + PackageVersion + '.stargate','Stargate Package files (*.stargate)|*.stargate|JSON files(*.json)|*.json');
        if String.IsNullOrWhiteSpace(FilePath) then
          exit;

        if IOFile.Exists(FilePath) then
          IOFile.Delete(FilePath);

        IOFile.AppendAllText(FilePath,Package.ToJsonString());
    end;
}

