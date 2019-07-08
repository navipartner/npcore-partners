page 6060012 "GIM - Process Flow"
{
    Caption = 'GIM - Process Flow';
    PageType = List;
    SourceTable = "GIM - Process Flow";
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
                field("Doc. Type Field ID";"Doc. Type Field ID")
                {
                }
                field(Description;Description)
                {
                }
                field(Stage;Stage)
                {
                }
                field(Pause;Pause)
                {
                }
                field("Notify When";"Notify When")
                {
                }
            }
        }
    }

    actions
    {
    }
}

