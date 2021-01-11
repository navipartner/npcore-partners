page 6059940 "NPR SMS Template List"
{
    Caption = 'SMS Template List';
    CardPageID = "NPR SMS Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR SMS Template Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Caption field';
                }
                field("""Table Filters"".HASVALUE"; "Table Filters".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Filters on Table';
                    ToolTip = 'Specifies the value of the Filters on Table field';
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Report ID field';
                }
            }
        }
    }

    actions
    {
    }
}

