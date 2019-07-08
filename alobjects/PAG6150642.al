page 6150642 "POS Info List"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info List';
    CardPageID = "POS Info Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Info";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Message;Message)
                {
                }
                field(Type;Type)
                {
                }
                field("Input Type";"Input Type")
                {
                }
                field("Input Mandatory";"Input Mandatory")
                {
                }
            }
        }
    }

    actions
    {
    }
}

