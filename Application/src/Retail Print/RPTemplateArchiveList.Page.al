page 6014631 "NPR RP Template Archive List"
{
    Extensible = False;
    Caption = 'Template Archive List';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR RP Template Archive";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Archived at"; Rec."Archived at")
                {

                    ToolTip = 'Specifies the value of the Archived at field';
                    ApplicationArea = NPRRetail;
                }
                field("Archived by"; Rec."Archived by")
                {

                    ToolTip = 'Specifies the value of the Archived by field';
                    ApplicationArea = NPRRetail;
                }
                field("Version Comments"; Rec."Version Comments")
                {

                    ToolTip = 'Specifies the value of the Version Comments field';
                    ApplicationArea = NPRRetail;
                }
                field("Archived Data"; Rec.Template.HasValue())
                {

                    Caption = 'Archived Data';
                    ToolTip = 'Specifies the value of the Archived Data field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Restore Version action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
                begin
                    RPTemplateMgt.RollbackVersion(Rec);
                    CurrPage.Close();
                end;
            }
            action(Export)
            {
                Caption = 'Export Version';
                Image = Export;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Export Version action';
                ApplicationArea = NPRRetail;

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

