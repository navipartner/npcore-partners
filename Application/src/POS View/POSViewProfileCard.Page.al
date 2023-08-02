page 6150636 "NPR POS View Profile Card"
{
    Extensible = False;
    Caption = 'POS View Profile Card';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/reference/view_profile/view_profile_ref/';
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
                    ToolTip = 'Specifies the unique code of the POS unit profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the short description of the profile.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Theme Code"; Rec."POS Theme Code")
                {
                    ToolTip = 'Specifies the POS theme used in the POS unit. If there is some which will be used instead of default theme.';
                    ApplicationArea = NPRRetail;
                }
                field("POS - Show discount fields"; Rec."POS - Show discount fields")
                {
                    ToolTip = 'Specifies if discount should be shown in POS sale lines.';
                    ApplicationArea = NPRRetail;
                }
                field("Show Prices Including VAT"; Rec."Show Prices Including VAT")
                {
                    ToolTip = 'Specifies if Unit price and Line amount on POS sale lines should be shown with VAT.';
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
                    ToolTip = 'Specifies which view will be shown as initial. Options: Sale view and Restaurant view.';
                    ApplicationArea = NPRRetail;
                }
                field("After End-of-Sale View"; Rec."After End-of-Sale View")
                {
                    ToolTip = 'Specifies which view will be shown after sale is done. Options: Initial Sales view and Login view.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Number and Date Formatting")
            {
                Caption = 'Name and Date Formatting';
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {
                    ToolTip = 'Specifies how numbers in POS will be separated from decimals (whether a comma or period will be used, e.g. 1234,10 or 1234.10).';
                    ApplicationArea = NPRRetail;
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {
                    ToolTip = 'Specifies how thousands will be separated (whether a comma or period will be used - e.g. 1.234,10 or 1,234.10).';
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
