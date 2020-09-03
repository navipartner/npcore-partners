page 6151551 "NPR NpXml Template Card"
{
    // NC1.00/MHA /20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01/MHA /20150201  CASE 199932 Removed field 1010 "Transaction Trigger" and added Template Triggers
    // NC1.05/MHA /20150219  CASE 206395 Removed field 7 "Xml Element Name". Obsolete as NpXml Elements defines the Xml Schema
    // NC1.09/MHA /20150313  CASE 208758 Added Field 5219 "API Username Type" and function SetEnabled
    // NC1.10/MHA /20150320  CASE 206395 Change API SOAP action Visibility- to Enabled functionality
    // NC1.11/MHA /20150330  CASE 210171 Added multi level triggers
    // NC1.12/MHA /20150402  CASE 209661 Replaced Subpage Xml Filters with Xml Batch Filters
    // NC1.13/MHA /20150414  CASE 211360 Restructured NpXml Codeunits. Independent functions moved to new codeunits
    // NC1.21/TTH /20151027  CASE 224528 Adding versioning and possibility to lock the modified versions. Added fields Template Version, Template Version Description and Template last modified date
    // NC1.22/MHA /20151203  CASE 224528 Changed Page to only be editable if not Archived
    // NC1.22/MHA /20160429  CASE 237658 NpXml extended with Namespaces
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20160905  CASE 242551 Added field 5254 API Reponse Success Path
    // NC2.01/TR  /20160812  CASE 240432 Added action Setup From WSDL (Url)
    // NC2.01/MHA /20161212  CASE 260498 Added Api Request Header fields
    // NC2.01/TR  /20170102  CASE 240432 Removed Setup from Wsdl (Url) and Setup from Wsdl (File)
    //                                   Added Setup from Wsdl
    // NC2.03/MHA /20170316  CASE 268788 Field 5285 Renamed from "API SOAP Namespace" to "Xml Root Namespace"
    // NC2.03/MHA /20170324  CASE 267094 Added fields: 4900 "Before Transfer Codeunit ID",4905 "Before Transfer Codeunit Name",4910 "Before Transfer Function"
    // NC2.05/MHA /20170615  CASE 265609 Added option to field 5270 "Api Type": REST (Json) and removed redundant Enabled Variables
    // NC2.06/MHA /20170809  CASE 265779 Added ListPart "NpXml Api Headers" [PAG6151566]
    // NC2.08/THRO/20171124  CASE 297308 Added "JSON Root is Array"  -only visible for Json Rest
    // NC2.08/MHA /20171206  CASE 265541 Added field 5405 "Use JSON Numbers"
    // NC2.22/MHA /20190711  CASE 361775 Removed action "Setup from Wsdl"
    // NPR5.55/MHA /20200630  CASE 411410 Added batch fields "Batch Last Run", "Runtime Error", "Last Error Message", "FTP Filename (Fixed)"

    Caption = 'Xml Template';
    DelayedInsert = true;
    PromotedActionCategories = 'New,Process,Report,Manage,Version';
    SourceTable = "NPR NpXml Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Xml Root Name"; "Xml Root Name")
                {
                    ApplicationArea = All;
                }
                group(Control6151403)
                {
                    ShowCaption = false;
                    Visible = "Namespaces Enabled";
                    field("Xml Root Namespace"; "Xml Root Namespace")
                    {
                        ApplicationArea = All;
                    }
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                        //-NC1.11
                        //CurrPage.NpXmlTemplateTriggers.PAGE.SetXmlTemplateTableNo("Table No.");
                        //+NC1.11
                    end;
                }
                group(Control6150672)
                {
                    ShowCaption = false;
                    field(Archived; Archived)
                    {
                        ApplicationArea = All;
                    }
                    field("Template Version"; "Template Version")
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            NpXmlTemplateArchive: Record "NPR NpXml Template Arch.";
                            NpXmlTemplateArchiveList: Page "NPR NpXml Templ. Arch. List";
                        begin
                            //-NC1.21
                            NpXmlTemplateArchive.Reset;
                            NpXmlTemplateArchive.SetRange(Code, Code);
                            Clear(NpXmlTemplateArchiveList);
                            NpXmlTemplateArchiveList.LookupMode(true);
                            NpXmlTemplateArchiveList.SetTableView(NpXmlTemplateArchive);
                            NpXmlTemplateArchiveList.RunModal;
                            //+NC1.21
                        end;
                    }
                    field("Last Modified at"; "Last Modified at")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Version Description"; "Version Description")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(Control6150677)
                {
                    ShowCaption = false;
                    field("Namespaces Enabled"; "Namespaces Enabled")
                    {
                        ApplicationArea = All;
                    }
                    part(Namespaces; "NPR NpXml Namespaces")
                    {
                        SubPageLink = "Xml Template Code" = FIELD(Code);
                        Visible = "Namespaces Enabled";
                    }
                }
            }
            group(Transaction)
            {
                Caption = 'Transaction';
                field("Transaction Task"; "Transaction Task")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Task Processor Code"; "Task Processor Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Disable Auto Task Setup"; "Disable Auto Task Setup")
                {
                    ApplicationArea = All;
                }
                part(NpXmlTemplateTriggers; "NPR NpXml Template Triggers")
                {
                    ShowFilter = false;
                    SubPageLink = "Xml Template Code" = FIELD(Code);
                    Visible = NpXmlTemplateTriggersVisible;
                }
            }
            group(Batch)
            {
                Caption = 'Batch';
                field("Batch Task"; "Batch Task")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Max Records per File"; "Max Records per File")
                {
                    ApplicationArea = All;
                }
                field("Batch Last Run"; "Batch Last Run")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Runtime Error"; "Runtime Error")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Error Message"; "Last Error Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                part(NpXmlBatchFilters; "NPR NpXml Batch Filters")
                {
                    ShowFilter = false;
                    SubPageLink = "Xml Template Code" = FIELD(Code),
                                  "Xml Element Line No." = CONST(-1);
                    Visible = NpXmlBatchFiltersVisible;
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                field("Before Transfer Codeunit ID"; "Before Transfer Codeunit ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Before Transfer Codeunit Name"; "Before Transfer Codeunit Name")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Before Transfer Function"; "Before Transfer Function")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                group("File")
                {
                    Caption = 'File';
                    field("File Transfer"; "File Transfer")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("File Path"; "File Path")
                    {
                        ApplicationArea = All;
                    }
                }
                group(FTP)
                {
                    field("FTP Transfer"; "FTP Transfer")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("FTP Server"; "FTP Server")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("FTP Username"; "FTP Username")
                    {
                        ApplicationArea = All;
                    }
                    field("FTP Password"; "FTP Password")
                    {
                        ApplicationArea = All;
                    }
                    field("FTP Port"; "FTP Port")
                    {
                        ApplicationArea = All;
                    }
                    field("FTP Passive"; "FTP Passive")
                    {
                        ApplicationArea = All;
                    }
                    field("FTP Directory"; "FTP Directory")
                    {
                        ApplicationArea = All;
                    }
                    field("FTP Filename (Fixed)"; "FTP Filename (Fixed)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                }
                group(API)
                {
                    field("API Transfer"; "API Transfer")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    field("API Type"; "API Type")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            //-NC2.05 [265609]
                            //APISoapActionEnabled := "API Type" = "API Type"::SOAP;
                            //SetEnabled();
                            //+NC2.05 [265609]
                        end;
                    }
                    field("API Url"; "API Url")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                    }
                    group(Control6151411)
                    {
                        ShowCaption = false;
                        Visible = "API Type" <> "API Type"::SOAP;
                        field("API Method"; "API Method")
                        {
                            ApplicationArea = All;
                            Importance = Promoted;
                        }
                    }
                    group(Control6150679)
                    {
                        ShowCaption = false;
                        Visible = "API Type" = "API Type"::SOAP;
                        field("API SOAP Action"; "API SOAP Action")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                        }
                    }
                    field("API Username Type"; "API Username Type")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            //-NC2.05 [265609]
                            //SetEnabled();
                            //+NC2.05 [265609]
                        end;
                    }
                    field("API Username"; "API Username")
                    {
                        ApplicationArea = All;
                        Enabled = "API Username Type" = "API Username Type"::Custom;
                    }
                    field("API Password"; "API Password")
                    {
                        ApplicationArea = All;
                    }
                    field("API Content-Type"; "API Content-Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("API Authorization"; "API Authorization")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("API Accept"; "API Accept")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    part("Api Headers"; "NPR NpXml Api Headers")
                    {
                        Caption = 'Api Headers';
                        ShowFilter = false;
                        SubPageLink = "Xml Template Code" = FIELD(Code);
                    }
                    group(Control6151410)
                    {
                        ShowCaption = false;
                        Visible = "API Type" <> "API Type"::"REST (Json)";
                        field("API Response Path"; "API Response Path")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                        }
                    }
                    field("API Response Success Path"; "API Response Success Path")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("API Response Success Value"; "API Response Success Value")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        Visible = "API Type" = "API Type"::"REST (Json)";
                        field("JSON Root is Array"; "JSON Root is Array")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                        }
                        field("Use JSON Numbers"; "Use JSON Numbers")
                        {
                            ApplicationArea = All;
                        }
                    }
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
                Enabled = true;
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Elements";
                RunPageLink = "Xml Template Code" = FIELD(Code);
            }
            action("Preview Xml")
            {
                Caption = 'Preview Xml';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpXmlMgt: Codeunit "NPR NpXml Mgt.";
                begin
                    //-NC2.05 [265609]
                    NpXmlMgt.PreviewXml(Code);
                    //+NC2.05 [265609]
                end;
            }
            action("Template History")
            {
                Caption = 'Template History';
                Image = History;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Templ. Chng. History";
                RunPageLink = "Template Code" = FIELD(Code);
            }
            action("Archived Versions")
            {
                Caption = 'Archived Versions';
                Image = Versions;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Templ. Arch. List";
                RunPageLink = Code = FIELD(Code);
            }
        }
        area(processing)
        {
            action("Init New Version")
            {
                Caption = 'Init New Version';
                Image = Add;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-NC1.22
                    InitVersion();
                    //-NC1.22
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
            action("Schedule Batch Task")
            {
                Caption = 'Schedule Batch Task';
                Image = NewToDo;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    NpXmlBatchProcessing: Codeunit "NPR NpXml Batch Processing";
                    PageManagement: Codeunit "Page Management";
                begin
                    //-NPR5.55 [411410]
                    NpXmlBatchProcessing.ScheduleBatchTask(Rec, JobQueueEntry);

                    Commit;
                    if GuiAllowed then
                        PAGE.Run(PageManagement.GetDefaultCardPageID(DATABASE::"Job Queue Entry"), JobQueueEntry);
                    //+NPR5.55 [411410]
                end;
            }
            action("Archive Template")
            {
                Caption = 'Archive Template';
                Image = Archive;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                begin
                    //-NC1.21
                    if Archived then
                        Error(Text100, "Template Version");

                    NpXmlTemplateMgt.Archive(Rec);
                    CurrPage.Update(false);
                    //+NC1.21
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NC2.05 [265609]
        //APISoapActionEnabled := "API Type" = "API Type"::SOAP;
        //+NC2.05 [265609]
        CurrPage.NpXmlBatchFilters.PAGE.SetParentTableNo("Table No.");
        //-NC1.11
        //CurrPage.NpXmlTemplateTriggers.PAGE.SetXmlTemplateTableNo("Table No.");
        //+NC1.11
        NpXmlTemplateTriggersVisible := Find;
        NpXmlBatchFiltersVisible := Find;
        //-NC2.05 [265609]
        //SetEnabled();
        //+NC2.05 [265609]
    end;

    trigger OnAfterGetRecord()
    begin
        //-NC2.05 [265609]
        //SetEnabled();
        //+NC2.05 [265609]
    end;

    trigger OnOpenPage()
    begin
        //-NC2.05 [265609]
        //SetEnabled();
        //+NC2.05 [265609]
    end;

    var
        NpXmlBatchMgt: Codeunit "NPR NpXml Batch Mgt.";
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        NpXmlTemplateTriggersVisible: Boolean;
        NpXmlBatchFiltersVisible: Boolean;
        Text100: Label 'Template %1 has already been archived';
}

