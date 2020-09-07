page 6184497 "NPR Pepper Version Card"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160412  CASE 231481 Page Actions updated
    // NPR5.25\BR\20160504  CASE 231481 Added Codeunit Install fields
    // NPR5.29\BR\20161206  CASE 260315 Improve Performance of Blob
    // NPR5.48/BHR /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Pepper Version Card';
    PageType = Card;
    SourceTable = "NPR Pepper Version";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Install Directory"; "Install Directory")
                {
                    ApplicationArea = All;
                }
                field("Pepper DLL Version"; "Pepper DLL Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Zip File"; HasZipFile)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(XMLports)
            {
                group(Configuration)
                {
                    field("XMLport Configuration"; "XMLport Configuration")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    field("XMLport Configuration Name"; "XMLport Configuration Name")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
            }
            group(Codeunits)
            {
                group("Begin Workshift")
                {
                    field("Codeunit Begin Workshift"; "Codeunit Begin Workshift")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    field("Codeunit Begin Workshift Name"; "Codeunit Begin Workshift Name")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
                group(Transaction)
                {
                    field("Codeunit Transaction"; "Codeunit Transaction")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    field("Codeunit Transaction Name"; "Codeunit Transaction Name")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
                group("End Workshift")
                {
                    field("Codeunit End Workshift"; "Codeunit End Workshift")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    field("Codeunit End Workshift Name"; "Codeunit End Workshift Name")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
                group(Auxiliary)
                {
                    field("Codeunit Auxiliary Functions"; "Codeunit Auxiliary Functions")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;

                        trigger OnValidate()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    field("Codeunit Auxiliary Name"; "Codeunit Auxiliary Name")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
                group(Install)
                {
                    field("Codeunit Install"; "Codeunit Install")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                    field("Codeunit Install Name"; "Codeunit Install Name")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
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
                Caption = 'Import';
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
                Caption = 'Delete';
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
                Caption = 'Export';
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
        HasZipFile: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        //-NPR5.29 [260315]
        //CALCFIELDS("Install Zip File");
        //+NPR5.29 [260315]
        HasZipFile := "Install Zip File".HasValue;
    end;
}

