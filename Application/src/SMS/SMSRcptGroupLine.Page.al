page 6014430 "NPR SMS Rcpt. Group Line"
{

    Caption = 'SMS Recipient Group Line';
    PageType = ListPart;
    SourceTable = "NPR SMS Rcpt. Group Line";
    AutoSplitKey = true;
    MultipleNewLines = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mobile Phone No. field';
                }
            }
        }
    }

}
