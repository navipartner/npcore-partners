page 6014631 "RP Template Archive List"
{
    Caption = 'Template Archive List';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "RP Template Archive";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Version;Version)
                {
                }
                field("Archived at";"Archived at")
                {
                }
                field("Archived by";"Archived by")
                {
                }
                field("Version Comments";"Version Comments")
                {
                }
                field("Template.HASVALUE";Template.HasValue)
                {
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
                    RPTemplateMgt: Codeunit "RP Template Mgt.";
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
                    RPTemplateMgt: Codeunit "RP Template Mgt.";
                begin
                    RPTemplateMgt.ExportArchived(Rec);
                end;
            }
        }
    }
}

