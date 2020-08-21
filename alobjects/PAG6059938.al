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
                field(SERIALNUMBER; SerialNumber)
                {
                    ApplicationArea = All;
                    Caption = 'License No.';
                }
            }
            repeater(Group)
            {
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                }
                field(Index; Index)
                {
                    ApplicationArea = All;
                }
                field(From; From)
                {
                    ApplicationArea = All;
                }
                field("To"; "To")
                {
                    ApplicationArea = All;
                }
                field("Read Permission"; "Read Permission")
                {
                    ApplicationArea = All;
                }
                field("Insert Permission"; "Insert Permission")
                {
                    ApplicationArea = All;
                }
                field("Modify Permission"; "Modify Permission")
                {
                    ApplicationArea = All;
                }
                field("Delete Permission"; "Delete Permission")
                {
                    ApplicationArea = All;
                }
                field("Execute Permission"; "Execute Permission")
                {
                    ApplicationArea = All;
                }
                field("Limited Usage Permission"; "Limited Usage Permission")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

