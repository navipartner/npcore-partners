page 6060057 "NPR Item Worksh. Field Mapping"
{
    Extensible = False;
    Caption = 'Item Worksheet Field Mapping';
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR Item Worksh. Field Mapping";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Matching; Rec.Matching)
                {

                    ToolTip = 'Specifies the value of the Matching field.';
                    ApplicationArea = NPRRetail;
                }
                field("Case Sensitive"; Rec."Case Sensitive")
                {

                    ToolTip = 'Specifies the value of the Case Sensitive field.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Value"; Rec."Source Value")
                {

                    ToolTip = 'Specifies the value of the Source Value field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Value"; Rec."Target Value")
                {

                    ToolTip = 'Specifies the value of the Target Value field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

