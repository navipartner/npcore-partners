page 6151532 "Nc Collection Lines"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collection Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Nc Collection Line";
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
                field("Collector Code";"Collector Code")
                {
                }
                field("Collection No.";"Collection No.")
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

