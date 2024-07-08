page 6014638 "NPR RP Template Card"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Template Card';
    SourceTable = "NPR RP Template Header";
#if not BC17
    AboutTitle = 'Template Card';
    AboutText = 'The Template Card serves as a versatile tool for configuring and managing template settings within your system. These templates play a crucial role in ensuring seamless and efficient printing processes.';
#endif

    layout
    {
        area(content)
        {
            group(General)
            {
#if not BC17
                AboutTitle = 'General Information';
                AboutText = 'In the "General" section, you will find key configuration options for the specific Template. Assign a unique code for easy identification and select the printer type from supported options. Add comments for context, track version changes, and view the last modification date and time. You can also enable or disable log output. These settings allow you to customize and manage the template efficiently.';
#endif
                Editable = NOT Rec.Archived;
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Printer Type"; Rec."Printer Type")
                {

                    ToolTip = 'Specifies the value of the Printer Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Comments field';
                    ApplicationArea = NPRRetail;
                }
                field(Archived; Rec.Archived)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Archived field';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    AssistEdit = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        RPTemplateArchive: Record "NPR RP Template Archive";
                    begin
                        RPTemplateArchive.SetRange(Code, Rec.Code);
                        PAGE.RunModal(PAGE::"NPR RP Template Archive List", RPTemplateArchive);
                    end;
                }
                field("Version Comments"; Rec."Version Comments")
                {

                    ToolTip = 'Specifies the value of the Version Comments field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Modified At"; Rec."Last Modified At")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Modified At field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Modified By"; Rec."Last Modified By")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Modified By field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Decimal Rounding"; Rec."Default Decimal Rounding")
                {

                    ToolTip = 'Specifies the value of the Default Decimal Rounding field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Output"; Rec."Log Output")
                {

                    ToolTip = 'Specifies the value of the Log Output field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Line Settings")
            {
                Caption = 'Line Settings';
                Editable = NOT Rec.Archived;
                Visible = Rec."Printer Type" = 1;
#if not BC17
                AboutTitle = 'Line Settings';
                AboutText = 'Within the "Lines Settings" section, you can further tailor the template to your needs. This section includes fields for selecting the line device that best suits your requirements, as well as options for defining distribution settings for templates with two, three, or four columns. These versatile settings empower you to optimize your template for various content layouts and printing needs, making it a valuable tool for your system.';
#endif
                field("Line Device"; Rec."Line Device")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Select the device the template is built for';
                }
                group("Two Column Distribution")
                {
                    Caption = 'Two Column Distribution';
                    field("Two Column Width 1"; Rec."Two Column Width 1")
                    {

                        ToolTip = 'Specifies the value of the Two Column Width 1 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Two Column Width 2"; Rec."Two Column Width 2")
                    {

                        ToolTip = 'Specifies the value of the Two Column Width 2 field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Three Column Distribution")
                {
                    Caption = 'Three Column Distribution';
                    field("Three Column Width 1"; Rec."Three Column Width 1")
                    {

                        ToolTip = 'Specifies the value of the Three Column Width 1 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Three Column Width 2"; Rec."Three Column Width 2")
                    {

                        ToolTip = 'Specifies the value of the Three Column Width 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Three Column Width 3"; Rec."Three Column Width 3")
                    {

                        ToolTip = 'Specifies the value of the Three Column Width 3 field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Four Column Distribution")
                {
                    Caption = 'Four Column Distribution';
                    field("Four Column Width 1"; Rec."Four Column Width 1")
                    {

                        ToolTip = 'Specifies the value of the Four Column Width 1 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Four Column Width 2"; Rec."Four Column Width 2")
                    {

                        ToolTip = 'Specifies the value of the Four Column Width 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Four Column Width 3"; Rec."Four Column Width 3")
                    {

                        ToolTip = 'Specifies the value of the Four Column Width 3 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Four Column Width 4"; Rec."Four Column Width 4")
                    {

                        ToolTip = 'Specifies the value of the Four Column Width 4 field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(MatrixSettings)
            {
                Caption = 'Matrix Settings';
                Editable = NOT Rec.Archived;
                Visible = Rec."Printer Type" = 0;
#if not BC17
                AboutTitle = 'Matrix Settings';
                AboutText = 'The "Matrix Settings" section allows you to select the appropriate matrix device for your template. You can choose from a variety of options, including Zebra, Blaster, Citizen, Epson and Boca. Selecting the right matrix device ensures that your template is compatible with the hardware you intend to use for printing.';
#endif
                field("Matrix Device"; Rec."Matrix Device")
                {
                    ToolTip = 'Select the device the template is built for';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Processing)
            {
                Caption = 'Processing';
                Editable = NOT Rec.Archived;
#if not BC17
                AboutTitle = 'Processing Section';
                AboutText = 'In the "Processing" section, you can configure the template''s processing settings. This typically involves setting up two preprocessing codeunits. These codeunits define how the template processes data before it''s sent to the selected matrix device for printing. It''s essential to define these codeunits accurately to achieve the desired output.';
#endif
                field("Pre Processing Codeunit"; Rec."Pre Processing Codeunit")
                {

                    ToolTip = 'Specifies the value of the Pre Processing Codeunit field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Processing Codeunit"; Rec."Post Processing Codeunit")
                {

                    ToolTip = 'Specifies the value of the Post Processing Codeunit field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Media)
            {
                Caption = 'Media';
                Editable = NOT Rec.Archived;
#if not BC17
                AboutTitle = 'Media Section';
                AboutText = 'The "Media" section is where you specify the media-related parameters for your template. This includes defining the type of media roll to be used with the template and providing a detailed description of the media roll. Accurate media settings are crucial for ensuring that your template prints correctly on the chosen media, whether it''s labels, receipts, or other printable materials.';
#endif
                field("Media Roll Picture"; tmpMediaInfo.Image)
                {

                    Caption = 'Media Roll Picture';
                    ToolTip = 'Specifies the value of the Media Roll Picture field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        MediaInfo: Record "NPR RP Template Media Info";
                        TempBlob: Codeunit "Temp Blob";
                        InStr: InStream;
                        OutStr: OutStream;
                    begin
                        GetMediaInfoRecord(MediaInfo, true);
                        TempBlob.CreateOutStream(OutStr);
                        tmpMediaInfo.Image.ExportStream(OutStr);
                        TempBlob.CreateInStream(InStr);
                        MediaInfo.Image.ImportStream(InStr, MediaInfo.FieldName(Image));
                        MediaInfo.Modify(true);
                        CurrPage.Update(true);
                    end;
                }
                field("Media Roll URL"; tmpMediaInfo.URL)
                {

                    Caption = 'Media Roll URL';
                    ToolTip = 'Specifies the value of the Media Roll URL field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        MediaInfo: Record "NPR RP Template Media Info";
                    begin
                        GetMediaInfoRecord(MediaInfo, true);
                        MediaInfo.URL := tmpMediaInfo.URL;
                        MediaInfo.Modify(true);
                        CurrPage.Update(true);
                    end;
                }
                field("Media Roll Description"; tmpMediaInfo.Description)
                {

                    Caption = 'Media Roll Description';
                    ToolTip = 'Specifies the value of the Media Roll Description field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        MediaInfo: Record "NPR RP Template Media Info";
                    begin
                        GetMediaInfoRecord(MediaInfo, true);
                        MediaInfo.Description := tmpMediaInfo.Description;
                        MediaInfo.Modify(true);
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Data Items")
            {
                Caption = 'Edit Data Items';
                Image = Splitlines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Data Items";
                RunPageLink = Code = FIELD(Code);

                ToolTip = 'Executes the Edit Data Items action';
                ApplicationArea = NPRRetail;
            }
            action("Edit Layout")
            {
                Caption = 'Edit Layout';
                Image = EditLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Edit Layout action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RPTemplateLine: Record "NPR RP Template Line";
                begin
                    RPTemplateLine.SetRange("Template Code", Rec.Code);

                    case Rec."Printer Type" of
                        Rec."Printer Type"::Line:
                            Page.RunModal(Page::"NPR RP Templ. Line Designer", RPTemplateLine);
                        Rec."Printer Type"::Matrix:
                            Page.RunModal(Page::"NPR RP Templ. Matrix Designer", RPTemplateLine);
                    end;
                end;
            }
            action("Edit Device Settings")
            {
                Caption = 'Edit Device Settings';
                Image = SetupLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Device Settings";
                RunPageLink = Template = FIELD(Code);

                ToolTip = 'Executes the Edit Device Settings action';
                ApplicationArea = NPRRetail;
            }
            action("New Version")
            {
                Caption = 'New Version';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the New Version action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RPTemplateHeader: Record "NPR RP Template Header";
                    TemplateMgt: Codeunit "NPR RP Template Mgt.";
                begin
                    RPTemplateHeader.Get(Rec.Code);
                    TemplateMgt.CreateNewVersion(RPTemplateHeader);
                end;
            }
            action(Archive)
            {
                Caption = 'Archive';
                Image = Archive;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Archive action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RPTemplateHeader: Record "NPR RP Template Header";
                begin
                    RPTemplateHeader.Get(Rec.Code);
                    RPTemplateHeader.Validate(Archived, true);
                end;
            }
            action("Show Log")
            {
                Caption = 'Show Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                RunObject = Page "NPR RP Template Output Log";
                RunPageLink = "Template Name" = FIELD(Code);
                ToolTip = 'Executes the Show Log action';
                ApplicationArea = NPRRetail;
            }
            action("View Archived Versions")
            {
                Caption = 'View Archived Versions';
                Image = Versions;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Template Archive List";
                RunPageLink = Code = FIELD(Code);

                ToolTip = 'Executes the View Archived Versions action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MediaInfo: Record "NPR RP Template Media Info";
    begin
        if GetMediaInfoRecord(MediaInfo, false) then
            tmpMediaInfo := MediaInfo;
    end;

    var
        tmpMediaInfo: Record "NPR RP Template Media Info";

    local procedure GetMediaInfoRecord(var MediaInfo: Record "NPR RP Template Media Info"; WithInsert: Boolean) Return: Boolean
    begin
        Return := MediaInfo.Get(Rec.Code);
        if not Return then
            if WithInsert then begin
                MediaInfo.Init();
                MediaInfo.Template := Rec.Code;
                Return := MediaInfo.Insert();
            end;
    end;
}

