page 6014431 "NPR SMS Recipient Group"
{

    Caption = 'SMS Recipient Group';
    PageType = Card;
    SourceTable = "NPR SMS Recipient Group";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            part("NPR SMS Rcpt. Group Line"; "NPR SMS Rcpt. Group Line")
            {
                Caption = 'Numbers';
                SubPageLink = "Group Code" = FIELD("Code");
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;

            }
        }
    }

}
