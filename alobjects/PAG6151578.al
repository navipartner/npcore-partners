page 6151578 "Event Exch. Int. Templates"
{
    // NPR5.34/TJ  /20170728 CASE 277938 New object
    // NPR5.35/TJ  /20170822 CASE 281185 Added new fields "Reminder Enabled (Calendar)" and "Reminder (Minutes) (Calendar)"
    // NPR5.36/TJ  /20170912 CASE 287800 Added CardPageID property and removed all columns except Code and Description
    // NPR5.37/TJ  /20171013 CASE 287800 Added CardPageID property

    Caption = 'Event Exch. Int. Templates';
    CardPageID = "Event Exch. Int. Template Card";
    PageType = List;
    SourceTable = "Event Exch. Int. Template";
    UsageCategory = Lists;

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
            }
        }
    }

    actions
    {
    }
}

