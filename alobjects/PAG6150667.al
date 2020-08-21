page 6150667 "NPRE Seating Location"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.52/ALPO/20190813 CASE 360258 Location specific setting of 'Auto print kitchen order'
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Seating Locations';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Layout';
    SourceTable = "NPRE Seating Location";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                }
                field(Control6014404; Seatings)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
                field(Seats; Seats)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("POS Store"; "POS Store")
                {
                    ApplicationArea = All;
                }
                field("Auto Send Kitchen Order"; "Auto Send Kitchen Order")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Layout")
            {
                Caption = 'Layout';
                action(Seatings)
                {
                    Caption = 'Seatings';
                    Image = Lot;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPRE Seating List";
                    RunPageLink = "Seating Location" = FIELD(Code);
                }
            }
        }
    }
}

