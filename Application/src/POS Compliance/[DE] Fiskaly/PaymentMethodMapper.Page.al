page 6014433 "NPR Payment Method Mapper"
{
    Extensible = False;
    Caption = 'Payment Method Mapper';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
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
                field("Fiskaly Payment Type"; Rec."Fiskaly Payment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies Fiskaly API payment type.';
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
