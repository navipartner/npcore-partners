page 6059776 "Member Card Types Subform"
{
    Caption = 'Point Card - Types Subform';
    PageType = ListPart;
    SourceTable = "Member Card Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Base Calculation On";"Base Calculation On")
                {
                }
                field("Units Per Point";"Units Per Point")
                {
                }
                field(Points;Points)
                {
                }
                field("Customer Group";"Customer Group")
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
            }
        }
    }

    actions
    {
    }
}

