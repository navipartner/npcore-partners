page 6150692 "NPRE Kitchen Request Stations"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Kitchen Request Station";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No.";"Request No.")
                {
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                    Visible = false;
                }
                field("Production Restaurant Code";"Production Restaurant Code")
                {
                }
                field("Kitchen Station";"Kitchen Station")
                {
                }
                field("Production Status";"Production Status")
                {
                }
                field("Start Date-Time";"Start Date-Time")
                {
                }
                field("End Date-Time";"End Date-Time")
                {
                }
            }
        }
    }

    actions
    {
    }
}

