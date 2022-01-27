page 6150616 "NPR POS Unit List"
{
    Caption = 'POS Unit List';
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

                    ToolTip = 'Specifies the unique number for each POS Unit.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the Name of the POS Unit.';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Displays Status for each POS Unit which includes: Open,Closed,End of Day. ';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies an unique Code for each POS Store.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the default Global Dimension 1 Code for the POS Unit.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the default Global Dimension 2 Code for the POS Unit.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }

                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {

                    ToolTip = 'Specifies the value of the POS Sales Workflow Set field.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Type"; Rec."POS Type")
                {

                    ToolTip = 'Displays Status for the POS Type field which includes: Attended or Unattended.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the default value of the POS Payment Bin.';
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
                    RunPageLink = "POS Unit No." = FIELD("No.");

                    ToolTip = 'Executes the POS Entries action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Unit Bins")
                {
                    Caption = 'POS Unit Bins';
                    Image = List;
                    RunObject = Page "NPR POS Unit to Bin Relation";
                    RunPageLink = "POS Unit No." = FIELD("No.");

                    ToolTip = 'Executes the POS Unit Bins action';
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

                    ToolTip = 'Executes the Workshifts action';
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
                    RunPageLink = "Cash Register Id" = FIELD("No.");

                    ToolTip = 'Displays a page showing list of related MPOS QR Code setups';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    procedure GetSelectionFilter(): Text
    var
        POSUnit: Record "NPR POS Unit";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        CurrPage.SetSelectionFilter(POSUnit);
        RecRef.GetTable(POSUnit);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, POSUnit.FieldNo("No.")));
    end;
}
