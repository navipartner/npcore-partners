page 6014433 "NPR Payment Method Mapper"
{


    Caption = 'Payment Method Mapper';
    PageType = List;
    SourceTable = "NPR Payment Method Mapper";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Payment Method"; Rec."POS Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'POS Payment Method for Fiskaly.';
                }
                field("Fiscal Name"; Rec."Fiscal Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Fiscal Name for Fiskaly API.';
                }
                field("DSFINVK Type"; Rec."DSFINVK Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Type for Fiskaly DSFINVK API.';
                }
            }
        }
    }
}