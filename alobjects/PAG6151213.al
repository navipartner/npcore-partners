page 6151213 "NpCs Store Opening Hours Setup"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    AutoSplitKey = true;
    Caption = 'Store Opening Hours Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpCs Store Opening Hours Setup";
    UsageCategory = Administration;

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
        area(navigation)
        {
            action("Opening Hours")
            {
                Caption = 'Opening Hours';
                Image = List;
                ShortCutKey = 'Ctrl+F7';

                trigger OnAction()
                var
                    NpCsStoreOpeningHourMgt: Codeunit "NpCs Store Opening Hours Mgt.";
                begin
                    NpCsStoreOpeningHourMgt.ShowOpeningHours();
                end;
            }
        }
    }
}

