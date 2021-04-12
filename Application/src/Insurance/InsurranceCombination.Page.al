page 6014540 "NPR Insurrance Combination"
{
    Caption = 'Insurance - Combination';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Insurance Combination";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Company; Rec.Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Amount From"; Rec."Amount From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount From field';
                }
                field("To Amount"; Rec."To Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Amount field';
                }
                field("Insurance Amount"; Rec."Insurance Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insurance Amount field';
                }
                field("Profit %"; Rec."Profit %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Profit % field';
                }
                field("Amount as Percentage"; Rec."Amount as Percentage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount as percentage of value field';
                }
                field("Ticket tekst"; Rec."Ticket tekst")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket tekst field';
                }
            }
        }
    }

    actions
    {
    }
}

