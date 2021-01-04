page 6151578 "NPR Event Exch. Int. Templates"
{
    // NPR5.34/TJ  /20170728 CASE 277938 New object
    // NPR5.35/TJ  /20170822 CASE 281185 Added new fields "Reminder Enabled (Calendar)" and "Reminder (Minutes) (Calendar)"
    // NPR5.36/TJ  /20170912 CASE 287800 Added CardPageID property and removed all columns except Code and Description
    // NPR5.37/TJ  /20171013 CASE 287800 Added CardPageID property

    Caption = 'Event Exch. Int. Templates';
    CardPageID = "NPR Event Exch.Int.Templ. Card";
    PageType = List;
    SourceTable = "NPR Event Exch. Int. Template";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

