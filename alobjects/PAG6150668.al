page 6150668 "NPRE Print Categories"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'Print Categories';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPRE Print Category";

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
                field("Print Tag";"Print Tag")
                {
                }
            }
        }
    }

    actions
    {
    }
}

