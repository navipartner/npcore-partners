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
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field(Index; Rec.Index)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Index field';
                }
                field(From; Rec.From)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From field';
                }
                field("To"; Rec."To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To field';
                }
                field("Read Permission"; Rec."Read Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Read Permission field';
                }
                field("Insert Permission"; Rec."Insert Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert Permission field';
                }
                field("Modify Permission"; Rec."Modify Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Permission field';
                }
                field("Delete Permission"; Rec."Delete Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Permission field';
                }
                field("Execute Permission"; Rec."Execute Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Execute Permission field';
                }
                field("Limited Usage Permission"; Rec."Limited Usage Permission")
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

