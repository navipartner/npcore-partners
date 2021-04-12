page 6151551 "NPR NpXml Template Card"
{
    UsageCategory = None;
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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Xml Root Name"; Rec."Xml Root Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Xml Root Name field';
                }
                group(Control6151403)
                {
                    ShowCaption = false;
                    Visible = Rec."Namespaces Enabled";
                    field("Xml Root Namespace"; Rec."Xml Root Namespace")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Xml Root Namespace field';
                    }
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                group(Control6150672)
                {
                    ShowCaption = false;
                    field(Archived; Rec.Archived)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Archived field';
                    }
                    field("Template Version"; Rec."Template Version")
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Version field';

                        trigger OnAssistEdit()
                        var
                            NpXmlTemplateArchive: Record "NPR NpXml Template Arch.";
                            NpXmlTemplateArchiveList: Page "NPR NpXml Templ. Arch. List";
                        begin
                            NpXmlTemplateArchive.Reset();
                            NpXmlTemplateArchive.SetRange(Code, Rec.Code);
                            Clear(NpXmlTemplateArchiveList);
                            NpXmlTemplateArchiveList.LookupMode(true);
                            NpXmlTemplateArchiveList.SetTableView(NpXmlTemplateArchive);
                            NpXmlTemplateArchiveList.RunModal();
                        end;
                    }
                    field("Last Modified at"; Rec."Last Modified at")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Last Modified at field';
                    }
                    field("Version Description"; Rec."Version Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Version Description field';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(Control6150677)
                {
                    ShowCaption = false;
                    field("Namespaces Enabled"; Rec."Namespaces Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Namespaces Enabled field';
                    }
                    part(Namespaces; "NPR NpXml Namespaces")
                    {
                        SubPageLink = "Xml Template Code" = FIELD(Code);
                        Visible = Rec."Namespaces Enabled";
                        ApplicationArea = All;
                    }
                }
            }
            group(Transaction)
            {
                Caption = 'Transaction';
                field("Transaction Task"; Rec."Transaction Task")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Transaction Task field';
                }
                field("Task Processor Code"; Rec."Task Processor Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Task Processor Code field';
                }
                field("Disable Auto Task Setup"; Rec."Disable Auto Task Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disable Auto Task Setup field';
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
                field("Batch Task"; Rec."Batch Task")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Batch Task field';
                }
                field("Max Records per File"; Rec."Max Records per File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max qty. records per XML File field';
                }
                field("Batch Last Run"; Rec."Batch Last Run")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Batch Last Run field';
                }
                field("Runtime Error"; Rec."Runtime Error")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Runtime Error field';
                }
                field("Last Error Message"; Rec."Last Error Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Error Message field';
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
                field("Before Transfer Codeunit ID"; Rec."Before Transfer Codeunit ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Before Transfer Codeunit ID field';
                }
                field("Before Transfer Codeunit Name"; Rec."Before Transfer Codeunit Name")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Before Transfer Codeunit Name field';
                }
                field("Before Transfer Function"; Rec."Before Transfer Function")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Before Transfer Function field';
                }
                group("File")
                {
                    Caption = 'File';
                    field("File Transfer"; Rec."File Transfer")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the File Transfer field';
                    }
                    field("File Path"; Rec."File Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the File Path field';
                    }
                }
                group(FTP)
                {
                    field("FTP Transfer"; Rec."FTP Transfer")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the FTP Transfer field';
                    }
                    field("FTP Server"; Rec."FTP Server")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the FTP Server field';
                    }
                    field("FTP Username"; Rec."FTP Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the FTP Username field';
                    }
                    field("FTP Password"; Rec."FTP Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the FTP Password field';
                    }
                    field("FTP Port"; Rec."FTP Port")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the FTP Port field';
                    }
                    field("FTP Passive"; Rec."FTP Passive")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the FTP Passive field';
                    }
                    field("FTP Directory"; Rec."FTP Directory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the FTP Directory field';
                    }
                    field("FTP Filename (Fixed)"; Rec."FTP Filename (Fixed)")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the FTP Filename (Fixed) field';
                    }
                }
                group(API)
                {
                    field("API Transfer"; Rec."API Transfer")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the API Transfer field';
                    }
                    field("API Type"; Rec."API Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the API Type field';
                    }
                    field("API Url"; Rec."API Url")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the API Url field';
                    }
                    group(Control6151411)
                    {
                        ShowCaption = false;
                        Visible = Rec."API Type" <> Rec."API Type"::SOAP;
                        field("API Method"; Rec."API Method")
                        {
                            ApplicationArea = All;
                            Importance = Promoted;
                            ToolTip = 'Specifies the value of the API Method field';
                        }
                    }
                    group(Control6150679)
                    {
                        ShowCaption = false;
                        Visible = Rec."API Type" = Rec."API Type"::SOAP;
                        field("API SOAP Action"; Rec."API SOAP Action")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the API SOAP Action field';
                        }
                    }
                    field("API Username Type"; Rec."API Username Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the API Username Type field';
                    }
                    field("API Username"; Rec."API Username")
                    {
                        ApplicationArea = All;
                        Enabled = Rec."API Username Type" = Rec."API Username Type"::Custom;
                        ToolTip = 'Specifies the value of the API Username field';
                    }
                    field("API Password"; Rec."API Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the API Password field';
                    }
                    field("API Content-Type"; Rec."API Content-Type")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Content-Type field';
                    }
                    field("API Authorization"; Rec."API Authorization")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Authorization field';
                    }
                    field("API Accept"; Rec."API Accept")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Accept field';
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
                        Visible = Rec."API Type" <> Rec."API Type"::"REST (Json)";
                        field("API Response Path"; Rec."API Response Path")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the API Response Path field';
                        }
                    }
                    field("API Response Success Path"; Rec."API Response Success Path")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Response Success Path field';
                    }
                    field("API Response Success Value"; Rec."API Response Success Value")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Response Success Value field';
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        Visible = Rec."API Type" = Rec."API Type"::"REST (Json)";
                        field("JSON Root is Array"; Rec."JSON Root is Array")
                        {
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the value of the JSON Root is Array field';
                        }
                        field("Use JSON Numbers"; Rec."Use JSON Numbers")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Use JSON Numbers field';
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Elements";
                RunPageLink = "Xml Template Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Edit Field Mapping action';
            }
            action("Preview Xml")
            {
                Caption = 'Preview Xml';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Preview Xml action';

                trigger OnAction()
                var
                    NpXmlMgt: Codeunit "NPR NpXml Mgt.";
                begin
                    NpXmlMgt.PreviewXml(Rec.Code);
                end;
            }
            action("Template History")
            {
                Caption = 'Template History';
                Image = History;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Templ. Chng. History";
                RunPageLink = "Template Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Template History action';
            }
            action("Archived Versions")
            {
                Caption = 'Archived Versions';
                Image = Versions;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page "NPR NpXml Templ. Arch. List";
                RunPageLink = Code = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Archived Versions action';
            }
        }
        area(processing)
        {
            action("Init New Version")
            {
                Caption = 'Init New Version';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Init New Version action';

                trigger OnAction()
                begin
                    Rec.InitVersion();
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
            action("Schedule Batch Task")
            {
                Caption = 'Schedule Batch Task';
                Image = NewToDo;
                ApplicationArea = All;
                ToolTip = 'Executes the Schedule Batch Task action';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    NpXmlBatchProcessing: Codeunit "NPR NpXml Batch Processing";
                    PageManagement: Codeunit "Page Management";
                begin
                    NpXmlBatchProcessing.ScheduleBatchTask(Rec, JobQueueEntry);

                    Commit();
                    if GuiAllowed then
                        PAGE.Run(PageManagement.GetDefaultCardPageID(DATABASE::"Job Queue Entry"), JobQueueEntry);
                end;
            }
            action("Archive Template")
            {
                Caption = 'Archive Template';
                Image = Archive;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Archive Template action';

                trigger OnAction()
                begin
                    if Rec.Archived then
                        Error(Text100, Rec."Template Version");

                    NpXmlTemplateMgt.Archive(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.NpXmlBatchFilters.PAGE.SetParentTableNo(Rec."Table No.");
        NpXmlTemplateTriggersVisible := Rec.Find();
        NpXmlBatchFiltersVisible := Rec.Find();
    end;

    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        NpXmlTemplateTriggersVisible: Boolean;
        NpXmlBatchFiltersVisible: Boolean;
        Text100: Label 'Template %1 has already been archived';
}
