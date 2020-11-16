page 6151532 "NPR Nc Collection Lines"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collection Lines';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collection Line";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Collector Code"; "Collector Code")
                {
                    ApplicationArea = All;
                }
                field("Collection No."; "Collection No.")
                {
                    ApplicationArea = All;
                }
                field("Type of Change"; "Type of Change")
                {
                    ApplicationArea = All;
                }
                field("Record ID"; "Record ID")
                {
                    ApplicationArea = All;
                }
                field(Obsolete; Obsolete)
                {
                    ApplicationArea = All;
                }
                field("Data log Record No."; "Data log Record No.")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("PK Code 1"; "PK Code 1")
                {
                    ApplicationArea = All;
                }
                field("PK Code 2"; "PK Code 2")
                {
                    ApplicationArea = All;
                }
                field("PK Line 1"; "PK Line 1")
                {
                    ApplicationArea = All;
                }
                field("PK Option 1"; "PK Option 1")
                {
                    ApplicationArea = All;
                }
                field("Date Created"; "Date Created")
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

