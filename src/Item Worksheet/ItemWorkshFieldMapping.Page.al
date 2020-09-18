page 6060057 "NPR Item Worksh. Field Mapping"
{
    // NPR5.25\BR  \20160729  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Worksheet Field Mapping';
    PageType = List;
    UsageCategory = Administration;
    PopulateAllFields = true;
    SourceTable = "NPR Item Worksh. Field Mapping";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Matching; Matching)
                {
                    ApplicationArea = All;
                }
                field("Case Sensitive"; "Case Sensitive")
                {
                    ApplicationArea = All;
                }
                field("Source Value"; "Source Value")
                {
                    ApplicationArea = All;
                }
                field("Target Value"; "Target Value")
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

