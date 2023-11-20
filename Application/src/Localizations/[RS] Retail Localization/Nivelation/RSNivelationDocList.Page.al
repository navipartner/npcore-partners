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
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Amount field.';
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