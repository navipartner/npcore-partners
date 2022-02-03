page 6150636 "NPR POS View Profile Card"
{
    Extensible = False;
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
                Editable = true;
                SubPageLink = "Code" = FIELD("Code");
                ApplicationArea = NPRRetail;
            }
        }
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("POS Theme Code"; Rec."POS Theme Code")
                {
                    ToolTip = 'Specifies the value of the POS Theme Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {
                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                    ApplicationArea = NPRRetail;
                }
                field("POS - Show discount fields"; Rec."POS - Show discount fields")
                {
                    ToolTip = 'Specifies the value of the Show Discount field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Prices Including VAT"; Rec."Show Prices Including VAT")
                {
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on POS Sale document lines should be shown with or without VAT.';
                    ApplicationArea = NPRRetail;  //we couldn't set ApplicationArea to 'VAT' to control visibility of the field
                    Visible = not IsSalesTaxEnabled;
                }
                field("Show Prices Including Tax"; Rec."Show Prices Including VAT")
                {
                    Caption = 'Show Prices Including Tax';
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on POS Sale document lines should be shown with or without tax.';
                    ApplicationArea = NPRRetail;  //we couldn't set ApplicationArea to 'SalesTax' to control visibility of the field
                    Visible = IsSalesTaxEnabled;
                }
                field("Initial Sales View"; Rec."Initial Sales View")
                {
                    ToolTip = 'Specifies the value of the Initial Sales View field';
                    ApplicationArea = NPRRetail;
                }
                field("After End-of-Sale View"; Rec."After End-of-Sale View")
                {
                    ToolTip = 'Specifies the value of the After End-of-Sale View field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Number and Date Formatting")
            {
                Caption = 'Name and Date Formatting';
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {
                    ToolTip = 'Specifies decimal separator (e.g. 1234,10 or 1234.10)';
                    ApplicationArea = NPRRetail;
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {
                    ToolTip = 'Specifies decimal separator (e.g. 1.234,10 or 1,234.10)';
                    ApplicationArea = NPRRetail;
                }
                field("Client Number Decimal Digits"; Rec."Client Number Decimal Digits")
                {
                    ToolTip = 'Specifies number of decimal places. Enter an integer value (e.g. 2 digits = 1.234,10; 5 digits = 1.234,43210)';
                    BlankZero = true;
                    ApplicationArea = NPRRetail;
                }
                field("Client Currency Symbol"; Rec."Client Currency Symbol")
                {
                    ToolTip = 'Specifies currency symbol (e.g. kr. or $)';
                    ApplicationArea = NPRRetail;
                }
                field("Client Short Date Pattern"; Rec."Client Short Date Pattern")
                {
                    ToolTip = 'Specifies short date pattern. Insert value in form dd-MM-yyyy or M/d/yyyy';
                    ApplicationArea = NPRRetail;
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {
                    ToolTip = 'Specifies date separator. Value inserted here depends on the value set in the field "Client Short Date Pattern". Insert value - or / or . as a date separator.';
                    ApplicationArea = NPRRetail;
                }
                field("Client Day Names"; Rec."Client Day Names")
                {
                    ToolTip = 'Specifies name of days in the week. Separate each value with comma (e.g. søndag,mandag,tirsdag,onsdag,torsdag,fredag,lørdag or Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday)';
                    ApplicationArea = NPRRetail;
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
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'If any value under the group "Name and Date Formatting" is not defined, this action will set default values in empty fields.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.SetFormats(Rec.GetDefaultFormats());
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Show Prices Including VAT" := not IsSalesTaxEnabled;
    end;

    trigger OnOpenPage()
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        IsSalesTaxEnabled := ApplicationAreaMgmt.IsSalesTaxEnabled();
    end;

    var
        IsSalesTaxEnabled: Boolean;
}
