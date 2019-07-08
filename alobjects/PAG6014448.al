page 6014448 "Mixed Discount Time Intervals"
{
    // NPR5.45/MHA /20180820  CASE 323568 Object created

    AutoSplitKey = true;
    Caption = 'Active Time Intervals';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Mixed Discount Time Interval";

    layout
    {
        area(content)
        {
            grid(Control6014404)
            {
                ShowCaption = false;
                group(Control6014416)
                {
                    ShowCaption = false;
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
                        field("Period Description";"Period Description")
                        {
                            Editable = false;
                        }
                    }
                }
                group(Period)
                {
                    Caption = 'Period';
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = ("Period Type" = 1);
                        field(Monday;Monday)
                        {
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
        }
    }

    actions
    {
    }
}

