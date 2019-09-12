page 6014448 "Mixed Discount Time Intervals"
{
    // NPR5.45/MHA /20180820  CASE 323568 Object created
    // NPR5.51/MAOT/20190614 CASE 352650 Fixed scaling error by changing grid layout to standard list

    AutoSplitKey = true;
    Caption = 'Active Time Intervals';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Mixed Discount Time Interval";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Time";"Start Time")
                {
                }
                field("End Time";"End Time")
                {
                }
                field("Period Type";"Period Type")
                {
                }
                field(Monday;Monday)
                {
                    Editable = "Period Type"=1;
                }
                field(Tuesday;Tuesday)
                {
                }
                field(Wednesday;Wednesday)
                {
                }
                field(Thursday;Thursday)
                {
                }
                field(Friday;Friday)
                {
                }
                field(Saturday;Saturday)
                {
                }
                field(Sunday;Sunday)
                {
                }
            }
        }
    }

    actions
    {
    }
}

