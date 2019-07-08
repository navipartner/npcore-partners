page 6059821 "Smart Email List"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

    Caption = 'Smart Email List';
    CardPageID = "Smart Email Card";
    Editable = false;
    PageType = List;
    SourceTable = "Smart Email";
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
                field("Merge Table ID";"Merge Table ID")
                {
                    Editable = false;
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("Smart Email Name";"Smart Email Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

