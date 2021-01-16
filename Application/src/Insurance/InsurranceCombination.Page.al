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
                field(Company; Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Amount From"; "Amount From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount From field';
                }
                field("To Amount"; "To Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Amount field';
                }
                field("Insurance Amount"; "Insurance Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insurance Amount field';
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Profit % field';
                }
                field("Amount as Percentage"; "Amount as Percentage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount as percentage of value field';
                }
                field("Ticket tekst"; "Ticket tekst")
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

