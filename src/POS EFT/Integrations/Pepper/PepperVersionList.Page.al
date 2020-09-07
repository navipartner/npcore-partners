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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Zip File"; HasInstallFile)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Pepper DLL Version"; "Pepper DLL Version")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                ApplicationArea=All;
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
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        UploadZipFile(0);
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
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ClearZipFile(0);
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
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ExportZipFile(0);
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

