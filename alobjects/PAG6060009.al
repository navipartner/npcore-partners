page 6060009 "GIM - Supported Data Formats"
{
    Caption = 'GIM - Supported Data Formats';
    PageType = List;
    SourceTable = "GIM - Supported Data Format";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Extension;Extension)
                {
                }
                field(Description;Description)
                {
                }
                field("Value Lookup Editable";"Value Lookup Editable")
                {
                }
            }
        }
    }

    actions
    {
    }
}

