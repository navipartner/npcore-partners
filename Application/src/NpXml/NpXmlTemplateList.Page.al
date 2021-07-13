page 6151552 "NPR NpXml Template List"
{
    Caption = 'Xml Templates';
    CardPageID = "NPR NpXml Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpXml Template";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


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

                        Editable = false;
                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Task Processor Code"; Rec."Task Processor Code")
                    {

                        ToolTip = 'Specifies the value of the Task Processor Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Xml Root Name"; Rec."Xml Root Name")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Xml Root Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Table No."; Rec."Table No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Table No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Template Version"; Rec."Template Version")
                    {

                        ToolTip = 'Specifies the value of the Version field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Transaction Task"; Rec."Transaction Task")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Transaction Task field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Batch Task"; Rec."Batch Task")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Batch Task field';
                        ApplicationArea = NPRRetail;
                    }
                    field("File Transfer"; Rec."File Transfer")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the File Transfer field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Transfer"; Rec."FTP Transfer")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the FTP Transfer field';
                        ApplicationArea = NPRRetail;
                    }
                    field("API Transfer"; Rec."API Transfer")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the API Transfer field';
                        ApplicationArea = NPRRetail;
                    }
                }
                part(Control6150623; "NPR NpXml Templ. Trigger List")
                {
                    Editable = false;
                    ShowFilter = false;
                    SubPageLink = "Xml Template Code" = FIELD(Code);
                    ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Edit Field Mapping action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the View Field Mapping action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Run Batch action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Codeunit.run(Codeunit::"NPR NpXml Process Single Batch", Rec);
                end;
            }
            action("Export Template")
            {
                Caption = 'Export Xml Template';
                Image = Export;

                ToolTip = 'Executes the Export Xml Template action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    NpXmlTemplateMgt.ExportNpXmlTemplate(Rec.Code);
                end;
            }
            action("Import Template")
            {
                Caption = 'Import Template';
                Image = Import;

                ToolTip = 'Executes the Import Template action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    NpXmlTemplateMgt.ImportNpXmlTemplate();
                end;
            }
            action("Import Template From Blob Storage")
            {
                Caption = 'Import Template From Blob Storage';
                Image = ImportDatabase;

                RunObject = page "NPR NpXml Templ. Dep. From Az.";
                ToolTip = 'Executes the Import Template action from Azure Blob storage';
                ApplicationArea = NPRRetail;
            }
            action("Delete Selected Templates")
            {
                Caption = 'Delete Selected Templates';
                Image = DeleteXML;

                ToolTip = 'Executes the Delete Selected Templates action';
                ApplicationArea = NPRRetail;

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
