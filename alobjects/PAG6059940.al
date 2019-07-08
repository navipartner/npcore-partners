page 6059940 "SMS Template List"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.40/THRO/20180308 CASE 304312 Added "Report ID"

    Caption = 'SMS Template List';
    CardPageID = "SMS Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "SMS Template Header";
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
                field("Table No.";"Table No.")
                {
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("""Table Filters"".HASVALUE";"Table Filters".HasValue)
                {
                    Caption = 'Filters on Table';
                }
                field("Report ID";"Report ID")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

