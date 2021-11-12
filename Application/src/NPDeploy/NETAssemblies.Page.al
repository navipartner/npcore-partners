page 6059808 "NPR .NET Assemblies"
{
    Caption = '.NET Assemblies';
    PageType = List;
    SourceTable = "NPR DotNet Assembly";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Assembly Name"; Rec."Assembly Name")
                {
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Default Tooltip';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Default Tooltip';
                }
                field("Assembly Loaded"; Rec.Assembly.HasValue)
                {
                    Caption = 'DLL Imported';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Default Tooltip';
                }
                field("Debug Info Loaded"; Rec."Debug Information".HasValue)
                {
                    Caption = 'PDB Imported';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Default Tooltip';
                }
                field("MD5 Hash"; Rec."MD5 Hash")
                {
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Default Tooltip';
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
                ApplicationArea = NPRRetail;
                ToolTip = 'Add';

                trigger OnAction()
                begin
                    ImportAssembly();
                end;
            }
        }
    }

    procedure ImportAssembly()
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        InStr: InStream;
        FileName: Text;
        AllFilesTxt: Label 'All Files';
        ImportFileTxt: Label '.NET Assembly';
        ImportTitleTxt: Label 'Import .NET Assembly';
    begin
        FileName := FileManagement.BLOBImportWithFilter(
          TempBlob, ImportTitleTxt, '',
          ImportFileTxt + ' (*.dll)|*.dll|' + AllFilesTxt + ' (*.*)|*.*', '*.*');

        if FileName <> '' then begin
            TempBlob.CreateInStream(InStr);
            Rec.InstallAssembly(InStr);
            CurrPage.Update(false);
        end;
    end;
}