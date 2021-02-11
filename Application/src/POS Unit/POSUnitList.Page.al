page 6150616 "NPR POS Unit List"
{
    Caption = 'POS Unit List';
    CardPageID = "NPR POS Unit Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Unit";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Ean Box Sales Setup"; "Ean Box Sales Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ean Box Sales Setup field';
                }
                field("POS Sales Workflow Set"; "POS Sales Workflow Set")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sales Workflow Set field';
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
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Function field';
                }
                field("POS Type"; "POS Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Type field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("POS Unit")
            {
                Caption = 'POS Unit';
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(6150615),
                                      "No." = FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-Single action';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-&Multiple action';

                        trigger OnAction()
                        var
                            POSUnit: Record "NPR POS Unit";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(POSUnit);
                            DefaultDimMultiple.SetMultiRecord(POSUnit, FieldNo("No."));
                            DefaultDimMultiple.RunModal;
                        end;
                    }
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
                action(Workshifts)
                {
                    Caption = 'Workshifts';
                    Ellipsis = true;
                    Image = Sales;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR POS Workshift Checkpoints";
                    RunPageLink = "POS Unit No." = FIELD("No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Workshifts action';
                }
            }
        }
        area(processing)
        {
            action("End Workshift (Prel)")
            {
                Caption = 'End Workshift (Prel)';
                Ellipsis = true;
                Image = Sales;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the End Workshift (Prel) action';

                trigger OnAction()
                begin
                    CreateCheckpointWorker(true, true, "No.");
                end;
            }
        }
    }

    local procedure CreateCheckpoint(UnitNo: Code[20])
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        if not (NPRetailSetup.Get()) then
            exit;

        CreateCheckpointWorker(true, false, UnitNo);
    end;

    local procedure CreateCheckpointWorker(UsePosEntry: Boolean; WithPosting: Boolean; UnitNo: Code[20])
    var
        POSCheckpointMgr: Codeunit "NPR POS Workshift Checkpoint";
    begin
        POSCheckpointMgr.CloseWorkshift(UsePosEntry, WithPosting, "No.");
    end;
}

