page 6014434 "NPR VAT Prod Post Group Mapper"
{

    ApplicationArea = All;
    Caption = 'VAT Prod Post Group Mapper List';
    PageType = List;
    SourceTable = "NPR VAT Post. Group Mapper";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("VAT Prod. Pos. Group"; Rec."VAT Prod. Pos. Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'VAT Prod. Pos. Group for Fiskaly.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'VAT Bus. Posting Group for Fiskaly.';
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'VAT Identifier for Fiskaly.';
                }
                field("Fiscal Name"; Rec."Fiscal Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Fiscal Name for Fiskaly API.';
                }
                field("DSFINVK ID"; Rec."DSFINVK ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'ID for Fiskaly DSFINVK API.';
                }
            }
        }
    }
}