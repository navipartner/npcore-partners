page 6151203 "NPR NpCs Document Mapping"
{
    Caption = 'Collect Document Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpCs Document Mapping";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("From Store Code"; Rec."From Store Code")
                {

                    ToolTip = 'Specifies the value of the From Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("From No."; Rec."From No.")
                {

                    ToolTip = 'Specifies the value of the From No. field';
                    ApplicationArea = NPRRetail;
                }
                field("From Description"; Rec."From Description")
                {

                    ToolTip = 'Specifies the value of the From Description field';
                    ApplicationArea = NPRRetail;
                }
                field("From Description 2"; Rec."From Description 2")
                {

                    ToolTip = 'Specifies the value of the From Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("To No."; Rec."To No.")
                {

                    ToolTip = 'Specifies the value of the To No. field';
                    ApplicationArea = NPRRetail;
                }
                field("To Description"; Rec."To Description")
                {

                    ToolTip = 'Specifies the value of the To Description field';
                    ApplicationArea = NPRRetail;
                }
                field("To Description 2"; Rec."To Description 2")
                {

                    ToolTip = 'Specifies the value of the To Description 2 field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

