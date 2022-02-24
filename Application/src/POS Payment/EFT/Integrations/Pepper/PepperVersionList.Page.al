page 6184496 "NPR Pepper Version List"
{
    Extensible = False;
    Caption = 'Pepper Version List';
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Zip File"; HasInstallFile)
                {

                    Caption = 'Zip File';
                    Editable = false;
                    ToolTip = 'Specifies the value of the HasInstallFile field';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper DLL Version"; Rec."Pepper DLL Version")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Pepper DLL Version field';
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

                ToolTip = 'Executes the Configurations action';
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

                    ToolTip = 'Executes the Zip action';
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

                    ToolTip = 'Executes the Zip action';
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

                    ToolTip = 'Executes the Zip action';
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

