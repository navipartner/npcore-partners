page 6060007 "GIM - Supported Data Types"
{
    Caption = 'GIM - Supported Data Types';
    PageType = List;
    SourceTable = "GIM - Supported Data Type";
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
        area(processing)
        {
            action(Properties)
            {
                Caption = 'Properties';
                Image = Properties;
                RunObject = Page "GIM - Data Type Properties";
                RunPageLink = "Data Type"=FIELD(Code);
            }
        }
    }
}

