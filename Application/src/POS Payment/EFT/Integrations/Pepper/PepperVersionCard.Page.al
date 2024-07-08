page 6184497 "NPR Pepper Version Card"
{
    Extensible = False;
    Caption = 'Pepper Version Card';
    PageType = Card;
    UsageCategory = None;

    SourceTable = "NPR Pepper Version";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique identifier for this Pepper Version. This code helps distinguish between different versions.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'SSpecifies a user-friendly description or a name for this Pepper Version, making it easier to identify its purpose.';
                    ApplicationArea = NPRRetail;
                }
                field("Install Directory"; Rec."Install Directory")
                {

                    ToolTip = 'Specifies the directory in which the Pepper Version is installed.';
                    ApplicationArea = NPRRetail;
                }
                field("Pepper DLL Version"; Rec."Pepper DLL Version")
                {

                    Editable = false;
                    ToolTip = 'Specifies the name or identifier for the XMLport configuration associated with this Pepper Version.';
                    ApplicationArea = NPRRetail;
                }
                field("Zip File"; HasZipFile)
                {

                    Caption = 'Zip File';
                    Editable = false;
                    ToolTip = 'Indicates whether a ZIP file is associated with this Pepper Version. This field is non-editable and serves as a flag to show whether a ZIP file is linked.';
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
                        ToolTip = 'Specifies the XMLport configuration associated with this Pepper Version. This field controls the XMLport settings used for data exchange.';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("XMLport Configuration Name"; Rec."XMLport Configuration Name")
                    {

                        ShowCaption = false;
                        ToolTip = 'Provides the name or identifier for the XMLport configuration associated with this Pepper Version. This field helps identify the specific XMLport configuration used.';
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

