page 6151095 "NPR RS Posted Nivelation List"
{
    Caption = 'Posted Nivelation Documents';
    PageType = List;
    ApplicationArea = NPRRSRLocal;
    UsageCategory = Lists;
    Extensible = false;
    Editable = false;
    SourceTable = "NPR RS Posted Nivelation Hdr";
    CardPageId = "NPR RS Posted Nivelation Doc";
    SourceTableView = sorting("No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Item Number.';
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
            }
        }
    }
}