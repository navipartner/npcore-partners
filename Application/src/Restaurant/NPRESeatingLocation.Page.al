page 6150667 "NPR NPRE Seating Location"
{
    Caption = 'Seating Locations';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Layout';
    SourceTable = "NPR NPRE Seating Location";
    UsageCategory = Administration;
    ApplicationArea = All;
    PopulateAllFields = true;

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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field(Control6014404; Rec.Seatings)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Seatings field';
                }
                field(Seats; Rec.Seats)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Seats field';
                }
                field("POS Store"; Rec."POS Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store field';
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Send Kitchen Order field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Seatings action';
                }
            }
        }
    }
}
