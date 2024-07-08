page 6151059 "NPR Distribution Lines"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Lines';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Distribution Lines";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Line"; Rec."Distribution Line")
                {

                    ToolTip = 'Specifies the value of the Distribution Line field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Item"; Rec."Distribution Item")
                {

                    ToolTip = 'Specifies the value of the Distribution Item field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Variant"; Rec."Item Variant")
                {

                    ToolTip = 'Specifies the value of the Item Variant field';
                    ApplicationArea = NPRRetail;
                }
                field(Location; Rec.Location)
                {

                    ToolTip = 'Specifies the value of the Location field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Group Member"; Rec."Distribution Group Member")
                {

                    ToolTip = 'Specifies the value of the Distribution Group Member field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Required"; Rec."Action Required")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Action Required field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Quantity"; Rec."Distribution Quantity")
                {

                    ToolTip = 'Specifies the value of the Distribution Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Avaliable Quantity"; Rec."Avaliable Quantity")
                {

                    ToolTip = 'Specifies the value of the Avaliable Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Demanded Quantity"; Rec."Demanded Quantity")
                {

                    ToolTip = 'Specifies the value of the Demanded Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Org. Distribution Quantity"; Rec."Org. Distribution Quantity")
                {

                    ToolTip = 'Specifies the value of the Org. Distribution Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Cost Value (LCY)"; Rec."Distribution Cost Value (LCY)")
                {

                    ToolTip = 'Specifies the value of the Distribution Cost Value (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Created"; Rec."Date Created")
                {

                    ToolTip = 'Specifies the value of the Date Created field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}

