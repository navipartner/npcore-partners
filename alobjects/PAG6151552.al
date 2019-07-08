page 6151552 "NpXml Template List"
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01/MH/20150201  CASE 199932 Removed field 1010 "Transaction Trigger" and added Template Triggers
    // NC1.05/MH/20150219  CASE 206395 Removed field 7 "Xml Element Name". Obsolete as NpXml Elements defines the Xml Schema
    // NC1.10/MH/20150320  CASE 206395 Updated action Export Template
    // NC1.11/MH/20150330  CASE 210171 Added multi level triggers
    // NC1.13/MH/20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.17/MH/20150624  CASE 215533 Added Transfer fields
    // NC1.21/MHA/20151104 CASE 224528 Changed page to Non Editable
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.05/TS  /20170613  CASE 269051 Added Action to Delete all templates
    // NC2.08/TS  /20180108  CASE 300893 Corrected Missing Page on  View Field Mapping

    Caption = 'Xml Templates';
    CardPageID = "NpXml Template Card";
    DelayedInsert = true;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NpXml Template";
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
                    field("Code";Code)
                    {
                        Editable = false;
                    }
                    field("Task Processor Code";"Task Processor Code")
                    {
                    }
                    field("Xml Root Name";"Xml Root Name")
                    {
                        Editable = false;
                    }
                    field("Table No.";"Table No.")
                    {
                        Editable = false;
                    }
                    field("Template Version";"Template Version")
                    {
                    }
                    field("Transaction Task";"Transaction Task")
                    {
                        Editable = false;
                    }
                    field("Batch Task";"Batch Task")
                    {
                        Editable = false;
                    }
                    field("File Transfer";"File Transfer")
                    {
                        Editable = false;
                    }
                    field("FTP Transfer";"FTP Transfer")
                    {
                        Editable = false;
                    }
                    field("API Transfer";"API Transfer")
                    {
                        Editable = false;
                    }
                }
                part(Control6150623;"NpXml Template Trigger List")
                {
                    Editable = false;
                    ShowFilter = false;
                    SubPageLink = "Xml Template Code"=FIELD(Code);
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
                RunObject = Page "NpXml Elements";
                RunPageLink = "Xml Template Code"=FIELD(Code);
                Visible = false;
            }
            action("View Field Mapping")
            {
                Caption = 'View Field Mapping';
                Image = Grid;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NpXml Elements";
                RunPageLink = "Xml Template Code"=FIELD(Code);
                Visible = false;
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

                trigger OnAction()
                begin
                    //-NC1.13
                    //CLEAR(XMLMgt);
                    //XMLMgt.RunBatch(Rec);
                    Clear(NpXmlBatchMgt);
                    NpXmlBatchMgt.RunBatch(Rec);
                    //+NC1.13
                end;
            }
            action("Export Template")
            {
                Caption = 'Export Xml Template';
                Image = Export;

                trigger OnAction()
                begin
                    //-NC1.13
                    ////-NC1.10
                    //XMLMgt.ExportNpXmlTemplate(Code);
                    ////+NC1.10
                    NpXmlTemplateMgt.ExportNpXmlTemplate(Code);
                    //+NC1.13
                end;
            }
            action("Import Template")
            {
                Caption = 'Import Template';
                Image = Import;

                trigger OnAction()
                begin
                    //-NC1.13
                    ////-NC1.10
                    //XMLMgt.ImportNpXmlTemplate();
                    ////+NC1.10
                    NpXmlTemplateMgt.ImportNpXmlTemplate();
                    //+NC1.13
                end;
            }
            action("Delete Selected Templates")
            {
                Caption = 'Delete Selected Templates';
                Image = DeleteXML;

                trigger OnAction()
                var
                    NpXmlTemplate: Record "NpXml Template";
                begin
                    //-NC2.05 [269051]
                    CurrPage.SetSelectionFilter(NpXmlTemplate);
                    if not Confirm(Text000,true,NpXmlTemplate.Count) then
                      exit;

                    NpXmlTemplate.DeleteAll(true);
                    //+NC2.05 [269051]
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NC1.11
        //CurrPage.NpXmlTemplateTriggers.PAGE.SetXmlTemplateTableNo("Table No.");
        //+NC1.11
    end;

    var
        NpXmlBatchMgt: Codeunit "NpXml Batch Mgt.";
        NpXmlMgt: Codeunit "NpXml Mgt.";
        NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";
        Text000: Label 'Delete %1 selected NpXml Templates?';
}

