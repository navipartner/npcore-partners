pageextension 6014454 "NPR Purchase Invoice" extends "Purchase Invoice"
{
    // NPR4.15/TS/20151013 CASE 224751 Added NpAttribute Factbox
    // NPR4.18/TS/20151211  CASE 228030 Added field Posting Description
    // NPR4.18/MMV/20160105 CASE 229221 Unify how label printing of lines are handled.
    // NPR5.22/MMV/20160428 CASE 237743 Updated references to label library CU.
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.24/JDH/20160720 CASE 241848 Added a Name to Posting Description, so Powershell didnt triggered a mergeConflicts in databases where its already used standard
    // NPR5.30/TJ  /20170202 CASE 262533 Removed actions Labels and Invert selection. Instead added actions Retail Print and Price Label
    // NPR5.55/CLVA/20200610 CASE Added Action "Show Imported File"
    layout
    {
        addafter(Status)
        {
            field("NPR PostingDescription"; "Posting Description")
            {
                ApplicationArea = All;
            }
        }
        addafter(Control1906949207)
        {
            part("NPR NPAttributes"; "NPR NP Attributes FactBox")
            {
                Provider = PurchLines;
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(RemoveIncomingDoc)
        {
            action("NPR Show Imported File")
            {
                Caption = 'Show Imported File';
                ApplicationArea = All;

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    //-366790 [366790]
                    NcImportListPg.ShowFormattedDocByDocNo("Vendor Invoice No.");
                    //+366790 [366790]
                end;
            }
        }
        addafter("P&osting")
        {
            group("NPR Print")
            {
                Caption = 'Print';
                Image = Print;
                action("NPR RetailPrint")
                {
                    Caption = 'Retail Print';
                    Ellipsis = true;
                    Image = BinContent;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                }
                action("NPR PriceLabel")
                {
                    Caption = 'Price Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                }
            }
        }
    }
}

