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
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Source Type field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Referring Document Code"; Rec."Referring Document Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Referring Document Code field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
            }
        }
    }
}