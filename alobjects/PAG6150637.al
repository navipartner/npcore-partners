page 6150637 "POS End of Day Profiles"
{
    // NPR5.49/TSA /20190314 CASE 348458 Initial Version

    Caption = 'POS End of Day Profile';
    PageType = List;
    SourceTable = "POS End of Day Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("End of Day Type";"End of Day Type")
                {
                }
                field("Master POS Unit No.";"Master POS Unit No.")
                {
                }
                field("Z-Report UI";"Z-Report UI")
                {
                }
                field("X-Report UI";"X-Report UI")
                {
                }
                field("Close Workshift UI";"Close Workshift UI")
                {
                }
                field("Force Blind Counting";"Force Blind Counting")
                {
                }
            }
        }
    }

    actions
    {
    }
}

