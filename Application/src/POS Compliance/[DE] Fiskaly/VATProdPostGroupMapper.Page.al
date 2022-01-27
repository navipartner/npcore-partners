page 6014434 "NPR VAT Prod Post Group Mapper"
{
    Extensible = False;


    Caption = 'VAT Prod Post Group Mapper List';
    PageType = List;
    SourceTable = "NPR VAT Post. Group Mapper";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("VAT Prod. Pos. Group"; Rec."VAT Prod. Pos. Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'VAT Prod. Pos. Group for Fiskaly.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'VAT Bus. Posting Group for Fiskaly.';
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'VAT Identifier for Fiskaly.';
                }
                field("Fiscal Name"; Rec."Fiscal Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Fiscal Name for Fiskaly API.';
                }
                field("DSFINVK ID"; Rec."DSFINVK ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'ID for Fiskaly DSFINVK API.';
                }
            }
        }
    }
}
