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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Xml Root Name"; Rec."Xml Root Name")
                {

                    ToolTip = 'Specifies the value of the Xml Root Name field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6151403)
                {
                    ShowCaption = false;
                    Visible = Rec."Namespaces Enabled";
                    field("Xml Root Namespace"; Rec."Xml Root Namespace")
                    {

                        ToolTip = 'Specifies the value of the Xml Root Namespace field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;

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

                        ToolTip = 'Specifies the value of the Archived field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Template Version"; Rec."Template Version")
                    {

                        AssistEdit = true;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Version field';
                        ApplicationArea = NPRRetail;

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

                        Editable = false;
                        ToolTip = 'Specifies the value of the Last Modified at field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Version Description"; Rec."Version Description")
                    {

                        ToolTip = 'Specifies the value of the Version Description field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                field("Root Element Attr. Enabled"; Rec."Root Element Attr. Enabled")
                {

                    ToolTip = 'Specifies if Attributes from Xml Root should be visible.';
                    ApplicationArea = NPRRetail;
                }
                group(ControlXmlRootAttributes)
                {
                    ShowCaption = false;
                    Visible = Rec."Root Element Attr. Enabled";
                    field("Root Element Attr. 1 Name"; Rec."Root Element Attr. 1 Name")
                    {

                        ToolTip = 'Specifies the Name of 1st Xml Root Attribute';
                        ApplicationArea = NPRRetail;
                    }
                    field("Root Element Attr. 1 Value"; Rec."Root Element Attr. 1 Value")
                    {

                        ToolTip = 'Specifies the Value of 1st Xml Root Attribute';
                        ApplicationArea = NPRRetail;
                    }
                    field("Root Element Attr. 2 Name"; Rec."Root Element Attr. 2 Name")
                    {

                        ToolTip = 'Specifies the Name of 2nd Xml Root Attribute';
                        ApplicationArea = NPRRetail;
                    }
                    field("Root Element Attr. 2 Value"; Rec."Root Element Attr. 2 Value")
                    {

                        ToolTip = 'Specifies the Value of 2nd Xml Root Attribute';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Custom Namespace for XMLNS"; Rec."Custom Namespace for XMLNS")
                {

                    ToolTip = 'Specifies the custom URI for default prefix/alias (xmlns).';
                    ApplicationArea = NPRRetail;
                }
                group(Control6150677)
                {
                    ShowCaption = false;
                    field("Namespaces Enabled"; Rec."Namespaces Enabled")
                    {

                        ToolTip = 'Specifies the value of the Namespaces Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    part(Namespaces; "NPR NpXml Namespaces")
                    {
                        SubPageLink = "Xml Template Code" = FIELD(Code);
                        Visible = Rec."Namespaces Enabled";
                        ApplicationArea = NPRRetail;

                    }
                }
            }
            group(Transaction)
            {
                Caption = 'Transaction';
                field("Transaction Task"; Rec."Transaction Task")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Transaction Task field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Processor Code"; Rec."Task Processor Code")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Task Processor Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Disable Auto Task Setup"; Rec."Disable Auto Task Setup")
                {

                    ToolTip = 'Specifies the value of the Disable Auto Task Setup field';
                    ApplicationArea = NPRRetail;
                }
                part(NpXmlTemplateTriggers; "NPR NpXml Template Triggers")
                {
                    ShowFilter = false;
                    SubPageLink = "Xml Template Code" = FIELD(Code);
                    Visible = NpXmlTemplateTriggersVisible;
                    ApplicationArea = NPRRetail;

                }
            }
            group(Batch)
            {
                Caption = 'Batch';
                field("Batch Task"; Rec."Batch Task")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Batch Task field';
                    ApplicationArea = NPRRetail;
                }
                field("Max Records per File"; Rec."Max Records per File")
                {

                    ToolTip = 'Specifies the value of the Max qty. records per XML File field';
                    ApplicationArea = NPRRetail;
                }
                field("Batch Last Run"; Rec."Batch Last Run")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Batch Last Run field';
                    ApplicationArea = NPRRetail;
                }
                field("Runtime Error"; Rec."Runtime Error")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Runtime Error field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Error Message"; Rec."Last Error Message")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Error Message field';
                    ApplicationArea = NPRRetail;
                }
                part(NpXmlBatchFilters; "NPR NpXml Batch Filters")
                {
                    ShowFilter = false;
                    SubPageLink = "Xml Template Code" = FIELD(Code),
                                  "Xml Element Line No." = CONST(-1);
                    Visible = NpXmlBatchFiltersVisible;
                    ApplicationArea = NPRRetail;

                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                field("Before Transfer Codeunit ID"; Rec."Before Transfer Codeunit ID")
                {

                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Before Transfer Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Before Transfer Codeunit Name"; Rec."Before Transfer Codeunit Name")
                {

                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Before Transfer Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Before Transfer Function"; Rec."Before Transfer Function")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Before Transfer Function field';
                    ApplicationArea = NPRRetail;
                }
                field("Do Not Add Comment Line"; Rec."Do Not Add Comment Line")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies whether a comment line should be added to the output file before transferring it to the destination resource';
                    ApplicationArea = NPRRetail;
                }
                group("File")
                {
                    Caption = 'File';
                    field("File Transfer"; Rec."File Transfer")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the File Transfer field';
                        ApplicationArea = NPRRetail;
                    }
                    field("File Path"; Rec."File Path")
                    {

                        ToolTip = 'Specifies the value of the File Path field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(FTP)
                {
                    field("FTP Transfer"; Rec."FTP Transfer")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the FTP Transfer field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Server"; Rec."FTP Server")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the FTP Server field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Username"; Rec."FTP Username")
                    {

                        ToolTip = 'Specifies the value of the FTP Username field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Password"; Rec."FTP Password")
                    {

                        ToolTip = 'Specifies the value of the FTP Password field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Port"; Rec."FTP Port")
                    {

                        ToolTip = 'Specifies the value of the FTP Port field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Passive"; Rec."FTP Passive")
                    {

                        ToolTip = 'Specifies the value of the FTP Passive field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Directory"; Rec."FTP Directory")
                    {

                        ToolTip = 'Specifies the value of the FTP Directory field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Filename (Fixed)"; Rec."FTP Filename (Fixed)")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the FTP Filename (Fixed) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("FTP Files temporrary extension"; Rec."FTP Files temporrary extension")
                    {
                        ApplicationArea = NPRRetail;
                        Importance = Additional;
                        ToolTip = 'Specifies temporrary file extension. If it is entered, file will be uploaded with this extension and then renamed to real (target) one.';
                    }
                }
                group(API)
                {
                    field("API Transfer"; Rec."API Transfer")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the API Transfer field';
                        ApplicationArea = NPRRetail;
                    }
                    field("API Type"; Rec."API Type")
                    {

                        ToolTip = 'Specifies the value of the API Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("API Url"; Rec."API Url")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the API Url field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6151411)
                    {
                        ShowCaption = false;
                        Visible = Rec."API Type" <> Rec."API Type"::SOAP;
                        field("API Method"; Rec."API Method")
                        {

                            Importance = Promoted;
                            ToolTip = 'Specifies the value of the API Method field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6150679)
                    {
                        ShowCaption = false;
                        Visible = Rec."API Type" = Rec."API Type"::SOAP;
                        field("API SOAP Action"; Rec."API SOAP Action")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the API SOAP Action field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Authorization)
                    {
                        Caption = 'Authorization';
                        field(AuthType; Rec.AuthType)
                        {
                            ApplicationArea = NPRRetail;
                            Tooltip = 'Specifies the Authorization Type.';

                            trigger OnValidate()
                            begin
                                CurrPage.Update();
                            end;
                        }
                        group(BasicAuth)
                        {
                            ShowCaption = false;
                            Visible = IsBasicAuthVisible;
                            field("API Username"; Rec."API Username")
                            {
                                Enabled = false;
                                ToolTip = 'Specifies the value of the API Username field';
                                ApplicationArea = NPRRetail;
                            }
                            field("API Password"; pw)
                            {
                                ToolTip = 'Specifies the value of the User Password field';
                                ApplicationArea = NPRRetail;
                                Caption = 'API Password';
                                trigger OnValidate()
                                begin
                                    if pw <> '' then
                                        WebServiceAuthHelper.SetApiPassword(pw, Rec."API Password Key")
                                    else begin
                                        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
                                            WebServiceAuthHelper.RemoveApiPassword(Rec."API Password Key");
                                    end;
                                end;
                            }
                        }
                        group(OAuth2)
                        {
                            ShowCaption = false;
                            Visible = IsOAuth2Visible;
                            field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                            {
                                ApplicationArea = NPRRetail;
                                ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                            }
                        }

                        group(CustomAuth)
                        {
                            ShowCaption = false;
                            Visible = IsCustomAuthVisible;
                            field("API Authorization"; Rec."API Authorization")
                            {
                                ToolTip = 'Specifies the value of the API Authorization field';
                                ApplicationArea = NPRRetail;
                            }
                        }

                    }
                    field("API Content-Type"; Rec."API Content-Type")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Content-Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("API Accept"; Rec."API Accept")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Accept field';
                        ApplicationArea = NPRRetail;
                    }
                    part("Api Headers"; "NPR NpXml Api Headers")
                    {
                        Caption = 'Api Headers';
                        ShowFilter = false;
                        SubPageLink = "Xml Template Code" = FIELD(Code);
                        ApplicationArea = NPRRetail;

                    }
                    group(Control6151410)
                    {
                        ShowCaption = false;
                        Visible = Rec."API Type" <> Rec."API Type"::"REST (Json)";
                        field("API Response Path"; Rec."API Response Path")
                        {

                            Importance = Additional;
                            ToolTip = 'Specifies the value of the API Response Path field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field("API Response Success Path"; Rec."API Response Success Path")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Response Success Path field';
                        ApplicationArea = NPRRetail;
                    }
                    field("API Response Success Value"; Rec."API Response Success Value")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the API Response Success Value field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        Visible = Rec."API Type" = Rec."API Type"::"REST (Json)";
                        field("JSON Root is Array"; Rec."JSON Root is Array")
                        {

                            Importance = Additional;
                            ToolTip = 'Specifies the value of the JSON Root is Array field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Use JSON Numbers"; Rec."Use JSON Numbers")
                        {

                            ToolTip = 'Specifies the value of the Use JSON Numbers field';
                            ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Edit Field Mapping action';
                ApplicationArea = NPRRetail;
            }
            action("Preview Xml")
            {
                Caption = 'Preview Xml';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                ToolTip = 'Executes the Preview Xml action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Template History action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Archived Versions action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Init New Version action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.InitVersion();
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
            action("Schedule Batch Task")
            {
                Caption = 'Schedule Batch Task';
                Image = NewToDo;

                ToolTip = 'Executes the Schedule Batch Task action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Archive Template action';
                ApplicationArea = NPRRetail;

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

    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);
    end;

    trigger OnAfterGetRecord()
    begin
        pw := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            pw := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.NpXmlBatchFilters.PAGE.SetParentTableNo(Rec."Table No.");
        NpXmlTemplateTriggersVisible := Rec.Find();
        NpXmlBatchFiltersVisible := Rec.Find();
    end;

    var
        [InDataSet]
        pw: Text[200];

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        NpXmlTemplateTriggersVisible: Boolean;
        NpXmlBatchFiltersVisible: Boolean;
        Text100: Label 'Template %1 has already been archived';
}
