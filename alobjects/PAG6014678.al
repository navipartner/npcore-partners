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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                }
                field("Request Batch No."; "Request Batch No.")
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
                field("Query No."; "Query No.")
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

