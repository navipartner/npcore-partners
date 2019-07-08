page 6060017 "GIM - Import Buffer Subpage"
{
    Caption = 'GIM - Import Buffer Subpage';
    PageType = ListPart;
    SourceTable = "GIM - Import Buffer Detail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID";"Table ID")
                {
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("Field ID";"Field ID")
                {
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Field Type";"Field Type")
                {
                }
                field("Field Additional Info";"Field Additional Info")
                {
                }
                field("Failed Data Type Validation";"Failed Data Type Validation")
                {
                }
                field("Failed Data Mapping";"Failed Data Mapping")
                {
                }
                field("Failed Data Verification";"Failed Data Verification")
                {
                }
                field("Failed Data Creation";"Failed Data Creation")
                {
                }
                field("Fail Reason";"Fail Reason")
                {
                }
            }
        }
    }

    actions
    {
    }
}

