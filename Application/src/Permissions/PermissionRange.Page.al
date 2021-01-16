page 6059938 "NPR Permission Range"
{
    // NPR4.15/JDH/20151019  CASE 223339 License Permission viewer

    Caption = 'Permission Range';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the License No. field';
                }
            }
            repeater(Group)
            {
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field(Index; Index)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Index field';
                }
                field(From; From)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From field';
                }
                field("To"; "To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To field';
                }
                field("Read Permission"; "Read Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Read Permission field';
                }
                field("Insert Permission"; "Insert Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert Permission field';
                }
                field("Modify Permission"; "Modify Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Permission field';
                }
                field("Delete Permission"; "Delete Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Permission field';
                }
                field("Execute Permission"; "Execute Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Execute Permission field';
                }
                field("Limited Usage Permission"; "Limited Usage Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Limited Usage Permission field';
                }
            }
        }
    }

    actions
    {
    }
}

