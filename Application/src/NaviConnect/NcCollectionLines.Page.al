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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Collector Code"; "Collector Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collector Code field';
                }
                field("Collection No."; "Collection No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collection No. field';
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
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("PK Code 1"; "PK Code 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Code 1 field';
                }
                field("PK Code 2"; "PK Code 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Code 2 field';
                }
                field("PK Line 1"; "PK Line 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Line 1 field';
                }
                field("PK Option 1"; "PK Option 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Option 1 field';
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

