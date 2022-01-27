page 6014540 "NPR Insurrance Combination"
{
    Extensible = False;
    Caption = 'Insurance - Combination';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Insurance Combination";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Company; Rec.Company)
                {

                    ToolTip = 'Specifies the value of the Company field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount From"; Rec."Amount From")
                {

                    ToolTip = 'Specifies the value of the Amount From field';
                    ApplicationArea = NPRRetail;
                }
                field("To Amount"; Rec."To Amount")
                {

                    ToolTip = 'Specifies the value of the To Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Insurance Amount"; Rec."Insurance Amount")
                {

                    ToolTip = 'Specifies the value of the Insurance Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {

                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount as Percentage"; Rec."Amount as Percentage")
                {

                    ToolTip = 'Specifies the value of the Amount as percentage of value field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket tekst"; Rec."Ticket tekst")
                {

                    ToolTip = 'Specifies the value of the Ticket tekst field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

