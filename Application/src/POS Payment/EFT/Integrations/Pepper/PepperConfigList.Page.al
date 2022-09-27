page 6184491 "NPR Pepper Config. List"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Configuration List';
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the value of the Mode field';
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

                ToolTip = 'Executes the Instances action';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Additional Parameters action';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Configuration XML action';
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

                    ToolTip = 'Executes the Additional Parameters action';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Additional parameters action';
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

                    ToolTip = 'Executes the License action';
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

                    ToolTip = 'Executes the Configuration XML action';
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

                    ToolTip = 'Executes the Additional Parameters action';
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

