page 6150636 "NPR POS View Profile Card"
{
    Caption = 'POS View Profile Card';
    PageType = Card;
    SourceTable = "NPR POS View Profile";
    UsageCategory = None;

    layout
    {

        area(factboxes)
        {
            part(POSViewPic; "NPR POS View Picture")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                SubPageLink = "Code" = FIELD("Code");
            }
        }
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("POS Theme Code"; Rec."POS Theme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Theme Code field';
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                }
                field("POS - Show discount fields"; Rec."POS - Show discount fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Discount field';
                }
                field("Initial Sales View"; Rec."Initial Sales View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Sales View field';
                }
                field("After End-of-Sale View"; Rec."After End-of-Sale View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the After End-of-Sale View field';
                }
                field("Lock Timeout"; Rec."Lock Timeout")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Timeout field';
                }
                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tax type, POS view should be adjusted for by default';
                }
                field("Open Register Password"; Rec."Open Register Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open POS Unit Password field.';
                    ExtendedDatatype = Masked;
                }
            }
            group("Number and Date Formatting")
            {
                Caption = 'Name and Date Formatting';
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies decimal separator (e.g. 1234,10 or 1234.10)';
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies decimal separator (e.g. 1.234,10 or 1,234.10)';
                }
                field("Client Number Decimal Digits"; Rec."Client Number Decimal Digits")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies number of decimal places. Enter an integer value (e.g. 2 digits = 1.234,10; 5 digits = 1.234,43210)';
                    BlankZero = true;
                }
                field("Client Currency Symbol"; Rec."Client Currency Symbol")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies currency symbol (e.g. kr. or $)';
                }
                field("Client Short Date Pattern"; Rec."Client Short Date Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies short date pattern. Insert value in form dd-MM-yyyy or M/d/yyyy';
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies date separator. Value inserted here depends on the value set in the field "Client Short Date Pattern". Insert value - or / or . as a date separator.';
                }
                field("Client Day Names"; Rec."Client Day Names")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies name of days in the week. Separate each value with comma (e.g. søndag,mandag,tirsdag,onsdag,torsdag,fredag,lørdag or Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday)';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action(SetDefaultNumberAndFormats)
                {
                    Caption = 'Set Default Formats';
                    Image = SuggestNumber;
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'If any value under the group "Name and Date Formatting" is not defined, this action will set default values in empty fields.';

                    trigger OnAction()
                    begin
                        Rec.SetFormats(Rec.GetDefaultFormats());
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }
}
