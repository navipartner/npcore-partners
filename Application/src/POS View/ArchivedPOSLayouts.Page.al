page 6060145 "NPR Archived POS Layouts"
{
    Extensible = False;
    ApplicationArea = NPRRetail;
    Caption = 'Archived POS Layouts';
    PageType = List;
    SourceTable = "NPR POS Layout Archive";
    UsageCategory = Administration;
    Editable = false;

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
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the version number assigned to the archive entry.';
                }
                field("Date-Time Archived"; Rec.SystemCreatedAt)
                {
                    Caption = 'Date-Time Archived';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date-time the archived POS layout has been created on.';
                }
                field("Archived By"; Rec."Archived By")
                {
                    Caption = 'Archived By';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the user id of the person, who created the archived POS layout.';
                }
            }
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
        area(processing)
        {
            action(Restore)
            {
                Caption = 'Restore';
                ApplicationArea = NPRRetail;
                ToolTip = 'Transfer the contents of this archived version to the POS layout the version was created from.';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    POSLayoutArchiveMgt: Codeunit "NPR POS Layout Archive Mgt.";
                begin
                    POSLayoutArchiveMgt.RestoreArchivedVersion(Rec);
                end;
            }
        }
    }
}
