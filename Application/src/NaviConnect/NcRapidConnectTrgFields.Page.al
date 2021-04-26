page 6151094 "NPR Nc RapidConnect Trg.Fields"
{
    Caption = 'RapidConnect Trigger Fields';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc RapidConnect Trig.Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
            }
        }
    }
}

