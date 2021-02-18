page 6014418 "NPR Staff Setup"
{

    Caption = 'Staff Setup';
    PageType = Card;
    SourceTable = "NPR Staff Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Internal Unit Price"; Rec."Internal Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internal Unit Price field';
                }
                field("Staff Disc. Group"; Rec."Staff Disc. Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff Disc. Group field';
                }
                field("Staff Price Group"; Rec."Staff Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff Price Group field';
                }
                field("Staff SalesPrice Calc Codeunit"; Rec."Staff SalesPrice Calc Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff SalesPrice Calc Codeunit field';
                }
            }
        }
    }

}
