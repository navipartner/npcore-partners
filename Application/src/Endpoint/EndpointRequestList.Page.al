page 6014678 "NPR Endpoint Request List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Query fields

    Caption = 'Endpoint Request List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Endpoint Request";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Code field';
                }
                field("Request Batch No."; "Request Batch No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Batch No. field';
                }
                field("Type of Change"; "Type of Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type of Change field';
                }
                field("Record ID"; "Record ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record ID field';
                }
                field(Obsolete; Obsolete)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Obsolete field';
                }
                field("Data log Record No."; "Data log Record No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data log Record No. field';
                }
                field("Query No."; "Query No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query No. field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("PK Code 1"; "PK Code 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Code 1 field';
                }
                field("PK Code 2"; "PK Code 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Code 2 field';
                }
                field("PK Line 1"; "PK Line 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Line 1 field';
                }
                field("PK Option 1"; "PK Option 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Option 1 field';
                }
                field("Date Created"; "Date Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Created field';
                }
            }
        }
    }

    actions
    {
    }
}

