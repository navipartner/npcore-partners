page 6151217 "NpCs Open. Hour Set Subpage"
{
    // #362443/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    AutoSplitKey = true;
    Caption = 'Opening Hours';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpCs Open. Hour Entry";

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
                        field("Entry Type";"Entry Type")
                        {
                        }
                        field("Start Time";"Start Time")
                        {
                            Enabled = "Entry Type" = 0;
                        }
                        field("End Time";"End Time")
                        {
                            Enabled = "Entry Type" = 0;
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
                    Caption = 'Period        ';
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
                    group(Control6014420)
                    {
                        ShowCaption = false;
                        Visible = ("Period Type" = 2) OR ("Period Type" = 3);
                        field("Entry Date";"Entry Date")
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

