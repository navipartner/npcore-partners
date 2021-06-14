page 6014639 "NPR RP Template List"
{
    Caption = 'Print Template List';
    CardPageID = "NPR RP Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR RP Template Header";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Printer Type"; Rec."Printer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer Type field';
                }
                field("Printer Device"; Rec."Printer Device")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer Device field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comments field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field("Last Modified At"; Rec."Last Modified At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Modified At field';
                }
            }
        }
        area(factboxes)
        {
            part(Control6014409; "NPR RP Template Media Factbox")
            {
                SubPageLink = Template = FIELD(Code);
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Create Copy action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Export Package (Selected) action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Export Package (All) action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Import Package File action';

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
                ApplicationArea = All;
                ToolTip = 'Downloads Template data.';

                trigger OnAction()
                var
                    PackageHandler: Codeunit "NPR RP Package Handler";
                begin
                    PackageHandler.DeployPackageFromBlobStorage();
                end;
            }
        }
    }
}

