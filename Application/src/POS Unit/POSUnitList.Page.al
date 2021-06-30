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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Ean Box Sales Setup"; Rec."Ean Box Sales Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ean Box Sales Setup field';
                }
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Sales Workflow Set field';
                }
                field("POS Type"; Rec."POS Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Type field';
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Payment Bin field';
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