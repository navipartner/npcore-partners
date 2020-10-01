page 6151552 "NPR NpXml Template List"
{
    Caption = 'Xml Templates';
    CardPageID = "NPR NpXml Template Card";
    DelayedInsert = true;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpXml Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group("Xml Templates")
            {
                Caption = 'Xml Templates';
                repeater(Group)
                {
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Task Processor Code"; "Task Processor Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Xml Root Name"; "Xml Root Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Table No."; "Table No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Template Version"; "Template Version")
                    {
                        ApplicationArea = All;
                    }
                    field("Transaction Task"; "Transaction Task")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Batch Task"; "Batch Task")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("File Transfer"; "File Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("FTP Transfer"; "FTP Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("API Transfer"; "API Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
                part(Control6150623; "NPR NpXml Templ. Trigger List")
                {
                    Editable = false;
                    ShowFilter = false;
                    SubPageLink = "Xml Template Code" = FIELD(Code);
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Edit Field Mapping")
            {
                Caption = 'Edit Field Mapping';
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Elements";
                RunPageLink = "Xml Template Code" = FIELD(Code);
                Visible = false;
                ApplicationArea = All;
            }
            action("View Field Mapping")
            {
                Caption = 'View Field Mapping';
                Image = Grid;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Elements";
                RunPageLink = "Xml Template Code" = FIELD(Code);
                Visible = false;
                ApplicationArea = All;
            }
        }
        area(processing)
        {
            action("Run Batch")
            {
                Caption = 'Run Batch';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Codeunit.run(Codeunit::"NPR NpXml Process Single Batch", Rec);
                end;
            }
            action("Export Template")
            {
                Caption = 'Export Xml Template';
                Image = Export;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NpXmlTemplateMgt.ExportNpXmlTemplate(Code);
                end;
            }
            action("Import Template")
            {
                Caption = 'Import Template';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NpXmlTemplateMgt.ImportNpXmlTemplate();
                end;
            }
            action("Delete Selected Templates")
            {
                Caption = 'Delete Selected Templates';
                Image = DeleteXML;
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpXmlTemplate: Record "NPR NpXml Template";
                begin
                    CurrPage.SetSelectionFilter(NpXmlTemplate);
                    if not Confirm(Text000, true, NpXmlTemplate.Count) then
                        exit;

                    NpXmlTemplate.DeleteAll(true);
                end;
            }
        }
    }

    var
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        Text000: Label 'Delete %1 selected NpXml Templates?';
}