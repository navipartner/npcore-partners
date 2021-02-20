page 6150617 "NPR POS Unit Card"
{
    UsageCategory = None;
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
                field("Default POS Payment Bin"; "Default POS Payment Bin")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Default POS Payment Bin field';
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
                field(ActiveEventNo; ActiveEventNo)
                {
                    Caption = 'Active Event No.';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit Active Event No.';

                    trigger OnValidate()
                    begin
                        Rec.SetActiveEventForCurrPOSUnit(ActiveEventNo);
                        CurrPage.Update();
                    end;
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
                    ShowMandatory = true;
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
                field("POS Pricing Profile"; Rec."POS Pricing Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Pricing Profile field where customer discount and price group should be set.';
                }
                field("MPOS Profile"; Rec."MPOS Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MPOS Profile field where ticket admission should be set.';
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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

    var
        ActiveEventNo: Code[20];

    trigger OnAfterGetRecord()
    begin
        ActiveEventNo := Rec.FindActiveEventFromCurrPOSUnit();
    end;
}

