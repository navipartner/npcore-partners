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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Printer Type"; Rec."Printer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer Type field';
                }
                field("Printer Device"; Rec."Printer Device")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    ToolTip = 'Blank = Decide based on printername keyword match.';

                    trigger OnAssistEdit()
                    begin
                        Rec.LookupDevice();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comments field';
                }
                field(Archived; Rec.Archived)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Archived field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Version field';

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version Comments field';
                }
                field("Last Modified At"; Rec."Last Modified At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Modified At field';
                }
                field("Last Modified By"; Rec."Last Modified By")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Modified By field';
                }
                field("Default Decimal Rounding"; Rec."Default Decimal Rounding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Decimal Rounding field';
                }
                field("Log Output"; Rec."Log Output")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Output field';
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Two Column Width 1 field';
                    }
                    field("Two Column Width 2"; Rec."Two Column Width 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Two Column Width 2 field';
                    }
                }
                group("Three Column Distribution")
                {
                    Caption = 'Three Column Distribution';
                    field("Three Column Width 1"; Rec."Three Column Width 1")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Three Column Width 1 field';
                    }
                    field("Three Column Width 2"; Rec."Three Column Width 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Three Column Width 2 field';
                    }
                    field("Three Column Width 3"; Rec."Three Column Width 3")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Three Column Width 3 field';
                    }
                }
                group("Four Column Distribution")
                {
                    Caption = 'Four Column Distribution';
                    field("Four Column Width 1"; Rec."Four Column Width 1")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Four Column Width 1 field';
                    }
                    field("Four Column Width 2"; Rec."Four Column Width 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Four Column Width 2 field';
                    }
                    field("Four Column Width 3"; Rec."Four Column Width 3")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Four Column Width 3 field';
                    }
                    field("Four Column Width 4"; Rec."Four Column Width 4")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Four Column Width 4 field';
                    }
                }
            }
            group(Processing)
            {
                Caption = 'Processing';
                Editable = NOT Rec.Archived;
                field("Pre Processing Codeunit"; Rec."Pre Processing Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pre Processing Codeunit field';
                }
                field("Print Processing Object Type"; Rec."Print Processing Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Processing Object Type field';
                }
                field("Print Processing Object ID"; Rec."Print Processing Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Processing Object ID field';
                }
                field("Post Processing Codeunit"; Rec."Post Processing Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Processing Codeunit field';
                }
            }
            group(Media)
            {
                Caption = 'Media';
                Editable = NOT Rec.Archived;
                field("tmpMediaInfo.Picture"; tmpMediaInfo.Image)
                {
                    ApplicationArea = All;
                    Caption = 'Media Roll Picture';
                    ToolTip = 'Specifies the value of the Media Roll Picture field';

                    trigger OnValidate()
                    var
                        MediaInfo: Record "NPR RP Template Media Info";
                    begin
                        GetMediaInfoRecord(MediaInfo, true);
                        MediaInfo.Image := tmpMediaInfo.Image;
                        MediaInfo.Modify(true);
                        CurrPage.Update(true);
                    end;
                }
                field("tmpMediaInfo.URL"; tmpMediaInfo.URL)
                {
                    ApplicationArea = All;
                    Caption = 'Media Roll URL';
                    ToolTip = 'Specifies the value of the Media Roll URL field';

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
                field("tmpMediaInfo.Description"; tmpMediaInfo.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Media Roll Description';
                    ToolTip = 'Specifies the value of the Media Roll Description field';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Edit Data Items action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Edit Layout action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Edit Device Settings action';
            }
            action("New Version")
            {
                Caption = 'New Version';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the New Version action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Archive action';

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
                ApplicationArea = All;
                RunObject = Page "NPR RP Template Output Log";
                RunPageLink = "Template Name" = FIELD(Code);
                ToolTip = 'Executes the Show Log action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the View Archived Versions action';
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

