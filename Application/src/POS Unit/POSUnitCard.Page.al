page 6150617 "NPR POS Unit Card"
{
    // NPR5.29/AP  /20170126  CASE 261728 Recreated ENU-captions
    // NPR5.36/BR  /20170810  CASE 277096 Added Actions to navigate to Entries and Legder Registers
    // NPR5.37/TSA /20171024  CASE 293905 Added Lock Timeout
    // NPR5.38/BR  /20171214  CASE 299888 Changed ENU Caption from POS Ledger Register to POS Period Register
    // NPR5.40/TS  /20180105  CASE  300893 Action Containers cannot have caption
    // NPR5.40/TSA /20180305  CASE 306581 Added navigate to POS Unit To Bin Relation
    // NPR5.41/TSA /20180412  CASE 306858 Added field "Default POS Payment Bin" to page
    // NPR5.45/MHA /20180803  CASE 323705 Added fields 300, 305, 310 to enable overload of Item Price functionality
    // NPR5.45/MHA /20180814  CASE 319706 Added field 200 Ean Box Sales Setup
    // NPR5.45/TJ  /20180809  CASE 323728 Field added "Kiosk Mode Unlock PIN"
    // NPR5.45/MHA /20180820 CASE 321266 Added field 205 "POS Sales Workflow Set"
    // NPR5.46/TSA /20181004 CASE 328338 Added Status field
    // NPR5.48/MMV /20181211 CASE 318028 Added field "POS Audit Profile"
    // NPR5.49/TJ  /20181115 CASE 335739 New field "POS View Profile"
    // NPR5.49/TSA /20190311 CASE 348458 Added field "POS End of Day Profile"
    // NPR5.51/YAHA/20190717 CASE 360536 Field "POS Store Code","Default POS Payment Bin","Ean Box Sales Setup","POS Audit Profile","POS View Profile" set to Mandatory(TRUE)
    // NPR5.51/SARA/20190823 CASE 363578 New field 'SMS Profile'
    // NPR5.52/ALPO/20190923 CASE 365326 New field "POS Posting Profile" (Posting related fields moved to POS Posting Profiles from NP Retail Setup)
    // NPR5.52/SARA/20190823 CASE 368395 Removed field 'SMS Profile' (Move to 'POS End of Day Profile')
    // NPR5.52/MHA /20191016 CASE 371388 Field 400 "Global POS Sales Setup" moved from Np Retail Setup to POS Unit
    // NPR5.53/ALPO/20191021 CASE 371956 Dimensions: POS Store & POS Unit integration
    // NPR5.54/BHR /20200210 CASE 389444 Field 'POS Unit Receipt Text Profile'
    // NPR5.54/TSA /20200219 CASE 391850 Added "POS Named Actions Profile"
    // NPR5.55/ZESO/20200603 CASE 407613 Added "POS Unit Serial No"
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link (added "POS Restaurant Profile")

    Caption = 'POS Unit Card';
    RefreshOnActivate = true;
    SourceTable = "NPR POS Unit";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
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
                field("Lock Timeout"; "Lock Timeout")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Timeout field';
                }
                field("Default POS Payment Bin"; "Default POS Payment Bin")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Default POS Payment Bin field';
                }
                field("Item Price Codeunit ID"; "Item Price Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit ID field';
                }
                field("Item Price Codeunit Name"; "Item Price Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit Name field';
                }
                field("Item Price Function"; "Item Price Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Price Function field';
                }
                field("Kiosk Mode Unlock PIN"; "Kiosk Mode Unlock PIN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kiosk Mode Unlock PIN field';
                }
                field("POS Type"; "POS Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Type field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("POS Unit Serial No"; "POS Unit Serial No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit Serial No field';
                }
            }
            group(Profiles)
            {
                Caption = 'Profiles';
                field("POS Audit Profile"; "POS Audit Profile")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Audit Profile field';
                }
                field("POS View Profile"; "POS View Profile")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS View Profile field';
                }
                field("POS End of Day Profile"; "POS End of Day Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS End of Day Profile field';
                }
                field("POS Posting Profile"; "POS Posting Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Posting Profile field';
                }
                field("POS Unit Receipt Text Profile"; "POS Unit Receipt Text Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit Receipt Text Profile field';
                }
                field("Ean Box Sales Setup"; "Ean Box Sales Setup")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Ean Box Sales Setup field';
                }
                field("POS Sales Workflow Set"; "POS Sales Workflow Set")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sales Workflow Set field';
                }
                field("Global POS Sales Setup"; "Global POS Sales Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global POS Sales Setup field';
                }
                field("POS Named Actions Profile"; "POS Named Actions Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Named Actions Profile field';
                }
                field("POS Restaurant Profile"; "POS Restaurant Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Restaurant Profile field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';
            }
            action("POS Unit Identity List")
            {
                Caption = 'POS Unit Identity List';
                Image = List;
                RunObject = Page "NPR POS Unit Identity List";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Unit Identity List action';
            }
            action("POS Period Registers")
            {
                Caption = 'POS Period Registers';
                Image = Register;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Period Register List";
                RunPageLink = "POS Unit No." = FIELD("No.");
                ApplicationArea = All;
                ToolTip = 'Executes the POS Period Registers action';
            }
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Entry List";
                RunPageLink = "POS Unit No." = FIELD("No.");
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
            }
            action("POS Unit Bins")
            {
                Caption = 'POS Unit Bins';
                Image = List;
                RunObject = Page "NPR POS Unit to Bin Relation";
                RunPageLink = "POS Unit No." = FIELD("No.");
                ApplicationArea = All;
                ToolTip = 'Executes the POS Unit Bins action';
            }
        }
    }
}

