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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Name 2"; "Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name 2 field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(Contact; Contact)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact field';
                }
                field(County; County)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the County field';
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                }
                field("Registration No."; "Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registration No. field';
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Fax No."; "Fax No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fax No. field';
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("Home Page"; "Home Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Home Page field';
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("VAT Customer No."; "VAT Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Customer No. field';
                }
                field("Default POS Posting Setup"; "Default POS Posting Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Posting Setup field';
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Liable"; "Tax Liable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Liable field';
                }
                field("Posting Compression"; "Posting Compression")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Compression field';
                }
                field("POS Period Register No. Series"; "POS Period Register No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Period Register No. Series field';
                }
            }
            group(Profiles)
            {
                Caption = 'Profiles';
                field("POS Restaurant Profile"; "POS Restaurant Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Restaurant Profile field';
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Store Group Code"; "Store Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Group Code field';
                }
                field("Store Category Code"; "Store Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Category Code field';
                }
                field("Store Locality Code"; "Store Locality Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Locality Code field';
                }
                field("Store Size"; "Store Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Size field';
                }
                field("Opening Date"; "Opening Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Opening Date field';
                }
                field("Geolocation Latitude"; "Geolocation Latitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Geolocation Latitude field';
                }
                field("Geolocation Longitude"; "Geolocation Longitude")
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

