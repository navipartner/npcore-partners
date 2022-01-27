page 6150667 "NPR NPRE Seating Location"
{
    Extensible = False;
    Caption = 'Seating Locations';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Layout';
    SourceTable = "NPR NPRE Seating Location";
    UsageCategory = Administration;

    PopulateAllFields = true;
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
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Control6014404; Rec.Seatings)
                {

                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Seatings field';
                    ApplicationArea = NPRRetail;
                }
                field(Seats; Rec.Seats)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Seats field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store"; Rec."POS Store")
                {

                    ToolTip = 'Specifies the value of the POS Store field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {

                    ToolTip = 'Specifies the value of the Auto Send Kitchen Order field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Layout)
            {
                Caption = 'Layout';
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Image = Lot;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR NPRE Seating List";
                    RunPageLink = "Seating Location" = FIELD(Code);

                    ToolTip = 'Executes the Seatings action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
