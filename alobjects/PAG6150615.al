page 6150615 "POS Store Card"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.30/AP/20170207 CASE 265509 Added new fields for Geolocation. Re-arranged layout to align more with std.
    // NPR5.31/AP/20170419 CASE 272321 Added new fields for "Store Size", "Opening Date", "Store Group Code", "Store Category Code" and "Store Locality Code"
    // NPR5.36/BR/20170810 CASE 277096 Added Navigate Actions
    // NPR5.36/BR/20170914 CASE 289641 Added field VAT Customer No.
    // NPR5.38/BR/20171214  CASE 299888 Changed ENU Caption from POS Ledger Register to POS Period Register
    // NPR5.38/BR/20180125 CASE 302803 Added fields Posting Compression, POS Period Register No. Series
    // NPR5.48/MMV /20180615 CASE 318028 Added field 28 for countries with location specific registration no.

    Caption = 'POS Store Card';
    RefreshOnActivate = true;
    SourceTable = "POS Store";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field("Name 2";"Name 2")
                {
                }
                field(Address;Address)
                {
                }
                field("Address 2";"Address 2")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field(Contact;Contact)
                {
                }
                field(County;County)
                {
                }
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Language Code";"Language Code")
                {
                }
                field("VAT Registration No.";"VAT Registration No.")
                {
                }
                field("Registration No.";"Registration No.")
                {
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No.";"Phone No.")
                {
                }
                field("Fax No.";"Fax No.")
                {
                }
                field("E-Mail";"E-Mail")
                {
                }
                field("Home Page";"Home Page")
                {
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Gen. Bus. Posting Group";"Gen. Bus. Posting Group")
                {
                }
                field("VAT Bus. Posting Group";"VAT Bus. Posting Group")
                {
                }
                field("VAT Customer No.";"VAT Customer No.")
                {
                }
                field("Default POS Posting Setup";"Default POS Posting Setup")
                {
                }
                field("Tax Area Code";"Tax Area Code")
                {
                }
                field("Tax Liable";"Tax Liable")
                {
                }
                field("Posting Compression";"Posting Compression")
                {
                }
                field("POS Period Register No. Series";"POS Period Register No. Series")
                {
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field("Store Group Code";"Store Group Code")
                {
                }
                field("Store Category Code";"Store Category Code")
                {
                }
                field("Store Locality Code";"Store Locality Code")
                {
                }
                field("Store Size";"Store Size")
                {
                }
                field("Opening Date";"Opening Date")
                {
                }
                field("Geolocation Latitude";"Geolocation Latitude")
                {
                }
                field("Geolocation Longitude";"Geolocation Longitude")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Unit List")
            {
                Caption = 'POS Unit List';
                Image = List;
                RunObject = Page "POS Unit List";
            }
            action("NP Retail Setup")
            {
                Caption = 'NP Retail Setup';
                Image = Setup;
                RunObject = Page "NP Retail Setup";
            }
            action("POS Posting Setup")
            {
                Caption = 'POS Posting Setup';
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Posting Setup";
                RunPageLink = "POS Store Code"=FIELD(Code);
            }
            action("POS Period Registers")
            {
                Caption = 'POS Period Registers';
                Image = Register;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Period Register List";
                RunPageLink = "POS Store Code"=FIELD(Code);
            }
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Entry List";
                RunPageLink = "POS Store Code"=FIELD(Code);
            }
        }
    }
}

