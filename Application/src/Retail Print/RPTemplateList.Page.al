page 6014639 "NPR RP Template List"
{
    Extensible = False;
    Caption = 'Print Template List';
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Printer Type"; Rec."Printer Type")
                {

                    ToolTip = 'Specifies the value of the Printer Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Printer Device"; Rec."Printer Device")
                {

                    ToolTip = 'Specifies the value of the Printer Device field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Comments field';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Modified At"; Rec."Last Modified At")
                {

                    ToolTip = 'Specifies the value of the Last Modified At field';
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

                ToolTip = 'Executes the Create Copy action';
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

                ToolTip = 'Executes the Export Package (Selected) action';
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

                ToolTip = 'Executes the Export Package (All) action';
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

                ToolTip = 'Executes the Import Package File action';
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

                ToolTip = 'Downloads Template data.';
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
}

