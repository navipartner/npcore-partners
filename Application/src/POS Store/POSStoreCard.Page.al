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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Name 2"; Rec."Name 2")
                {

                    ToolTip = 'Specifies the value of the Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Address 2"; Rec."Address 2")
                {

                    ToolTip = 'Specifies the value of the Address 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field(Contact; Rec.Contact)
                {

                    ToolTip = 'Specifies the value of the Contact field';
                    ApplicationArea = NPRRetail;
                }
                field(County; Rec.County)
                {

                    ToolTip = 'Specifies the value of the County field';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {

                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {

                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Registration No."; Rec."Registration No.")
                {

                    ToolTip = 'Specifies the value of the Registration No. field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Home Page"; Rec."Home Page")
                {

                    ToolTip = 'Specifies the value of the Home Page field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Profiles)
            {
                Caption = 'Profiles';
                field("POS Restaurant Profile"; Rec."POS Restaurant Profile")
                {

                    ToolTip = 'Specifies the value of the POS Restaurant Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Posting Profile"; Rec."POS Posting Profile")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Posting Profile field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Group Code"; Rec."Store Group Code")
                {

                    ToolTip = 'Specifies the value of the Store Group Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Category Code"; Rec."Store Category Code")
                {

                    ToolTip = 'Specifies the value of the Store Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Locality Code"; Rec."Store Locality Code")
                {

                    ToolTip = 'Specifies the value of the Store Locality Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Size"; Rec."Store Size")
                {

                    ToolTip = 'Specifies the value of the Store Size field';
                    ApplicationArea = NPRRetail;
                }
                field("Opening Date"; Rec."Opening Date")
                {

                    ToolTip = 'Specifies the value of the Opening Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Latitude"; Rec."Geolocation Latitude")
                {

                    ToolTip = 'Specifies the value of the Geolocation Latitude field';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Longitude"; Rec."Geolocation Longitude")
                {

                    ToolTip = 'Specifies the value of the Geolocation Longitude field';
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

