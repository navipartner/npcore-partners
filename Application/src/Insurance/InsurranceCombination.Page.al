page 6014540 "NPR Insurrance Combination"
{
    Caption = 'Insurance - Combination';
    PageType = List;
    UsageCategory = Administration;
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
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Amount From"; "Amount From")
                {
                    ApplicationArea = All;
                }
                field("To Amount"; "To Amount")
                {
                    ApplicationArea = All;
                }
                field("Insurance Amount"; "Insurance Amount")
                {
                    ApplicationArea = All;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                }
                field("Amount as Percentage"; "Amount as Percentage")
                {
                    ApplicationArea = All;
                }
                field("Ticket tekst"; "Ticket tekst")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

