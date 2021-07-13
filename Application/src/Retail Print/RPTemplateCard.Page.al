page 6014638 "NPR RP Template Card"
{
    UsageCategory = None;
    Caption = 'Template Card';
    SourceTable = "NPR RP Template Header";

    layout
    {
        area(content)
        {
            group(General)
            {
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
                field("Printer Device"; Rec."Printer Device")
                {

                    AssistEdit = true;
                    ToolTip = 'Blank = Decide based on printername keyword match.';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.LookupDevice();
                    end;
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
            group(Processing)
            {
                Caption = 'Processing';
                Editable = NOT Rec.Archived;
                field("Pre Processing Codeunit"; Rec."Pre Processing Codeunit")
                {

                    ToolTip = 'Specifies the value of the Pre Processing Codeunit field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Processing Object Type"; Rec."Print Processing Object Type")
                {

                    ToolTip = 'Specifies the value of the Print Processing Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Processing Object ID"; Rec."Print Processing Object ID")
                {

                    ToolTip = 'Specifies the value of the Print Processing Object ID field';
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
                // field("Media Roll Picture"; tmpMediaInfo.Image)
                field("Media Roll Picture"; tmpMediaInfo.Picture)
                {

                    Caption = 'Media Roll Picture';
                    ToolTip = 'Specifies the value of the Media Roll Picture field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        MediaInfo: Record "NPR RP Template Media Info";
                    begin
                        GetMediaInfoRecord(MediaInfo, true);
                        // MediaInfo.Image := tmpMediaInfo.Image;
                        MediaInfo.Picture := tmpMediaInfo.Picture;
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
                RunObject = Page "NPR RP Template Designer";
                RunPageLink = Code = FIELD(Code);

                ToolTip = 'Executes the Edit Layout action';
                ApplicationArea = NPRRetail;
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
        MediaInfo.SetAutoCalcFields(Picture);
        Return := MediaInfo.Get(Rec.Code);
        if not Return then
            if WithInsert then begin
                MediaInfo.Init();
                MediaInfo.Template := Rec.Code;
                Return := MediaInfo.Insert();
            end;
    end;
}

