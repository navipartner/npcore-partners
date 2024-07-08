page 6151090 "NPR RS Nivelation Doc. List"
{
    PageType = List;
    ApplicationArea = NPRRSRLocal;
    UsageCategory = Lists;
    Extensible = false;
    SourceTable = "NPR RS Nivelation Header";
    CardPageId = "NPR RS Nivelation Header";
    SourceTableView = sorting("No.") order(descending);
    Caption = 'Nivelation Documents';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Nivelation Document Number.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Nivelation Type.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Nivelation Source Type.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Posting Date.';
                }
                field("Referring Document Code"; Rec."Referring Document Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Referring Document Code.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the total value to be adjusted.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
        }
    }
}