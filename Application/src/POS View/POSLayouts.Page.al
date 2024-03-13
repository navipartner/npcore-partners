page 6060102 "NPR POS Layouts"
{
    Extensible = False;
    ApplicationArea = NPRRetail;
    Caption = 'POS Layouts';
    ContextSensitiveHelpPage = 'docs/retail/pos_layout/how-to/activate_pos_editor/';
    PageType = List;
    SourceTable = "NPR POS Layout";
    UsageCategory = Administration;
    DelayedInsert = true;
    PromotedActionCategories = 'Manage,Process,Report,Migrate,Archive';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a code to identify this POS layout.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a text that describes the POS layout.';
                }
                field("Template Name"; Rec."Template Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the template this POS layout is based on.';
                }
                field("Frontend Properties"; Rec."Frontend Properties".HasValue())
                {
                    Caption = 'Frontend Properties';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether a collection of frontend properties has been defined for this POS layout.';
                }
                field("No. of Archived Versions"; Rec."No. of Archived Versions")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of archived versions for this POS layout.';
                }
            }
#if DEBUG
            group(JsonEditor)
            {
                Caption = 'Frontend Properties';

                usercontrol(Editor; "NPR JsonEditor")
                {
                    ApplicationArea = NPRRetail;

                    trigger OnControlReady()
                    begin
                        CurrPage.Editor.Invoke('setJson', Rec.GetLayot(true));
                    end;

                    trigger OnEvent(Method: Text; EventContent: Text)
                    begin
                        case Method of
                            'save':
                                begin
                                    if (format(EventContent) = '{}') then
                                        EventContent := '';
                                    Rec.SetLayout(EventContent);
                                    CurrPage.SaveRecord();
                                end;
                            'retrieve':
                                begin
                                    //RetrieveAutoCompleteOptions(EventContent);
                                end;
                        end;
                    end;
                }
            }
#endif
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = NPRRetail;
                Visible = false;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Archive Layout")
            {
                Caption = 'Create Archive Version';
                ApplicationArea = NPRRetail;
                ToolTip = 'Create a new archive version of the POS layout, for example because you want to change the layout, and retain possibility to revert to previous version.';
                Image = Archive;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    POSLayoutArchiveMgt: Codeunit "NPR POS Layout Archive Mgt.";
                begin
                    POSLayoutArchiveMgt.CreateArchivedVersion(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ExportPackageSelected)
            {
                Caption = 'Export to File';
                ApplicationArea = NPRRetail;
                ToolTip = 'Export selected POS layouts into a file.';
                Image = Export;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    POSLayout: Record "NPR POS Layout";
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                begin
                    CurrPage.SetSelectionFilter(POSLayout);
                    POSLayout := Rec;
                    POSPackageHandler.ExportPOSLayoutsToFile(POSLayout);
                end;
            }
            action(ImportPackage)
            {
                Caption = 'Import from File';
                ApplicationArea = NPRRetail;
                ToolTip = 'Import POS layouts from a file.';
                Image = Import;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Ellipsis = true;
                Scope = Page;

                trigger OnAction()
                var
                    POSPackageHandler: Codeunit "NPR POS Package Handler";
                begin
                    POSPackageHandler.ImportPOSLayoutsFromFile();
                    CurrPage.Update(false);
                end;
            }
            action(DeployPackageFromAzureBlob)
            {
                Caption = 'Download';
                ApplicationArea = NPRRetail;
                ToolTip = 'Download POS layouts from a package hosted online.';
                Image = ImportDatabase;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Ellipsis = true;
                Scope = Page;
                RunObject = Page "NPR POS Layout Deploy fr.Azure";
            }
        }
    }
#if DEBUG
    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Editor.Invoke('setJson', Rec.GetLayot(true));
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CurrPage.Editor.Invoke('setJson', '');
    end;
#endif
}
