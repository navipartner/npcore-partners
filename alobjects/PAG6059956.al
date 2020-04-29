page 6059956 "MCS Person Group Setup"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person Group Setup';
    PageType = List;
    SourceTable = "MCS Person Groups Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Id";"Table Id")
                {
                }
                field("Person Groups Id";"Person Groups Id")
                {
                }
                field("Person Groups Name";"Person Groups Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

