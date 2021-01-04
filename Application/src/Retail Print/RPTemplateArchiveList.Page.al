page 6014631 "NPR RP Template Archive List"
{
    Caption = 'Template Archive List';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field("Archived at"; "Archived at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived at field';
                }
                field("Archived by"; "Archived by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived by field';
                }
                field("Version Comments"; "Version Comments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version Comments field';
                }
                field("Template.HASVALUE"; Template.HasValue)
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Restore Version action';

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

