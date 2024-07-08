page 6059902 "NPR Periodes"
{
    Extensible = False;
    Caption = 'Periodes';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Periodes";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Period Code"; Rec."Period Code")
                {

                    ToolTip = 'Specifies the value of the Period Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date"; Rec."Start Date")
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date"; Rec."End Date")
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }

                field("Start Date Last Year"; Rec."Start Date Last Year")
                {

                    ToolTip = 'Specifies the value of the Start Date Last Year field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date Last Year"; Rec."End Date Last Year")
                {

                    ToolTip = 'Specifies the value of the End Date Last Year field';
                    ApplicationArea = NPRRetail;
                }
            }

        }
    }


}

