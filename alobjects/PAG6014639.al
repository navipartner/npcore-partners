page 6014639 "RP Template List"
{
    // NPR4.10/MMV/20150506 CASE 167059 Removed field "Label Type" - It was deprecated a long time ago.
    // NPR4.12/MMV/20150702 CASE 217872 Moved actions from "RelatedInformation" (Navigation) to "ActionItems" (Handlinger) subtype
    // NPR5.29/MMV /20170110 CASE 241995 Added package module support instead of table export/import.
    // NPR5.32/MMV /20170424 CASE 241995 Retail Print 2.0

    Caption = 'Template List';
    CardPageID = "RP Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "RP Template Header";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                }
                field("Printer Type";"Printer Type")
                {
                }
                field("Printer Device";"Printer Device")
                {
                }
                field(Description;Description)
                {
                }
                field(Version;Version)
                {
                }
                field("Last Modified At";"Last Modified At")
                {
                }
            }
        }
        area(factboxes)
        {
            part(Control6014409;"RP Template Media Factbox")
            {
                SubPageLink = Template=FIELD(Code);
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

                trigger OnAction()
                var
                    TemplateMgt: Codeunit "RP Template Mgt.";
                    TemplateHeader: Record "RP Template Header";
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

                trigger OnAction()
                var
                    TemplateHeader: Record "RP Template Header";
                    PackageHandler: Codeunit "RP Package Handler";
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

                trigger OnAction()
                var
                    PackageHandler: Codeunit "RP Package Handler";
                    TemplateHeader: Record "RP Template Header";
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

                trigger OnAction()
                var
                    PackageHandler: Codeunit "RP Package Handler";
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

                trigger OnAction()
                var
                    PackageHandler: Codeunit "RP Package Handler";
                begin
                    //-NPR5.29 [241995]
                    PackageHandler.DeployPackageFromGC();
                    //+NPR5.29 [241995]
                end;
            }
        }
    }

    var
        Text00001: Label 'Overwrite All,Update All,Add Only';
        Text00002: Label 'Choose Method';
}

