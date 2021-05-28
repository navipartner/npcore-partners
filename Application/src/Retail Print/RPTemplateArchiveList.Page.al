page 6014631 "NPR RP Template Archive List"
{
    Caption = 'Template Archive List';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR RP Template Archive";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field("Archived at"; Rec."Archived at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived at field';
                }
                field("Archived by"; Rec."Archived by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived by field';
                }
                field("Version Comments"; Rec."Version Comments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version Comments field';
                }
                field("Template.HASVALUE"; Rec.Template.HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Archived Data';
                    ToolTip = 'Specifies the value of the Archived Data field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Restore Version action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Export Version action';

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

