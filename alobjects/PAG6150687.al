page 6150687 "NPRE Kitchen Station Selection"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Station Selection Setup';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPRE Kitchen Station Selection";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code";"Restaurant Code")
                {
                }
                field("Seating Location";"Seating Location")
                {
                }
                field("Serving Step";"Serving Step")
                {
                }
                field("Print Category Code";"Print Category Code")
                {
                }
                field("Production Restaurant Code";"Production Restaurant Code")
                {
                }
                field("Kitchen Station";"Kitchen Station")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014409;Notes)
            {
                Visible = false;
            }
            systempart(Control6014410;Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

