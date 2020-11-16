page 6151551 "NPR NpXml Template Card"
{
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
                            NpXmlTemplateArchive.Reset;
                            NpXmlTemplateArchive.SetRange(Code, Code);
                            Clear(NpXmlTemplateArchiveList);
                            NpXmlTemplateArchiveList.LookupMode(true);
                            NpXmlTemplateArchiveList.SetTableView(NpXmlTemplateArchive);
                            NpXmlTemplateArchiveList.RunModal;
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
                        ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                        ApplicationArea = All;
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
                ApplicationArea = All;
            }
            action("Preview Xml")
            {
                Caption = 'Preview Xml';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpXmlMgt: Codeunit "NPR NpXml Mgt.";
                begin
                    NpXmlMgt.PreviewXml(Code);
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                begin
                    InitVersion();
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
            action("Schedule Batch Task")
            {
                Caption = 'Schedule Batch Task';
                Image = NewToDo;
                ApplicationArea = All;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    NpXmlBatchProcessing: Codeunit "NPR NpXml Batch Processing";
                    PageManagement: Codeunit "Page Management";
                begin
                    NpXmlBatchProcessing.ScheduleBatchTask(Rec, JobQueueEntry);

                    Commit;
                    if GuiAllowed then
                        PAGE.Run(PageManagement.GetDefaultCardPageID(DATABASE::"Job Queue Entry"), JobQueueEntry);
                end;
            }
            action("Archive Template")
            {
                Caption = 'Archive Template';
                Image = Archive;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                begin
                    if Archived then
                        Error(Text100, "Template Version");

                    NpXmlTemplateMgt.Archive(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.NpXmlBatchFilters.PAGE.SetParentTableNo("Table No.");
        NpXmlTemplateTriggersVisible := Find;
        NpXmlBatchFiltersVisible := Find;
    end;

    var
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        NpXmlTemplateTriggersVisible: Boolean;
        NpXmlBatchFiltersVisible: Boolean;
        Text100: Label 'Template %1 has already been archived';
}