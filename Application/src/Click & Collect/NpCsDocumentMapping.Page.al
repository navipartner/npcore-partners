page 6151203 "NPR NpCs Document Mapping"
{
    Caption = 'Collect Document Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpCs Document Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("From Store Code"; Rec."From Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Store Code field';
                }
                field("From No."; Rec."From No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From No. field';
                }
                field("From Description"; Rec."From Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Description field';
                }
                field("From Description 2"; Rec."From Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Description 2 field';
                }
                field("To No."; Rec."To No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To No. field';
                }
                field("To Description"; Rec."To Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Description field';
                }
                field("To Description 2"; Rec."To Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Description 2 field';
                }
            }
        }
    }
}

