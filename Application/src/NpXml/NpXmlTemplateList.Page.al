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
    ApplicationArea = All;

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
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field("Task Processor Code"; "Task Processor Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Task Processor Code field';
                    }
                    field("Xml Root Name"; "Xml Root Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Xml Root Name field';
                    }
                    field("Table No."; "Table No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Table No. field';
                    }
                    field("Template Version"; "Template Version")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Version field';
                    }
                    field("Transaction Task"; "Transaction Task")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Transaction Task field';
                    }
                    field("Batch Task"; "Batch Task")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Batch Task field';
                    }
                    field("File Transfer"; "File Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the File Transfer field';
                    }
                    field("FTP Transfer"; "FTP Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the FTP Transfer field';
                    }
                    field("API Transfer"; "API Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the API Transfer field';
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
                ToolTip = 'Executes the Edit Field Mapping action';
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
                ToolTip = 'Executes the View Field Mapping action';
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
                ToolTip = 'Executes the Run Batch action';

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
                ToolTip = 'Executes the Export Xml Template action';

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
                ToolTip = 'Executes the Import Template action';

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
                ToolTip = 'Executes the Delete Selected Templates action';

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
