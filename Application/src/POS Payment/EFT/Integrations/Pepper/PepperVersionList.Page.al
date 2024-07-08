page 6184496 "NPR Pepper Version List"
{
    Extensible = False;
    Caption = 'Pepper Version List';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/pepper_terminal/';
    CardPageID = "NPR Pepper Version Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Version";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique code of the Pepper Version';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Pepper Version';
                    ApplicationArea = NPRRetail;
                }
                field("Zip File"; HasInstallFile)
                {

                    Caption = 'Zip File';
                    Editable = false;
                    ToolTip = 'Indicates whether the Pepper Version has an associated installation zip file';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper DLL Version"; Rec."Pepper DLL Version")
                {

                    Editable = false;
                    ToolTip = 'Specifies the version of the Pepper DLL associated with the Pepper Version';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Configurations)
            {
                Caption = 'Configurations';
                Image = Setup;
                RunObject = Page "NPR Pepper Config. List";

                ToolTip = 'Configures settings for the Pepper Version';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            group(Import)
            {
                action(ImportZip)
                {
                    Caption = 'Zip';
                    Image = Import;

                    ToolTip = 'Imports a zip file for the Pepper Version';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadZipFile(0);
                        UpdateBLOBCheck();
                    end;
                }
            }
            group("Delete")
            {
                action(DeleteZip)
                {
                    Caption = 'Zip';
                    Image = DeleteQtyToHandle;

                    ToolTip = 'Deletes the zip file associated with the Pepper Version';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearZipFile(0);
                        UpdateBLOBCheck();
                    end;
                }
            }
            group(Export)
            {
                action(ExportZip)
                {
                    Caption = 'Zip';
                    Image = Export;

                    ToolTip = 'Exports the zip file for the Pepper Version';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportZipFile(0);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateBLOBCheck();
    end;

    var
        HasInstallFile: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        HasInstallFile := Rec."Install Zip File".HasValue();
    end;
}