page 6014639 "NPR RP Template List"
{
    // NPR4.10/MMV/20150506 CASE 167059 Removed field "Label Type" - It was deprecated a long time ago.
    // NPR4.12/MMV/20150702 CASE 217872 Moved actions from "RelatedInformation" (Navigation) to "ActionItems" (Handlinger) subtype
    // NPR5.29/MMV /20170110 CASE 241995 Added package module support instead of table export/import.
    // NPR5.32/MMV /20170424 CASE 241995 Retail Print 2.0
    // NPR5.55/MMV /20200615 CASE 409573 Moved deployment of retail print templates from npdeploy to azure blob storage.

    Caption = 'Template List';
    CardPageID = "NPR RP Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR RP Template Header";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Printer Type"; "Printer Type")
                {
                    ApplicationArea = All;
                }
                field("Printer Device"; "Printer Device")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                }
                field("Last Modified At"; "Last Modified At")
                {
                    ApplicationArea = All;
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    TemplateMgt: Codeunit "NPR RP Template Mgt.";
                    TemplateHeader: Record "NPR RP Template Header";
                begin
                    CurrPage.SetSelectionFilter(TemplateHeader);
                    TemplateMgt.CreateCopy(TemplateHeader);
                end;
            }
            action(ExportPackageSingle)
            {
                Caption = 'Export Package (Selected)';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    TemplateHeader: Record "NPR RP Template Header";
                    PackageHandler: Codeunit "NPR RP Package Handler";
                begin
                    //-NPR5.29 [241995]
                    CurrPage.SetSelectionFilter(TemplateHeader);
                    PackageHandler.ExportPackageToFile(TemplateHeader);
                    //+NPR5.29 [241995]
                end;
            }
            action(ExportPackageAll)
            {
                Caption = 'Export Package (All)';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    PackageHandler: Codeunit "NPR RP Package Handler";
                    TemplateHeader: Record "NPR RP Template Header";
                begin
                    //-NPR5.29 [241995]
                    TemplateHeader.Copy(Rec);
                    PackageHandler.ExportPackageToFile(TemplateHeader);
                    //+NPR5.29 [241995]
                end;
            }
            action(ImportPackage)
            {
                Caption = 'Import Package File';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    PackageHandler: Codeunit "NPR RP Package Handler";
                begin
                    //-NPR5.29 [241995]
                    PackageHandler.ImportPackageFromFile();
                    //+NPR5.29 [241995]
                end;
            }
            action(DeployPackage)
            {
                Caption = 'Deploy Package';
                Image = ImportDatabase;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    PackageHandler: Codeunit "NPR RP Package Handler";
                begin
                    //-NPR5.55 [409573]
                    PackageHandler.DeployPackageFromBlobStorage();
                    //+NPR5.55 [409573]
                end;
            }
        }
    }

    var
        Text00001: Label 'Overwrite All,Update All,Add Only';
        Text00002: Label 'Choose Method';
}

