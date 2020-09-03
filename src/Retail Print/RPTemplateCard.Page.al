page 6014638 "NPR RP Template Card"
{
    // NPR5.32/MMV /20170424 CASE 241995 Retail Print 2.0
    // NPR5.34/MMV /20170727 CASE 284505 Expose all column distributions.
    // NPR5.41/MMV /20180417 CASE 311633 Added field "Default Decimal Rounding".

    Caption = 'Template Card';
    SourceTable = "NPR RP Template Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = NOT Archived;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Printer Type"; "Printer Type")
                {
                    ApplicationArea = All;
                }
                field("Printer Device"; "Printer Device")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    ToolTip = 'Blank = Decide based on printername keyword match.';

                    trigger OnAssistEdit()
                    begin
                        LookupDevice();
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Archived; Archived)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        RPTemplateArchive: Record "NPR RP Template Archive";
                    begin
                        RPTemplateArchive.SetRange(Code, Code);
                        PAGE.RunModal(PAGE::"NPR RP Template Archive List", RPTemplateArchive);
                    end;
                }
                field("Version Comments"; "Version Comments")
                {
                    ApplicationArea = All;
                }
                field("Last Modified At"; "Last Modified At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Modified By"; "Last Modified By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Default Decimal Rounding"; "Default Decimal Rounding")
                {
                    ApplicationArea = All;
                }
            }
            group("Line Settings")
            {
                Caption = 'Line Settings';
                Editable = NOT Archived;
                Visible = "Printer Type" = 1;
                group("Two Column Distribution")
                {
                    Caption = 'Two Column Distribution';
                    field("Two Column Width 1"; "Two Column Width 1")
                    {
                        ApplicationArea = All;
                    }
                    field("Two Column Width 2"; "Two Column Width 2")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Three Column Distribution")
                {
                    Caption = 'Three Column Distribution';
                    field("Three Column Width 1"; "Three Column Width 1")
                    {
                        ApplicationArea = All;
                    }
                    field("Three Column Width 2"; "Three Column Width 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Three Column Width 3"; "Three Column Width 3")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Four Column Distribution")
                {
                    Caption = 'Four Column Distribution';
                    field("Four Column Width 1"; "Four Column Width 1")
                    {
                        ApplicationArea = All;
                    }
                    field("Four Column Width 2"; "Four Column Width 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Four Column Width 3"; "Four Column Width 3")
                    {
                        ApplicationArea = All;
                    }
                    field("Four Column Width 4"; "Four Column Width 4")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Processing)
            {
                Caption = 'Processing';
                Editable = NOT Archived;
                field("Pre Processing Codeunit"; "Pre Processing Codeunit")
                {
                    ApplicationArea = All;
                }
                field("Print Processing Object Type"; "Print Processing Object Type")
                {
                    ApplicationArea = All;
                }
                field("Print Processing Object ID"; "Print Processing Object ID")
                {
                    ApplicationArea = All;
                }
                field("Post Processing Codeunit"; "Post Processing Codeunit")
                {
                    ApplicationArea = All;
                }
            }
            group(Media)
            {
                Caption = 'Media';
                Editable = NOT Archived;
                field("tmpMediaInfo.Picture"; tmpMediaInfo.Picture)
                {
                    ApplicationArea = All;
                    Caption = 'Media Roll Picture';

                    trigger OnValidate()
                    var
                        MediaInfo: Record "NPR RP Template Media Info";
                    begin
                        GetMediaInfoRecord(MediaInfo, true);
                        MediaInfo.Picture := tmpMediaInfo.Picture;
                        MediaInfo.Modify(true);
                        CurrPage.Update(true);
                    end;
                }
                field("tmpMediaInfo.URL"; tmpMediaInfo.URL)
                {
                    ApplicationArea = All;
                    Caption = 'Media Roll URL';

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Data Items";
                RunPageLink = Code = FIELD(Code);
            }
            action("Edit Layout")
            {
                Caption = 'Edit Layout';
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Template Designer";
                RunPageLink = Code = FIELD(Code);
            }
            action("Edit Device Settings")
            {
                Caption = 'Edit Device Settings';
                Image = SetupLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Device Settings";
                RunPageLink = Template = FIELD(Code);
            }
            action("New Version")
            {
                Caption = 'New Version';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TemplateHeader: Record "NPR RP Template Header";
                    TemplateMgt: Codeunit "NPR RP Template Mgt.";
                begin
                    TemplateHeader.Get(Code);
                    TemplateMgt.CreateNewVersion(TemplateHeader);
                end;
            }
            action(Archive)
            {
                Caption = 'Archive';
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TemplateHeader: Record "NPR RP Template Header";
                begin
                    TemplateHeader.Get(Code);
                    TemplateHeader.Validate(Archived, true);
                end;
            }
            action("View Archived Versions")
            {
                Caption = 'View Archived Versions';
                Image = Versions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR RP Template Archive List";
                RunPageLink = Code = FIELD(Code);
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
        Return := MediaInfo.Get(Code);
        if not Return then
            if WithInsert then begin
                MediaInfo.Init;
                MediaInfo.Template := Code;
                Return := MediaInfo.Insert;
            end;
    end;
}

