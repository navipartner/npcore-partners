page 6059938 "Permission Range"
{
    // NPR4.15/JDH/20151019  CASE 223339 License Permission viewer

    Caption = 'Permission Range';
    PageType = List;
    SourceTable = "Permission Range";

    layout
    {
        area(content)
        {
            group(Control6150626)
            {
                ShowCaption = false;
                field(SERIALNUMBER;SerialNumber)
                {
                    Caption = 'License No.';
                }
            }
            repeater(Group)
            {
                field("Object Type";"Object Type")
                {
                }
                field(Index;Index)
                {
                }
                field(From;From)
                {
                }
                field("To";"To")
                {
                }
                field("Read Permission";"Read Permission")
                {
                }
                field("Insert Permission";"Insert Permission")
                {
                }
                field("Modify Permission";"Modify Permission")
                {
                }
                field("Delete Permission";"Delete Permission")
                {
                }
                field("Execute Permission";"Execute Permission")
                {
                }
                field("Limited Usage Permission";"Limited Usage Permission")
                {
                }
            }
        }
    }

    actions
    {
    }
}

