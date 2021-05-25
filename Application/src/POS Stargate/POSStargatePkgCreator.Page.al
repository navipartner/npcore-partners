page 6150720 "NPR POS Stargate Pkg Creator"
{
    UsageCategory = None;
    PageType = Card;
    Caption = 'POS Stargate Package Creator';
    DataCaptionExpression = AssemblyName;
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "NPR POS Stargate Assem. Map";
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
                    field(AssemblyPath; AssemblyPath)
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Caption = 'Select Assembly';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Select Assembly field';

                        trigger OnAssistEdit()
                        begin
                            LoadAssembly();
                        end;
                    }
                    field(Control6150627; '')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                    field(PackageName; PackageName)
                    {
                        ApplicationArea = All;
                        Caption = 'Package Name';
                        ToolTip = 'Specifies the value of the Package Name field';
                    }
                    field(PackageVersion; PackageVersion)
                    {
                        ApplicationArea = All;
                        Caption = 'Package Version';
                        ToolTip = 'Specifies the value of the Package Version field';
                    }
                }
            }
            group(Dependencies)
            {
                Caption = 'Dependencies';
                Editable = false;
                field("Assembly Name"; Rec."Assembly Name")
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Assembly Name field';
                }
                field(Path; Rec.Path)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Editable = false;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Path field';

                    trigger OnAssistEdit()
                    begin
                        MapAssembly();
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                    ToolTip = 'Specifies the value of the Status field';
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the &Map Assembly action';

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the &Add Assembly action';

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create &Package action';

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
        Package: DotNet NPRNetPackage;
        AssemblyPath: Text;
        Text001: Label 'Select an assembly file';
        AssemblyName: Text;
        PackageName: Text;
        PackageVersion: Text;
        Style: Text;
        Text002: Label 'The assembly you selected has a different assembly name.\\Expected: %1\Actual: %2';
        Text003: Label 'Assembly you selected does not seem to be a valid match for %1.';
        Text004: Label 'Deleting this assembly will exclude it from the Stargate Package, and this may prevent the entier package from working correctly on the client.\\Are you sure you want to do this?';
        Text006: Label 'The assembly you selected does not contain any Stargate methods.';

    local procedure LoadAssembly()
    var
        FileMgt: Codeunit "File Management";
        String: DotNet NPRNetString;
        [RunOnClient]
        Assembly: DotNet NPRNetAssembly;
        FilePath: Text;
        TempBLOB: Codeunit "Temp Blob";
        Attachment: Record Attachment temporary;
    begin
        FilePath := FileMgt.BLOBImport(TempBLOB, '');

        Attachment.SetAttachmentFileFromBlob(TempBLOB);
        Attachment."Attachment File".Export(FilePath);

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
        Detector: DotNet NPRNetAssemblyDetector;
    begin
        Rec.DeleteAll();
        Detector := Detector.AssemblyDetector();
        Detector.DetectDependencies(Path);

        PopulateAssemblies(Detector.Resolved, Rec.Status::Mapped);
        PopulateAssemblies(Detector.Unknown, Rec.Status::Unknown);

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

    local procedure PopulateAssemblies(Dependencies: DotNet NPRNetIEnumerable_Of_T; Status: Option)
    var
        [RunOnClient]
        Dependency: DotNet NPRNetDetectionResult;
    begin
        foreach Dependency in Dependencies do begin
            Rec.Init();
            Rec."Assembly Name" := Dependency.AssemblyName;
            Rec.Status := Status;
            if Status = Rec.Status::Mapped then
                Rec.Path := Dependency.ResolvedPath;
            if IsKnownAssembly(Dependency.AssemblyName) then begin
                Rec.Status := Rec.Status::Known;
                Rec.Path := '';
            end;
            Rec.Insert();
        end;
    end;

    local procedure GetStyle()
    begin
        case Rec.Status of
            Rec.Status::Known:
                Style := 'Subordinate';
            Rec.Status::Mapped:
                Style := 'Favorable';
            Rec.Status::Unknown:
                Style := 'Unfavorable';
            Rec.Status::Additional:
                Style := 'StandardAccent';
        end;
    end;

    local procedure MapAssembly()
    var
        FileMgt: Codeunit "File Management";
        String: DotNet NPRNetString;
        [RunOnClient]
        Assembly: DotNet NPRNetAssembly;
        [RunOnClient]
        Detector: DotNet NPRNetAssemblyDetector;
        FilePath: Text;
        TempBLOB: Codeunit "Temp Blob";
        Attachment: Record Attachment temporary;
    begin
        FilePath := FileMgt.BLOBImportWithFilter(TempBLOB, Text001, AssemblyPath, 'Assembly files (*.dll)|*.dll', 'dll');

        Attachment.SetAttachmentFileFromBlob(TempBLOB);
        Attachment."Attachment File".Export(FilePath);

        if String.IsNullOrWhiteSpace(FilePath) then
            exit;

        Assembly := Assembly.ReflectionOnlyLoadFrom(FilePath);
        if Assembly.FullName <> Rec."Assembly Name" then
            Error(Text002, Rec."Assembly Name", Assembly.FullName);

        Detector := Detector.AssemblyDetector();
        if not Detector.IsSameAssembly(Rec."Assembly Name", FilePath) then
            Error(Text003, Rec."Assembly Name");

        Rec.Path := FilePath;
        Rec.Status := Rec.Status::Mapped;
        CurrPage.Update(true);
    end;

    local procedure AddAssembly()
    var
        FileMgt: Codeunit "File Management";
        String: DotNet NPRNetString;
        [RunOnClient]
        Assembly: DotNet NPRNetAssembly;
        FilePath: Text;
        TempBLOB: Codeunit "Temp Blob";
        Attachment: Record Attachment temporary;
    begin
        FilePath := FileMgt.BLOBImport(TempBLOB, '');

        Attachment.SetAttachmentFileFromBlob(TempBLOB);
        Attachment."Attachment File".Export(FilePath);

        if String.IsNullOrWhiteSpace(FilePath) then
            exit;

        Assembly := Assembly.ReflectionOnlyLoadFrom(FilePath);
        Rec.Init();
        Rec."Assembly Name" := Assembly.FullName;
        Rec.Status := Rec.Status::Additional;
        Rec.Path := FilePath;
        Rec.Insert(false);

        CurrPage.Update(false);
    end;

    local procedure CreatePackage()
    var
        Rec2: Record "NPR POS Stargate Assem. Map";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        Json: Text;
        [RunOnClient]
        AssemblyContent: DotNet NPRNetAssemblyPackageContent;
        FileName: Text;
    begin
        // TODO: if there are Unknown, then warnand ask for confirmation!
        Rec2 := Rec;

        Package.Name := PackageName;
        Package.Version := PackageVersion;

        if Rec.FindSet() then
            repeat
                if Rec.Status in [Rec.Status::Mapped, Rec.Status::Additional] then begin
                    AssemblyContent := AssemblyContent.AssemblyPackageContent(Rec.Path);
                    Package.AddContent(AssemblyContent);
                end;
            until Rec.Next() = 0;

        Rec := Rec2;

        Json := Package.ToJsonString();
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(Json);
        FileName := PackageName + '.' + PackageVersion + '.stargate';
        FileMgt.BLOBExport(TempBlob, FileName, true);
    end;
}

