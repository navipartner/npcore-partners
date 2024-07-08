page 6014430 "NPR SMS Rcpt. Group Line"
{
    Extensible = False;

    Caption = 'SMS Recipient Group Line';
    PageType = ListPart;
    SourceTable = "NPR SMS Rcpt. Group Line";
    AutoSplitKey = true;
    MultipleNewLines = true;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {

                    ToolTip = 'Specifies the value of the Mobile Phone No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
