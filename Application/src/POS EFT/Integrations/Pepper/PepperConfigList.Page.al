page 6184491 "NPR Pepper Config. List"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Configuration List';
    CardPageID = "NPR Pepper Config. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Config.";
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Instances action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        UploadFile(0);
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = Import;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional Parameters action';

                    trigger OnAction()
                    begin
                        UploadFile(1);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        ShowFile(0);
                    end;
                }
                action(ShowConfigXML)
                {
                    Caption = 'Configuration XML';
                    Image = CreateXMLFile;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Configuration XML action';

                    trigger OnAction()
                    begin
                        ShowFile(1);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = ElectronicDoc;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional Parameters action';

                    trigger OnAction()
                    begin
                        ShowFile(2);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        ClearFile(0);
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Additional parameters';
                    Image = DeleteXML;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional parameters action';

                    trigger OnAction()
                    begin
                        ClearFile(1);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        ExportFile(0);
                    end;
                }
                action(ExportConfig)
                {
                    Caption = 'Configuration XML';
                    Image = ExportElectronicDocument;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Configuration XML action';

                    trigger OnAction()
                    begin
                        ExportFile(1);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional Parameters action';

                    trigger OnAction()
                    begin
                        ExportFile(2);
                    end;
                }
            }
        }
    }
}

