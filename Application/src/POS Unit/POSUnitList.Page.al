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

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Ean Box Sales Setup"; Rec."Ean Box Sales Setup")
                {

                    ToolTip = 'Specifies the value of the Ean Box Sales Setup field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {

                    ToolTip = 'Specifies the value of the POS Sales Workflow Set field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Type"; Rec."POS Type")
                {

                    ToolTip = 'Specifies the value of the POS Type field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Payment Bin field';
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

                        ToolTip = 'Executes the Dimensions-Single action';
                        ApplicationArea = NPRRetail;
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        ToolTip = 'Executes the Dimensions-&Multiple action';
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