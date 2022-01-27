page 6184497 "NPR Pepper Version Card"
{
    Extensible = False;
    Caption = 'Pepper Version Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Pepper Version";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
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
                field("Install Directory"; Rec."Install Directory")
                {

                    ToolTip = 'Specifies the value of the Install Directory field';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper DLL Version"; Rec."Pepper DLL Version")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Pepper DLL Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Zip File"; HasZipFile)
                {

                    Caption = 'Zip File';
                    Editable = false;
                    ToolTip = 'Specifies the value of the HasZipFile field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(XMLports)
            {
                group(Configuration)
                {
                    field("XMLport Configuration"; Rec."XMLport Configuration")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the XMLport Configuration field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("XMLport Configuration Name"; Rec."XMLport Configuration Name")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the XMLport Configuration Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Codeunits)
            {
                group("Begin Workshift")
                {
                    field("Codeunit Begin Workshift"; Rec."Codeunit Begin Workshift")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Begin Workshift field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("Codeunit Begin Workshift Name"; Rec."Codeunit Begin Workshift Name")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Begin Workshift Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Transaction)
                {
                    field("Codeunit Transaction"; Rec."Codeunit Transaction")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Transaction field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("Codeunit Transaction Name"; Rec."Codeunit Transaction Name")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Transaction Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("End Workshift")
                {
                    field("Codeunit End Workshift"; Rec."Codeunit End Workshift")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit End Workshift field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("Codeunit End Workshift Name"; Rec."Codeunit End Workshift Name")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit End Workshift Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Auxiliary)
                {
                    field("Codeunit Auxiliary Functions"; Rec."Codeunit Auxiliary Functions")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Auxiliary Functions field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("Codeunit Auxiliary Name"; Rec."Codeunit Auxiliary Name")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Auxiliary Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Install)
                {
                    field("Codeunit Install"; Rec."Codeunit Install")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Install field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Codeunit Install Name"; Rec."Codeunit Install Name")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Codeunit Install Name field';
                        ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Configurations action';
                ApplicationArea = NPRRetail;
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
                Caption = 'Delete';
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
                Caption = 'Export';
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
        HasZipFile: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        HasZipFile := Rec."Install Zip File".HasValue();
    end;
}

