page 6184496 "NPR Pepper Version List"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25\BR\20160510  CASE 231481 Added Install Zip File;
    // NPR5.29\BR\20161206  CASE 260315 Improve Performance of Blob
    // NPR5.48/BHR /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Pepper Version List';
    CardPageID = "NPR Pepper Version Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Version";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Zip File"; HasInstallFile)
                {
                    ApplicationArea = All;
                    Caption = 'Zip File';
                    Editable = false;
                    ToolTip = 'Specifies the value of the HasInstallFile field';
                }
                field("Pepper DLL Version"; Rec."Pepper DLL Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Pepper DLL Version field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Configurations action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Zip action';

                    trigger OnAction()
                    begin
                        Rec.UploadZipFile(0);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group("Delete")
            {
                action(DeleteZip)
                {
                    Caption = 'Zip';
                    Image = DeleteQtyToHandle;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Zip action';

                    trigger OnAction()
                    begin
                        Rec.ClearZipFile(0);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group(Export)
            {
                action(ExportZip)
                {
                    Caption = 'Zip';
                    Image = Export;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Zip action';

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
        UpdateBLOBCheck;
    end;

    var
        HasInstallFile: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        //-NPR5.29 [260315]
        //CALCFIELDS("Install Zip File");
        HasInstallFile := "Install Zip File".HasValue;
        //+NPR5.29 [260315]
    end;
}

