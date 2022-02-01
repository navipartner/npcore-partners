page 6150615 "NPR POS Store Card"
{
    Extensible = False;

    UsageCategory = None;
    Caption = 'POS Store Card';
    RefreshOnActivate = true;
    SourceTable = "NPR POS Store";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the store ID, which can contain both letters and numbers. ';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the POS store name which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {

                    ToolTip = 'Specifies a longer legal name of the store, if necessary. This name is not displayed on sales documents by default.';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ToolTip = 'Specifies the POS store address which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Address 2"; Rec."Address 2")
                {

                    ToolTip = 'Specifies the optional second address.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the POS store''s postal code which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the city in which the POS store is located.';
                    ApplicationArea = NPRRetail;
                }
                field(Contact; Rec.Contact)
                {

                    ToolTip = 'Specifies the name of the person that should be contacted regarding information about the store. This is also displayed on sales documents, receipts etc. ';
                    ApplicationArea = NPRRetail;
                }
                field(County; Rec.County)
                {

                    ToolTip = 'Specifies the country in which the POS store is located.';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the POS store''s country/region code which will be displayed on sales documents, receipts etc. If you are reporting for Intrastat, please ensure this is correct.';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the POS store''s location code, which is used for registering the store''s inventory. This field needs to be populated if your company has more than one store, if not, the location code is optional.';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {

                    ToolTip = 'Specifies the system language, which could be for example DK (Danish) or ENG (English) among others.';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {

                    ToolTip = 'Specifies a unique number used for identifying a registered store owner.';
                    ApplicationArea = NPRRetail;
                }
                field("Registration No."; Rec."Registration No.")
                {

                    ToolTip = 'Specifies the registration number. Will display on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the POS store''s phone number, which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the POS store''s email, which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Home Page"; Rec."Home Page")
                {

                    ToolTip = 'Specifies the store''s home page URL.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Profiles)
            {
                Caption = 'Profiles';
                field("POS Restaurant Profile"; Rec."POS Restaurant Profile")
                {

                    ToolTip = 'Specifies which restaurant the store is connected to.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Posting Profile"; Rec."POS Posting Profile")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies which General and VAT Posting group this store is using as well as journal definitions etc.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the department code - the dimension used for reporting. By setting up this dimension, it''s possible to filter reports in relation to the dimension and get more specific data that way.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the project code - the dimension used for reporting. By setting up this dimension, it''s possible to filter your reports in relation to the dimension and get more specific data that way.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Group Code"; Rec."Store Group Code")
                {

                    ToolTip = 'Specifies the code of store groups. This is a useful field for reporting.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Category Code"; Rec."Store Category Code")
                {

                    ToolTip = 'Specifies the code of store categories. This is a useful field for reporting.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Locality Code"; Rec."Store Locality Code")
                {

                    ToolTip = 'Specifies the locality code of stores. This is a useful field for reporting.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Size"; Rec."Store Size")
                {

                    ToolTip = 'Specifies the size of the POS store in square meters. ';
                    ApplicationArea = NPRRetail;
                }
                field("Opening Date"; Rec."Opening Date")
                {

                    ToolTip = 'Specifies the first business day. This field is used for reports.';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Latitude"; Rec."Geolocation Latitude")
                {

                    ToolTip = 'Specifies the store''s location on Google Maps or Bing. This could help the customer get driving instructions or to figure out if the store is close enough for picking up a collect order.';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Longitude"; Rec."Geolocation Longitude")
                {

                    ToolTip = 'Specifies the store''s location on Google Maps or Bing. This could help the customer get driving instructions or to figure out if the store is close enough for picking up a collect order.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6150614),
                              "No." = FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;
            }
            action("POS Unit List")
            {
                Caption = 'POS Unit List';
                Image = List;
                RunObject = Page "NPR POS Unit List";

                ToolTip = 'Executes the POS Unit List action';
                ApplicationArea = NPRRetail;
            }
            action("POS Posting Setup")
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Posting Setup";
                RunPageLink = "POS Store Code" = FIELD(Code);

                ToolTip = 'Executes the POS Posting Setup action';
                ApplicationArea = NPRRetail;
            }
            action("POS Period Registers")
            {
                Caption = 'POS Period Registers';
                Image = Register;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Period Register List";
                RunPageLink = "POS Store Code" = FIELD(Code);

                ToolTip = 'Executes the POS Period Registers action';
                ApplicationArea = NPRRetail;
            }
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Entry List";
                RunPageLink = "POS Store Code" = FIELD(Code);

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

