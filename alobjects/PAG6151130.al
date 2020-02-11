page 6151130 "TM Seating Setup"
{
    // TM1.45/TSA /20191113 CASE 322432 Initial Version

    Caption = 'Seating Setup';
    PageType = List;
    SourceTable = "TM Seating Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code";"Admission Code")
                {
                }
                field("Seat Numbering";"Seat Numbering")
                {
                }
                field("Row Numbering";"Row Numbering")
                {
                }
                field("Template Cache";"Template Cache")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Seating Template")
            {
                Caption = 'Seating Template';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SeatingManagement: Codeunit "TM Seating Management";
                begin

                    SeatingManagement.ShowSeatingTemplate ("Admission Code");
                end;
            }
        }
    }
}

