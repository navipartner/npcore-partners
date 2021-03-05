page 6150615 "NPR POS Store Card"
{

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name 2 field';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(Contact; Rec.Contact)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact field';
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the County field';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registration No. field';
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("Home Page"; Rec."Home Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Home Page field';
                }
            }
            group(Profiles)
            {
                Caption = 'Profiles';
                field("POS Restaurant Profile"; Rec."POS Restaurant Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Restaurant Profile field';
                }
                field("POS Posting Profile"; Rec."POS Posting Profile")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Posting Profile field';
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Store Group Code"; Rec."Store Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Group Code field';
                }
                field("Store Category Code"; Rec."Store Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Category Code field';
                }
                field("Store Locality Code"; Rec."Store Locality Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Locality Code field';
                }
                field("Store Size"; Rec."Store Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Size field';
                }
                field("Opening Date"; Rec."Opening Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Date field';
                }
                field("Geolocation Latitude"; Rec."Geolocation Latitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Geolocation Latitude field';
                }
                field("Geolocation Longitude"; Rec."Geolocation Longitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Geolocation Longitude field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';
            }
            action("POS Unit List")
            {
                Caption = 'POS Unit List';
                Image = List;
                RunObject = Page "NPR POS Unit List";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Unit List action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Posting Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Period Registers action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
            }
        }
    }
}

