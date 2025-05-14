page 6150617 "NPR POS Unit Card"
{
    UsageCategory = None;
    Caption = 'POS Unit Card';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/create_pos_unit/';
    RefreshOnActivate = true;
    SourceTable = "NPR POS Unit";
#IF NOT BC17
    AboutTitle = 'POS Unit';
    AboutText = 'The Point of Sale Unit (POS Unit) is an essential component within the store. And a place where retail transaction is done in the store. A POS unit can be a physical Cash Register, or other devices such as Tablet or even a mobile phone where NPR has a lighter App. (Mpos) that can be installed on the latter. In the Card Page, all devices used for doing transactions will be defined as a POS Unit. ';
#ENDIF

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
#IF NOT BC17
                AboutTitle = 'General Information';
                AboutText = 'Provide fundamental details about the Point of Sale Unit in this section. Include the unit''s name, identifier, location within the store, and any other pertinent information that distinguishes it from other units.';
#ENDIF
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the unique code of the store the POS unit belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the payment bin (cash drawer) that will be used by the POS unit. It’s recommended to use the same number as the one provided in the POS unit No.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies Global Dimension associated with the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the Global Dimension associated with the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Type"; Rec."POS Type")
                {
                    ToolTip = 'Specifies the type of the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the current status of the POS unit, updated automatically by the system.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Profiles)
            {
                Caption = 'Profiles';
#IF NOT BC17
                AboutTitle = 'Profiles';
                AboutText = 'If the Point of Sale Unit is associated with distinct operational profiles, specify them here. For instance, if this unit serves as a dedicated counter for takeaway orders, link the appropriate Takeaway Profile. Additionally, select the specific Posting Profile to be used for transactions conducted through this unit. Each profile is dedicated to setting up different aspects of POS units.';
#ENDIF
                field("POS Audit Profile"; Rec."POS Audit Profile")
                {
                    ShowMandatory = true;
                    ToolTip = 'Assign different number series and different rules for printing to a POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS View Profile"; Rec."POS View Profile")
                {
                    ShowMandatory = true;
                    ToolTip = 'Add a custom POS theme, and configure various visual components that are displayed on the POS unit screen.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Layout Code"; Rec."POS Layout Code")
                {
                    ShowMandatory = false;
                    ToolTip = 'Specifies the layout system applies on front-end for the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS End of Day Profile"; Rec."POS End of Day Profile")
                {
                    ShowMandatory = true;
                    ToolTip = 'Set up components of the end-of-day process, and intervals in which it is performed. Also, establish parameters for the bin transfer process.';
                    ApplicationArea = NPRRetail;
                }
                field("Ean Box Sales Setup"; Rec."Ean Box Sales Setup")
                {
                    ShowMandatory = true;
                    ToolTip = 'Set up what type of data is supported by the input boxes in POS units.';
                    ApplicationArea = NPRRetail;
                }
                field("Ean Box Payment Setup"; Rec."Ean Box Payment Setup")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Choose which Ean Box Setup will be used on Payment screen.';
                }
                field("POS Unit Receipt Text Profile"; Rec."POS Unit Receipt Text Profile")
                {
                    ToolTip = 'Set up additional custom text in the receipt footer area depending on your business needs.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {
                    ToolTip = 'Specifies the  scenario used by the POS unit. For example, we can define a particular behaviour such as the user being asked to select a Dimension for the transaction when moving from Sales screen to Payment screen.';
                    ApplicationArea = NPRObsoletePOSScenarios;
                }
                field("Global POS Sales Setup"; Rec."Global POS Sales Setup")
                {
                    ToolTip = 'Configure multi-company sales transactions.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Named Actions Profile"; Rec."POS Named Actions Profile")
                {
                    ToolTip = 'Configure the main actions associated with POS units.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Restaurant Profile"; Rec."POS Restaurant Profile")
                {
                    ToolTip = 'Specifies the default Restaurant profile that is using this POS Unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Pricing Profile"; Rec."POS Pricing Profile")
                {
                    ToolTip = 'Set up the customer price lists, customer discount lists, and price matching associated with the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Self Service Profile"; Rec."POS Self Service Profile")
                {
                    ToolTip = 'Configure the behavior of the POS unit if it''s meant to serve as a self-service kiosk.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Display Profile"; Rec."POS Display Profile")
                {
                    ToolTip = 'Configure the POS unit’s display view.';
                    ApplicationArea = NPRRetail;
                }
                field("POS HTML Display Profile"; Rec."POS HTML Display Profile")
                {
                    ToolTip = 'Configure how the media content is displayed, and upload a HTML file which provides responses for customer input on the POS display.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Tax Free Profile"; Rec."POS Tax Free Prof.")
                {
                    ToolTip = 'If there is integration with Global Blue Tax Free or Premier Tax Free in place, you can set the handler for the interface to the POS Unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Security Profile"; Rec."POS Security Profile")
                {
                    ToolTip = 'Configure security-related settings like passwords and display timeout.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Inventory Profile"; Rec."POS Inventory Profile")
                {
                    ToolTip = 'Configure Stockout warnings on the POS.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Receipt Profile"; Rec."POS Receipt Profile")
                {
                    ToolTip = 'Specifies POS Receipt Profile on this POS Unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Member Profile"; Rec."POS Member Profile")
                {
                    ToolTip = 'Configure member specific settings on the pos unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Loyalty Profile"; Rec."POS Loyalty Profile")
                {
                    ToolTip = 'Configure loyalty specific settings on the pos unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Ticket Profile"; Rec."POS Ticket Profile")
                {
                    ToolTip = 'Configure ticket specific settings on the pos unit.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Hardware Profile"; Rec."POS Hardware Profile")
                {
                    ToolTip = 'Specifies the Hardware Profile of the Hardware Connector.';
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
                RunPageLink = "Table ID" = CONST(6150615),
                              "No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+D';
                ToolTip = 'Specifies the value of the Default Dimensions attached to the POS Unit.';
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
                RunPageLink = "POS Unit No." = FIELD("No.");
                ToolTip = 'Display the list of POS Period Registers for the POS Unit.';
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
                RunPageLink = "POS Unit No." = FIELD("No.");
                ToolTip = 'Display the list of POS Entries (transactions) tied to the POS Unit.';
                ApplicationArea = NPRRetail;
            }
            action("POS Unit Bins")
            {
                Caption = 'POS Unit Bins';
                Image = List;
                RunObject = Page "NPR POS Unit to Bin Relation";
                RunPageLink = "POS Unit No." = FIELD("No.");
                ToolTip = 'Display the relationships between POS Units and their respective Bins.  You can difine multiple POS Bins for a single POS Unit.';
                ApplicationArea = NPRRetail;
            }
            action("POS Unit Display")
            {
                Caption = 'POS Unit Display';
                Image = Administration;
                RunObject = Page "NPR POS Unit Display";
                ToolTip = 'Set up which screen is used as the second display for that POS Unit.';
                ApplicationArea = NPRRetail;
            }
            action("Tax Free Vouchers")
            {
                Caption = 'Tax Free Vouchers';
                Image = Voucher;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Tax Free Voucher";
                RunPageLink = "POS Unit No." = field("No.");
                ToolTip = 'Display the list of Tax Free Vouchers for that POS Unit.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}