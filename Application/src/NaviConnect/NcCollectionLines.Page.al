page 6151532 "NPR Nc Collection Lines"
{
    Caption = 'Nc Collection Lines';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collection Line";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Collector Code"; Rec."Collector Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collector Code field';
                }
                field("Collection No."; Rec."Collection No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collection No. field';
                }
                field("Type of Change"; Rec."Type of Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type of Change field';
                }
                field("Record ID"; Rec."Record ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record ID field';
                }
                field(Obsolete; Rec.Obsolete)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Obsolete field';
                }
                field("Data log Record No."; Rec."Data log Record No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data log Record No. field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("PK Code 1"; Rec."PK Code 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Code 1 field';
                }
                field("PK Code 2"; Rec."PK Code 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Code 2 field';
                }
                field("PK Line 1"; Rec."PK Line 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Line 1 field';
                }
                field("PK Option 1"; Rec."PK Option 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PK Option 1 field';
                }
                field("Date Created"; Rec."Date Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Created field';
                }
            }
        }
    }
}

