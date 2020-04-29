page 6060107 "MM Loyalty Item Point Setup"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System

    Caption = 'Loyalty Item Point Setup';
    PageType = List;
    SourceTable = "MM Loyalty Item Point Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                    Visible = false;
                }
                field(Blocked;Blocked)
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Constraint;Constraint)
                {
                }
                field("Allow On Discounted Sale";"Allow On Discounted Sale")
                {
                }
                field(Award;Award)
                {
                }
                field(Points;Points)
                {
                }
                field("Amount Factor";"Amount Factor")
                {
                }
            }
        }
    }

    actions
    {
    }
}

