page 6151461 "Magento Customer Mapping"
{
    // MAG2.22/MHA /20190710  CASE 360098 Object created

    Caption = 'Magento Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Magento Customer Mapping";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = City;
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field("Country/Region Name";"Country/Region Name")
                {
                }
                field(City;City)
                {
                }
                field("Customer Template Code";"Customer Template Code")
                {
                }
                field("Config. Template Code";"Config. Template Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

