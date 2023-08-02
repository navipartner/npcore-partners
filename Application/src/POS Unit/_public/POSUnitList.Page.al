page 6150616 "NPR POS Unit List"
{
    Caption = 'POS Unit List';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/intro/';
    CardPageID = "NPR POS Unit Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Unit";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Defines number of POS Unit';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Defines name of POS Unit';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Defines in which status POS is: 1. Open POS is active in the moment, 2. Closed POS is closed in the moment, end of day is done, 3. End of Day POS is in the process of end of day in the moment';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ToolTip = 'Defines to which store is assigned a POS unit';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Dimension value of Global dimension 1 assigned to POS Unit';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Dimension value of Global dimension 2 assigned to POS Unit';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {
                    ToolTip = 'Defines Scenarios Profile attached to Unit. Depending on scenario profile will initiate defined actions in POS';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("POS Type"; Rec."POS Type")
                {
                    ToolTip = 'Specifies POS Type: 1. Full/Fixed normal cash register, 2. Unattended used for Self-service, 3. mPOS, 4. External';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {
                    ShowMandatory = true;
                    ToolTip = 'Defines Payment Bin attached to POS Unit';
                    ApplicationArea = NPRRetail;
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
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                        ApplicationArea = NPRRetail;
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            POSUnit: Record "NPR POS Unit";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(POSUnit);
                            DefaultDimMultiple.SetMultiRecord(POSUnit, Rec.FieldNo("No."));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
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
                    ToolTip = 'Opens the POS Period Registers List';
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
                    ToolTip = 'Opens the POS Entries List';
                    ApplicationArea = NPRRetail;
                }
                action("POS Unit Bins")
                {
                    Caption = 'POS Unit Bins';
                    Image = List;
                    RunObject = Page "NPR POS Unit to Bin Relation";
                    RunPageLink = "POS Unit No." = FIELD("No.");
                    ToolTip = 'Opens the POS Unit Bins List';
                    ApplicationArea = NPRRetail;
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
                    ToolTip = 'Opens the Workshifts List';
                    ApplicationArea = NPRRetail;
                }
                action("MPOS QR Code")
                {
                    Caption = 'MPOS QR Code';
                    Ellipsis = true;
                    Image = Sales;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR MPOS QR Code List";
                    ToolTip = 'Displays a page showing list of related MPOS QR Code setups';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure GetSelectionFilter(): Text
    var
        POSUnit: Record "NPR POS Unit";
    begin
        CurrPage.SetSelectionFilter(POSUnit);
        exit(GetSelectionFilter(POSUnit));
    end;

    internal procedure GetSelectionFilter(var POSUnit: Record "NPR POS Unit"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(POSUnit);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, POSUnit.FieldNo("No.")));
    end;
}