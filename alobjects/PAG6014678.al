page 6014678 "Endpoint Request List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Query fields

    Caption = 'Endpoint Request List';
    Editable = false;
    PageType = List;
    SourceTable = "Endpoint Request";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field("Endpoint Code";"Endpoint Code")
                {
                }
                field("Request Batch No.";"Request Batch No.")
                {
                }
                field("Type of Change";"Type of Change")
                {
                }
                field("Record ID";"Record ID")
                {
                }
                field(Obsolete;Obsolete)
                {
                }
                field("Data log Record No.";"Data log Record No.")
                {
                }
                field("Query No.";"Query No.")
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("PK Code 1";"PK Code 1")
                {
                }
                field("PK Code 2";"PK Code 2")
                {
                }
                field("PK Line 1";"PK Line 1")
                {
                }
                field("PK Option 1";"PK Option 1")
                {
                }
                field("Date Created";"Date Created")
                {
                }
            }
        }
    }

    actions
    {
    }
}

