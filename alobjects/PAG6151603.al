page 6151603 "NpDc Valid Time Intervals"
{
    // NPR5.35/MHA /20170809  CASE 286355 Object created
    // NPR5.37/MHA /20171010  CASE 292171 Added Period Type and Weekday fields

    AutoSplitKey = true;
    Caption = 'Valid Time Intervals';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpDc Valid Time Interval";

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

