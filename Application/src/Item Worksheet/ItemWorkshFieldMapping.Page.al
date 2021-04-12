page 6060057 "NPR Item Worksh. Field Mapping"
{
    Caption = 'Item Worksheet Field Mapping';
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR Item Worksh. Field Mapping";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Matching; Rec.Matching)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Matching field.';
                }
                field("Case Sensitive"; Rec."Case Sensitive")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Case Sensitive field.';
                }
                field("Source Value"; Rec."Source Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Value field.';
                }
                field("Target Value"; Rec."Target Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Value field.';
                }
            }
        }
    }

}

