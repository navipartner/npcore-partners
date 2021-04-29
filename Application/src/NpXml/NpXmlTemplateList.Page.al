page 6151552 "NPR NpXml Template List"
{
    Caption = 'Xml Templates';
    CardPageID = "NPR NpXml Template Card";
    Editable = false;
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
                    field("Code"; Rec.Code)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field("Task Processor Code"; Rec."Task Processor Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Task Processor Code field';
                    }
                    field("Xml Root Name"; Rec."Xml Root Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Xml Root Name field';
                    }
                    field("Table No."; Rec."Table No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Table No. field';
                    }
                    field("Template Version"; Rec."Template Version")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Version field';
                    }
                    field("Transaction Task"; Rec."Transaction Task")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Transaction Task field';
                    }
                    field("Batch Task"; Rec."Batch Task")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Batch Task field';
                    }
                    field("File Transfer"; Rec."File Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the File Transfer field';
                    }
                    field("FTP Transfer"; Rec."FTP Transfer")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the FTP Transfer field';
                    }
                    field("API Transfer"; Rec."API Transfer")
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
                    NpXmlTemplateMgt.ExportNpXmlTemplate(Rec.Code);
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
            action("Import Template From Blob Storage")
            {
                Caption = 'Import Template From Blob Storage';
                Image = ImportDatabase;
                ApplicationArea = All;
                RunObject = page "NPR NpXml Templ. Dep. From Az.";
                ToolTip = 'Executes the Import Template action from Azure Blob storage';
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
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        Text000: Label 'Delete %1 selected NpXml Templates?';
}
