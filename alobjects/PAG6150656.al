page 6150656 "POS Payment Line List"
{
    // NPR5.36/BR  /20170810  CASE  277096 Object created
    // NPR5.53/SARA/20191024 CASE 373672 Addde Action button POS Entry Card

    Caption = 'POS Payment Line List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "POS Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date";"Entry Date")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("POS Period Register No.";"POS Period Register No.")
                {
                }
                field("POS Payment Method Code";"POS Payment Method Code")
                {
                }
                field("POS Payment Bin Code";"POS Payment Bin Code")
                {
                }
                field(Description;Description)
                {
                }
                field(Amount;Amount)
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Amount (Sales Currency)";"Amount (Sales Currency)")
                {
                }
                field("Amount (LCY)";"Amount (LCY)")
                {
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("Line No.";"Line No.")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("POS Entry")
            {
                Caption = 'POS Entry';
                action("POS Entry Card")
                {
                    Caption = 'POS Entry Card';
                    Image = List;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "POS Entry Card";
                    RunPageLink = "Entry No."=FIELD("POS Entry No.");
                    RunPageView = SORTING("Entry No.");
                }
            }
        }
    }
}

