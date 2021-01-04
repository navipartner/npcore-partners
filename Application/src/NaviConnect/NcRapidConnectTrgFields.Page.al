page 6151094 "NPR Nc RapidConnect Trg.Fields"
{
    // NC2.14/MHA /20180716  CASE 322308 Object created - Partial Trigger functionality

    Caption = 'RapidConnect Trigger Fields';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Nc RapidConnect Trig.Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
            }
        }
    }

    actions
    {
    }
}

