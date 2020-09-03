page 6014631 "NPR RP Template Archive List"
{
    Caption = 'Template Archive List';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR RP Template Archive";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                }
                field("Archived at"; "Archived at")
                {
                    ApplicationArea = All;
                }
                field("Archived by"; "Archived by")
                {
                    ApplicationArea = All;
                }
                field("Version Comments"; "Version Comments")
                {
                    ApplicationArea = All;
                }
                field("Template.HASVALUE"; Template.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Archived Data';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Restore)
            {
                Caption = 'Restore Version';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
                begin
                    RPTemplateMgt.RollbackVersion(Rec);
                    CurrPage.Close;
                end;
            }
            action(Export)
            {
                Caption = 'Export Version';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
                begin
                    RPTemplateMgt.ExportArchived(Rec);
                end;
            }
        }
    }
}

