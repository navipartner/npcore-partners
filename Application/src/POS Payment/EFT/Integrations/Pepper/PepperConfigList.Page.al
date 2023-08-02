page 6184491 "NPR Pepper Config. List"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Configuration List';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/pepper_terminal/';
    CardPageID = "NPR Pepper Config. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Config.";
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

                    ToolTip = 'Specifies the code for the Pepper Configuration';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Pepper Configuration';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the version of the Pepper Configuration';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the mode of the Pepper Configuration';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Instances)
            {
                Caption = 'Instances';
                Image = Server;
                RunObject = Page "NPR Pepper Instances";
                RunPageLink = "Configuration Code" = FIELD(Code);
                RunPageView = SORTING(ID)
                              ORDER(Ascending);

                ToolTip = 'Opens the list of instances associated with the Pepper Configuration';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            group(Import)
            {
                Caption = 'Import';
                action(ImportLicense)
                {
                    Caption = 'License';
                    Image = ImportCodes;

                    ToolTip = 'Imports the license for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadFile(0);
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = Import;

                    ToolTip = 'Imports additional parameters for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadFile(1);
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Show';
                action(ShowLicense)
                {
                    Caption = 'License';
                    Image = ElectronicNumber;

                    ToolTip = 'Shows the license file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowFile(0);
                    end;
                }
                action(ShowConfigXML)
                {
                    Caption = 'Configuration XML';
                    Image = CreateXMLFile;

                    ToolTip = 'Shows the configuration XML file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowFile(1);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = ElectronicDoc;

                    ToolTip = 'Shows the additional parameters file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowFile(2);
                    end;
                }
            }
            group("Delete")
            {
                Caption = 'Delete';
                action(DeleteLicense)
                {
                    Caption = 'License';
                    Image = DeleteQtyToHandle;

                    ToolTip = 'Deletes the license file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearFile(0);
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Additional parameters';
                    Image = DeleteXML;

                    ToolTip = 'Deletes the additional parameters file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearFile(1);
                    end;
                }
            }
            group(Export)
            {
                Caption = 'Export';
                action(ExportLicense)
                {
                    Caption = 'License';
                    Image = Export;

                    ToolTip = 'Exports the license file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(0);
                    end;
                }
                action(ExportConfig)
                {
                    Caption = 'Configuration XML';
                    Image = ExportElectronicDocument;

                    ToolTip = 'Exports the configuration XML file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(1);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;

                    ToolTip = 'Exports the additional parameters file for the Pepper Configuration';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(2);
                    end;
                }
            }
        }
    }
}