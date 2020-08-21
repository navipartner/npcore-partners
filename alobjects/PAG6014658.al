page 6014658 ".NET Assemblies"
{
    // NPR4.17/VB/20151106 CASE 219641 Object created to support automatic assembly deployment
    // NPR5.01/VB/20160222 CASE 234462 Export Manifest file to managed services
    // NPR5.01/VB/20160223 CASE 234541 Support for storing and using debug information at assembly deployment
    // NPR5.29/TSA/20170105 CASE 260046 Added export assembly as a binary
    // NPR5.32.10/MMV /20170308 CASE 265454 Changed export manifest action.
    // NPR5.32.10/MMV /20170609 CASE 280081 Added support for payload versions in manifest.
    // NPR5.37/MMV /20171019 CASE 293066 Added hash support.

    Caption = '.NET Assemblies';
    PageType = List;
    SourceTable = ".NET Assembly";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Assembly Name"; "Assembly Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Assembly.HASVALUE"; Assembly.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'DLL Imported';
                    Editable = false;
                }
                field("""Debug Information"".HASVALUE"; "Debug Information".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'PDB Imported';
                    Editable = false;
                }
                field("MD5 Hash"; "MD5 Hash")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import Assembly...")
            {
                Caption = 'Import Assembly...';
                Ellipsis = true;
                Image = ImportDatabase;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ImportAssembly();
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
                    Rec2: Record ".NET Assembly";
                    JArray: DotNet JArray;
                begin
                    CurrPage.SetSelectionFilter(Rec2);
                    //-NPR5.32.10 [265454]
                    JArray := JArray.JArray();
                    ManagedDepMgt.RecordToJArray(Rec2, JArray);
                    ManagedDepMgt.ExportManifest(Rec2, JArray, 0);
                    //ManagedDepMgt.ExportManifest(Rec2);
                    //+NPR5.32.10 [265454]
                end;
            }
            action("Export Assemblies")
            {
                Caption = 'Export Assemblies';
                Image = ExportAttachment;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                begin
                    ExportAssembly();
                end;
            }
        }
    }

    procedure ImportAssembly()
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        Asm: DotNet npNetAssembly;
        Path: DotNet npNetPath;
        InStr: InStream;
        FileName: Text;
        AllFilesTxt: Label 'All Files';
        ImportFileTxt: Label '.NET Assembly';
        ImportTitleTxt: Label 'Import .NET Assembly';
        PDBFileName: Text;
    begin
        FileName := FileManagement.BLOBImportWithFilter(
          TempBlob, ImportTitleTxt, '',
          ImportFileTxt + ' (*.dll)|*.dll|' + AllFilesTxt + ' (*.*)|*.*', '*.*');

        if FileName <> '' then begin
            PDBFileName := Path.Combine(
              Path.GetDirectoryName(FileName),
              Path.GetFileNameWithoutExtension(FileName) + '.pdb');

            TempBlob.CreateInStream(InStr);
            InstallAssembly(InStr, Asm, '', PDBFileName);
            CurrPage.Update(false);
        end;
    end;

    local procedure ExportAssembly()
    var
        NETAssembly: Record ".NET Assembly";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        In_Stream: InStream;
        Out_Stream: OutStream;
        FileName: Text;
    begin

        CurrPage.SetSelectionFilter(NETAssembly);
        if (NETAssembly.FindSet()) then begin
            repeat

                NETAssembly.CalcFields(Assembly);
                if NETAssembly.Assembly.HasValue() then begin
                    TempBlob.CreateOutStream(Out_Stream);
                    NETAssembly.Assembly.CreateInStream(In_Stream);
                    CopyStream(Out_Stream, In_Stream);

                    FileManagement.BLOBExport(TempBlob, MakeNiceFilename(NETAssembly."Assembly Name"), true);
                end;
            until (NETAssembly.Next() = 0);
        end;
    end;

    local procedure MakeNiceFilename(Name: Text) Filename: Text
    begin

        Filename := Name + '.dll';
        if (StrPos(Name, ', Culture') - 1 > 2) then
            Filename := CopyStr(Name, 1, StrPos(Name, ', Culture') - 1) + '.dll';

        Filename := DelChr(Filename, '=', ',=');
        Filename := ConvertStr(Filename, ' ', '_');
    end;
}

