page 6014639 "NPR RP Template List"
{
    Extensible = False;
    Caption = 'Print Template List';
    ContextSensitiveHelpPage = 'docs/retail/printing/how-to/print_template_setup/';
    CardPageID = "NPR RP Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR RP Template Header";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the print template';
                    ApplicationArea = NPRRetail;
                }
                field("Printer Type"; Rec."Printer Type")
                {
                    ToolTip = 'Specifies the printer type of the print template';
                    ApplicationArea = NPRRetail;
                }
                field(DeviceType; DeviceType)
                {
                    Caption = 'Device Type';
                    ToolTip = 'Specifies the device type of the print template';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the comments of the print template';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {
                    ToolTip = 'Specifies the version of the print template';
                    ApplicationArea = NPRRetail;
                }
                field("Last Modified At"; Rec."Last Modified At")
                {
                    ToolTip = 'Specifies when this print template was last modified';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(Control6014409; "NPR RP Template Media Factbox")
            {
                SubPageLink = Template = FIELD(Code);
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Copy")
            {
                Caption = 'Create Copy';
                Image = Copy;

                ToolTip = 'Creates a copy of the selected print template';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TemplateMgt: Codeunit "NPR RP Template Mgt.";
                    RPTemplateHeader: Record "NPR RP Template Header";
                begin
                    CurrPage.SetSelectionFilter(RPTemplateHeader);
                    TemplateMgt.CreateCopy(RPTemplateHeader);
                end;
            }
            action(ExportPackageSingle)
            {
                Caption = 'Export Package (Selected)';
                Image = Export;

                ToolTip = 'Exports a package of the selected record';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RPTemplateHeader: Record "NPR RP Template Header";
                    PackageHandler: Codeunit "NPR RP Package Handler";
                begin
                    CurrPage.SetSelectionFilter(RPTemplateHeader);
                    PackageHandler.ExportPackageToFile(RPTemplateHeader);
                end;
            }
            action(ExportPackageAll)
            {
                Caption = 'Export Package (All)';
                Image = Export;

                ToolTip = 'Exports a package of all records';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PackageHandler: Codeunit "NPR RP Package Handler";
                    RPTemplateHeader: Record "NPR RP Template Header";
                begin
                    RPTemplateHeader.Copy(Rec);
                    PackageHandler.ExportPackageToFile(RPTemplateHeader);
                end;
            }
            action(ImportPackage)
            {
                Caption = 'Import Package File';
                Image = Import;

                ToolTip = 'Imports a package, a json file';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PackageHandler: Codeunit "NPR RP Package Handler";
                begin
                    PackageHandler.ImportPackageFromFile();
                end;
            }
            action(DeployPackage)
            {
                Caption = 'Download Template data';
                Image = ImportDatabase;

                ToolTip = 'Downloads different print templates for different devices and versions';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PackageHandler: Codeunit "NPR RP Package Handler";
                begin
                    PackageHandler.DeployPackageFromBlobStorage();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec."Printer Type" of
            Rec."Printer Type"::Line:
                DeviceType := Format(Rec."Line Device");
            Rec."Printer Type"::Matrix:
                DeviceType := Format(Rec."Matrix Device");
        end
    end;

    var
        DeviceType: Text;
}

